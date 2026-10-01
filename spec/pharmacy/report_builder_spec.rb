# frozen_string_literal: true

RSpec.describe Pharmacy::ReportBuilder do
  def prescription_with(*events)
    Pharmacy::Prescription.new.tap do |prescription|
      events.each { |event| prescription.public_send(event) }
    end
  end

  it "aggregates a patient's prescriptions without mutating them" do
    prescriptions = {
      %w[Mark B] => prescription_with(:fill, :fill, :return, :fill),
      %w[Mark C] => prescription_with(:fill)
    }
    prescriptions.each_value(&:freeze)
    prescriptions.freeze

    reports = described_class.build(prescriptions)

    expect(reports).to contain_exactly(
      Pharmacy::PatientReport.new(patient: "Mark", fills: 3, income: 14)
    )
  end

  it "builds reports for multiple patients, including zero-fill patients" do
    prescriptions = {
      %w[Mark B] => prescription_with(:fill, :fill, :return, :fill),
      %w[John E] => prescription_with(:fill, :return),
      %w[Nick A] => prescription_with
    }

    reports = described_class.build(prescriptions)

    expect(reports).to contain_exactly(
      Pharmacy::PatientReport.new(patient: "Mark", fills: 2, income: 9),
      Pharmacy::PatientReport.new(patient: "John", fills: 0, income: -1),
      Pharmacy::PatientReport.new(patient: "Nick", fills: 0, income: 0)
    )
  end
end
