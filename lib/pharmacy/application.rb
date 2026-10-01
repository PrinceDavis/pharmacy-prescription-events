# frozen_string_literal: true

module Pharmacy
  module Application
    def self.run(input:, output:)
      prescriptions = {}
      processor = Processor.new(prescriptions)

      input.each_line do |line|
        processor.handle(EventParser.parse(line))
      end

      ReportBuilder.build(prescriptions).each do |report|
        output.puts(ReportFormatter.format(report))
      end
    end
  end
end
