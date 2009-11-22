class MailingsController < ApplicationController

  def prep_to_members
    @organism = Organism.find(params[:organism_id])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def send_to_members
    organism = Organism.find(params[:id])
    mail = Mail.new(:sender => current_user, :subject => "#{organism.name} - "+ params[:subject], :body => params[:message])

    if params[:to_admins] && params[:to_admins] == "1"
      organism.admins.each do |user|
        recipient = Recipient.new
        recipient.user = user
        mail.recipients << recipient
      end
    end

    if params[:to_moderators] && params[:to_moderators] == "1"
      organism.moderators.each do |user|
        recipient = Recipient.new
        recipient.user = user
        mail.recipients << recipient
      end
    end

    if params[:to_members] && params[:to_members] == "1"
      organism.members.each do |user|
        recipient = Recipient.new
        recipient.user = user
        mail.recipients << recipient
      end
    end

    if(mail.save!)
      Delayed::Job.enqueue(EmailsSenderJob.new(mail.id),2)
      flash[:notice] = I18n.t('organisms.mailing.Successfully_sent')
      respond_to do |format|
        format.html { redirect_to(organism) }
        format.xml  { head :ok }
      end
    end
  end

end
