# frozen_string_literal: true

require 'zip'

module Api
  module V1
    class GymThreeDAssetsController < ApiController
      include Gymable

      skip_before_action :protected_by_session, only: %i[show index]
      skip_before_action :protected_by_gym_administrator, only: %i[show index]
      before_action :set_gym_three_d_asset, except: %i[index create]
      before_action -> { can? GymRole::MANAGE_SPACE }, except: %i[index show]

      def index
        gym_three_d_assets = GymThreeDAsset.where(gym_id: @gym.id).or(GymThreeDAsset.where(gym_id: nil))
        render json: gym_three_d_assets.map(&:summary_to_json), status: :ok
      end

      def show
        render json: @gym_three_d_asset.detail_to_json, status: :ok
      end

      def create
        @gym_three_d_asset = GymThreeDAsset.new gym_three_d_asset_params

        unless attach_three_d_file
          render json: { error: { base: ['3d_import_error'] } }, status: :unprocessable_entity
          return
        end

        @gym_three_d_asset.gym = @gym
        if @gym_three_d_asset.save
          render json: @gym_three_d_asset.detail_to_json, status: :ok
        else
          render json: { error: @gym_three_d_asset.errors }, status: :unprocessable_entity
        end
      end

      def update
        import_type = params[:gym_three_d_asset].fetch(:import_type, '').to_s
        if !attach_three_d_file && import_type.present?
          render json: { error: { base: ['three_d_import_error'] } }, status: :unprocessable_entity
          return
        end

        if @gym_three_d_asset.update gym_three_d_asset_params
          render json: @gym_three_d_asset.detail_to_json, status: :ok
        else
          render json: { error: @gym_three_d_asset.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        if @gym_three_d_asset.destroy
          head :no_content
        else
          render json: { error: @gym_three_d_asset.errors }, status: :unprocessable_entity
        end
      end

      def change_three_d_file
        if @gym_three_d_asset.update(three_d_file_params)
          render json: @gym_three_d_asset.detail_to_json, status: :ok
        else
          render json: { error: @gym_three_d_asset.errors }, status: :unprocessable_entity
        end
      end

      def add_picture
        if @gym_three_d_asset.update(gym_asset_picture_params)
          render json: @gym_three_d_asset.detail_to_json, status: :ok
        else
          render json: { error: @gym_three_d_asset.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_gym_three_d_asset
        @gym_three_d_asset = GymThreeDAsset.find params[:id]
      end

      def attach_three_d_file
        import_type = params[:gym_three_d_asset].fetch(:import_type, '').to_s

        return false if import_type.blank?

        if %w[obj_zip obj_mtl].include? import_type
          random_file_name = SecureRandom.uuid
          folder = FileUtils.mkdir_p "tmp/obj2gltf_folder/#{random_file_name}"
          obj_name = nil

          # Save file on folder for conversion to .gltf
          case import_type
          when 'obj_zip'
            zip_file_params = params[:gym_three_d_asset].fetch(:three_d_file, nil)

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
            mtl_file_params = params[:gym_three_d_asset].fetch(:three_d_file_mtl, nil)
            obj_file_params = params[:gym_three_d_asset].fetch(:three_d_file_obj, nil)

            if File.extname(mtl_file_params) != '.mtl' || File.extname(obj_file_params) != '.obj'
              @gym_three_d_asset.errors.add(:base, 'wrong_file_format')
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
            @gym_three_d_asset.errors.add(:base, 'wrong_file_format')
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
              @gym_three_d_asset.three_d_gltf.attach(
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
          file = params[:gym_three_d_asset].fetch(:three_d_file, nil)
          if file && File.extname(file) == '.gltf'
            @gym_three_d_asset.three_d_gltf.attach(
              io: file,
              filename: file.original_filename,
              content_type: 'model/gltf+json'
            )
            unless @gym_three_d_asset.valid?
              @gym_three_d_asset.errors.add(:base, 'wrong_file_format')
              return false
            end
          else
            @gym_three_d_asset.errors.add(:base, 'wrong_file_format')
            return false
          end
        else
          @gym_three_d_asset.errors.add(:base, 'wrong_file_format')
          return false
        end
        true
      end

      def gym_three_d_asset_params
        if params[:gym_three_d_asset][:three_d_parameters].present?
          params[:gym_three_d_asset][:three_d_parameters][:color_correction_sketchup_exports] = params[:gym_three_d_asset][:three_d_parameters][:color_correction_sketchup_exports] == 'true'
          params[:gym_three_d_asset][:three_d_parameters][:highlight_edges] = params[:gym_three_d_asset][:three_d_parameters][:highlight_edges] == 'true'
        end
        params.require(:gym_three_d_asset).permit(
          :name,
          :description,
          three_d_parameters: %i[color_correction_sketchup_exports highlight_edges]
        )
      end

      def gym_asset_picture_params
        params.require(:gym_three_d_asset).permit(:picture)
      end
    end
  end
end
