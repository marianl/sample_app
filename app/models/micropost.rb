class Micropost < ActiveRecord::Base
  # attr_writer :in_reply_to
  @@reply_to_regexp = /\A@([^\s]*)/

  attr_accessible :content, :in_reply_to
  belongs_to :user
  belongs_to :in_reply_to, class_name: "User"
  
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
  #validates :in_reply_to, presence: true, :on => :create, :if => :reply_micropost?, :message => "Recipient doesn't exist."
  validates :in_reply_to, :presence => { :on => :create, :if => :reply_micropost?, :message => "Recipient doesn't exist" }
  validates :in_reply_length, :presence => { :on => :create, :if => :reply_micropost?, :message => "Reply content can't be blank" }
  default_scope order: 'microposts.created_at DESC'
  #before_save :extract_in_reply_to

  # Return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  # same, including replies.
  scope :from_users_followed_by_including_replies, lambda { |user| followed_by_including_replies(user) }

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user)
  end

  def self.followed_by_including_replies(user)
      followed_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
      where("user_id IN (#{followed_ids}) OR user_id = :user_id OR in_reply_to_id = :user_id",
            { :user_id => user })
    #followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    #where("user_id IN (#{followed_user_ids}) OR user_id = :user_id OR in_reply_to_id = :user_id", user_id: user)
  end

private

#def extract_in_reply_to
#  if match = @@reply_to_regexp.match(content)
#    user = User.find_by_shorthand(match[1])
#    self.in_reply_to = user if user
#    if user 
#      puts "-----------------------extract_in_reply_to match and user exists --------------------- "
#    else
#      puts "-----------------------extract_in_reply_to match and user doesn't exist --------------------- "
#    end
#  else
#    puts "-----------------------extract_in_reply_to not mach --------------------- "
#  end
#end

def reply_micropost?
  if match = @@reply_to_regexp.match(content)
    user = User.find_by_shorthand(match[1]) 
    
    self.in_reply_to = user if user
    if user
      reply_message = content.sub( '@' + match[1], '')
      reply_message.gsub!(/ /,'')
      if reply_message.empty?
        #puts "-----------------------reply_micropost? match and user exists ------REPLY_MESSAGE EMPTY -----*#{reply_message}*---- "
      else
        self.in_reply_length = content.length
        #puts "-----------------------reply_micropost? match and user exists ------REPLY_MESSAGE NOT EMPTY -----*#{reply_message}*---- "
      end 
    end
    true
  else
    false  
  end
end



end
