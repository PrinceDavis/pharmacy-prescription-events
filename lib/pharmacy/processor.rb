# frozen_string_literal: true

module Pharmacy
  class Processor
    def initialize(prescriptions)
      @prescriptions = prescriptions
    end

    def handle(event)
      case event.type
      when :created then handle_created(event)
      when :filled then handle_filled(event)
      when :returned then handle_returned(event)
      end
    end

    private

    def handle_created(event)
      @prescriptions[prescription_key(event)] = Prescription.new
    end

    def handle_filled(event)
      @prescriptions[prescription_key(event)]&.fill
    end

    def handle_returned(event)
      @prescriptions[prescription_key(event)]&.return
    end

    def prescription_key(event)
      [event.patient, event.drug]
    end
  end
end
