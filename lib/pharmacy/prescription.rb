# frozen_string_literal: true

module Pharmacy
  class Prescription
    attr_reader :fills, :returns

    def initialize
      @fills = 0
      @returns = 0
    end

    def fill
      @fills += 1
    end

    def return
      return if @fills.zero?

      @fills -= 1
      @returns += 1
    end
  end
end
