# frozen_string_literal: true

require 'test_helper'

class ApplicationRecordTest < ActiveSupport::TestCase
  test 'ApplicationRecord is an abstract class' do
    assert ApplicationRecord.abstract_class?
  end

  test 'ApplicationRecord inherits from ActiveRecord::Base' do
    assert_equal ActiveRecord::Base, ApplicationRecord.superclass
  end
end
