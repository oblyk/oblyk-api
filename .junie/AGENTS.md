# AGENTS.md — Oblyk API Development Guide

This document contains key instructions, configuration details, testing procedures, and development conventions specific to the `oblyk-api` repository.

---

## 1. Tech Stack & Environment

- **Framework**: Ruby on Rails 8.1.3.1 (API mode)
- **Ruby Version**: `3.4.10` (managed via `rbenv`)
- **Database**: MySQL 8.0 (default local port `13306`)
- **Cache / Background Jobs**: Redis 8.0.2 (port `16379`) & Sidekiq
- **Search Engine**: Meilisearch (port `17700`)
- **Test Framework**: Minitest (`ActionDispatch::IntegrationTest`, `ActiveSupport::TestCase`)
- **Code Coverage**: SimpleCov (configured in `test/test_helper.rb`)
- **Linter & Security**: RuboCop (Rails Omakase), Brakeman, Bundler-Audit

---

## 2. Build & Configuration Instructions

### Prerequisites
- `rbenv` with Ruby `3.4.10` installed
- `docker` and `docker-compose`
- `libvips` >= 8.13

### Setup Steps

1. **Ruby Environment**:
   Ensure `3.4.10` is selected:
   ```bash
   rbenv local 3.4.10
   ```
   *Note*: When running commands in non-interactive shells or automated agent environments, prefix bundle/rails commands with `rbenv exec`:
   ```bash
   rbenv exec bundle install
   ```

2. **Environment Variables**:
   Copy and adjust local environment settings:
   ```bash
   cp config/local_env.example.yml config/local_env.yml
   ```

3. **Start Required Infrastructure**:
   Launch MySQL, Redis, and Meilisearch via Docker:
   ```bash
   docker compose up -d
   ```

4. **Database Initialization**:
   Create and seed development and test databases:
   ```bash
   rbenv exec bundle exec rails db:setup
   ```

5. **Start Application Services**:
   - Rails API Server:
     ```bash
     rbenv exec bundle exec rails s
     ```
   - Sidekiq Worker:
     ```bash
     rbenv exec bundle exec sidekiq
     ```

6. **Search Index Initialization (Meilisearch)**:
   In a Rails console (`rbenv exec bundle exec rails c`):
   ```ruby
   [GuideBookPaper, Area, Gym, Word, User].each(&:ms_reindex!)
   Crag.includes(:areas).ms_reindex!
   CragRoute.joins(:crag, :crag_sector).includes(:crag, :crag_sector).ms_reindex!
   Town.includes(:department).ms_reindex!
   ```

---

## 3. Testing Information

### Test Runner Configuration
- Tests run using Minitest and Rails test runner.
- Multi-process parallelization is enabled by default (`5` workers via `PARALLEL_WORKERS`). You can override this using `PARALLEL_WORKERS=1` or `TEST_NUMBER_OF_PROCESSORS=1`.
- SimpleCov measures coverage across models, controllers, serializers, services, jobs, mailers, and helpers. Reports are saved in `coverage/index.html` and `coverage/coverage.json`.

### Rule and prohibition
- Never modify, create, or delete any files other than those in the `test/` folder
- Stop as requested in the prompt and do not attempt to update the branch on Git

### Executing Tests
Always prefer running targeted tests instead of the entire suite:

- **Single Test File**:
  ```bash
  rbenv exec bundle exec rails test test/controllers/api/v1/crags_controller_test.rb
  ```

- **Single Test Case by Line Number**:
  ```bash
  rbenv exec bundle exec rails test test/controllers/api/v1/crags_controller_test.rb:18
  ```

- **Single Model Test**:
  ```bash
  rbenv exec bundle exec rails test test/models/crag_test.rb
  ```

### Writing New Tests

#### 1. Integration / Controller Tests
- Inherit from `ActionDispatch::IntegrationTest` within the `Api::V1` namespace.
- Always use the `AuthHelper` methods (`api_headers` or `api_access_token_headers`).
- Send and receive JSON exclusively (`as: :json`, `response.parsed_body`).

```ruby
# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class CragsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @crag = crags(:rocher_des_aures)
        @user_headers = api_headers(user: :normal_user)
      end

      test "should get show" do
        get api_v1_crag_url(@crag), headers: @user_headers
        assert_response :success
        json = response.parsed_body
        assert_equal @crag.id, json["id"]
      end
    end
  end
end
```

#### 2. Model Tests
- Inherit from `ActiveSupport::TestCase`.
- Fixtures are preloaded alphabetically (`test/fixtures/*.yml`).
- Test validations, associations, custom scopes, and model methods.

```ruby
# frozen_string_literal: true

require "test_helper"

class CragTest < ActiveSupport::TestCase
  setup do
    @crag = crags(:rocher_des_aures)
  end

  test "crag is valid" do
    assert_predicate @crag, :valid?
  end

  test "crag is invalid without name" do
    @crag.name = nil
    assert_predicate @crag, :invalid?
    assert_includes @crag.errors[:name], "is_mandatory"
  end
end
```

### Coverage Guidelines
- **Target Coverage**: >= 98% on new features; >= 90% on modified models and controllers.
- Check uncovered lines in `coverage/coverage.json` after running tests.

---

## 4. Additional Development Information & Conventions

### Code Style & Linting
- Always include `# frozen_string_literal: true` at the top of Ruby source files.
- Run RuboCop to inspect code style:
  ```bash
  rbenv exec bundle exec rubocop
  ```
- Run full CI checks locally:
  ```bash
  rbenv exec bundle exec rails test
  rbenv exec bundle exec rubocop
  rbenv exec bundle exec brakeman --quiet --no-pager
  ```

### Authentication Architecture
- API endpoints authenticate requests through two headers:
  - `Authorization`: Bearer JWT token generated via `JwtToken::Token.generate(user_data, exp)`.
  - `HttpApiAccessToken`: Organization API access token (e.g., `organizations(:oblyk_orga).api_access_token`).
- In tests, use `api_headers(user: :user_fixture_name, organization: :org_fixture_name)`.

### Debugging & Useful Commands
- **Generate Organization API Token (Console)**:
  ```ruby
  org = Organization.create!(name: "Test Org", email: "test@org.com", api_usage_type: "personal")
  org.api_access_token
  ```
- **Generate User JWT Token (Console)**:
  ```ruby
  user = User.first
  user_data = user.as_json(only: %i[id first_name last_name])
  exp = Time.now.to_i + Rails.application.config.jwt_session_lifetime
  JwtToken::Token.generate(user_data, exp)
  ```
- **Inspect SQL Queries**: Set `LOG_LEVEL: 'debug'` in `config/local_env.yml` or run `ActiveRecord::Base.logger = Logger.new(STDOUT)` in console.
