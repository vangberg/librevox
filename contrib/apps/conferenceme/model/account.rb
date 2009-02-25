class User < Sequel::Model
  set_schema do
    primary_key :id

    varchar :login, :unique => true
    varchar :pass
    varchar :openid, :unique => true

    time :created_at
  end

  create_table!

  def self.authenticate(hash)
    if pass = hash['pass']
      self[:pass => digestify(pass), :login => login]
    elsif openid = hash['openid']
      self[:openid => openid]
    end
  end

  def self.digestify(pass)
    Digest::SHA1.hexdigest(pass.to_s)
  end
end
