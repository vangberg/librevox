class AuthController < Controller
  map '/auth'
  helper :simple_captcha, :identity

  def index
    redirect_referer if request.referer =~ /\/auth\/\w+$/
    redirect Rs(:login)
  end

  def new
    redirect_referrer if logged_in?
    @user = User.prepare(request.params)
    # they will be used in the form
    @login, @email = @user.login, @user.email

    return unless request.post?

    unless valid_captcha = check_captcha(request[:captcha])
      form_error('captcha', "Wrong answer")
    end

    unless valid_tos = request['tos'] == 'on'
      form_error('tos', "Terms of Service not accepted")
    end

    if @user.valid? and valid_captcha and valid_tos and @user.save
      flash[:good] = "You signed up, welcome on board #{@user.login}!"
      user_login('login' => @user.login, 'digest' => @user.digest)
      answer R(ProfileController, @user.login)
    else
      form_errors_from_model(@user)
    end
  end

  def login
    redirect_referrer if logged_in?
    push request.referrer unless inside_stack?

    if request[:fail] == 'session'
      flash[:ERROR] =
        'Failed to login, please make sure you have cookies enabled for this site'
    end

    return unless request.post?

    if user_login(request.params)
      flash[:good] = "Welcome back #{user.login}"
      answer Rs(:after_login)
    else
      flash[:error] = "Login or password is wrong"
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
      flash[:ERROR] = 'There exists more than one user with this email address'
      # This is very bad... duplicate email addresses
    elsif user = users.first
      send_forgot_email(user)
      flash[:good] = "We sent you some information to recover your password, please check your inbox."
      redirect R(Main, :/)
    else
      flash[:ERROR] = 'No user with this address found'
    end

    redirect Rs(:forgot)
  end

  def recover(login, hash)
    redirect_referrer if logged_in?

    user = User[:login => login, :digest => hash]

    if user
      user_login('login' => user.login, 'digest' => user.digest)
      user.recovery = nil
      user.save!
      flash[:good] = "We log you in this one time, change your password as soon as possible"
      redirect R(Users, :edit)
    else
      flash[:ERROR] = "Is it a bird? Is it a plane? No, it's a failed password recovery!"
    end

    redirect Rs(:forgot)
  end

  private

  def openid_finalize
    if user_login('openid' => @oid)
      flash[:good] = flash[:success]
      answer R('/')
    else
      flash[:ERROR] = "None of our users belongs to this OpenID"
    end
  end
end
