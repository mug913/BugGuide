class Bugguide::Info_handeler

  def self.info_handeler(info)
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
  
  def self.getinfo(url)
    input = nil
    info_page = []
    info_url = url.chomp("/bgpage")
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
        if  
          input.to_i > 0 && input.to_i < info_page.length
          self.info_handeler(info_page[input.to_i])
          getinfo(url)
        elsif input != 'x'
          puts "Invalid input. Press 'X' to return."
          getinfo(url)
        end
      end
    end
    
end