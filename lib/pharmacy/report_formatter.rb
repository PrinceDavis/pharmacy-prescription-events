# frozen_string_literal: true

module Pharmacy
  module ReportFormatter
    def self.format(report)
      "#{report.patient}: #{report.fills} fills #{format_income(report.income)} income"
    end

    def self.format_income(income)
      income.negative? ? "-$#{income.abs}" : "$#{income}"
    end
    private_class_method :format_income
  end
end
