class Bugguide::Scraper

@@all = []

attr_accessor :data_doc, :url, :info_page

  def initialize(url)
    @url = url
    @data_doc = Nokogiri::HTML(open(url))
    info_url = url.chomp("/bgpage")
    @info_page = Nokogiri::HTML(open(info_url))
    @@current_doc = self
    if !@@all.include?(self.url)
      @@all << self
    end
  end

  def self.current_doc
    @@current_doc
  end

  def self.scraped_docs
    @all
  end

  def getinfo
    input = nil
    info_page = []
    self.info_page.css(".bgpage-section").each do |section|
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
        if input.to_i > 0 && input.to_i < info_page.length
          info_handeler(info_page[input.to_i])
          getinfo
        elsif input == 'x' || input == 'X'
          Bugguide::CLI.return.list_options
        else
          puts "Invalid input. Press 'X' to return."
          getinfo
        end
      end
  #    Bugguide::CLI.list_options
    end

    def info_handeler(info)
    #  binding.pry
       puts "#{info.css(".bgpage-section-heading").text}:"
     #  binding.pry
       if info.css(".bgpage-taxon").text != ""
         taxon_title = info.css(".bgpage-taxon-title")
         taxon_desc = info.css(".bgpage-taxon-desc")
         i = 0
         while i < taxon_title.length
           puts "#{taxon_title.children[i].text} : #{taxon_desc.children[i].text}"
           i += 1
         end
       end
       if info.css(".bgpage-text").text != ""
         puts "#{info.css(".bgpage-text").text}"
       elsif info.css(".bgpage-bullet").text
         bullets = info.css(".bgpage-bullet").text.split(/\r/)
         bullets.each do |bullet|
           puts " * #{bullet}"
         end
       end
       if info.css(".bgpage-cite-entry").text != ""
         puts "#{info.css(".bgpage-cite-entry").text}"
        end
       puts ""
     end

     def travel_map
       paths = []
       pages = []
       scrape = Bugguide::Scraper.current_doc.data_doc
       pages << current_doc.url
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
