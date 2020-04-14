let fs=require('fs');
let puppeteer=require('puppeteer');
let cfile=process.argv[2];
let pageToSurf=process.argv[3];
let numberOfPostsToLike=parseInt(process.argv[4]);
(async function(){
  try{
     const browser=await puppeteer.launch({
         headless:false,
         defaultViewport:null,
         slowMo:20,
         args:['--start-maximized','--disable-notifications']
     });
     let content=await fs.promises.readFile(cfile,'utf-8');
     let object=JSON.parse(content);
     let username=object.username;
     let password=object.password;
     let url=object.url;
     let pages=await browser.pages();
     let page=pages[0];
     page.goto(url,{
         waitUntil:'networkidle0' //we can also use networkidle2
     });
     await page.waitForSelector('#email',{
         visible:true
     });
     await page.type('#email',username);
     await page.type('#pass',password);
     await page.click('#loginbutton');
     await page.waitForSelector('[data-testid=search_input]',{
         visible:true
     });
     await page.type('[data-testid=search_input]',pageToSurf);
     await page.keyboard.press('ArrowDown');
     await page.keyboard.press('Enter');
     await page.waitForSelector('div._6v_0._4ik4._4ik5 a',{
         visible:true
     });
     await page.click('div._6v_0._4ik4._4ik5 a');
     await page.waitForSelector('[data-key=tab_posts]',{
         visible:true
     });
     await page.click('[data-key=tab_posts]');
     await page.waitForSelector('#pagelet_timeline_main_column ._1xnd > ._4-u2._4-u8');
     let index=0;
     do{
         let posts=await page.$$('#pagelet_timeline_main_column ._1xnd > ._4-u2._4-u8');
        //  console.log(posts.length+posts[0]);
        await serveElement(posts[index]);
        index++;
        await page.waitForSelector('.uiMorePagerLoader',{
            hidden:true
        });
      }while(index<numberOfPostsToLike);
    }catch(err){
      console.log(err);
   }
})(); 

async function serveElement(post){
    let postToLike=await post.$('._666k');
    await postToLike.click();
}