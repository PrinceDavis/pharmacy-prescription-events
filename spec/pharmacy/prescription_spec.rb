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
end
