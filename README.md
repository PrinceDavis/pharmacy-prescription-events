# Pharmacy

A Ruby application for a pharmacy prescription event take-home exercise.

## Setup

The project uses Ruby 3.4.11 and Bundler.

```sh
mise install
bundle install
```

## Run the CLI

Process events from a file:

```sh
./bin/process-pharmacy-events events.txt
```

Or pipe events through standard input:

```sh
cat events.txt | ./bin/process-pharmacy-events
```

## Run the tests and lint

```sh
bundle exec rspec
bundle exec rubocop
bundle exec rake
```

The default Rake task runs both the test suite and RuboCop. Run only linting with `bundle exec rake lint`.

## Status

The prescription event processing pipeline and executable are implemented.
