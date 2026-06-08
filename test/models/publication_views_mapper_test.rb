# frozen_string_literal: true

require 'test_helper'

class PublicationViewsMapperTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @user_2 = users(:super_admin_user)
    @pub_user = publications(:publication_user)
    @pub_crag = publications(:publication_crag)
    @pub_gym = publications(:publication_gym)
    @pub_old = publications(:publication_old)
  end

  test 'returns publications as is if user is nil' do
    publications = [@pub_user, @pub_crag]
    mapper = PublicationViewsMapper.new(publications, nil)
    assert_equal publications, mapper.map_publications
  end

  test 'maps a single publication' do
    mapper = PublicationViewsMapper.new(@pub_gym, @user)
    result = mapper.map_publications

    assert_instance_of Publication, result
    assert_equal @pub_gym.id, result.id
    assert PublicationView.exists?(user: @user, publication: @pub_gym)
  end

  test 'sets viewed to true on returned publication if already viewed' do
    mapper = PublicationViewsMapper.new([@pub_user], @user)
    result = mapper.map_publications

    assert result.first.viewed
  end

  test 'returns the same object when mapping single publication' do
    mapper = PublicationViewsMapper.new(@pub_user, @user)
    result = mapper.map_publications
    assert_equal @pub_user.id, result.id
    assert result.viewed
  end

  test 'marks old publications as viewed even if not in DB' do
    mapper = PublicationViewsMapper.new([@pub_old], @user)
    result = mapper.map_publications

    assert result.first.viewed
    assert_not PublicationView.exists?(user: @user, publication: @pub_old)
  end

  test 'saves new views and deletes notifications' do
    notification = Notification.create!(
      user: @user,
      notification_type: 'new_publication',
      notifiable: @pub_gym
    )

    assert_difference 'PublicationView.count', 1 do
      assert_difference 'Notification.count', -1 do
        mapper = PublicationViewsMapper.new([@pub_gym], @user)
        mapper.map_publications
      end
    end

    assert PublicationView.exists?(user: @user, publication: @pub_gym)
    assert_not Notification.exists?(id: notification.id)
  end

  test 'mixes viewed and unviewed publications' do
    publications = [@pub_user, @pub_gym]

    assert_difference 'PublicationView.count', 1 do
      mapper = PublicationViewsMapper.new(publications, @user)
      result = mapper.map_publications

      assert result.find { |p| p.id == @pub_user.id }.viewed
    end
  end
end
