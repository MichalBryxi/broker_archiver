#!/usr/bin/env ruby
require 'nokogiri'
require 'csv'
require 'net/http'
require 'fileutils'

LOOPS=99
XPATH_RECORDS='/html/body/div[1]/div/section/section/ol/li'
XPATH_COMPANY='//section/div/div/h1/a'
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

def search_page(name, url, counter = 0)
  puts ">>> #{name} search on page: #{url}"
  page = `curl --silent #{url}`
  html = Nokogiri::HTML(page)

  records = html.xpath(XPATH_RECORDS)
  records.each do |record|
    save_record(name, record.inner_html)
  end

  if records.size > 0
    puts ">>> found #{records.size} records, moving to next page"
    search_page(name, url, counter + 1)
  end
end

def save_record(name, item)
  company = Nokogiri::HTML(item).xpath(XPATH_COMPANY).inner_html
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
  puts "company: #{company}"
  puts "address: #{address}"
  puts "web: #{web}"
  puts "mail: #{mail}"
  puts "phone: #{phone}"

  data = [name, address, web, mail, phone]
  append_to_file(name, data)
end

def append_to_file(name, data)
  file = filename(name)
  line = data.join(',')
  File.open(file, "a") do |f|
    f.write line
  end
end

def filename(name)
  DST_DIR + name + ".csv"
end

mkdir_p(DST_DIR)
PROJECTS.each do |project|
  name = project['name']
  url = project['url']
  file = filename(name)

  delete(file)
  search_page(name, url)
end