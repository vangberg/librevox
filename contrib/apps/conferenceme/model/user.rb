class User < Sequel::Model
  set_schema do
    primary_key :id

    varchar :login, :unique => true
    varchar :nick, :unique => true
    varchar :digest
    varchar :openid, :unique => true
    varchar :email, :unique => true
  end

  create_table!

  attr_accessor :pass

  def self.authenticate(hash)
    login, pass, digest, openid =
      hash.values_at('login', 'pass', 'digest', 'openid')

    if pass and login
      self[:digest => digestify(pass), :login => login]
    elsif digest and login
      self[:digest => digest, :login => login]
    elsif openid
      self[:openid => openid]
    end
  end

  def self.prepare(hash)
    login, email, pass, pass_confirmation =
      hash.values_at('login', 'email', 'pass', 'pass_confirmation')

    instance = new(:login => login, :email => email, :digest => digestify(pass))

    # they are only used for validation
    instance.pass_confirmation = pass_confirmation
    instance.pass = pass

    instance
  end

  def self.digestify(password)
    Digest::SHA1.hexdigest(password.to_s)
  end

  attr_accessor :pass, :pass_confirmation

  validations.clear
  validates do
    uniqueness_of :login, :nick, :email, :openid
    format_of :login, :with => /\A[\w.]+\z/
    length_of :login, :within => 3..255

    format_of :email, :with => /\A.+@.+\..+\Z/ # KISS
    length_of :email, :within => 5..255

    confirmation_of :pass
    length_of :pass, :within => 6..255
  end
end
