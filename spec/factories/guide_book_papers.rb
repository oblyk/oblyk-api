# frozen_string_literal: true

FactoryBot.define do
  factory :guide_book_paper do
    name { 'Escalade en Drôme Provençale Sud' }
    author { 'Collectif CD FFME 26' }
    editor { 'FFME' }
    publication_year { 2011 }
    price_cents { 2000 }
    number_of_page { 310 }
    weight { 700 }
  end
end
