class Bugguide::CLI
  

  def call 
    @@url = "https://bugguide.net/node/view/3/bgpage"
    puts "Welcome to the BugGuide.net CLI."
    list_options
  end
  
  def list_options
    scrape_page(@@url)
    input = nil
    current_level
    puts "Options:"
    puts "1: Get Info"
    puts "2: Travel down tree"
    puts "3: Travel up tree"
    puts "Q: Quit"
      input = gets.strip
      case input
        when "1"
          getinfo
        when "2"
          travel_down
        when "q","Q"
          puts "Goodbye."
          exit!
        else 
          puts "Invalid input."
          list_options
        end
  
   end
  
  def scrape_page(url)
    @@doc = Nokogiri::HTML(open(url))
    #binding.pry
  end
  
  def info_scrape_page(url)
    @@info_doc = Nokogiri::HTML(open(url))
    #binding.pry
  end
  
  def current_level
    level = @@doc.css(".node-title h1").text 
    puts "Currently on #{level}"
  end
  
  def getinfo
    input = nil
    info_page = []
    info_url = @@url.chomp("/bgpage")
    info_scrape_page(info_url)
    @@info_doc.css(".bgpage-section").each do |section|
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
    if info.css("bgpage-cite-entry")
      puts "#{info.css(".bgpage-cite-entry").text}"
    end
    end
  end
  
  def travel_down
   paths = []
   scrape_page(@@url)
   @@doc.css(".node-title a").each do |node|
     paths << node 
   end 
   paths.each_with_index do |path, index|
     puts " #{index+1} : #{path.text}"
   end
   input = gets.strip
   if input == 'x' || input == 'X'
      list_options
    elsif input.to_i > 0 && input.to_i < paths.length
      choice = input.to_i - 1
      @@url = paths[choice].attribute('href').value
      list_options
    else
      puts "Invalid input. Press 'X' to return."
    travel_down
    end
    #binding.pry
  end
    
  
end