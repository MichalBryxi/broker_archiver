#!/usr/bin/env ruby
require 'nokogiri'
require 'csv'
require 'net/http'
require 'fileutils'

### SETUP
PHPSESSID   = 'xxxxxxxxx'
### END SETUP

XPATH_RECORDS='/html/body/div[1]/div/section/section/ol/li'
XPATH_NAME='//section/div/div/h1/a'
XPATH_ADDRESS='//section/div[1]/div[1]/ul/li[1]/address'
XPATH_WEB='//section/div[1]/div[1]/ul/li[2]/a[@data-ta="LinkClick"]'
XPATH_MAIL='//section/div[1]/div[1]/ul/li[2]/a[@data-ta="EmailClick"]'
XPATH_PHONE='//i[@class="fa fa-phone"]/..'

PROJECTS = [
  {
    'name' => 'projektanti_praha',
    'url' => 'http://www.zlatestranky.cz/hledani/projektanti+projektov%C3%A1n%C3%AD+bl%C3%ADzko+Praha,+okres+Hlavn%C3%AD+m%C4%9Bsto+Praha/'
  # }, {
  #   'name' => 'projektanti',
  #   'url' => ''
  }
]
DST_DIR     = './archive'

def search_page(name, url)
  puts ">>> #{name} search on page: #{url}"
  page = `curl --silent #{url}`
  html = Nokogiri::HTML(page)

  records = html.xpath(XPATH_RECORDS)
  records.each do |record|
    save_record(record.inner_html)
  end
end

def save_record(item)
  name = Nokogiri::HTML(item).xpath(XPATH_NAME).inner_html
  address = Nokogiri::HTML(item).xpath(XPATH_ADDRESS).text.strip
  web = Nokogiri::HTML(item).xpath(XPATH_WEB)
  unless web.empty?
    web = web.attr('href')
  end
  mail = Nokogiri::HTML(item).xpath(XPATH_MAIL)
  unless mail.empty?
    mail = mail.attr('href').to_s.slice(7..-1).strip
  end
  phone = Nokogiri::HTML(item).xpath(XPATH_PHONE).text.strip

  puts "---------------------"
  puts "name: #{name}"
  puts "address: #{address}"
  puts "web: #{web}"
  puts "mail: #{mail}"
  puts "phone: #{phone}"

  # new_page_link = html.xpath($xpath_page).attr('href')
  # new_page = URI::join($START_URL, new_page_link)

  # # For all rows on one page
  # html.xpath($xpath_row).each do |row|
  #   agent  = Nokogiri::HTML(row.inner_html).xpath($xpath_agent).attr('title')
  #   client = Nokogiri::HTML(row.inner_html).xpath($xpath_client).inner_html
  #   no     = Nokogiri::HTML(row.inner_html).xpath($xpath_no).inner_html
  #   fella  = Nokogiri::HTML(row.inner_html).xpath($xpath_fella).attr('href')

  #   dir = "%s/%s/%s" % [DST_DIR, agent, client]
  #   # puts "dir: #{dir}"
  #   FileUtils.mkdir_p(dir)
  #   # puts "fella: #{fella}"

  #   fella_page = URI::join($START_URL, fella)
  #   query_2 = $query_1_tmp % [fella_page]
  #   popup = `curl --silent #{query_2}`

  #   doc_url = nil
  #   # Find document URL
  #   Nokogiri::HTML(popup).xpath($xpath_documents).each do |document_url|
  #     doc_url = URI::join($START_URL, document_url.attr('href'))
  #     # puts "document_url: #{doc_url}"
  #   end

  #   query_3 = $query_1_tmp % [doc_url]
  #   documents = `curl --silent #{query_3}`

  #   files = Nokogiri::HTML(documents).xpath($xpath_files)
  #   #puts "Found: %d files" % [files.size]

  #   counter = 0
  #   # For all files found
  #   files.each do |file|
  #     counter = counter + 1
  #     file.attr('href')
  #     file_url = URI::join($START_URL, file.attr('href'))
  #     # puts "file_url: #{file_url}"

  #     file_path = "#{dir}/#{no}_#{counter}.pdf"
  #     # puts "file_path: #{file_path}"

  #     puts "Downloading: #{file_url} -> #{file_path}"

  #     query_4 = $query_1_tmp % [file_url]
  #     puts `curl -o "#{file_path}" #{query_4}`
  #   end
  # end

  # puts "new_page: #{new_page}"
  # # Recursive search
  # search_page new_page
end

PROJECTS.each do |project|
  search_page(project['name'], project['url'])
end