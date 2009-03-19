class MainController < Controller
  def about
    @title = "Welcome to ConfMe, The Conference Service that calls You!"
  end

  # the index action is called automatically when no other action is specified
  def index
    @title = "Welcome to ConfMe, The Conference Service that calls You!"
  end

  def start
    phone_number, caller_id = request[:phone_number, :caller_id]
    return unless phone_number and caller_id

    conference = next_conf
    @action_taken = "started"
    conference(conference, phone_number, caller_id)
  end

  def join(conference = nil)
    @conference = conference || request[:conference].to_s

    target = request[:phone_number].to_s

    return if target.empty?

    if conference_exists?(conference)
      Ramaze::Log.info("joining #{conference} for #{target}")
      @action_taken = "joined"
      caller_id = request.params["caller_id"]
      conference(conference, target, caller_id)
    else
      flash[:ERROR] = "Conference #{h conference} does not exist!"
    end
  end

  private

  # See if a conference exists, later add a db check as well as the realtime socket check
  def conference_exists?(conf)
    Conference.exists?(conf)
  end

  # I made the target validation more flexible, this allows people to use
  # dashes and stuff within the number while still making sure it's 10 digits.
  # We don't convert it to an Integer as that would remove leading zeroes.
  #
  # TODO:
  #   The input form still has a size restriction that makes little sense.
  def conference(conf, target, caller_id = "0008675309")
    target_number = target.scan(/\d+/).join

    unless target_number.size == 10
      flash[:ERROR] = "Must be 10 digit number to dial!"
      return
    end
    
    @sock ||= FSR::CommandSocket.new
    orig = @sock.originate(
      :target => "sofia/gateway/carlos/#{target_number}",
      :target_options => {:origination_caller_id_number => caller_id},
      :endpoint => FSA::Conference.new(conf, "default")).run
    @conference, @target = conf, target

    Ramaze::Action.current.template = 'view/conference_joined.haml'
  end

  # Since ruby 1.8.7 this could be:
  #
  #     require 'securerandom'
  #     begin
  #       conf = SecureRandom.hex(4).to_i(16).to_s(32)
  #     end while conference_exists?(conf)
  #
  # A length of 4 will give us around 4^16 possible values, encoding it with
  # base32 gives us a string length of 7.
  #
  # Otherwise we can also go with base64:
  #
  #     require 'securerandom'
  #     begin
  #       conf = SecureRandom.base64(4).delete('=').tr('/+', '-_')
  #     end while conference_exists?(conf)
  #
  # That gives us the same amount while keeping the string length at 5.
  def next_conf
    charray = ("A" .. "Z").to_a + ("a" .. "z").to_a + ("0" .. "9").to_a
    rands = ""
    rands << charray[rand(charray.size - 1)] until rands.size > 4
    conf = "a"
    conf = conf.succ while conference_exists?([rands, conf].join("-"))
    [rands, conf].join("-")
  end
end
