# frozen_string_literal: true

RSpec.describe Pharmacy::EventParser do
  it "parses each input event name into its domain event type" do
    examples = {
      "Nick A created" => Pharmacy::PrescriptionEvent.new(patient: "Nick", drug: "A", type: :created),
      "Mark B filled" => Pharmacy::PrescriptionEvent.new(patient: "Mark", drug: "B", type: :filled),
      "John E returned" => Pharmacy::PrescriptionEvent.new(patient: "John", drug: "E", type: :returned)
    }

    examples.each do |line, event|
      expect(described_class.parse(line)).to eq(event)
    end
  end
end
