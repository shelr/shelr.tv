require 'digest/md5'
require 'securerandom'

class User

  include Mongoid::Document
  include Mongoid::Timestamps

  field :email,              type: String,  unique: true
  field :nickname,           type: String,  unique: false
  field :records_count,      type: Integer, default: 0
  field :api_key,            type: String,  unique: true
  field :twitter_name,       type: String,  unique: false
  field :twitter_uid,        type: String,  unique: true, allow_nil: true
  field :github_name,        type: String,  unique: false
  field :github_uid,         type: String,  unique: true, allow_nil: true
  field :google_oauth2_name, type: String,  unique: false
  field :google_oauth2_uid,  type: String,  unique: true, allow_nil: true
  field :open_id_name,       type: String,  unique: false
  field :open_id_uid,        type: String,  unique: true, allow_nil: true
  field :atom_key,           type: String,  unique: true, allow_nil: true
  field :website,            type: String
  field :bitcoin,            type: String
  field :about,              type: String
  field :god,                type: Boolean, default: false

  attr_accessible :nickname, :email, :website, :about, :bitcoin

  validates_uniqueness_of :api_key, :twitter_uid, :github_uid, :google_oauth2_uid, :open_id_uid, allow_nil: true

  validates_length_of :nickname, maximum: 20

  has_many :records
  has_many :comments

  before_create :maybe_assign_nickname_placeholder
  after_create :generate_api_key!

  def owner
    self
  end

  def editable_by?(user)
    return false if user.blank?
    return true  if user.god?
    self.id == user.id
  end

  def generate_api_key
    self.api_key = Digest::MD5.hexdigest(self.id.to_s + rand.to_s + Time.now.to_s)
  end

  def generate_api_key!
    generate_api_key && save
  end

  def maybe_assign_nickname_placeholder
    self.nickname = 'noname' if nickname.blank?
  end

  def comments_for_records
    comments = records.map(&:comments).flatten.compact.sort! { |a, b| b.updated_at <=> a.updated_at }
  end

  def atom_key
    if read_attribute(:atom_key).blank?
      hex_size = 16
      _atom_key = SecureRandom.hex(hex_size)

      while User.where(atom_key: _atom_key).present?
        _atom_key = SecureRandom.hex(hex_size)
      end

      self.atom_key = _atom_key
      save
    end

    read_attribute(:atom_key)
  end
end
