# frozen_string_literal: true

json.extract! guide_book_paper,
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
json.cover guide_book_paper.cover.attached? ? url_for(guide_book_paper.cover) : nil
