# frozen_string_literal: true

json.array! @users do |user|
  json.extract! user, :uuid, :first_name, :last_name, :slug_name, :date_of_birth, :genre, :description
end
