class Bugguide::CLI
  
  attr_accessor :url, :past_url 
  
  def call 
    @url = "https://bugguide.net/node/view/3/bgpage"
    @past_url = "https://bugguide.net/node/view/3/bgpage"
    puts "Welcome to the BugGuide.net CLI."
    list_options
  end

  
  def list_options
    Bugguide::Scraper.scrape_page(@url)
    input = nil
    current_level
    puts "Options:"
    puts "1: Get Info"
    puts "2: Travel down tree"
    puts "3: Travel up tree"
    puts "Q: Quit"
    input = gets.strip
    case input
      when '1'
        getinfo
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
    level = Bugguide::Scraper.scraped_doc.css(".node-title h1").text 
    puts "Currently on #{level}"
  end
  
  def getinfo
    input = nil
    info_page = []
    info_url = @url.chomp("/bgpage")
    Bugguide::Scraper.info_scrape_page(info_url)
    Bugguide::Scraper.info_scraped_doc.css(".bgpage-section").each do |section|
      info_page << section
    end
    puts "Pick a category:"
    puts "Press 'X' to return."
    info_page.each_with_index do |section, index|
      if !(section.css(".bgpage-section-heading").text == " ")
        puts "#{index}: #{section.css(".bgpage-section-heading").text}"
      end 
    end 
    until input == 'x' || input == 'X'
      input = gets.strip
        if input == 'x' || input == 'X'
          list_options
        elsif 
          input.to_i > 0 && input.to_i < info_page.length
          info_handeler(info_page[input.to_i])
          getinfo
        else
          puts "Invalid input. Press 'X' to return."
          getinfo
        end
      end
    end
  
  def info_handeler(info)
    puts "#{info.css(".bgpage-section-heading").text}:"
    if info.css(".bgpage-taxon").text 
      taxon_title = info.css(".bgpage-taxon-title")
      taxon_desc = info.css(".bgpage-taxon-desc")
      i = 0 
      while i < taxon_title.length
        puts "#{taxon_title.children[i].text} : #{taxon_desc.children[i].text}"
        i += 1
      end
    end
    if !info.css(".bgpage-text").text != ""
      puts "#{info.css(".bgpage-text").text}"
    end
    if info.css(".bgpage-bullet").text 
      bullets = info.css(".bgpage-bullet").text.split(/\r/)
      bullets.each do |bullet|
        puts" * #{bullet}"
      end
    end
    if info.css("bgpage-cite-entry")
      puts "#{info.css(".bgpage-cite-entry").text}"
    end
  end
  
  def travel_down(paths)
    paths.each_with_index do |path, index|
      puts " #{index+1} : #{path.text}"
    end
    input = gets.strip
    if input == 'x' || input == 'X'
      list_options
    elsif input.to_i > 0 && input.to_i < paths.length
      choice = input.to_i - 1
      @past_url = @url
      @url = paths[choice].attribute('href').value
      list_options
    else
      puts "Invalid input. Press 'X' to return to the main menu."
      travel_down
    end
  end
  
  def travel_up
    if @url == "https://bugguide.net/node/view/3/bgpage"
      puts "You are at the top level"
    else
      @url = @past_url
    end
    list_options
  end 
  
  def travel_map
    paths = []
    pages = []
    scrape = Bugguide::Scraper.scraped_doc
    scrape.css(".pager a").attribute('href').value.each do |node|
      pages << node 
    end
    pages.each do |page|
      page = Bugguide::Scraper.scrape_page(page)
      page.css(".node-title a").each do |node|
      paths << node 
    end 
    travel_down(paths)
   end 
    
 
 end