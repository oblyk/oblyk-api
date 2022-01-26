# frozen_string_literal: true

class Report < ApplicationRecord
  include StripTagable

  belongs_to :user, optional: true
  belongs_to :reportable, polymorphic: true

  REPORTABLE_LIST = %w[
    Approach
    Area
    Crag
    CragSector
    CragRoute
    GuideBookPaper
    GuideBookPdf
    GuideBookWeb
    Comment
    Link
    Gym
    Photo
    Park
    PlacesOfSales
    Video
    Word
    User
    Organization
  ].freeze

  validates :reportable_type, inclusion: { in: REPORTABLE_LIST }

  after_create :send_email_notification

  private

  def send_email_notification
    ReportMailer.with(
      report_id: id,
      body: body,
      reportable_type: reportable_type,
      reportable_id: reportable_id,
      report_from_url: report_from_url,
      user_full_name: user&.full_name,
      user_id: user&.id
    ).new_report.deliver_later
  end
end
