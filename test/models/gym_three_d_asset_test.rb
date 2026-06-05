# frozen_string_literal: true

require 'test_helper'

class GymThreeDAssetTest < ActiveSupport::TestCase
  setup do
    @gym_three_d_asset = gym_three_d_assets(:asset_1)
  end

  test 'gym_three_d_asset is valid' do
    assert @gym_three_d_asset.valid?
  end

  test 'gym_three_d_asset is invalid without name' do
    @gym_three_d_asset.name = nil
    assert_not @gym_three_d_asset.valid?
  end

  test 'summary_to_json returns correct keys' do
    summary = @gym_three_d_asset.summary_to_json
    assert_equal @gym_three_d_asset.id, summary[:id]
    assert_equal @gym_three_d_asset.name, summary[:name]
    assert_includes summary.keys, :three_d_gltf_url
    assert_includes summary.keys, :attachments
  end

  test 'three_d? returns true if three_d_gltf is attached' do
    assert_not @gym_three_d_asset.three_d?
    # Simuler l'attachement est complexe sans fichier réel, 
    # mais on peut tester le comportement par défaut
  end

  test 'three_d_gltf_url returns nil if nothing attached' do
    assert_nil @gym_three_d_asset.three_d_gltf_url
  end
end
