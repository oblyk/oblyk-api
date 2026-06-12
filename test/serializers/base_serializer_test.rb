# frozen_string_literal: true

require 'test_helper'

class BaseSerializerTest < ActiveSupport::TestCase
  test 'include_attribute returns true if attribute is in params' do
    params = {
      include_attributes: {
        my_key: %i[attr1 attr2]
      }
    }
    assert BaseSerializer.include_attribute(params, :attr1, :my_key)
    assert BaseSerializer.include_attribute(params, :attr2, :my_key)
  end

  test 'include_attribute returns false if attribute is not in params' do
    params = {
      include_attributes: {
        my_key: %i[attr1]
      }
    }
    assert_not BaseSerializer.include_attribute(params, :attr2, :my_key)
  end

  test 'include_attribute returns false if object_key is missing' do
    params = {
      include_attributes: {
        other_key: %i[attr1]
      }
    }
    assert_not BaseSerializer.include_attribute(params, :attr1, :my_key)
  end

  test 'include_attribute returns false if include_attributes is missing' do
    params = {}
    assert_not BaseSerializer.include_attribute(params, :attr1, :my_key)
  end
end
