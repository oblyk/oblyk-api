# frozen_string_literal: true

require 'zip'

module Api
  module V1
    class GymSpacesController < ApiController
      include Gymable
      skip_before_action :protected_by_session, only: %i[show index groups three_d_elements]
      skip_before_action :protected_by_gym_administrator, only: %i[show index groups three_d_elements]
      before_action :set_gym_space, except: %i[index create groups]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show groups three_d_elements]

      def index
        gym_spaces = @gym.gym_spaces
                         .joins('LEFT JOIN gym_space_groups ON gym_space_groups.id = gym_spaces.gym_space_group_id')
                         .reorder('gym_space_groups.order IS NULL ASC, gym_space_groups.order, gym_spaces.order')
        render json: gym_spaces.map { |gym_space| gym_space.summary_to_json(with_figures: true) }, status: :ok
      end

      def groups
        gym_spaces = @gym.gym_spaces
                         .joins('LEFT JOIN gym_space_groups ON gym_space_groups.id = gym_spaces.gym_space_group_id')
                         .reorder('gym_space_groups.order IS NULL ASC, gym_space_groups.order, gym_spaces.order')
        in_group = {}
        out_group = []
        gym_spaces.each do |gym_space|
          if gym_space.gym_space_group_id.present?
            in_group["group-#{gym_space.gym_space_group_id}"] ||= {
              id: gym_space.gym_space_group_id,
              name: gym_space.gym_space_group.name,
              order: gym_space.gym_space_group.order,
              gym_spaces: []
            }
            in_group["group-#{gym_space.gym_space_group_id}"][:gym_spaces] << gym_space.summary_to_json(with_figures: true)
          else
            out_group << gym_space.summary_to_json(with_figures: true)
          end
        end
        render json: {
          grouped_spaces: in_group.map(&:last),
          ungrouped_spaces: out_group
        }, status: :ok
      end

      def three_d_elements
        sector = []
        @gym_space.gym_sectors.each do |gym_sector|
          sector << {
            id: gym_sector.id,
            name: gym_sector.name,
            three_d_path: gym_sector.three_d_path,
            three_d_height: gym_sector.three_d_height
          }
        end
        render json: { gym_sectors: sector }, status: :ok
      end

      def show
        render json: @gym_space.detail_to_json, status: :ok
      end

      def create
        @gym_space = GymSpace.new(gym_space_params)
        @gym_space.representation_type ||= '2d_picture'
        @gym_space.gym = @gym
        if @gym_space.save
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def update
        if @gym_space.update(gym_space_params)
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_space.destroy
          head :no_content
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def publish
        if @gym_space.publish!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def unpublish
        if @gym_space.unpublish!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_banner
        if @gym_space.update(banner_params)
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_plan
        if @gym_space.update(plan_params)
          @gym_space.set_plan_dimension!
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_three_d_capture
        if @gym_space.update(three_d_capture_params)
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      def add_three_d_file
        unless attach_three_d_file
          render json: { error: { base: ['three_d_import_error'] } }, status: :unprocessable_entity
          return
        end

        @gym_space.three_d_parameters ||= { highlight_edges: true, color_correction_sketchup_exports: true }
        if @gym_space.save
          render json: @gym_space.detail_to_json, status: :ok
        else
          render json: { error: @gym_space.errors }, status: :unprocessable_entity
        end
      end

      private

      def attach_three_d_file
        import_type = params[:gym_space].fetch(:import_type, '').to_s

        if %w[obj_zip obj_mtl].include? import_type
          random_file_name = SecureRandom.uuid
          folder = FileUtils.mkdir_p "tmp/obj2gltf_folder/#{random_file_name}"
          obj_name = nil

          # Save file on folder for conversion to .gltf
          case import_type
          when 'obj_zip'
            zip_file_params = params[:gym_space].fetch(:three_d_file, nil)

            # Unzip .obj.zip
            Zip::File.open(zip_file_params) do |zip_file|
              zip_file.each do |f|
                file_extension = f.name.split('.').last
                next unless %w[obj mtl].include? file_extension

                f_path = File.join(folder, f.name)
                zip_file.extract(f, f_path) unless File.exist?(f_path)
                obj_name = f.name if file_extension == 'obj'
              end
            end
          when 'obj_mtl'
            mtl_file_params = params[:gym_space].fetch(:three_d_file_mtl, nil)
            obj_file_params = params[:gym_space].fetch(:three_d_file_obj, nil)

            if File.extname(mtl_file_params) != '.mtl' || File.extname(obj_file_params) != '.obj'
              @gym_space.errors.add(:base, 'wrong_file_format')
              FileUtils.remove_dir folder.first
              return false
            end

            # write obj file
            obj_name = obj_file_params.original_filename
            f_path_obj = File.join(folder, obj_name)
            File.open(f_path_obj, 'wb') { |f| f.write obj_file_params.read }

            # write mtl file
            mtl_name = mtl_file_params.original_filename
            f_path_mtl = File.join(folder, mtl_name)
            File.open(f_path_mtl, 'wb') { |f| f.write mtl_file_params.read }
          else
            @gym_space.errors.add(:base, 'wrong_file_format')
            FileUtils.remove_dir folder.first
            return false
          end

          # Convert .mtl + .obj to .gltf
          if obj_name
            # Run obj2gltf shell command
            _stdout, stderr, status = Open3.capture3(
              "#{ENV['NPM_BIN_PATH']}/obj2gltf",
              '-i',
              "#{folder.first}/#{obj_name}"
            )
            if status.success?
              gltf_file_name = "#{obj_name.split('.').first}.gltf"
              file = File.open("#{folder.first}/#{gltf_file_name}", 'r')
              @gym_space.three_d_gltf.attach(
                io: file,
                filename: gltf_file_name,
                content_type: 'model/gltf+json'
              )
            else
              RorVsWild.record_error(stderr)
              return false
            end
          end

          # Delete unzip file
          FileUtils.remove_dir folder.first
        elsif import_type == 'gltf'
          file = params[:gym_space].fetch(:three_d_file, nil)
          if file && File.extname(file) == '.gltf'
            @gym_space.three_d_gltf.attach(
              io: file,
              filename: file.original_filename,
              content_type: 'model/gltf+json'
            )
            unless @gym_space.valid?
              @gym_space.errors.add(:base, 'wrong_file_format')
              return false
            end
          else
            @gym_space.errors.add(:base, 'wrong_file_format')
            return false
          end
        else
          @gym_space.errors.add(:base, 'wrong_file_format')
          return false
        end

        @gym_space.gym.delete_summary_cache
        @gym_space.delete_summary_cache
        true
      end

      def set_gym_space
        @gym_space = GymSpace.find params[:id]
      end

      def gym_space_params
        params.require(:gym_space).permit(
          :name,
          :description,
          :order,
          :climbing_type,
          :sectors_color,
          :gym_grade_id,
          :gym_space_group_id,
          :anchor,
          :three_d_scale,
          :representation_type,
          three_d_parameters: %i[color_correction_sketchup_exports highlight_edges],
          three_d_position: %i[x y z],
          three_d_rotation: %i[x y z]
        )
      end

      def banner_params
        params.require(:gym_space).permit(
          :banner
        )
      end

      def plan_params
        params.require(:gym_space).permit(
          :plan
        )
      end

      def three_d_capture_params
        params.require(:gym_space).permit(
          :three_d_picture,
          three_d_camera_position: %i[x y z]
        )
      end
    end
  end
end
