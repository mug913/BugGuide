class Bugguide::Taxon

  @@all = []
  attr_accessor :name, :url, :data_doc, :children

  def initialize(url)
    @url = url
    @data_doc = Bugguide::Scraper.scrape(url)
    @name = self.data_doc.css(".node-title h1").text
    @@all << self
    @children = Bugguide::Scraper.map_children(self)
  end

  def self.find_or_create_page(url)
    if !@@all.any?{|taxon| taxon.url == url}
      new_taxon = self.new(url)
    else
      found = @@all.find{|taxon| taxon.url == url}
    end
  end

  def current_level
    puts "Currently on #{self.name}"
  end



end
