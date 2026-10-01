# frozen_string_literal: true

require "open3"
require "tempfile"

RSpec.describe "process-pharmacy-events" do
  let(:executable) { File.expand_path("../../bin/process-pharmacy-events", __dir__) }
  let(:events) { "Nick A created\n" }
  let(:expected_output) { "Nick: 0 fills $0 income\n" }

  it "processes events from a filename" do
    Tempfile.create("pharmacy-events") do |file|
      file.write(events)
      file.flush

      stdout, = Open3.capture3(executable, file.path)

      expect(stdout).to eq(expected_output)
    end
  end

  it "processes events from stdin when no filename is supplied" do
    stdout, = Open3.capture3(executable, stdin_data: events)

    expect(stdout).to eq(expected_output)
  end
end
