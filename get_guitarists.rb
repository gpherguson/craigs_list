
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'rss/maker'

URL = 'http://phoenix.craigslist.org/search/ggg/evl?query=guitar&srchType=A'
RSS_VERSION = '2.0'

class String
  def collapse_space
    tr("\t", ' ').squeeze(' ').strip
  end
end

doc = Nokogiri::HTML(open(URL))
rss_content = RSS::Maker.make(RSS_VERSION) do |_rss|

  _rss.channel.title       = "Craigslist Guitar gigs: #{Time.now}"
  _rss.channel.link        = URL
  _rss.channel.description = 'Guitar gigs found after searching for: guitar'
  _rss.items.do_sort       = true

  doc.css('a[@href^="http://phoenix.craigslist.org/evl/tlg/"]').each do |_href|
    referred_doc_url = _href['href']
    
    # get the referenced page to get some content
    referred_doc = Nokogiri::HTML(open(referred_doc_url))

    _rss.items.new_item do |_item|
      _item.link        = _href['href']
      _item.date        = Time.parse((referred_doc.at_css('body')).content.collapse_space[/Date: (\S+,\s\S+\s\w+)/, 1])
      _item.title       = referred_doc.at_css('h2').content.collapse_space
      _item.description = referred_doc.at_css('div#userbody').content.collapse_space
    end
  end
  
end

print "Content-Type: application/rss+xml\n\n"
print rss_content, "\n"
