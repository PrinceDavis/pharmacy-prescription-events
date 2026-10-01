# frozen_string_literal: true

module Pharmacy
  PrescriptionEvent = Data.define(:patient, :drug, :type)
end
