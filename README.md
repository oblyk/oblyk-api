# Oblyk API | Climbing Community API   

Oblyk is an open-source community website dedicated to climbing. It aims to build a large open-data database of cliffs, routes and climbing gyms in France and around the world that can be freely consulted via an API. Climbers can also use this tool to rate their crosses or find climbing partners.

This repository is the API part of Oblyk project.  
For front app, go here : [oblyk-app](https://github.com/oblyk/oblyk-app) 

## Dependencies

- ruby 2.6.5
- bundle >= 2.0.0
- docker >= 20.10
    - docker-compose >= 1.25

## Installation
```shell
# Clone project
git clone git@github.com:oblyk/oblyk-api.git

# Go to project folder
cd oblyk-api

# Install gem
bundle

# Copy example local_env.yml 
cp config/local_env.example.yml config/local_env.yml

# Up docker
docker-compose up -d

# Create oblyk_development database
bundle exec rails db:setup
```

## Launch Oblyk rails server
```shell
bundle exec rails s
```
Go to [localhost:3000](http://localhost:3000)  
Enjoy !


## Create your organization for set yours API private key
First open rails console
```shell
bundle exec rails c
```
End create your organization
```ruby
my_organization = Organization.new name: 'My Awesome Organization', email: 'my@email.com', api_usage_type: 'personal'
my_organization.save
my_organization.api_access_token
# => vvPpFZhg....
# You can use this token in HttpApiAccessToken header
```

## Run sidekiq
Sidekiq si job system, start it to unstack the background tasks
```shell
bundle exec sidekiq
```
Go to [localhost:3000](http://localhost:3000/sidekiq) to see the monitor.  
Sidekiq user and password is configured in `config/local_env.yml`

## Helpers

### Recreate the search base
```shell
bundle exec rake search_tasks:import["Crag"]
bundle exec rake search_tasks:import["CragRoute"]
bundle exec rake search_tasks:import["GuideBookPaper"]
bundle exec rake search_tasks:import["Area"]
bundle exec rake search_tasks:import["Gym"]
bundle exec rake search_tasks:import["Word"]
bundle exec rake search_tasks:import["User"]
```

### Recreate feeds
_(sidekiq must be started)_

Open rails console
```shell
bundle exec rails c
```

```ruby
Crag.all.find_each(&:save_feed!)
CragRoute.all.find_each(&:save_feed!)
Alert.all.find_each(&:save_feed!)
Gym.all.find_each(&:save_feed!)
GuideBookPaper.all.find_each(&:save_feed!)
GuideBookPdf.all.find_each(&:save_feed!)
GuideBookWeb.all.find_each(&:save_feed!)
Word.all.find_each(&:save_feed!)
Video.all.find_each(&:save_feed!)
Photo.all.find_each(&:save_feed!)
AscentCragRoute.all.find_each(&:save_feed!)
Article.all.find_each(&:save_feed!)
```
