# frozen_string_literal: true

module Api
  module V1
    class UserCragDeclarationsController < ApiController
      before_action :protected_by_session

      def create
        # If honour system (like checkbox)
        if user_crag_declaration_params[:declaration_system] == "honour"
          user_declaration = UserCragDeclaration.find_or_initialize_by(
            crag_id: user_crag_declaration_params[:crag_id],
            user_id: @current_user.id
          )
          user_declaration.declaration_system = "honour"
          if user_declaration.save
            head :no_content
          else
            render json: { error: user_declaration.errors }, status: :unprocessable_content
          end
        end

        # If is secret question system
        if user_crag_declaration_params[:declaration_system] == "guide_book_secret_question"
          question = GuideBookPaperQuestion.find user_crag_declaration_params[:question_id]

          if question.answer&.parameterize == user_crag_declaration_params[:answer]&.parameterize
            question.guide_book_paper.crags.each do |crag|
              user_declaration = UserCragDeclaration.find_or_initialize_by(
                crag_id: crag.id,
                user_id: @current_user.id
              )
              user_declaration.guide_book_paper_id = question.guide_book_paper.id
              user_declaration.declaration_system = "guide_book_secret_question"
              user_declaration.save
            end
            head :no_content
          else
            render json: { error: { base: [ "bad_answer" ] } }, status: :unprocessable_content
          end
        end
      end

      def available_guide_book_papers
        crag = Crag.find(params[:crag_id])

        guide_book_papers = GuideBookPaper.includes(:guide_book_paper_questions)
                                          .where(funding_status: "contributes_to_financing")
                                          .where(GuideBookPaperQuestion.where("guide_book_paper_questions.guide_book_paper_id = guide_book_papers.id").arel.exists)
                                          .where(
                                            GuideBookPaperCrag.where(crag_id: crag.id)
                                                              .where("guide_book_paper_crags.guide_book_paper_id = guide_book_papers.id")
                                                              .arel.exists
                                          )
        serializer = serializer(
          GuideBookPaperSerializer,
          guide_book_papers,
          {
            include: %i[guide_book_paper_questions],
            params: {
              include_attachments: {
                GuideBookPaper: %i[cover]
              }
            }
          }
        )
        render json: serializer, status: :ok
      end

      private

      def user_crag_declaration_params
        params.require(:user_crag_declaration).permit(
          :declaration_system,
          :crag_id,
          :answer,
          :question_id
        )
      end
    end
  end
end
