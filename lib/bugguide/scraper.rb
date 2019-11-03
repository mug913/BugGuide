class Bugguide::Scraper

  def self.scrape(url)
    Nokogiri::HTML(open(url))
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

     def self.map_children(parent)
       paths = []
       pages = []
       scrape = parent.data_doc
       pages << parent.url
       scrape.css(".pager a").each do |node|
         if !pages.include?(node.attribute('href').value)
           pages << node.attribute('href').value
         end
       end
       pages.each do |page|
          option = scrape(page)
          option.css(".node-title a").each do |node|
         paths << {
           :page_title => node.text,
           :page_url => node.attribute('href').value
           }
         end
       end
       if parent.url == "https://bugguide.net/node/view/3/bgpage"
         paths.pop(17)
       end
       paths
      end

      def self.back_path(page)
        paths = []
        scrape = page.data_doc
        scrape.css(".bgpage-roots a").each do |node|
          if !paths.include?(node.attribute('href').value) && node.attribute('href').value != "https://bugguide.net/" && node.attribute('href').value != page.url
            paths << {
            :page_title => node.text,
            :page_url => node.attribute('href').value
            }
          end
        end
        paths
      end


end
