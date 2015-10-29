#encoding: utf-8
require 'scraperwiki'
require 'nokogiri'

# Read in a page
url = "https://docs.google.com/spreadsheets/d/1cfC1bsNoTvNC6YSNIyTqLpQkEMTvrGavS_EmJL6HdH8/pubhtml?gid=1424272470&single=true"
page = Nokogiri::HTML(open(url), nil, 'utf-8')
rows = page.xpath('//table[@class="waffle"]/tbody/tr')

# Find something on the page using css selectors
content = []
rows.collect do |r|
  content << r.xpath('td').map { |td| td.text.strip }
end

# Builds records
content.shift(2)
content.each do |row|
  record = {
    "date" => row[0],
    "cat01" => if row[1].empty? then '0' else row[1] end,
    "cat02" => if row[2].empty? then '0' else row[2] end,
    "cat03" => if row[3].empty? then '0' else row[3] end,
    "cat04" => if row[4].empty? then '0' else row[4] end,
    "cat05" => if row[5].empty? then '0' else row[5] end,
    "last_update" => Date.today.to_s
  }

  # Storage the record
  if ((ScraperWiki.select("* from data where `source`='#{record['date']}'").empty?) rescue true)
    ScraperWiki.save_sqlite(["date"], record)
    puts "Adds new record with timestamp " + record['date']
  else
    ScraperWiki.save_sqlite(["date"], record)
    puts "Updating already saved record from " + record['date']
  end
end
