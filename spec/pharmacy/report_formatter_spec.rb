# frozen_string_literal: true

RSpec.describe Pharmacy::ReportFormatter do
  it "formats positive, negative, and zero income reports" do
    examples = {
      Pharmacy::PatientReport.new(patient: "Mark", fills: 2, income: 9) => "Mark: 2 fills $9 income",
      Pharmacy::PatientReport.new(patient: "John", fills: 0, income: -1) => "John: 0 fills -$1 income",
      Pharmacy::PatientReport.new(patient: "Nick", fills: 0, income: 0) => "Nick: 0 fills $0 income"
    }

    examples.each do |report, expected_output|
      expect(described_class.format(report)).to eq(expected_output)
    end
  end
end
