# frozen_string_literal: true

require 'test_helper'

class VideoTest < ActiveSupport::TestCase
  setup do
    @video_youtube = videos(:video_youtube)
    @video_vimeo = videos(:video_vimeo)
    @crag = crags(:rocher_des_aures)
    @user = users(:normal_user)
  end

  test 'video is valid' do
    assert @video_youtube.valid?
    assert @video_vimeo.valid?
  end

  test 'validates video service inclusion' do
    video = Video.new(viewable: @crag, url: nil)
    # init_embedded_code est appelé before_validation et met 'oblyk_video' si url est nil.
    # Pour tester l'échec de validation, on peut mettre une URL qui n'est pas reconnue par le service.
    video.url = 'https://google.com'
    assert_not video.valid?
    # embedded_code_service retourne nil pour le service si l'URL ne matche pas, ce qui déclenche l'erreur de présence/inclusion.
    assert_not_empty video.errors[:video_service]
  end

  test 'validates viewable type inclusion' do
    video = Video.new(viewable: @crag, video_service: 'youtube', url: 'https://youtu.be/123')
    assert video.valid?

    video.viewable_type = 'User'
    video.valid?
    assert_not_empty video.errors[:viewable_type]
  end

  test 'validates url_format_for_external_services' do
    video = Video.new(
      user: @user,
      viewable: @crag,
      video_service: 'youtube',
      url: 'https://invalid-url.com'
    )
    video.valid?
    assert_not_empty video.errors[:url]

    video.url = 'https://www.youtube.com/watch?v=valid'
    # Mocking Net::HTTP for embedded_code_service called in before_validation
    mock_response = Minitest::Mock.new
    mock_response.expect :body, '{"html": "<iframe></iframe>"}'
    
    Net::HTTP.stub :get_response, mock_response do
      assert video.valid?
    end
  end

  test 'name returns id' do
    assert_equal @video_youtube.id, @video_youtube.name
  end

  test 'app_path returns correct path' do
    assert_equal "/videos/#{@video_youtube.id}", @video_youtube.app_path
  end

  test 'valid_url? checks URL regexp' do
    @video_youtube.url = 'https://youtu.be/123'
    assert @video_youtube.valid_url?

    @video_youtube.url = 'https://google.com'
    assert_not @video_youtube.valid_url?
  end

  test 'init_embedded_code initializes embedded_code from oembed' do
    video = Video.new(
      user: @user,
      viewable: @crag,
      url: 'https://www.youtube.com/watch?v=123'
    )
    
    mock_response = Minitest::Mock.new
    mock_response.expect :body, '{"html": "<iframe src=\"https://www.youtube.com/embed/123\"></iframe>"}'
    
    Net::HTTP.stub :get_response, mock_response do
      video.valid? # triggers init_embedded_code via before_validation
      assert_equal 'youtube', video.video_service
      assert_equal '<iframe src="https://www.youtube.com/embed/123"></iframe>', video.embedded_code
    end
  end

  test 'publication_push! creates a publication after create' do
    video = Video.new(
      user: @user,
      viewable: @crag,
      video_service: 'youtube',
      url: 'https://www.youtube.com/watch?v=new_video'
    )
    mock_response = Minitest::Mock.new
    mock_response.expect :body, '{"html": "<iframe></iframe>"}'

    Net::HTTP.stub :get_response, mock_response do
      assert_difference 'Publication.count', 1 do
        video.save!
      end
    end
    
    publication = Publication.last
    assert_equal @crag.id, publication.publishable_id
    assert_equal 'Crag', publication.publishable_type
    assert_equal 'new_video', publication.publishable_subject
    assert_equal 1, publication.publication_attachments.count
    assert_equal video.id, publication.publication_attachments.first.attachable_id
  end
end
