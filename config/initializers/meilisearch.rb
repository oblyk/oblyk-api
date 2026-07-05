# frozen_string_literal: true

MeiliSearch::Rails.configuration = {
  meilisearch_url: ENV.fetch('MEILISEARCH_HOST', 'http://localhost:17700'),
  meilisearch_api_key: ENV.fetch('MEILISEARCH_API_KEY', 'YourMeilisearchAPIKey'),
  pagination_backend: :kaminari,
  per_environment: true
}
