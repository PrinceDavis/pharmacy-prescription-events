# frozen_string_literal: true

require "open3"
require "tempfile"

RSpec.describe "process-pharmacy-events" do
  let(:executable) { File.expand_path("../../bin/process-pharmacy-events", __dir__) }
  let(:events) do
    <<~EVENTS
      Nick A created
      Mark B created
      Mark B filled
    EVENTS
  end
  let(:expected_lines) do
    [
      "Nick: 0 fills $0 income",
      "Mark: 1 fills $5 income"
    ]
  end

  it "processes events from a filename" do
    Tempfile.create("pharmacy-events") do |file|
      file.write(events)
      file.flush

      stdout, stderr, status = Open3.capture3(executable, file.path)

      expect(stdout.lines(chomp: true)).to contain_exactly(*expected_lines)
      expect(stdout).to end_with("\n")
      expect(stderr).to be_empty
      expect(status).to be_success
    end
  end

  it "processes events from stdin when no filename is supplied" do
    stdout, stderr, status = Open3.capture3(executable, stdin_data: events)

    expect(stdout.lines(chomp: true)).to contain_exactly(*expected_lines)
    expect(stdout).to end_with("\n")
    expect(stderr).to be_empty
    expect(status).to be_success
  end
end
