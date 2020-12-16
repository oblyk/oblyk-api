# frozen_string_literal: true

module Search
  class RecordBuilder
    attr_accessor :record

    def initialize(record)
      @record = record
    end

    def self.call(record)
      new(record).call
    end

    def call
      OblykResultBuilder.new(@record).json_record
    end
  end
end
