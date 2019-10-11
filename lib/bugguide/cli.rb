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
    puts "Q: Quit"
    until input == "Q" || input == "q" 
      input = gets.strip
      case input
        when "1"
          getinfo
        when "q","Q"
          puts "Goodbye."
        else 
          puts "Invalid input."
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
    min = 0
    info_page = []
    info_url = @@url.chomp("/bgpage")
    scrape_page(info_url)
    @@doc.css(".bgpage-section").each do |section|
      info_page << section
    end
    puts "Pick a category:"
    puts "Press 'X' to return."
    info_page.each_with_index do |section, index|
      if !(section.css(".bgpage-section-heading").text == " ")
        puts "#{index}: #{section.css(".bgpage-section-heading").text}"
        #binding.pry
      end 
    end 
    input = gets.strip
    binding.pry
      if input.to_i < info_page.length
        if info_page[input.to_i].css(".bgpage-taxon").text 
          taxon_title = info_page[input.to_i].css(".bgpage-taxon-title")
          taxon_desc = info_page[input.to_i].css(".bgpage-taxon-desc")
          i = 0 
          while i < taxon_title.length
            puts "#{taxon_title.children[i].text} : #{taxon_desc.children[i].text}"
            i += 1
          end
        end
        if !info_page[input.to_i].css(".bgpage-text").text != ""
          puts "#{info_page[input.to_i].css(".bgpage-text").text}"
        end
        if info_page[input.to_i].css(".bgpage-bullet").text 
          bullets = info_page[input.to_i].css(".bgpage-bullet").text.split(/\r/)
          bullets.each do |bullet|
            puts" * #{bullet}"
          end
        end
        getinfo
      elsif input == 'x' || input == 'X'
      binding.pry
        list_options
      else
        puts "Invalid input. Press 'X' to return."
        getinfo
      end
    #binding.pry
  end
  
  
end