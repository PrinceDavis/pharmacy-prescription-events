# frozen_string_literal: true

RSpec.describe Pharmacy::Prescription do
  subject(:prescription) { described_class.new }

  it "starts with no fills or returns" do
    expect(prescription).to have_attributes(fills: 0, returns: 0)
  end
end
