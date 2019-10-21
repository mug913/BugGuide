class Bugguide::Scraper

@@all = []

attr_accessor :data_doc, :url, :info_page, :level

  def initialize(url, level = 0)
    @url = url
    @data_doc = Nokogiri::HTML(open(url))
    info_url = url.chomp("/bgpage")
    @info_page = Nokogiri::HTML(open(info_url))
    @level = level
    if !@@all.any?{|cell| cell[self.url]}
      @@all << {self.url => self}
    end
  end

  def self.find_or_create_page(url, level = 0)
      if !@@all.any?{|cell| cell[url]}
        Bugguide::Scraper.new(url,level)
      else
        found = @@all.find{|cell| cell[url]}
        found[url]
      end
    end

  def self.scraped_docs
    @@all
  end

  def current_level
    level = self.data_doc.css(".node-title h1").text
    puts "Currently on #{level}"
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
          Bugguide::CLI.return(self.url).list_options
        else
          puts "Invalid input. Press 'X' to return."
          getinfo
        end
      end
    end

    def info_handeler(info)
       puts "#{info.css(".bgpage-section-heading").text}:"
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

     def travel_map_down
       paths = []
       pages = []
       current_level = self.level
       scrape = self.data_doc
       pages << self.url
       scrape.css(".pager a").each do |node|
         if !pages.include?(node.attribute('href').value)
           pages << node.attribute('href').value
         end
       end
       pages.each do |page|
         option = Bugguide::Scraper.find_or_create_page(page, current_level += 1)
         option.data_doc.css(".node-title a").each do |node|
         paths << {
           :page_title => node.text,
           :page_url => node.attribute('href').value
           }
         end
       end
       travel_down(paths)
      end

      def travel_map_up
        if self.level == 0
          puts "You are at the top level."
        else
          @level -= 1
          @url = @history[@level]
          @history.pop(1)
        end
        list_options
      end

      def travel(paths)
        if paths.length = 0
          puts "You have reached the bottom level."
        else
          paths.each_with_index do |path, index|
            if ((self.level == 0) && (index < 4)) || (self.level > 0)
              puts " #{index+1} : #{path[:page_title]}"
            end
          end
          input = gets.strip
          if input == 'x' || input == 'X'
            Bugguide::CLI.return(self.url).list_options
          elsif input.to_i > 0 && input.to_i <= paths.length
            choice = input.to_i - 1
            Bugguide::CLI.return(paths[choice][:page_url]).list_options
          else
            puts "Invalid input. Press 'X' to return to the main menu."
            travel_down(paths)
          end
        end
      end



end
