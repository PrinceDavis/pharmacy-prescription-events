# frozen_string_literal: true

RSpec.describe Pharmacy::Prescription do
  subject(:prescription) { described_class.new }

  it "starts with no fills or returns" do
    expect(prescription).to have_attributes(fills: 0, returns: 0)
  end

  it "tracks fills, returns, and refills" do
    prescription.fill
    prescription.fill
    prescription.return
    prescription.fill

    expect(prescription).to have_attributes(fills: 2, returns: 1)
  end

  it "discards a return without an outstanding fill" do
    prescription.return

    expect(prescription).to have_attributes(fills: 0, returns: 0)
  end

  it "records only returns backed by fills, including subsequent fills" do
    prescription.fill
    prescription.return
    prescription.return

    expect(prescription).to have_attributes(fills: 0, returns: 1)

    prescription.fill
    prescription.return

    expect(prescription).to have_attributes(fills: 0, returns: 2)
  end
end
