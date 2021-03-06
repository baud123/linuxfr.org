# encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id            :integer(4)      not null, primary key
#  name          :string(32)
#  homesite      :string(100)
#  jabber_id     :string(32)
#  cached_slug   :string(32)
#  created_at    :datetime
#  updated_at    :datetime
#  gravatar_hash :string(32)
#  avatar        :string(255)
#  signature     :string(255)
#


# The users are the public informations about the people who create contents.
# See accounts for the private ones, like authentication.
#
class User < ActiveRecord::Base
  has_one  :account, :dependent => :destroy, :inverse_of => :user
  has_many :nodes, :inverse_of => :user
  has_many :diaries, :dependent => :destroy, :inverse_of => :owner, :foreign_key => "owner_id"
  has_many :news_versions, :dependent => :nullify
  has_many :wiki_versions, :dependent => :nullify
  has_many :comments, :inverse_of => :user
  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :uniq => true

  attr_accessible :name, :homesite, :jabber_id, :signature, :avatar, :remove_avatar, :remote_avatar_url, :gravatar_hash

### SEO ###

  extend FriendlyId
  friendly_id :login

  def login
    account ? account.login : name
  end

  def name=(name)
    super name.present? ? name : account.login
  end

### Avatar ###

  mount_uploader :avatar, AvatarUploader

end
