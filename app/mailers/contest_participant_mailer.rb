# frozen_string_literal: true

class ContestParticipantMailer < ApplicationMailer
  layout 'contest_mailer'

  def subscribe
    @contest_participant = params[:contest_participant]
    to = @contest_participant.email
    subject = "#{@contest_participant.contest.name}, votre inscription"
    if use_send_in_blue?
      send_with_send_in_blue(to, subject, 'contest_participant_mailer/subscribe')
    else
      mail(to: to, subject: subject)
    end
  end
end
