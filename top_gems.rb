require 'terminal-table'
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'yaml'


gem_name = YAML.load_file('./gems.yml')['gems']
current_gem = gem_name[0]
 p  current_gem 

def get_github(gem_name)
  
    gem_info = 'https://rubygems.org/api/v1/gems/'+gem_name+'.yaml'

    html = open(gem_info)
    doc = Nokogiri::HTML(html)
    doc_h = doc.css('p').text.strip.scan(/(.+):(\s.+)\n/).to_h

    resours = doc_h['source_code_uri'].strip

end

link = get_github(current_gem)

p link

def get_gem_info(link)
    html = open(link)
    doc = Nokogiri::HTML(html)

    rating = []

    doc.css('.pagehead-actions li .social-count').each do |li|
    array =  li['aria-label'].split(' ')
    li_w =  array[0]
    word_key = array[2].start_with?("fork", "star", "watch")?array[2]:
    (array[3].start_with?("fork", "star", "watch")?array[3]:nil)

    if word_key.start_with?("fork", "star", "watch") 
        rating.push(fork: li_w) if word_key.start_with?("fork")
            rating.push(star: li_w) if word_key.start_with?("star")
            rating.push(watch: li_w) if word_key.start_with?("watch")
    end
    
    end


    doc.css('h1.public span a.url').each do |i|
    # puts i.children
        user_name = i.children.text.strip
    rating.push(user: user_name) 

    end

    doc.css('.numbers-summary li a').each do |i|
        if i.children.text.strip.include?('con')
        contributors = i.css('span.num').children.text.strip 
        rating.push(contributors: contributors)
        end

    end

    doc.css('span a.reponav-item').each do |i|

        if i.children.text.strip.include?('Issues')
        issue = i.css('span.Counter').children.text.strip 
        rating.push(issues: issue)
   
        end
    
    end

    p rating
end

data = get_gem_info(link)

def view_table(data, current_gem)
    watch = data[0].values.join('').to_i
    star = data[1].values.join('').to_i
    fork = data[2].values.join('').to_i
    contributors = data[4].values.join('').to_i
    issues = data[5].values.join('').to_i

    table = Terminal::Table.new do |t|
        t << ["#{current_gem}", "used by", "watched by #{watch}", "#{star} stars", "#{fork} forks", "#{contributors} contributors", "#{issues} issues"]
    end
      puts table
end

view_table(data, current_gem)