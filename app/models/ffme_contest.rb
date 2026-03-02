# frozen_string_literal: true

class FfmeContest < ApplicationRecord
  belongs_to :contest
  has_one :gym, through: :contest

  before_validation :set_attributes

  STATUS_LIST = %w[draft create_on_my_compet result_sent result_resent].freeze
  CONTEST_TYPES_LIST = %w[boulder sport_climbing speed_climbing combined].freeze

  validates :name, :contact_email, presence: true
  validates :status, inclusion: { in: STATUS_LIST }
  validates :contest_type, inclusion: { in: CONTEST_TYPES_LIST }
  after_save :delete_caches
  after_destroy :delete_caches

  def summary_to_json
    {
      id: id,
      contest_id: contest_id
    }
  end

  def detail_to_json
    summary_to_json.merge(
      {
        status: status,
        contest_type: contest_type,
        name: name,
        description: description,
        start_date: start_date,
        end_date: end_date,
        contact_email: contact_email,
        contact_phone: contact_phone,
        min_send_date: min_send_date,
        max_send_date: max_send_date,
        sendable: sendable?
      }
    )
  end

  def ffme_contest_type
    labels = {
      boulder: 'BLOC',
      sport_climbing: 'DIFFICULTE',
      speed_climbing: 'VITESSE',
      combined: 'COMBINE,'
    }
    labels[contest_type&.to_sym]
  end

  def delete_caches
    contest.delete_summary_cache
  end

  def create_on_my_compet!
    resp = MyCompet.create_contest self
    self.external_ffme_contest_id = resp['idFFME']
    self.status = 'create_on_my_compet'
    save
  end

  def update_on_my_compet!
    MyCompet.update_contest self
    save
  end

  def link_on_my_compet
    MyCompet.link self
  end

  def min_send_date
    start_date
  end

  def max_send_date
    end_date.next_occurring :tuesday
  end

  def sendable?
    Time.current.between?(min_send_date.beginning_of_day, max_send_date.beginning_of_day)
  end

  def send_results!
    MyCompet.send_results self
    self.results_send_at = Time.zone.now
    self.status = status == 'result_sent' ? 'result_resent' : 'result_sent'
    save
  end

  private

  def set_attributes
    self.status ||= 'draft'
  end
end
