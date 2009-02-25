class Auth < Controller
  helper :simple_captcha, :identity

  def new
    redirect_referrer if logged_in?
    @user = User.prepare(request.params)
    # they will be used in the form
    @login, @email = @user.login, @user.email

    if request.post?
      redirect_referrer unless check_captcha(request[:captcha])
      if @user.save
        flash[:good] = "You signed up, welcome on board #{@user.login}!"
        user_login('login' => @user.login)
        answer R(ProfileController, @user.login)
      end
    end
  end

  def login
    redirect_referrer if logged_in?
    push request.referrer unless inside_stack?

    case request[:fail]
    when 'session'
      flash[:bad] =
        'Failed to login, please make sure you have cookies enabled for this site'
    end

    return unless request.post?

    if user_login
      flash[:good] = "Welcome back #{user.login}"
      answer Rs(:after_login)
    end
  end

  def openid
    redirect_referrer if logged_in?

    @oid = session[:openid_identity]
    @url = request[:url] || @oid

    if @oid
      openid_finalize
    elsif request.post?
      openid_begin
    else
      flash[:bad] = flash[:error] || "Bleep"
    end
  end

  # This method is simply to check whether we really did login and the browser
  # sends us a cookie, if we're not logged in by now it would indicate that the
  # client doesn't support cookies or has it disabled and so unable to use this
  # site.
  # For some reason, the arora seems to have problems handling cookies on
  # localhost from rack.
  def after_login
    if logged_in?
      answer('/')
    else
      redirect Rs(:login, :fail => :session)
    end
  end

  def logout
    user_logout

    [:openid, :openid_identity, :openid_sreg].each do |sym|
      session.delete(sym)
    end

    flash[:good] = "You logged out successfully"

    redirect R(:/)
  end

  def forgot
    redirect_referrer if logged_in?

    return unless request.post?

    user = User[:email => @email]

    if users.size > 1
      flash[:bad] = 'There exists more than one user with this email address'
      # This is very bad... duplicate email addresses
    elsif user = users.first
      send_forgot_email(user)
      flash[:good] = "We sent you some information to recover your password, please check your inbox."
      redirect R(Main, :/)
    else
      flash[:bad] = 'No user with this address found'
    end

    redirect Rs(:forgot)
  end

  def recover(nick, hash)
    redirect_referrer if logged_in?

    users = User.view_docs(:recover, :key => [nick, hash])

    if users.size > 1
      flash[:bad] = "Something went terribly wrong!"
    elsif user = users.first
      user_login('nick' => user.nick, 'digest' => user.digest)
      user.recovery = nil
      user.save!
      flash[:good] = "We log you in this one time, change your password as soon as possible"
      redirect R(Users, :edit)
    else
      flash[:bad] = "Is it a bird? Is it a plane? No, it's a failed password recovery!"
    end

    redirect Rs(:forgot)
  end

  private

  def openid_finalize
    if user_login('openid' => @oid)
      flash[:good] = flash[:success]
      answer R('/')
    else
      flash[:bad] = "None of our users belongs to this OpenID"
    end
  end
end
