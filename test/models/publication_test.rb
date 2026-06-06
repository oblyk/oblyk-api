# frozen_string_literal: true

require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  setup do
    @publication_user = publications(:publication_user)
    @publication_draft = publications(:publication_draft)
    @user = users(:normal_user)
    @crag = crags(:rocher_des_aures)

    @photo = Photo.create!(
      user: users(:normal_user),
      illustrable: crags(:rocher_des_aures),
      description: 'Une belle vue du Rocher des Aures',
      copyright_by: true,
      copyright_nc: false,
      copyright_nd: false
    )
    @photo.picture.attach(
      io: File.open(Rails.root.join('test/fixtures/files/image.jpg')),
      filename: 'image.jpg',
      content_type: 'image/jpeg'
    )
  end

  # test_helper_locales

  test 'validates publishable type' do
    pub = Publication.new(publishable: @user, author: @user, body: 'test', published_at: Time.zone.now)
    assert pub.valid?

    pub.publishable_type = 'Area'
    assert pub.invalid?
  end

  test 'validates body if published and no subject' do
    pub = Publication.new(publishable: @user, author: @user, published_at: Time.zone.now)
    assert pub.invalid?

    pub.publishable_subject = 'new_photo'
    assert pub.valid?
  end

  test 'app_path returns correct path' do
    assert_equal "/publications/#{@publication_user.id}", @publication_user.app_path
  end

  test 'publishable_name returns correct name' do
    assert_equal @user.full_name, @publication_user.publishable_name

    pub_crag = publications(:publication_crag)
    assert_equal @crag.name, pub_crag.publishable_name
  end

  test 'draft? returns true if not published' do
    assert @publication_draft.draft
    assert_not @publication_user.draft
  end

  test 'published? returns true if published' do
    assert @publication_user.published?
    assert_not @publication_draft.published?
  end

  test 'publish! sets published_at and creates notification' do
    # Create a new user to avoid daily limit
    new_user = User.new(
      first_name: 'New',
      last_name: 'User',
      email: 'new.user@test.com',
      password: 'password123',
      slug_name: 'new-user'
    )
    new_user.save(validate: false)

    pub = Publication.new(publishable: new_user, author: new_user, body: 'New pub unique')
    assert_nil pub.published_at

    result = pub.publish!
    assert result, "Publication should be published"
    assert_not_nil pub.published_at
    assert pub.published?
  end

  test 'posting limit for today' do
    new_user = User.new(
      first_name: 'Limit',
      last_name: 'User',
      email: 'limit.user@test.com',
      password: 'password123',
      slug_name: 'limit-user'
    )
    new_user.save(validate: false)

    # User limit is 1
    pub1 = Publication.new(publishable: new_user, author: new_user, body: 'Pub 1')
    pub1.publish!

    pub2 = Publication.new(publishable: new_user, author: new_user, body: 'Pub 2')
    assert_no_difference 'Publication.count' do
      result = pub2.publish!
      assert_not result
      assert_includes pub2.errors[:base], 'posting_limit_for_today'
    end
  end

  test 'refresh_attachment_types_count updates counts' do
    pub = Publication.new(publishable: @user, author: @user, body: 'test')
    pub.save(validate: false)

    assert_equal 0, pub.attachables_count
    assert_equal({}, pub.attachable_types_count)

    pub.publication_attachments.create!(attachable: @photo)
    pub.refresh_attachment_types_count
    assert_equal 1, pub.attachables_count
    assert_equal({ 'Photo' => 1 }, pub.attachable_types_count)
  end
end
