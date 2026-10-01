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

  it "reports idempotent creation and only returns backed by fills" do
    input = StringIO.new(<<~INPUT)
      Mark B created
      Mark B filled
      Mark B returned
      Mark B created
      Nick A created
      Nick A returned
      John E created
      John E filled
      John E returned
      John E returned
      Paul D created
      Paul D filled
      Paul D returned
      Paul D returned
      Paul D filled
      Paul D returned
    INPUT
    output = described_class.run(input:)

    expect(output.lines(chomp: true)).to contain_exactly(
      "Mark: 0 fills -$1 income",
      "Nick: 0 fills $0 income",
      "John: 0 fills -$1 income",
      "Paul: 0 fills -$2 income"
    )
  end

  it "keeps prescriptions independent and does not replay premature events" do
    input = StringIO.new(<<~INPUT)
      Mark A filled
      Mark A returned
      Mark A created
      Mark B created
      Mark B filled
      Mark B filled
      John A created
      John A filled
      John A returned
    INPUT
    output = described_class.run(input:)

    expect(output.lines(chomp: true)).to contain_exactly(
      "Mark: 2 fills $10 income",
      "John: 0 fills -$1 income"
    )
  end
end
