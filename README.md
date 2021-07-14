# Oblyk API | Climbing Community API   

# Dependencies

- ruby 2.6.5
- bundle >= 2.0.0
- docker >= 20.10
    - docker-compose >= 1.25

# Installation
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

# Launch Oblyk rails server
```shell
bundle exec rails s
```
Go to [localhost:3000](http://localhost:3000)  
Enjoy !

### Index search value
Add `RAILS_ENV=production` before bundle if in production environment
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
```shell
# development environment
bundle exec rails c

# Production environment
RAILS_ENV=production bundle exec rails c
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

# Server

Check oblyk service
```shell
systemctl status nginx
systemctl status redis
systemctl status mysql.service
```
