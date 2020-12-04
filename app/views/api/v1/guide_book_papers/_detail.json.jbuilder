# frozen_string_literal: true

json.extract! guide_book_paper,
              :name,
              :author,
              :editor,
              :publication_year,
              :price_cents,
              :ean,
              :vc_reference,
              :number_of_page,
              :weight
json.cover guide_book_paper.cover.attached? ? url_for(guide_book_paper.cover) : nil
json.crags do
  json.array! guide_book_paper.crags do |crag|
    json.extract! crag, :id, :name
  end
end
json.creator do
  json.id guide_book_paper.user_id
  json.name guide_book_paper.user&.full_name
end
json.history do
  json.extract! guide_book_paper, :created_at, :updated_at
end
