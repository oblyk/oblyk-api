# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class UserCragDeclarationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = users(:normal_user)
        @crag = crags(:rocher_des_aures)
        @orpierre = crags(:orpierre)
        @guide_book_paper = guide_book_papers(:guide_book_2024)
        @question = guide_book_paper_questions(:one)

        @user_headers = api_headers(user: :normal_user)
        @public_headers = api_access_token_headers
      end

      test "should be protected by session on create" do
        post api_v1_user_crag_declarations_url,
             params: { user_crag_declaration: { declaration_system: "honour", crag_id: @crag.id } },
             headers: @public_headers, as: :json

        assert_response :unauthorized
      end

      test "should be protected by session on available_guide_book_papers" do
        get available_guide_book_papers_api_v1_user_crag_declarations_url(crag_id: @crag.id),
            headers: @public_headers, as: :json

        assert_response :unauthorized
      end

      test "should declare crag with honour system" do
        assert_difference("UserCragDeclaration.count", 1) do
          post api_v1_user_crag_declarations_url,
               params: {
                 user_crag_declaration: {
                   declaration_system: "honour",
                   crag_id: @crag.id
                 }
               },
               headers: @user_headers, as: :json
        end

        assert_response :no_content

        declaration = UserCragDeclaration.find_by(user_id: @user.id, crag_id: @crag.id)

        assert_not_nil declaration
        assert_equal "honour", declaration.declaration_system
        assert_equal 2, declaration.equivalent_level
      end

      test "should update existing declaration with honour system" do
        existing_declaration = UserCragDeclaration.create!(
          user: @user,
          crag: @crag,
          declaration_system: "guide_book_secret_question",
          guide_book_paper: @guide_book_paper
        )

        assert_no_difference("UserCragDeclaration.count") do
          post api_v1_user_crag_declarations_url,
               params: {
                 user_crag_declaration: {
                   declaration_system: "honour",
                   crag_id: @crag.id
                 }
               },
               headers: @user_headers, as: :json
        end

        assert_response :no_content
        existing_declaration.reload

        assert_equal "honour", existing_declaration.declaration_system
        assert_equal 2, existing_declaration.equivalent_level
      end

      test "should return unprocessable_content on invalid honour declaration" do
        assert_no_difference("UserCragDeclaration.count") do
          post api_v1_user_crag_declarations_url,
               params: {
                 user_crag_declaration: {
                   declaration_system: "honour",
                   crag_id: nil
                 }
               },
               headers: @user_headers, as: :json
        end

        assert_response :unprocessable_content
        json_response = response.parsed_body

        assert json_response.key?("error")
      end

      test "should declare crags with guide book secret question on correct answer" do
        assert_difference("UserCragDeclaration.count", @guide_book_paper.crags.count) do
          post api_v1_user_crag_declarations_url,
               params: {
                 user_crag_declaration: {
                   declaration_system: "guide_book_secret_question",
                   question_id: @question.id,
                   answer: "summit"
                 }
               },
               headers: @user_headers, as: :json
        end

        assert_response :no_content

        declaration = UserCragDeclaration.find_by(user_id: @user.id, crag_id: @crag.id)

        assert_not_nil declaration
        assert_equal "guide_book_secret_question", declaration.declaration_system
        assert_equal @guide_book_paper.id, declaration.guide_book_paper_id
        assert_equal 3, declaration.equivalent_level
      end

      test "should return error on guide book secret question with wrong answer" do
        assert_no_difference("UserCragDeclaration.count") do
          post api_v1_user_crag_declarations_url,
               params: {
                 user_crag_declaration: {
                   declaration_system: "guide_book_secret_question",
                   question_id: @question.id,
                   answer: "wrong_answer"
                 }
               },
               headers: @user_headers, as: :json
        end

        assert_response :unprocessable_content
        json_response = response.parsed_body

        assert_equal({ "error" => { "base" => [ "bad_answer" ] } }, json_response)
      end

      test "should get available guide book papers for crag" do
        get available_guide_book_papers_api_v1_user_crag_declarations_url(crag_id: @crag.id),
            headers: @user_headers, as: :json

        assert_response :success
        json_response = response.parsed_body

        assert_equal "jsonapi.org", json_response["json_type"]
        assert_kind_of Array, json_response["data"]
        assert_equal 1, json_response["data"].size
        assert_equal @guide_book_paper.id.to_s, json_response["data"].first["id"]
        assert_equal @guide_book_paper.name, json_response["data"].first["attributes"]["name"]

        # Check relationships and included questions
        assert json_response["data"].first["relationships"].key?("guide_book_paper_questions")
        assert_equal 1, json_response["included"].size
        assert_equal @question.id.to_s, json_response["included"].first["id"]
        assert_equal @question.question, json_response["included"].first["attributes"]["question"]
      end

      test "should return empty data when crag has no financing guide books with questions" do
        get available_guide_book_papers_api_v1_user_crag_declarations_url(crag_id: @orpierre.id),
            headers: @user_headers, as: :json

        assert_response :success
        json_response = response.parsed_body

        assert_equal "jsonapi.org", json_response["json_type"]
        assert_equal [], json_response["data"]
      end

      test "should return not found for available guide book papers with unknown crag" do
        get available_guide_book_papers_api_v1_user_crag_declarations_url(crag_id: 0),
            headers: @user_headers, as: :json

        assert_response :not_found
      end
    end
  end
end
