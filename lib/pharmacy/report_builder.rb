# frozen_string_literal: true

module Pharmacy
  module ReportBuilder
    FILL_INCOME = 5
    RETURN_LOSS = 1
    private_constant :FILL_INCOME, :RETURN_LOSS

    def self.build(prescriptions)
      totals_by_patient(prescriptions).map do |patient, totals|
        build_patient_report(patient, totals)
      end
    end

    def self.totals_by_patient(prescriptions)
      prescriptions.each_with_object(
        Hash.new { |totals, patient| totals[patient] = { fills: 0, returns: 0 } }
      ) do |entry, totals|
        (patient, _drug), prescription = entry
        totals[patient][:fills] += prescription.fills
        totals[patient][:returns] += prescription.returns
      end
    end

    def self.build_patient_report(patient, totals)
      fills = totals[:fills]
      income = (fills * FILL_INCOME) - (totals[:returns] * RETURN_LOSS)

      PatientReport.new(patient:, fills:, income:)
    end
    private_class_method :totals_by_patient, :build_patient_report
  end
end
