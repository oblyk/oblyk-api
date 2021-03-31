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

Todo migration des tables :
- [x] articles
- [x] approaches
- [x] comments
- [x] conversations
- [X] conversation_users
- [X] messages
- [x] crags
- [ ] ascents (old crosses)
- [x] user_ascents
- [x] alerts (old exceptions)
- [x] follows
- [x] links
- [x] area (old massives)
- [x] area_crag (old massive_crags)
- [x] parkings
- [x] crag_routes
- [x] crag_sectors
- [x] subscribes
- [x] tags
- [x] tick_lists
- [x] guide_book_papers
- [x] guide_book_paper_crags
- [x] guide_book_pdfs
- [x] guide_book_webs
- [x] users
- [x] videos
- [x] photos
- [x] words

Gym :
- [x] gym_administrators
- [x] gym_grade_lines
- [x] gym_grades
- [x] gym_rooms
- [x] gym_routes
- [x] gym_sectors
- [x] gyms

Gym later :
- [ ] contest_routes
- [ ] contest_users
- [ ] contests

Feed :
- Oblyk
  - [x] Article
- community
  - [x] crags added
  - [x] alerts added
  - [x] crag_routes added
  - [x] gyms added
  - [x] photos added
  - [x] videos created
  - [x] guide book paper added
  - [x] guide book pdf added
  - [x] guide book web added
  - [x] word
- around
  - [ ] alerts posted
  - [ ] crags, routes, gyms, etc. if not community
- follower
  - [x] subscribers ascents added
  
Notification :
- [ ] New conversation
- [ ] New message
- [ ] New follower
