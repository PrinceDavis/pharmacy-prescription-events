# Pharmacy Prescription Events

A small Ruby application that processes prescription lifecycle events and reports each patient's current fills and derived income. The project uses Ruby 3.4.11.

## Running

Install dependencies:

```bash
bundle install
```

Process events from a file:

```bash
./bin/process-pharmacy-events events.txt
```

Or provide events through standard input:

```bash
cat events.txt | ./bin/process-pharmacy-events
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

Parsing, state transitions, reporting, and presentation are separate responsibilities. The design is deliberately small: each boundary reflects a behavior required by the exercise, without adding frameworks or abstractions that the problem does not justify.

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
- its return count

Income and patient totals are derived later rather than stored as additional mutable state.

`PrescriptionEvent` is an immutable value object containing the patient, drug, and event type. It gives the rest of the application a domain representation, so raw input lines and textual event names do not leak beyond parsing. `PatientReport` is likewise an immutable value containing the final patient, fills, and income values.

## Design Decisions

### Parsing versus lifecycle rules

`EventParser` translates one line of text into a `PrescriptionEvent`; it does not decide whether that event is valid for the current state. For example, `Mark B filled` is syntactically valid even when that prescription has not been created. `Processor` owns that lifecycle decision and discards the premature fill.

### Processor and state ownership

The prescriptions Hash is created by `Application` and supplied to the processor:

```ruby
prescriptions = {}
processor = Pharmacy::Processor.new(prescriptions)
```

The processor exposes `handle(event)`. This keeps ownership and lifetime of the state in the composition layer while avoiding the need to pass the same Hash into every operation.

### Prescription behavior

`Processor` locates the prescription and decides which operation applies. `Prescription` owns the actual fill and return transitions on its counters. This keeps orchestration separate from the object responsible for maintaining valid prescription state.

### Derived income

Income is not stored on `Prescription`; `ReportBuilder` derives it from final state:

```text
income = (current fills * 5) - returns
```

A return removes a prior fill from the current fill count and contributes the specified $1 loss. Therefore:

```text
filled
returned
```

produces zero current fills and `-$1` income. This interpretation is necessary to match the exercise's supplied output.

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

- immutable event representation
- text-to-event parsing
- prescription fill and return transitions
- event dispatch and pre-creation discards
- patient aggregation and income derivation
- report formatting, including negative income

Higher-level specs cover application composition and both executable input modes using in-memory IO or temporary files. They verify integration without repeating every domain rule. Tests also trust guarantees made explicitly by the exercise instead of adding defensive cases for impossible or malformed states outside the contract.

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
