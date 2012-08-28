class Micropost < ActiveRecord::Base
  # attr_writer :in_reply_to
  @@reply_to_regexp = /\A@([^\s]*)/

  attr_accessible :content, :in_reply_to
  belongs_to :user
  belongs_to :in_reply_to, class_name: "User"
  
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true

  default_scope order: 'microposts.created_at DESC'
  before_save :extract_in_reply_to

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

def extract_in_reply_to
  if match = @@reply_to_regexp.match(content)
    user = User.find_by_shorthand(match[1])
    self.in_reply_to = user if user
  end
end


end
