# frozen_string_literal: true

module Pharmacy
  PatientReport = Data.define(:patient, :fills, :income)
end
