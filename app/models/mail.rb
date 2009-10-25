class Mail < ActiveRecord::Base

  def initialize(options = {})
    super(nil)
    self.sender = options[:sender]
    self.subject = options[:subject]
    self.body = options[:body]
  end

  validates_presence_of   :subject
  validates_presence_of   :body
  validates_presence_of   :sender_id

  belongs_to :sender, :class_name => 'User'

  has_many :recipients
  has_many :users, :through => :recipients, :uniq => true

  with_options :through => :recipients, :source => :user do |obj|
    obj.has_many :recipients_to_send, :conditions => "recipients.sent = 0"
    obj.has_many :recipients_sent, :conditions => "recipients.sent = 1"
  end
  
end
