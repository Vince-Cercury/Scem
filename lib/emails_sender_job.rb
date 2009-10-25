# To change this template, choose Tools | Templates
# and open the template in the editor.

class EmailsSenderJob < Struct.new(:mail_id)
  def perform

    mail = Mail.find(mail_id)
    

    mail.recipients_to_send.each do |a_user|
      
      UserMailer.deliver_simple_email(a_user.email, mail.sender.email, mail.subject, mail.body)
     
      #once the email has been sent, we can set the recipient has sent
      recipient = Recipient.find_by_user_id_and_mail_id(a_user.id, mail_id)
      
      recipient.sent = true
      recipient.save
    end

  end
end
