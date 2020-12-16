# frozen_string_literal: true

module Search
  class OblykResultBuilder < ResultBuilderBase
    def json_record
      record.search_json
    end
  end
end
