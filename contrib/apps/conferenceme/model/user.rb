class User < Sequel::Model
  set_schema do
    primary_key :id

    varchar :login, :unique => true
    varchar :digest
    varchar :openid, :unique => true
    varchar :email, :unique => true
  end

  create_table!

  def self.authenticate(hash)
    login, pass, digest, openid =
      hash.values_at('login', 'pass', 'digest', 'openid')

    if pass and login
      self[:pass => digestify(pass), :login => login]
    elsif digest and login
      self[:digest => digest, :login => login]
    elsif openid
      self[:openid => openid]
    end
  end
end
