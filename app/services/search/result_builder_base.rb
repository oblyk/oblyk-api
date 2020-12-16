# frozen_string_literal: true

module Search
  class ResultBuilderBase
    def initialize(record)
      @record = record
    end

    private

    attr_reader :record
  end
end
