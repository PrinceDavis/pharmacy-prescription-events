# frozen_string_literal: true

RSpec.describe Pharmacy::Processor do
  subject(:processor) { described_class.new(prescriptions) }

  let(:prescriptions) { {} }

  def event(type)
    Pharmacy::PrescriptionEvent.new(patient: "Mark", drug: "B", type:)
  end

  it "stores a new prescription for a created event" do
    processor.handle(event(:created))

    expect(prescriptions[%w[Mark B]]).to be_a(Pharmacy::Prescription)
  end

  it "applies a prescription lifecycle" do
    %i[created filled filled returned filled].each do |type|
      processor.handle(event(type))
    end

    expect(prescriptions[%w[Mark B]]).to have_attributes(fills: 2, returns: 1)
  end

  it "discards fills and returns for prescriptions that have not been created" do
    processor.handle(event(:filled))
    processor.handle(event(:returned))

    expect(prescriptions).to be_empty
  end
end
