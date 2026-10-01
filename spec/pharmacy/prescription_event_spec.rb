# frozen_string_literal: true

RSpec.describe Pharmacy::PrescriptionEvent do
  it "represents its patient, drug, and type" do
    event = described_class.new(patient: "Ada Lovelace", drug: "PainAway", type: :filled)

    expect(event).to have_attributes(
      patient: "Ada Lovelace",
      drug: "PainAway",
      type: :filled
    )
  end
end
