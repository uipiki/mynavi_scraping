require 'open-uri'
require 'nokogiri'

# スクレイピング test
$urlHeader = 'http://job.mynavi.jp'
$charset = nil
# http://job.mynavi.jp
url = $urlHeader + '/17/pc/search/query.html?OP:1/'
# http://job.mynavi.jp/17/pc/search/corp111394/employment.html
def getCorpId(doc) 
	doc.xpath("//input").each do |input|
		if input.attr('name') == "searchIdAllList" then
			return input.attr('value')
		end
	end
end

html = open(url) do |f|
	charset = f.charset
	f.read
end

corpIds = getCorpId(Nokogiri::HTML.parse(html, nil, $charset)).split(",")

def getCorpInfo(corpIds)
	corpIds.each do |id|
		corpUrl = $urlHeader + '/17/pc/search/corp' + id + '/employment.html'
		corpHtml = open(corpUrl) do |f|
			charset = f.charset
			f.read
		end
		corpDoc = Nokogiri::HTML.parse(corpHtml, nil, $charset)
		p corpDoc.title
	end
end

getCorpInfo(corpIds)

#http://job.mynavi.jp/17/pc/search/corp111394/employment.html