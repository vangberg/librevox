class MainController < Controller
  def about
    @title = "Welcome to ConfMe, The Conference Service that calls You!"
  end

  # the index action is called automatically when no other action is specified
  def index
    @title = "Welcome to ConfMe, The Conference Service that calls You!"
  end

  def start
    target = request.params["phone_number"]
    if target
      conference = "#{next_conf}"
      @action_taken = "started"
      caller_id = request.params["caller_id"]
      conference(conference, target, caller_id)
    end
  end
  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  #
  def join(conference = nil)
    @conference = conference || request[:conference]

    target = request[:phone_number].to_s

    if target != ""
      if conference_exists?(conference)
        Ramaze::Log.info("joining #{conference} for #{target}")
        @action_taken = "joined"
        caller_id = request.params["caller_id"]
        conference(conference, target, caller_id)
      else
        flash[:ERROR] = "Conference #{conference} does not exist!"
      end
    end
  end

  private

  def conference_exists?(conf)
    require "hpricot"
    @sock ||= FSR::CommandSocket.new
    confs = Hpricot(@sock.say("api conference xml_list")["body"])
    all_conf_names = (confs/:conferences/:conference).map { |n| n[:name] }
    all_conf_names.include?(conf)
  end

  def conference(conf, target, caller_id = "0008675309")
    unless target.match(/^\d\d{9}$/)
      flash[:ERROR] = "Must be 10 digit number to dial!"
      return false
    end
    @sock ||= FSR::CommandSocket.new
    orig = @sock.originate(:target => "sofia/gateway/carlos/#{target}", :target_options => {:origination_caller_id_number => caller_id}, :endpoint => FSA::Conference.new(conf, "default")).run
    @conference, @target = conf, target
    Ramaze::Action.current.template = 'view/conference_joined.haml'
  end

  def next_conf
    charray = ("A" .. "Z").to_a + ("a" .. "z").to_a + ("0" .. "9").to_a
    rands = ""
    until rands.size > 4
      rands << charray[rand(charray.size - 1)]
    end
    conf = "a"
    while conference_exists?([rands, conf].join("-"))
      conf = conf.succ
    end
    [rands, conf].join("-")
  end
end
