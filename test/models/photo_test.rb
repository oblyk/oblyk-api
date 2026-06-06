# frozen_string_literal: true

require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  setup do
    @photo = Photo.create!(
      user: users(:normal_user),
      illustrable: crags(:rocher_des_aures),
      description: 'Une belle vue du Rocher des Aures',
      copyright_by: true,
      copyright_nc: false,
      copyright_nd: false
    )
    @photo_article = Photo.create!(
      user: users(:normal_user),
      illustrable: articles(:article_1),
      description: "Image pour l'article 1",
      copyright_by: true,
      copyright_nc: true,
      copyright_nd: true
    )
    @photo.picture.attach(
      io: File.open(Rails.root.join('test/fixtures/files/image.jpg')),
      filename: 'image.jpg',
      content_type: 'image/jpeg'
    )
  end

  test 'photo is valid' do
    assert @photo.valid?
  end

  test 'photo without illustrable is invalid' do
    @photo.illustrable = nil
    assert_not @photo.valid?
  end

  test 'photo with invalid illustrable type is invalid' do
    gym = gyms(:my_gym)
    @photo.illustrable = gym
    assert_not @photo.valid?
    assert_includes @photo.errors[:illustrable_type], 'is_not_a_permitted_value'
  end

  test 'init_posted_at before validation' do
    new_photo = Photo.new(user: users(:normal_user), illustrable: crags(:orpierre))
    new_photo.valid?
    assert_not_nil new_photo.posted_at
  end

  test 'copy returns correct string' do
    assert_equal 'BY', @photo.copy
    assert_equal 'BY - NC - ND', @photo_article.copy
  end

  test 'app_path returns correct path' do
    assert_equal "/photos/#{@photo.id}", @photo.app_path
  end

  test 'photo_height and photo_width return metadata values' do
    @photo.picture.blob.metadata = { 'height' => 100, 'width' => 200 }
    @photo.picture.blob.save!
    assert_equal 100, @photo.photo_height
    assert_equal 200, @photo.photo_width
  end

  test 'destroyable? returns true if not used' do
    assert @photo.destroyable?
  end

  test 'summary_to_json returns correct keys' do
    json = @photo.summary_to_json
    assert_equal @photo.id, json[:id]
    assert_equal @photo.description, json[:description]
    assert_equal @photo.app_path, json[:app_path]
    assert_not_nil json[:illustrable]
    assert_not_nil json[:attachments]
  end

  test 'publication_push! creates a publication for crag' do
    @photo.posted_at = DateTime.current - 1.day
    assert_difference 'Publication.count', 1 do
      @photo.save!
      @photo.publication_push!
    end
    publication = Publication.last
    assert_equal 'Crag', publication.publishable_type
    assert_equal @photo.illustrable_id, publication.publishable_id
    assert_equal 'new_photo', publication.publishable_subject
  end
end
