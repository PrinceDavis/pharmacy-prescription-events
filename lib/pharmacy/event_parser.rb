# frozen_string_literal: true

module Pharmacy
  module EventParser
    EVENT_TYPES = {
      "created" => :created,
      "filled" => :filled,
      "returned" => :returned
    }.freeze
    private_constant :EVENT_TYPES

    def self.parse(line)
      patient, drug, event_name = line.split

      PrescriptionEvent.new(patient:, drug:, type: EVENT_TYPES[event_name])
    end
  end
end
