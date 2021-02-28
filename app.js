const chromium = require('chrome-aws-lambda');
const puppeteer = require('puppeteer-core');

let response;

exports.lambdaHandler = async (event, context) => {
  let result = null;
  let browser = null;

  try {
    browser = await puppeteer.launch({
      args: chromium.args,
      defaultViewport: chromium.defaultViewport,
      executablePath: await chromium.executablePath,
      headless: chromium.headless,
    });

    let page = await browser.newPage();

    await page.goto(event.url || 'https://google.co.jp/');

    result = await page.title();
    console.log(result);
  } catch (error) {
    return context.fail(error);
  } finally {
    if (browser !== null) {
      await browser.close();
    }
  }
  
  try {
       // const ret = await axios(url);
       response = {
            'statusCode': 200,
            'body': JSON.stringify({
                message: result,
                // location: ret.data.trim()
           })
       }
   } catch (err) {
       console.log(err);
       return err;
   }

   return response

};