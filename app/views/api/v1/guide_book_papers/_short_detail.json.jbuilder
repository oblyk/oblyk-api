# frozen_string_literal: true

json.extract! guide_book_paper,
              :id,
              :name,
              :slug_name,
              :author,
              :editor,
              :publication_year,
              :price_cents,
              :ean,
              :vc_reference,
              :number_of_page,
              :weight
json.price guide_book_paper.price_cents ? guide_book_paper.price_cents / 100 : nil
json.cover guide_book_paper.cover.attached? ? url_for(guide_book_paper.cover) : nil
# json.cover guide_book_paper.cover.attached? ? guide_book_paper.thumbnail_url : nil
