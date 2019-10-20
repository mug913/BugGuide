class Bugguide::CLI

@@cli = nil

  def call
    @history = []
    @url = "https://bugguide.net/node/view/3/bgpage"
    @past_url = "https://bugguide.net/node/view/3/bgpage"
    @level = 0
    @@cli = self
    puts "Welcome to the BugGuide.net CLI."
    list_options
  end

  def self.return
    @@cli
  end

  def list_options
    Bugguide::Scraper.new(@url)
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
        Bugguide::Scraper.current_doc.getinfo
        list_options
      when '2'
        travel_map
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

  def travel_down(paths)
    paths.each_with_index do |path, index|
      if ((@level == 0) && (index < 4)) || (@level > 0)
        puts " #{index+1} : #{path[:page_title]}"
      end
    end
    input = gets.strip
    if input == 'x' || input == 'X'
      list_options
    elsif input.to_i > 0 && input.to_i <= paths.length
      choice = input.to_i - 1
      @level += 1
      @history << @url
      @url = paths[choice][:page_url]
      list_options
    else
      puts "Invalid input. Press 'X' to return to the main menu."
      travel_down(paths)
    end
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

  def travel_map
    paths = []
    pages = []
    scrape = Bugguide::Scraper.scraped_doc
    pages << @url
    scrape.css(".pager a").each do |node|
      pages << node.attribute('href').value
    end
    pages.uniq.each do |page|
      option = Bugguide::Scraper.scrape_page(page)
      option.css(".node-title a").each do |node|
      paths << {
        :page_title => node.text,
        :page_url => node.attribute('href').value
        }
      end
    end
    travel_down(paths)
   end


 end
