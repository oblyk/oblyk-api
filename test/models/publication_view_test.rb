# frozen_string_literal: true

require 'test_helper'

class PublicationViewTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @publication = publications(:publication_user)
  end

  test 'is valid with user and publication' do
    publication_view = PublicationView.new(user: @user, publication: @publication)
    assert publication_view.valid?
  end

  test 'sets viewed_at before create' do
    @user_2 = users(:super_admin_user)
    publication_view = PublicationView.create(user: @user_2, publication: publications(:publication_crag))
    assert_not_nil publication_view.viewed_at
  end

  test 'does not override viewed_at if already set' do
    viewed_at = 2.days.ago.change(usec: 0)
    publication_view = PublicationView.create(user: @user, publication: publications(:publication_gym), viewed_at: viewed_at)
    assert_equal viewed_at.to_i, publication_view.viewed_at.to_i
  end
end
