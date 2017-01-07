require 'open-uri'
require 'nokogiri'
require 'parallel'
require 'optparse'
require 'timeout'

params = ARGV.getopts("","year:17","file:")
$year = params["year"]
$resCsv = File.open(params["file"],'a')

$urlHeader = 'http://job.mynavi.jp'
$charset = nil
$TIME_OUT = 30

$errorIds = []

class CorpInfo
  def initialize(corpName,empNum,reqNum,mail,tel)
    @corpName = corpName
    @empNum = empNum
    @reqNum = reqNum
    @mail = mail
    @tel = tel 
  end
  def getData
  	return @corpName+","+@empNum+","+@reqNum+","+@mail+","+@tel
  end
  def printData
  	$resCsv.puts getData
  end
  def echoData
    puts getData
  end
end

#
# Parameter : document
#
def getCorpIdList(doc) 
  doc.xpath("//input").each do |input|
    if input.attr('name') == "searchIdAllList" then
      return input.attr('value')
    end
  end
end

#
# Parameter : String
#
def getCorpInfo(id)
  corpUrl = $urlHeader + '/' + $year + '/pc/search/corp' + id + '/employment.html'
  begin
  	Timeout.timeout($TIME_OUT) {
  		corpHtml = open(corpUrl) do |f|
        charset = f.charset
        f.read
      end
      corpDoc = Nokogiri::HTML.parse(corpHtml, nil, $charset)
      corpName = corpDoc.title.split('|')[0]
      p corpName
      empNum = getDataFromPlace(corpDoc,"従業員")
      reqNum = getDataFromPlace(corpDoc,"募集人数")
      mail = getMail(corpDoc)
      tel = getTel(corpDoc)
      return CorpInfo.new(corpName,empNum,reqNum,mail,tel)
    }
  rescue Timeout::Error => e
  	puts "timeout ......."
  	sleep(10)
  rescue => e
    p e.backtrace
  end
end

#
# Parameter : document , String
# class=placeにある、key (募集人数,従業員数)の取得を行う
# 
def getDataFromPlace(doc,key)
  dls = doc.xpath("//div[@class='place']//dl")
  selectedDl = dls.select do |dl|
    dl.children.search('dt').text == key
  end
  if selectedDl.size > 0 then
    return selectedDl[0].children.search('dd').text
  end
  return ""
end

#
# Parameter : document
# メールアドレスの取得を行う
# 先ずはE-mailから検索し、(実装済)
# 無ければ問い合わせ先から検索する。
# 
def getMail(doc)
  mailNode = getDataFromTr(doc,"E-mail")
  if mailNode.size > 0 then
    return mailNode.text
  end
  begin
    mailAry = getDataFromTr(doc,"問い合わせ先").children.select do |line|
      line.text.match(/@/) != nil
    end
    if mailAry.size > 0 then
      return mailAry[0].text
    end
    return ""
  rescue
  	return ""
  end
end

#
# Parameter : document,key
# trから情報の取得を行う
# 
def getDataFromTr(doc,key)
  trs = doc.xpath("//tr")
  inquireInfo = trs.select do |tr|
    tr.children.search('th').text == key
  end
  if inquireInfo.size > 0 then
    return inquireInfo[0].children.search('td')
  end
  return ""
end

#
# Parameter : document
# telの取得を行う
# 
def getTel(doc)
	begin
    telAry = getDataFromTr(doc,"問い合わせ先").children.select do |line|
      line.text.match(/TEL/i) != nil
    end
    if telAry.size > 0 then
      return telAry[0].text.delete('TEL').delete('^0-9|^-')
    end
    return ""
  rescue
  	return ""
  end
end

html = open($urlHeader + '/17/pc/search/query.html?OP:1/') do |f|
  charset = f.charset
  f.read
end

corpIds = getCorpIdList(Nokogiri::HTML.parse(html, nil, $charset)).split(",")

Parallel.map(corpIds,:in_threads => 10) {|id|
	begin
    getCorpInfo(id).printData
  rescue
  	puts "error id is " + id
  	p e.backtrace
  	$errorIds.push(id)
  end
}
$resCsv.close
p $errorIds