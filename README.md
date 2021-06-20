# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


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
