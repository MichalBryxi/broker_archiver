#!/usr/bin/env ruby
# Skript umí extrahovat data z interního systému Broker Consulting.
# Lze použít pro zálohování vašich dat o vašich klientech.
# Nutno vyplnit JSESSIONID cookie, kterou dostane váš prohlížeč
# po úspěšném přihlášení do systému.

require 'nokogiri'
require 'csv'

grep        = 'findBusinessCaseByPK.do.businessCaseId.'
xpath_query = '//*[@id="businessCaseForm"]/div/div/span[2]/input'
headers     = []
sleep_t     = 1
JSESSIONID  = 'XXXXXXXXXXXXXXXXXXX'
query_1     = "'https://portal.bcas.cz:4443/findBusinessCaseByFilter.do?use-session-filter=true&filtermeta-countAllRows=true&filtermeta-page=1&filtermeta-pagesize=300' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Host: portal.bcas.cz:4443' -H 'Accept-Language: cs,en-GB;q=0.8,en;q=0.6,en-US;q=0.4' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Referer: https://portal.bcas.cz:4443/findBusinessCaseByFilter.do?use-session-filter=true&filtermeta-countAllRows=true&filtermeta-pagesize=25' -H 'Cookie: JSESSIONID=#{JSESSIONID}' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' --compressed --insecure"
query_2_tmp = "'https://portal.bcas.cz:4443/%s' -H 'Accept-Encoding: gzip,deflate,sdch' -H 'Host: portal.bcas.cz:4443' -H 'Accept-Language: cs,en-GB;q=0.8,en;q=0.6,en-US;q=0.4' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Referer: https://portal.bcas.cz:4443/findBusinessCaseByFilter.do?use-session-filter=true&filtermeta-countAllRows=true&filtermeta-pagesize=25' -H 'Cookie: JSESSIONID=#{JSESSIONID}' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' --compressed --insecure"
csv_file    = 'contacts.csv'
File.delete csv_file

contact_urls = `curl --silent #{query_1} | grep #{grep} | awk -F '"' '{print $4}'`

contact_urls.split(/\n/).each_with_index do |contact_url, i|
  data = []
  query_2 = query_2_tmp % [contact_url]
  raw_html = `curl --silent #{query_2}`

  html = Nokogiri::HTML(raw_html)
  html.xpath(xpath_query).each do |item|
    data << item.attr('value')
    if i == 0
      headers << item.attr('name')
    end
  end

  CSV.open(csv_file, 'ab') do |csv|
    if i == 0
      csv << headers
    end
    csv << data
  end

  puts data.inspect

  sleep sleep_t
end