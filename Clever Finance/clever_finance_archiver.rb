#!/usr/bin/env ruby
require 'nokogiri'
require 'csv'
require 'net/http'
require 'fileutils'

### SETUP
PHPSESSID   = 'xxxxxxxxx'
### END SETUP

$xpath_row    = '//*[contains(@class,"datalist_row")]'
$xpath_fella  = '//*/td[12]/a'
$xpath_page   = '//*[@id="paginator-next-item"]'
$xpath_agent  = '//*[contains(@class,"nazovporadca")]/a'
$xpath_client = '//*[contains(@class,"poistnik_meno")]'
$xpath_no     = '//*[contains(@class,"zmluva_cislo_navrhu")]'
$xpath_documents = '//*[@id="tabs"]/ul/li[2]/a'
$xpath_files     = '//*[@id="zmluva-detail-page"]/table/tr/td[7]/a'
$fellas      = []
$pages       = []
DST_DIR     = './archive'
$START_URL   = 'https://rhea.tiviosoft.net/cleverfinance/zmluvy'
$query_1_tmp = "'%s' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Accept-Language: cs,en-GB;q=0.8,en;q=0.6,en-US;q=0.4,pl;q=0.2,de;q=0.2,fr;q=0.2,sk;q=0.2' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: https://rhea.tiviosoft.net/cleverfinance/zmluvy' -H 'Cookie: PHPSESSID=#{PHPSESSID}; arp_scroll_position=5' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' --compressed"

def search_page(url)
  puts ">>> search on page: #{url}"
  query_1 = $query_1_tmp % [url]
  page = `curl --silent #{query_1}`
  html = Nokogiri::HTML(page)

  new_page_link = html.xpath($xpath_page).attr('href')
  new_page = URI::join($START_URL, new_page_link)

  # For all rows on one page
  html.xpath($xpath_row).each do |row|
    agent  = Nokogiri::HTML(row.inner_html).xpath($xpath_agent).attr('title')
    client = Nokogiri::HTML(row.inner_html).xpath($xpath_client).inner_html
    no     = Nokogiri::HTML(row.inner_html).xpath($xpath_no).inner_html
    fella  = Nokogiri::HTML(row.inner_html).xpath($xpath_fella).attr('href')

    dir = "%s/%s/%s" % [DST_DIR, agent, client]
    # puts "dir: #{dir}"
    FileUtils.mkdir_p(dir)
    # puts "fella: #{fella}"

    fella_page = URI::join($START_URL, fella)
    query_2 = $query_1_tmp % [fella_page]
    popup = `curl --silent #{query_2}`

    doc_url = nil
    # Find document URL
    Nokogiri::HTML(popup).xpath($xpath_documents).each do |document_url|
      doc_url = URI::join($START_URL, document_url.attr('href'))
      # puts "document_url: #{doc_url}"
    end

    query_3 = $query_1_tmp % [doc_url]
    documents = `curl --silent #{query_3}`

    files = Nokogiri::HTML(documents).xpath($xpath_files)
    #puts "Found: %d files" % [files.size]

    counter = 0
    # For all files found
    files.each do |file|
      counter = counter + 1
      file.attr('href')
      file_url = URI::join($START_URL, file.attr('href'))
      # puts "file_url: #{file_url}"

      file_path = "#{dir}/#{no}_#{counter}.pdf"
      # puts "file_path: #{file_path}"

      puts "Downloading: #{file_url} -> #{file_path}"

      query_4 = $query_1_tmp % [file_url]
      puts `curl -o "#{file_path}" #{query_4}`
    end
  end

  puts "new_page: #{new_page}"
  # Recursive search
  search_page new_page
end

search_page($START_URL)