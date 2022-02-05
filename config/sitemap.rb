# frozen_string_literal: true

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV['OBLYK_APP_URL']
SitemapGenerator::Sitemap.compress = false

# possible changefreq : 'always', 'hourly', 'daily', 'weekly', 'monthly', 'yearly' or 'never'

SitemapGenerator::Sitemap.create do
  # Main page
  add '/api-and-developers', priority: 1, changefreq: 'yearly'
  add '/about/partner-search', priority: 1, changefreq: 'yearly'
  add '/grades', priority: 1, changefreq: 'yearly'
  add '/about', priority: 0.8, changefreq: 'yearly'
  add '/library', priority: 0.8, changefreq: 'monthly'
  add '/guide-book-papers/find', priority: 0.6, changefreq: 'yearly'
  add '/support-us', priority: 0.6, changefreq: 'yearly'
  add '/contact', priority: 0.4, changefreq: 'yearly'
  add '/helps', priority: 0.2, changefreq: 'yearly'
  add '/newsletters/subscribe', priority: 0.2, changefreq: 'yearly'

  # Maps
  add '/maps/crags', priority: 0.6, changefreq: 'weekly'
  add '/maps/gyms', priority: 0.6, changefreq: 'weekly'
  add '/maps/climbers', priority: 0.6, changefreq: 'weekly'

  # Session
  add '/sign-in', priority: 0, changefreq: 'never'
  add '/sign-up', priority: 0, changefreq: 'never'

  # Words
  group(sitemaps_path: 'sitemaps/', filename: :words) do
    add '/glossary', priority: 0.2, changefreq: 'monthly'
    Word.find_each do |word|
      add "/words/#{word.id}/#{word.slug_name}", lastmod: word.updated_at, priority: 0.8, changefreq: 'yearly'
    end
  end

  # Area
  group(sitemaps_path: 'sitemaps/', filename: :areas) do
    Area.find_each do |area|
      add "/areas/#{area.id}/#{area.slug_name}", lastmod: area.updated_at, priority: 0.4, changefreq: 'monthly'
    end
  end

  # Crags
  group(sitemaps_path: 'sitemaps/', filename: :crags) do
    Crag.find_each do |crag|
      add "/crags/#{crag.id}/#{crag.slug_name}", lastmod: crag.updated_at, priority: 1, changefreq: 'monthly'
    end
  end

  # Crag Sectors
  group(sitemaps_path: 'sitemaps/', filename: 'crag-sectors') do
    CragSector.find_each do |crag|
      add "/crag-sectors/#{crag.id}/#{crag.slug_name}", lastmod: crag.updated_at, priority: 0.2, changefreq: 'monthly'
    end
  end

  # Crag Routes
  group(sitemaps_path: 'sitemaps/', filename: 'crag-routes') do
    CragRoute.find_each do |crag_route|
      add "/crag-routes/#{crag_route.id}/#{crag_route.slug_name}", lastmod: crag_route.updated_at, priority: 0.8, changefreq: 'monthly'
    end
  end

  # Guide Book Papers
  group(sitemaps_path: 'sitemaps/', filename: 'guide-book-papers') do
    GuideBookPaper.find_each do |guide_book_paper|
      add "/guide-book-papers/#{guide_book_paper.id}/#{guide_book_paper.slug_name}", lastmod: guide_book_paper.updated_at, priority: 1, changefreq: 'monthly'
    end
  end

  # Gyms
  group(sitemaps_path: 'sitemaps/', filename: 'gyms') do
    Gym.find_each do |gym|
      add "/gyms/#{gym.id}/#{gym.slug_name}", lastmod: gym.updated_at, priority: 0.8, changefreq: 'monthly'
    end
  end

  # Articles
  group(sitemaps_path: 'sitemaps/', filename: 'articles') do
    add '/articles', priority: 0.8, changefreq: 'monthly'
    Article.find_each do |article|
      add "/articles/#{article.id}/#{article.slug_name}", lastmod: article.updated_at, priority: 1, changefreq: 'weekly'
    end
  end

  # Users
  group(sitemaps_path: 'sitemaps/', filename: 'users') do
    User.where(public_profile: true).find_each do |user|
      add "/users/#{user.uuid}/#{user.slug_name}", lastmod: user.updated_at, priority: 0.6, changefreq: 'monthly'
      add "/users/#{user.uuid}/#{user.slug_name}/ascents", lastmod: user.updated_at, priority: 0.6, changefreq: 'monthly' if user.public_outdoor_ascents
    end
  end
end
