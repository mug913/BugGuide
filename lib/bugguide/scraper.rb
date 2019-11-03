class Bugguide::Scraper

  def self.scrape(url)
    Nokogiri::HTML(open(url))
  end

  def self.get_info(page)
    body =""
    categories = []
    choices = []
    info_page = Nokogiri::HTML(open(page.url.chomp("/bgpage")))
    info_page.css(".bgpage-section").each do |section|
      categories << section
    end
    categories.each do |category|
      if category.css(".bgpage-taxon").text != ""
        taxon_title = category.css(".bgpage-taxon-title")
        taxon_desc = category.css(".bgpage-taxon-desc")
        i = 0
        while i < taxon_title.length
          body += "#{taxon_title.children[i].text} : #{taxon_desc.children[i].text} \n"
          i += 1
        end
      end
      if category.css(".bgpage-text").text != ""
        body = category.css(".bgpage-text").text
      elsif category.css(".bgpage-bullet").text
        bullets = category.css(".bgpage-bullet").text.split(/\r/)
        bullets.each do |bullet|
          body += " * #{bullet} \n"
        end
      end
      if category.css(".bgpage-cite-entry").text != ""
        body = category.css(".bgpage-cite-entry").text
      end
    choices << {
    :title => category.css(".bgpage-section-heading").text,
    :body => body
    }
    end
    choices.each_with_index do |category, index|
      if (category[:title] == " ")
        choices.delete_at(index)
      end
    end
    choices
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
