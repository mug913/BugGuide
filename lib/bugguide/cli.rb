class Bugguide::CLI

@@cli = nil

  def call
    @history = []
    @url = "https://bugguide.net/node/view/3/bgpage"
    @past_url = "https://bugguide.net/node/view/3/bgpage"
    @@cli = self
    puts "Welcome to the BugGuide.net CLI."
    list_options
  end

  def self.return
    @@cli
  end

  def list_options
    data_page = Bugguide::Scraper.new(@url)
    input = nil
#    current_level
    puts "Options:"
    puts "1: Get Info"
    puts "2: Travel down tree"
    puts "3: Travel up tree"
    puts "Q: Quit"
    input = gets.strip
    case input
      when '1'
        data_page.getinfo
        list_options
      when '2'
        data_page.travel_map
      when '3'
        travel_up
      when "q","Q"
        puts "Goodbye."
        exit!
      else
        puts "Invalid input."
        list_options
    end
  end


  def current_level
  #  binding.pry
    level = Bugguide::Scraper.current_doc.data_doc.css(".node-title h1").text
    puts "Currently on #{level}"
  end



  def travel_up
    if @level == 0
      puts "You are at the top level"
    else
      @level -= 1
      @url = @history[@level]
      @history.pop(1)
    end
    list_options
  end


 end
