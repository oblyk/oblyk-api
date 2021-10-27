# frozen_string_literal: true

FactoryBot.define do
  factory :guide_book_web do
    name { 'Fiche FFME Rocher des aures' }
    url { 'https://www.ffme.fr/sne-fiche/238/' }
    crag
  end
end
