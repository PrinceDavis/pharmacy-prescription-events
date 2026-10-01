# Pharmacy

A Ruby application for a pharmacy prescription event take-home exercise.

## Setup

The project uses Ruby 3.4.11 and Bundler.

```sh
mise install
bundle install
```

## Run the CLI

The executable currently loads the application without performing any business behavior:

```sh
bin/pharmacy
```

## Run the tests and lint

```sh
bundle exec rspec
bundle exec rubocop
bundle exec rake
```

The default Rake task runs both the test suite and RuboCop. Run only linting with `bundle exec rake lint`.

## Status

The project foundation is in place. Prescription event processing and all related business behavior have not yet been implemented.
