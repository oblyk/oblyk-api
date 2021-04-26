
# Import order and todo list

## TODO before import

- down oblyk.org
- get public storage

## Deactivate concern

```ruby
include GapGradable
include Searchable
include ActivityFeedable
after_save :update_crag_route
```

## Tables

- [x] users `bundle exec rake import:users["development","/home/lucien/Documents/oblyk/public"]`
- [x] subscribes `bundle exec rake import:subscribes["development"]`
----
- [x] conversations `bundle exec rake import:conversations["development"]`
- [x] conversation_users `bundle exec rake import:conversation_users["development"]`
- [X] conversation_messages `bundle exec rake import:conversation_messages["development"]`
----
- [x] words `bundle exec rake import:words["development"]`
----
- [x] crags `bundle exec rake import:crags["development"]`
- [x] crag_sectors `bundle exec rake import:crag_sectors["development"]`
- [x] crag_routes `bundle exec rake import:crag_routes["development"]`
- [x] parks `bundle exec rake import:parks["development"]`
- [x] approaches `bundle exec rake import:approaches["development"]`
- [x] areas `bundle exec rake import:areas["development"]`
- [x] area_crags `bundle exec rake import:area_crags["development"]`
----
- [x] ascents `bundle exec rake import:ascents["development"]`
- [x] tick_lists `bundle exec rake import:tick_lists["development"]`
- [x] ascent_users `bundle exec rake import:ascent_users["development"]`
----
- [x] comments `bundle exec rake import:comments["development"]`
- [x] links `bundle exec rake import:links["development"]`
- [x] follows `bundle exec rake import:follows["development"]`
- [x] alerts `bundle exec rake import:alerts["development"]`
----  
- [x] guide_book_webs `bundle exec rake import:guide_book_webs["development"]`
- [x] guide_book_pdfs `bundle exec rake import:guide_book_pdfs["development","/home/lucien/Documents/oblyk/public"]`
- [x] guide_book_papers `bundle exec rake import:guide_book_papers["development","/home/lucien/Documents/oblyk/public"]`
- [x] guide_book_paper_crags `bundle exec rake import:guide_book_paper_crags["development"]`
- [x] place_of_sales `bundle exec rake import:place_of_sales["development"]`
----
- [x] videos `bundle exec rake import:videos["development"]`
- [x] photos `bundle exec rake import:photos["development","/home/lucien/Documents/oblyk/public"]`
---
- [x] gyms `bundle exec rake import:gyms["development","/home/lucien/Documents/oblyk/public"]`
- [x] gym_administrators `bundle exec rake import:gym_administrators["development"]`
- [x] gym_grades `bundle exec rake import:gym_grades["development"]`
- [x] gym_grade_lines `bundle exec rake import:gym_grade_lines["development"]`
- [x] gym_spaces `bundle exec rake import:gym_spaces["development","/home/lucien/Documents/oblyk/public"]`
- [x] gym_sectors `bundle exec rake import:gym_sectors["development"]`

### function after import
- [x] refresh crag data `bundle exec rake refresh_data:crag`
- [x] refresh crag sector data `bundle exec rake refresh_data:crag_sector`
- [ ] refresh crag route data `bundle exec rake refresh_data:crag_route`
- [ ] refresh counters cache (see `reset_counters_cache` task)
