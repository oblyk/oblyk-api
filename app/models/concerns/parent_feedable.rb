# frozen_string_literal: true

module ParentFeedable
  extend ActiveSupport::Concern

  def feed_parent_id
    id
  end

  def feed_parent_type
    self.class.name
  end

  def feed_parent_object
    {
      type: self.class.name,
      id: id,
      uuid: has_attribute?(:uuid) ? uuid : nil,
      name: defined?(full_name) ? full_name : name,
      slug_name: slug_name
    }
  end
end
