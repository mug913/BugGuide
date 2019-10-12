class Bugguide::Scraper
  


  def self.scrape_page(url)
    @doc = Nokogiri::HTML(open(url))
    #binding.pry
  end
  
  def self.info_scrape_page(url)
    @info_doc = Nokogiri::HTML(open(url))
    #binding.pry
  end
  
  def self.scraped_doc
    @doc
  end
  
  def self.info_scraped_doc
    @info_doc
  end
  
end