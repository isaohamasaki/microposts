class WelcomeController < ApplicationController
	
	before_action :logged_in_user, only: [:create, :booklog, :amazon, :bookmeter]
	
  require 'capybara'
  require 'capybara/dsl'
  require 'capybara/poltergeist'
  
  include Capybara::DSL
  include WelcomeHelper

  def index
  end
  
  def create2
    p "start********************************"

    site_config("https://account.nicovideo.jp/login?site=niconico&time=1485659938&hash_key=e233515f&next_url=")
    
    driver_setting
    
    # ログイン
		visit('')
		fill_in "mail_tel",
		:with => 'testmailacount1001@gmail.com'
		fill_in "password",
		:with => 'sssggg'
		click_button "Login"
		
		# ユーザーページへ
		find('#siteHeaderUserContainer').click

    page.save_screenshot('picture/page.png')
		
		# マイリスト
		click_link 'My List'

		# 新しいマイリスト(1)
		find('#SYS_box_group_58149954 > a').click

    # 要素と要素数をピックアップ
    contents = find('#myContBody > div.articleBody').all('div.mylistVideo')
    
    # ループで要素を取り出す
    contents.each do |content|
      p "タイトル:  #{content.find('h5').text}"
      p content.find('li.play').text.gsub('Views', '再生数')
      p "投稿日:  #{content.find('p.date').text.split(' ／')[0].to_s}"
      p "url:  #{content.find('h5 > a')[:href]}"
    end

    p "end**********************************"
    redirect_to root_path
  end

  def booklog
    p "start********************************"
    url = "http://booklog.jp/item/1/" + params[:text]
    
    site_config(url)
    
    driver_setting
    
    visit('')
    
    loop do
		  
		  #レビューを取得
		  reviews = all('div.summary')
		  reviews.each do |review|
		    
		    rev = Review.new
		    
		    #星があるか判定
		    if review.has_selector?('div.rating-star-area > span')
		      rev.evalution = review.find('div.rating-star-area > span')[:content].to_i
		    end
		    
		    rev.comment = review.find("p[itemprop='description']").text
		    rev.source = "booklog"
		    rev.save!
		  end
		  
		  #次のページに移動するか判定
		  flag = 0
		  nexts = find('#mainArea > div.pagerArea').all('a')
		  nexts.each{|n| 
		    if n[:rel]=="next"
		    	flag = 1
		      p "次のページに移動します"
		      click_on ('»')
		      break
		    end
		  }
		  
		  #次のページがない場合
		  if flag == 0
		  	#redirect_to root_path
		  	p "end**********************************"
		  	return
		  end
		end
		
  end
  
  def amazon
    p "start********************************"
    
    url = "https://www.amazon.co.jp/product-reviews/" + params[:text] + "/ref=cm_cr_dp_see_all_summary?ie=UTF8&reviewerType=all_reviews&showViewpoints=1&sortBy=helpful"

    site_config(url)
    
    driver_setting
    
    # ログイン
		visit('')
		
	  loop do
	  
		  #save_and_open_page
		  
		  #レビューを取得
		  articles = all("div[class='a-section celwidget']")
		  articles.each do |article|
		  	rev = Review.new
		  	rev.evalution = article.find("i[data-hook='review-star-rating']")[:class][26,1].to_i
		  	rev.comment = article.find("span[class='a-size-base review-text']").text
		  	rev.source = "amazon"
		  	rev.save!
		  end
		  
		  #次のページに移動するか判定
		  flag = 0
		  nexts = find('#cm_cr-pagination_bar').all('a')
		  nexts.each{|n| 
		    if n.text=="次へ→"
		    	flag = 1
		      p "次のページに移動します"
		      
		      begin
		      	click_link ('次へ→')
		      rescue
		      	#redirect_to root_path
		  			p "end**********************************"
		  			return
		      end
		      
		      break
		    end
		  }
		  
		  #次のページがない場合
		  if flag == 0
		  	#redirect_to root_path
		  	p "end**********************************"
		  	return
		  end
    
    end
    
  end
  
  def bookmeter
  	p "start********************************"

		#ログインページに移動（ログインしないと一部のレビューしか見ることができないため）
    site_config("https://bookmeter.com/login")
    
    driver_setting
    
		visit('')
		
		fill_in "mail",
		:with => 'hikurochan@gmail.com'
		fill_in "password",
		:with => 'issa1309'
		click_button "ログイン"
		
		page.save_screenshot('picture/page.png')
		
		url = "http://bookmeter.com/b/" + params[:text]
		
		#商品ページに移動
		site_config(url)
		
		driver_setting
    
		visit('')
		
		loop do
		
			#レビューを取得
			comments = all("div[class='log_list_comment summary']")
			comments.each do |comment|
				rev = Review.new
				rev.comment = comment.text
				rev.source = "bookmeter"
				rev.save!
			end
			
			#次のページに移動するか判定
		  flag = 0
		  nexts = all('a')
		  nexts.each{|n| 
		    if n.text=="次へ→"
		    	flag = 1
		      p "次のページに移動します"
		      click_on ('次へ→')
		      break
		    end
		  }
		  
		  #次のページがない場合
		  if flag == 0
		  	#redirect_to root_path
		  	p "end**********************************"
		  	return
		  end
		
		end
		
  end
  
  def create
  	Review.destroy_all
  	booklog
  	amazon
  	bookmeter
  	@title = params[:text]
  	@reviews = Review.all
  	#redirect_to root_path
  end
  
end