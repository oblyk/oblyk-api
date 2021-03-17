# frozen_string_literal: true

module Search
  class OblykResultBuilder < ResultBuilderBase
    def json_record
      record.summary_to_json
    end
  end
end
