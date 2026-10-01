# frozen_string_literal: true

module Pharmacy
  module Application
    def self.run(input:)
      prescriptions = {}
      processor = Processor.new(prescriptions)

      input.each_line do |line|
        processor.handle(EventParser.parse(line))
      end

      reports = ReportBuilder.build(prescriptions)
      reports.map { |report| ReportFormatter.format(report) }.join("\n")
    end
  end
end
