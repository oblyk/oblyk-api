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

### Elastic Search
```ruby
Crag.__elasticsearch__.create_index! force: true
Crag.import
Crag.__elasticsearch__.refresh_index!

CragSector.__elasticsearch__.create_index! force: true
CragSector.import
CragSector.__elasticsearch__.refresh_index!

CragRoute.__elasticsearch__.create_index! force: true
CragRoute.import
CragRoute.__elasticsearch__.refresh_index!

GuideBookPaper.__elasticsearch__.create_index! force: true
GuideBookPaper.import
GuideBookPaper.__elasticsearch__.refresh_index!

Area.__elasticsearch__.create_index! force: true
Area.import
Area.__elasticsearch__.refresh_index!

Gym.__elasticsearch__.create_index! force: true
Gym.import
Gym.__elasticsearch__.refresh_index!

Word.__elasticsearch__.create_index! force: true
Word.import
Word.__elasticsearch__.refresh_index!

User.__elasticsearch__.create_index! force: true
User.import
User.__elasticsearch__.refresh_index!
```

Recreate feeds :
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
systemctl status elasticsearch.service
systemctl status mysql.service
```
