# frozen_string_literal: true

module ParentFeedable
  extend ActiveSupport::Concern

  def feed_parent_id
    has_attribute?(:uuid) ? uuid : id
  end

  def feed_parent_type
    self.class.name
  end

  def feed_parent_object
    {
      type: self.class.name,
      id: id,
      name: has_attribute?(:full_name) ? full_name : name,
      slug_name: slug_name
    }
  end
end
