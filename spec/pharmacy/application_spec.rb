# frozen_string_literal: true

require "stringio"

RSpec.describe Pharmacy::Application do
  it "processes prescription events and returns one report line per patient" do
    input = StringIO.new(<<~INPUT)
      Nick A created
      Mark B created
      Mark B filled
      Mark C filled
      Mark B returned
      John E created
      Mark B filled
      Mark B filled
      Paul D filled
      John E filled
      John E returned
    INPUT
    output = described_class.run(input:)

    expect(output.lines(chomp: true)).to contain_exactly(
      "Mark: 2 fills $9 income",
      "John: 0 fills -$1 income",
      "Nick: 0 fills $0 income"
    )
  end
end
