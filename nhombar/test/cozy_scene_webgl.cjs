const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { chromium } = require('playwright');

async function main() {
  const browser = await chromium.launch({
    executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe',
    headless: true,
    args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
  });
  try {
    const page = await browser.newPage({ viewport: { width: 360, height: 270 } });
    const errors = [], external = [];
    page.on('pageerror', error => errors.push(String(error)));
    page.on('request', request => {
      // GLTFLoader uses local blob URLs for the texture embedded in the model.
      if (/^https?:/.test(request.url())) external.push(request.url());
    });
    const script = fs.readFileSync('assets/loading/cozy_cat.js', 'utf8');
    const model = fs.readFileSync('assets/loading/cat.glb').toString('base64');
    await page.setContent('<body style="margin:0;background:#fff8f1"><script>' +
      'window.CatStatus={postMessage:m=>{throw Error(m)}};' + script +
      ';window.loadCozyCat(' + JSON.stringify(model) + ',true);</script>');
    await page.waitForSelector('canvas');
    await page.waitForTimeout(250);
    const screenshot = path.join(os.tmpdir(), 'scan3d-cozy-cat.png');
    await page.screenshot({ path: screenshot });
    await page.evaluate(() => window.setCatActive(false));
    assert.deepEqual(errors, []);
    assert.deepEqual(external, []);
    assert.equal(await page.locator('canvas').count(), 1);
    console.log(JSON.stringify({ passed: true, externalRequests: 0, screenshot }));
  } finally {
    await browser.close();
  }
}
main().catch(error => { console.error(error); process.exitCode = 1; });
