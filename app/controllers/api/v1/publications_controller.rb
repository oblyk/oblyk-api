# frozen_string_literal: true

module Api
  module V1
    class PublicationsController < ApiController
      include GymRolesVerification

      before_action :protected_by_session, only: %i[drafts create update destroy publish my_publication_feed]
      before_action :set_publication, only: %i[show update destroy publish]
      before_action :set_publications, only: %i[index drafts]
      before_action :private_protected, except: %i[create index drafts my_publication_feed]
      before_action :index_private_protected, only: %i[create index]
      before_action :protected_by_owner, only: %i[update destroy publish]

      def index
        type = params[:publishable_type].to_s
        id = params[:publishable_id].to_i

        # Add linked publication for somme type
        publications = if %w[Crag GuideBookPaper].include? type
                         Publication.where(
                           '(publications.publishable_type = :type AND publications.publishable_id = :id AND publications.published_at IS NOT NULL)
                            OR (publications.id IN (SELECT publications.id FROM publications
                                                    INNER JOIN publication_attachments ON publications.id = publication_attachments.publication_id
                                                    WHERE attachable_type = :type
                                                      AND attachable_id = :id
                                                      AND publications.published_at IS NOT NULL))',
                           type: type,
                           id: id
                         )
                       elsif type == 'User'
                         Publication.where(author_id: id)
                                    .where.not(publishable_type: %w[Gym])
                                    .where('publications.publishable_subject IS NULL OR publications.publishable_subject NOT IN ("new_crag_routes", "new_video", "new_alert")')
                                    .where.not(published_at: nil)
                       else
                         Publication.where(publishable_type: type, publishable_id: id)
                                    .where.not(published_at: nil)
                       end

        publications = publications.includes(author: { avatar_attachment: :blob }, publication_attachments: attachment_includes)
                                   .order(published_at: :desc, id: :desc)
                                   .page(params.fetch(:page, 1))
                                   .per(params.fetch(:per_page, 5))

        publications = PublicationViewsMapper.new(publications, @current_user).map_publications if login?

        render json: serializer(PublicationSerializer, publications, publication_options), status: :ok
      end

      def drafts
        type = params[:publishable_type]
        id = params[:publishable_id].to_i

        # If current_user isn't logged in, return an empty array
        unless login?
          render json: [], status: :ok
          return
        end

        publications = @publications.includes(author: { avatar_attachment: :blob }, publication_attachments: attachment_includes)
                                    .where(published_at: nil)

        # If current_user is not a gym team member, return an empty array
        if type == 'Gym'
          @gym = Gym.find id
          unless gym_team_user?
            render json: [], status: :ok
            return
          end
        end

        # If is not a Gym draft, then: only the author can see their draft
        publications = publications.where(author: @current_user) if %w[Gym].exclude? type
        publications = publications.order(last_updated_at: :desc, id: :desc)

        render json: serializer(PublicationSerializer, publications, publication_options), status: :ok
      end

      def my_publication_feed
        publications = Publication.includes(publishable: publishable_includes,
                                            author: { avatar_attachment: :blob },
                                            publication_attachments: attachment_includes)
                                  .where.not(published_at: nil)
                                  .where(
                                    '(EXISTS (SELECT *
                                             FROM follows
                                             WHERE user_id = :current_user_id
                                               AND accepted_at IS NOT NULL
                                               AND followable_id = publications.publishable_id
                                               AND followable_type = publications.publishable_type)
                                      OR (publications.publishable_type = "User" AND publications.publishable_id = :current_user_id)
                                      OR publications.publishable_type = "Article"
                                    )',
                                    current_user_id: @current_user.id
                                  )
                                  .order(published_at: :desc, id: :desc)
                                  .page(params.fetch(:page, 1))
                                  .per(params.fetch(:per_page, 5))

        publications = PublicationViewsMapper.new(publications, @current_user).map_publications

        render json: serializer(PublicationSerializer, publications, publication_options), status: :ok
      end

      def show
        publication = PublicationViewsMapper.new(@publication, @current_user).map_publications if login?

        render json: serialized_publication(publication), status: :ok
      end

      def create
        @publication = Publication.new publication_params
        @publication.author = @current_user
        @publication.last_updated_at = Time.zone.now
        if @publication.save
          render json: serialized_publication(@publication), status: :ok
        else
          render json: { error: @publication.errors }, status: :unprocessable_entity
        end
      end

      def update
        @publication.last_updated_at = Time.zone.now
        if @publication.update publication_params
          render json: serialized_publication(@publication), status: :ok
        else
          render json: { error: @publication.errors }, status: :unprocessable_entity
        end
      end

      def publish
        if @publication.publish!
          head :no_content
        else
          render json: { error: @publication.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @publication.destroy
          render json: {}, status: :ok
        else
          render json: { error: @publication.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_publications
        publishable_type = params[:publishable_type] == 'CurrentUser' ? 'User' : params[:publishable_type]
        if publishable_type.blank? || Publication::PUBLISHABLE_TYPES.exclude?(publishable_type)
          render json: nil, status: :not_found
          return
        end

        @publications = Publication.where(publishable_type: publishable_type, publishable_id: params[:publishable_id].to_i)
      end

      def set_publication
        @publication = Publication.includes(publication_attachments: :attachable).find params[:id]
      end

      def serialized_publication(publication)
        serializer(PublicationSerializer, publication, publication_options)
      end

      def publication_params
        params.require(:publication).permit(
          :publishable_type,
          :publishable_id,
          :body
        )
      end

      def publication_options
        {
          include: [
            :publication_attachments,
            :publishable,
            :author,
            'publication_attachments.attachable',
            'publication_attachments.attachable.gym_space',
            'publication_attachments.attachable.crag_sector'
          ],
          params: {
            include_attachments: {
              Crag: %i[avatar cover],
              Gym: %i[avatar logo],
              User: %i[avatar],
              GymSpace: %i[avatar],
              GymRoute: %i[thumbnail],
              GuideBookPaper: %i[avatar],
              Article: %i[avatar],
              Contest: %i[banner],
              Photo: %i[picture]
            }
          }
        }
      end

      def attachment_includes
        {
          attachable: [
            { crag: { photo: { picture_attachment: :blob }, static_map_attachment: :blob } },
            { crag_route: { photo: { picture_attachment: :blob } } },
            { crag_sector: :crag },
            { crag_space: { plan_attachment: :blob, three_d_picture_attachment: :blob } },
            { guide_book_paper: { cover_attachment: :blob } },
            { gym: [:gym_spaces, { logo_attachment: :blob }] },
            { gym_sector: :gym_space },
            { video: { video_file_attachment: :blob } },
            { photo: { picture_attachment: :blob } }
          ]
        }
      end

      def publishable_includes
        {
          crag: { static_map_attachment: :blob, photo: { picture_attachment: :blob } },
          photo: { picture_attachment: :blob },
          gym: [:gym_options, :gym_spaces, { logo_attachment: :blob }]
        }
      end

      def private_protected
        return true unless @publication.publishable_type == 'User'

        user = @publication.publishable

        forbidden if user.present? && !user.other_user_can?(@current_user, request: :see_publications)
      end

      def index_private_protected
        return true if params[:publishable_type] != 'User'

        user = User.find_by(id: params[:publishable_id])

        # Set current user
        login?

        forbidden if user.present? && !user.other_user_can?(@current_user, request: :see_publications)
      end

      def protected_by_owner
        case @publication.publishable_type
        when 'Gym'
          @gym = @publication.publishable
          forbidden unless gym_team_user?
        when 'User'
          forbidden unless @publication.publishable == @current_user
        end
      end
    end
  end
end
