#I have to install ffi gem (for programmatically loading dynamically-linked native libraries, binding functions within them)
#I have to update chrome to 81 version 
require "selenium-webdriver"
include Selenium
include Selenium::WebDriver
cfile=ARGV[0]
pageToLike=ARGV[1]
numberOfPostsToLike=ARGV[2].to_i  #ARGV intake as string
wait=Wait.new(:timeout=>30000) #wait for given time

# alternate method
# options=Selenium::WebDriver::Chrome::Options.new(args: ['start-maximized','--disable-notifications'])
# driver=Selenium::WebDriver.for(:chrome,options:options)

#options = Chrome::Options.new(args: ['start-maximized','--disable-notifications']) for this we don't need to add arguments separately

options = Chrome::Options.new()
options.add_argument('--disable-notifications')
options.add_argument('start-maximized')
driver = WebDriver.for(:chrome, options: options)
file=File.read(cfile)
map=JSON.parse(file)
username=map['username']
password=map['password']
url=map['url']

driver.get(url)
wait.until{driver.find_element(:css,'#email')} #wait for email field to load
 
email=driver.find_element(:css,'#email')
email.send_keys(username)

pass=driver.find_element(:css,'#pass')
pass.send_keys(password)


loginButton=driver.find_element(:css,'#loginbutton')
loginButton.click()
wait.until{driver.find_element(:css,'[data-testid=search_input]')} #search box of fb

searchBar=driver.find_element(:css,'[data-testid=search_input]')
searchBar.send_keys(pageToLike)
searchBar.send_keys(:arrow_down)
searchBar.send_keys(:enter)
wait.until{driver.find_element(:css,'div._6v_0._4ik4._4ik5 a')}  #pagelink 

pageLink=driver.find_element(:css,'div._6v_0._4ik4._4ik5 a')#post button on LHS
pageLink.click()
wait.until{driver.find_element(:css,'[data-key=tab_posts]')}

posts=driver.find_element(:css,'[data-key=tab_posts]') #posts
posts.click()

wait.until{driver.find_element(:css,'#pagelet_timeline_main_column ._1xnd > ._4-u2._4-u8')}

index=0;

while (index < numberOfPostsToLike)
    wait.until{driver.find_element(:css,'.uiMorePagerLoader')}
    wait.until{driver.find_element(:css,'.uiMorePagerLoader').css_value('display')=='none'} #wait for loader to disapper
    #puts('hi')
    wait.until{driver.find_elements(:css,'#pagelet_timeline_main_column ._1xnd > ._4-u2._4-u8')} #we have used find_elements instead of find_element because it gives multiple objects
    elements=driver.find_elements(:css,'#pagelet_timeline_main_column ._1xnd > ._4-u2._4-u8') #collection of all posts
    #puts('hii')
    wait.until{elements[index].find_element(:css,'._666k')}
    likeButton=elements[index].find_element(:css,'._666k'); #likebutton click
    likeButton.click()
    #puts('hiii')
    index = index + 1

    if(index==elements.length)
        driver.execute_script('window.scrollTo(0,document.body.clientHeight)')
        sleep 3
    end
end
    

