class Bugguide::CLI
  

  def call 
    @@url = "https://bugguide.net/node/view/3/bgpage"
    puts "Welcome to the BugGuide.net CLI."
    scrape_page(@@url)
    current_level
    list_options
  end
  
  def list_options
    input = nil
    puts "Options:"
    puts "1: Get Info"
    puts "2: List lower branches"
    puts "3: Return up tree"
    puts "4: Quit"
    until input == "4" || input == "q" 
      input = gets.strip
      case input
        when "1"
          getinfo
        when "n","N"
          puts "Goodbye."
        else 
          puts "Scrape? (y/n)"
      end
    end        
    #binding.pry
  end
  
  def scrape_page(url)
    @@doc = Nokogiri::HTML(open(url))
    #binding.pry
  end
  
  def current_level
    level = @@doc.css(".node-title h1").text 
    puts "Currently on #{level}"
  end
  
  def getinfo
    info_page = []
    info_url = @@url.chomp("/bgpage")
    scrape_page(info_url)
    @@doc.css(".bgpage-section").each do |section|
      info_page << section
    end
    puts "Pick a category:"
    info_page.each_with_index do |section, index|
      if section.css(".bgpage-section-heading").text != /\s/
        puts "#{index}: #{section.css(".bgpage-section-heading").text}"
        input = gets.strip
      end 
    end 
    binding.pry
  end
end