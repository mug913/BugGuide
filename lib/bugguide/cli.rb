class Bugguide::CLI

@@cli = nil

attr_accessor :url, :page

  def call
    @history = []
    @url = "https://bugguide.net/node/view/3/bgpage"
    @@cli = self
    puts "Welcome to the BugGuide.net CLI."
    list_options
  end

  def self.return(url)
    @@cli.url = url
    @@cli
  end

  def list_options
    page = Bugguide::Taxon.find_or_create_page(self.url)
    input = nil
    page.current_level
    puts "Options:"
    puts "1: Get Info"
    puts "2: Travel down tree"
    puts "3: Travel up tree"
    puts "Q: Quit"
    input = gets.strip
    case input
      when '1'
        page.info
  #      list_options
      when '2'
        paths = page.children
        travel(paths)
      when '3'
        paths = Bugguide::Scraper.back_path(page)
        travel(paths)
      when "q","Q"
        puts "Goodbye."
        exit!
      else
        puts "Invalid input."
        list_options
    end
  end

  def travel(paths)
    root = "https://bugguide.net/node/view/3/bgpage"
    if paths.length == 0 && self.url == root
      puts "You are on the Top Level."
      list_options
    elsif paths.length == 0 && self.url != root
      puts "You have reached the bottom level."
      list_options
    else
      paths.each_with_index do |path, index|
        puts " #{index+1} : #{path[:page_title]}"
      end
    end
    input = gets.strip
    if input == 'x' || input == 'X'
      list_options
    elsif input.to_i > 0 && input.to_i <= paths.length
      choice = input.to_i - 1
      @@cli.url = paths[choice][:page_url]
      list_options
    else
      puts "Invalid input. Press 'X' to return to the main menu."
    travel(paths)
    end
  end

 end
