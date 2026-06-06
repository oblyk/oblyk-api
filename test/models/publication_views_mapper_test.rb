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
    # @pub_gym is not viewed by @user
    mapper = PublicationViewsMapper.new(@pub_gym, @user)
    result = mapper.map_publications
    
    assert_instance_of Publication, result
    assert_equal @pub_gym.id, result.id
    assert PublicationView.exists?(user: @user, publication: @pub_gym)
  end

  test 'sets viewed to true on returned publication if already viewed' do
    # @pub_user is already viewed by @user in fixtures
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
    # @pub_old is > 3 months old
    mapper = PublicationViewsMapper.new([@pub_old], @user)
    result = mapper.map_publications
    
    assert result.first.viewed
    # Mapper rejects old publications from being saved in PublicationView
    assert_not PublicationView.exists?(user: @user, publication: @pub_old)
  end

  test 'saves new views and deletes notifications' do
    # Ensure a notification exists
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
    # @pub_user is viewed, @pub_gym is not
    publications = [@pub_user, @pub_gym]
    
    assert_difference 'PublicationView.count', 1 do
      mapper = PublicationViewsMapper.new(publications, @user)
      result = mapper.map_publications
      
      assert result.find { |p| p.id == @pub_user.id }.viewed
      # Note: For newly saved views, the current implementation of mapper doesn't set viewed = true 
      # on the object in the same call if it went through `save_views` at the end of `mapper` method.
      # Wait, let's re-read mapper:
      # if publication_views.size.zero?
      #   save_views(publication_ids)
      #   return publications
      # end
      # ...
      # publications.each do |publication|
      #   if publications_view_ids.include?(publication.id) ...
      #     publication.viewed = true
      #   else
      #     unviewed_publications << publication.id
      #   end
      # end
      # save_views(unviewed_publications) if unviewed_publications.size.positive?
      # publications
      
      # So for @pub_gym, viewed will NOT be set to true on the object returned, 
      # but it WILL be saved in DB.
    end
  end
end
