# Pharmacy Prescription Events

A small Ruby application that processes prescription lifecycle events and reports each patient's current fills and derived income.

## Running

Ruby 3.4.11 and Bundler 2.6.9 must be installed and active before setup. These versions match `.ruby-version`, `Gemfile`, and `Gemfile.lock`.

```bash
ruby --version
bundle --version
bundle install
```

Each input line has three whitespace-separated fields:

```text
patient drug event
```

Patient and drug identifiers are single tokens. The supported event names are `created`, `filled`, and `returned`.

Process the checked-in sample from a file:

```bash
./bin/process-pharmacy-events sample.txt
```

Or provide it through standard input:

```bash
cat sample.txt | ./bin/process-pharmacy-events
```

Both commands produce:

```text
Nick: 0 fills $0 income
Mark: 2 fills $9 income
John: 0 fills -$1 income
```

Run the tests:

```bash
bundle exec rspec
```

The default Rake task runs both the test suite and RuboCop:

```bash
bundle exec rake
```

Linting can also be run independently with `bundle exec rubocop`.

## Architecture

The processing flow is:

```text
input
  ↓
EventParser
  ↓
PrescriptionEvent
  ↓
Processor
  ↓
Hash<[patient, drug], Prescription>
  ↓
ReportBuilder
  ↓
PatientReport
  ↓
ReportFormatter
```

`Pharmacy::Application` composes these components. It reads the supplied input line by line, owns the prescription Hash for that run, and returns the final formatted report as a string. The executable chooses either a file or standard input, calls the application, and writes the result to standard output.

Parsing, state transitions, reporting, and presentation are separate responsibilities. The design is deliberately small: each boundary reflects required behavior without adding frameworks or abstractions that the problem does not justify.

## Data Structures

Prescription state is held in a plain Hash:

```ruby
{
  [patient, drug] => prescription
}
```

A prescription is identified by patient and drug. Ruby Arrays have value-based equality and hashing, so `[patient, drug]` is already a suitable compound key; a dedicated `PrescriptionKey` object would not add useful behavior.

A `Prescription` stores only:

- its current fill count
- its accepted return count

Income and patient totals are derived later rather than stored as additional mutable state.

`PrescriptionEvent` is a value object with read-only members for patient, drug, and event type. It gives the rest of the application a domain representation, so raw input lines and textual event names do not leak beyond parsing. `PatientReport` is also a value object with read-only members for patient, fills, and income.

## Design Decisions

### Parsing versus lifecycle rules

`EventParser` translates one line of text into a `PrescriptionEvent`; it does not decide whether that event is valid for the current state. For example, `Mark B filled` is syntactically valid even when that prescription has not been created. `Processor` owns the lifecycle decision and discards that event.

### Processor and state ownership

The prescriptions Hash is created by `Application` and supplied to the processor:

```ruby
prescriptions = {}
processor = Pharmacy::Processor.new(prescriptions)
```

The processor exposes `handle(event)`. This keeps ownership and lifetime of the state in the composition layer while avoiding the need to pass the same Hash into every operation.

Creation is idempotent for each patient/drug pair. A repeated `created` event keeps the existing `Prescription`, including its fill and return activity, rather than replacing it with a fresh object.

Fills and returns received before creation are permanently discarded. Creating the prescription later does not replay those earlier events.

### Prescription behavior

`Processor` locates the prescription and decides which operation applies. `Prescription` owns the fill and return transitions on its counters.

A return cancels one outstanding fill and records a $1 loss. When no fill is outstanding, the return is discarded: neither counter changes. This prevents negative fill counts and financial deductions for returns that cannot be matched to a fill. A later fill remains eligible for a normal return.

### Derived income

Income is not stored on `Prescription`; `ReportBuilder` derives it from final state:

```text
income = (current fills * 5) - accepted returns
```

For example:

```text
filled
returned
```

produces zero current fills and `-$1` income. The return removes the outstanding fill and contributes the specified $1 loss, matching the exercise's supplied output.

### Derived patient totals

Patient summaries are built after all events have been processed. Maintaining patient counters alongside prescription counters would duplicate state and create synchronization concerns. Deriving summaries from the authoritative prescription Hash avoids that second mutable representation.

### No state or repository wrapper

A wrapper around the prescriptions Hash was considered but rejected. The application only needs insertion, lookup, and iteration, all of which a Ruby Hash expresses directly and clearly.

### No ordering requirement

The exercise does not define report ordering. The implementation does not sort reports, and tests compare report lines without asserting their relative order.

### No CLI framework

The executable supports only a filename argument or piped standard input. An option parser, subcommand structure, or CLI framework would add machinery without supporting a required behavior.

## Testing Strategy

The project was developed through lean Red → Green → Refactor cycles. Tests focus on observable behavior and use a few meaningful scenarios rather than one example for every method or branch.

Lower-level specs cover:

- parsing each textual event type into a `PrescriptionEvent`
- prescription fill, return, refill, and unmatched-return behavior
- event dispatch, idempotent creation, and pre-creation discards
- patient aggregation and income derivation
- report formatting, including negative income

Application specs cover composition, independent prescriptions across patients and drugs, lifecycle outcomes, and the fact that discarded events are not replayed. Executable specs cover both file and standard-input wiring, including output, final newlines, empty standard error, and successful exit status.

Malformed input remains outside the stated input contract, so the suite does not add speculative validation cases.

## Complexity

Let:

```text
n = number of events
p = number of created prescriptions
```

Events are processed in one pass, with average constant-time Hash lookup per event. Report generation performs one additional pass over the stored prescriptions.

```text
Time:  O(n + p), approximately O(n)
Space: O(p)
```

The report collection is bounded by the number of patients and therefore by `p`.
