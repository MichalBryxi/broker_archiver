#!/usr/bin/env ruby
require 'nokogiri'
require 'csv'
require 'net/http'
require 'fileutils'

LOOPS=99
XPATH_RECORDS='//section[@class="listings"]/ol/li'
XPATH_COMPANY='//section/div/div/h1/a'
XPATH_ADDRESS='//section/div[1]/div[1]/ul/li[1]/address'
XPATH_WEB='//section/div[1]/div[1]/ul/li[2]/a[@data-ta="LinkClick"]'
XPATH_MAIL='//section/div[1]/div[1]/ul/li[2]/a[@data-ta="EmailClick"]'
XPATH_PHONE='//i[@class="fa fa-phone"]/..'

PROJECTS = [
  {
  #   'name' => 'projektanti_praha',
  #   'url' => 'http://www.zlatestranky.cz/hledani/projektanti+projektov%C3%A1n%C3%AD+bl%C3%ADzko+Praha,+okres+Hlavn%C3%AD+m%C4%9Bsto+Praha/@'
  # }, {
    'name' => 'projektanti',
    'url' => 'http://www.zlatestranky.cz/firmy/-/q_projektanti,+projektov%C3%A1n%C3%AD/@/?f_c=Brno&fb=0&crc=oRVh271rcoEnUP7Llouzlw=='
  }, {
  #   'name' => 'architekti_praha',
  #   'url' => 'http://www.zlatestranky.cz/firmy/-/q_architekti/@/?f_c=Praha&fb=0&crc=fq811uZoYBjrVC7ymzN%2ftA%3d%3d'
  # }, {
  #   'name' => 'architekti_brno',
  #   'url' => 'http://www.zlatestranky.cz/firmy/-/q_architekti/@/?fb=0&f_c=Brno&crc=oRVh271rcoEnUP7Llouzlw%3d%3d'
  # }, {
    'name' => 'vytahy_praha',
    'url' => 'http://www.zlatestranky.cz/firmy/-/q_architekti/@/?f_c=Praha&fb=0&crc=fq811uZoYBjrVC7ymzN%2ftA%3d%3d'
  }, {
    'name' => 'vytahy_brno',
    'url' => 'http://www.zlatestranky.cz/firmy/-/q_v%C3%BDtahy/@/?fb=0&f_c=Brno&crc=oRVh271rcoEnUP7Llouzlw%3d%3d'
  }
]
DST_DIR     = './archive'

def search_page(name, url, counter = 0)
  paged_url = url.sub('@', counter.to_s)
  puts ">>> #{name} search on page: #{paged_url}"
  page = `curl --silent #{paged_url}`
  html = Nokogiri::HTML(page)
  puts html

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

  # puts "---------------------"
  # puts "company: #{company}"
  # puts "address: #{address}"
  # puts "web: #{web}"
  # puts "mail: #{mail}"
  # puts "phone: #{phone}"

  data = [name, company, address, web, mail, phone]
  append_to_file(name, data)
end

def append_to_file(name, data)
  file = filename(name)
  CSV.open(file, "ab") do |f|
    f << data
  end
end

def filename(name)
  DST_DIR + "/" + name + ".csv"
end

FileUtils.mkdir_p(DST_DIR)
PROJECTS.each do |project|
  name = project['name']
  url = project['url']
  file = filename(name)

  File.delete(file) if File.exists?(file)
  search_page(name, url)
end