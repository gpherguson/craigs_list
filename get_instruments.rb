#!/usr/bin/env ruby

require 'nokogiri'
require 'typhoeus'
require 'rss/maker'

URL     = 'http://phoenix.craigslist.org/search/msg?query=amplifier&srchType=A'
TARGETS = ['rivera', 'egnater', 'blackstar', 'mesa boogie', 'lonestar', 'les paul', 'carvin' ]

RSS_VERSION = '2.0'


rss_content = RSS::Maker.make(RSS_VERSION) do |_rss|

  _rss.channel.title       = "Craigslist instruments: #{Time.now}"
  _rss.channel.link        = URL
  _rss.channel.description = 'Musical instruments found after searching for: ' << (ARGV | TARGETS).join(', ')
  _rss.items.do_sort       = true

  (ARGV.map{ |_i| _i.downcase } + TARGETS).each do |_target|

    page = Nokogiri::HTML(Typhoeus::Request.get("http://phoenix.craigslist.org/search/msg?query=#{ _target }&srchType=A").body)

    page.css('p.row').each do |_result|
      desc = _result.inner_text.tr(" \t\r\n", ' ').squeeze(' ').strip[2 .. -1]

      item = _rss.items.new_item
      item.title = "\"#{_target}\" --> #{desc[/ - (.+)$/, 1]}"
      item.link  = _result.at('a').attr('href')
      item.date  = Time.parse(desc[0 .. 5])
    end
  end
end

print "Content-Type: application/rss+xml\n\n"
print rss_content, "\n"