class Bugguide::CLI

@@cli = nil

attr_accessor :url, :page

  def call
    @history = []
    @url = "https://bugguide.net/node/view/3/bgpage"
    @@cli = self
    puts "Welcome to the BugGuide.net CLI."
    list_options
  end

  def self.return(url)
    @@cli.url = url
    @@cli
  end

  def list_options
    page = Bugguide::Scraper.find_or_create_page(self.url)
    input = nil
    page.current_level
    puts "Options:"
    puts "1: Get Info"
    puts "2: Travel down tree"
    puts "3: Travel up tree"
    puts "Q: Quit"
    input = gets.strip
    case input
      when '1'
        page.getinfo
        list_options
      when '2'
        page.travel_map
      when '3'
        page.travel_up
      when "q","Q"
        puts "Goodbye."
        exit!
      else
        puts "Invalid input."
        list_options
    end
  end

 end
