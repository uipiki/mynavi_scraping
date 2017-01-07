mynavi scraping
===================
### 概要
mynaviの各社採用ページから
http://job.mynavi.jp/17/pc/search/corp111394/employment.html

 - 企業名
 - 従業員数
 - 募集人数
 - メールアドレス（あれば）
 - 電話番号(あれば）

を抽出し、csvファイル形式で出力します。
`会社名,従業員数,募集人数,メールアドレス,電話番号`

### How to run this script
 ` ruby main.rb --year {西暦の下2桁} --file {結果ファイル名称(絶対パス)}`

###Sample
 `$ruby main.rb --year 17 --file /Users/home/mynavi_scraping/result.csv`
 実行用shellのrun.shを用意しているので、
 `$./run.sh 17`
 でもok(引数ないと17で実行されます。)