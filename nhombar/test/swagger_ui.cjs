// Exercise the actual local Swagger UI and HTTP server without exposing a tunnel.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { chromium } = require('playwright');
const { createServer } = require('../../backend/src/server');
const { Store } = require('../../backend/src/store');

async function main() {
  const folder = fs.mkdtempSync(path.join(os.tmpdir(), 'nhombar-swagger-'));
  const server = createServer({ store: new Store(path.join(folder, 'state.json')) });
  let browser;
  try {
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    const base = `http://127.0.0.1:${server.address().port}`;
    browser = await chromium.launch({ headless: true,
      executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
    const page = await browser.newPage();
    const external = [];
    page.on('request', request => { if (!request.url().startsWith(base)) external.push(request.url()); });
    await page.goto(`${base}/docs`);
    const operation = route => page.locator('.opblock').filter({
      has: page.locator(`.opblock-summary-path[data-path="${route}"]`),
    });
    async function execute(route, method, status, body) {
      const block = operation(route);
      await block.locator('.opblock-summary').click();
      if (body) await block.locator('textarea.body-param__text').fill(JSON.stringify(body));
      const received = page.waitForResponse(response => response.url() === `${base}${route}` && response.request().method() === method);
      await block.getByRole('button', { name: 'Execute', exact: true }).click();
      const response = await received;
      assert.equal(response.status(), status);
      return response.json();
    }
    assert.equal((await execute('/api/v1/health', 'GET', 200)).status, 'ok');
    const session = await execute('/api/v1/sessions', 'POST', 201, { name: 'Giang vien' });
    await page.getByRole('button', { name: 'Authorize', exact: true }).first().click();
    const auth = page.locator('.auth-container').filter({ hasText: 'bearerAuth' });
    await auth.locator('input').fill(session.token);
    await auth.locator('button').filter({ hasText: /^Authorize$/ }).click();
    await page.locator('.modal-ux .btn-done').first().click();
    const room = await execute('/api/v1/bartender/rooms', 'POST', 201);
    assert.ok(room.room.players[session.uid]);
    assert.equal(JSON.parse(fs.readFileSync(path.join(folder, 'state.json'))).bartender[room.code].status, 'lobby');
    assert.deepEqual(external, []);
    console.log('Swagger UI: GET health 200; POST session 201; authorized POST room 201; local persistence; no external requests.');
  } finally {
    await browser?.close();
    server.closeAllConnections();
    await new Promise(resolve => server.close(resolve));
    assert.equal(path.dirname(folder), os.tmpdir());
    fs.rmSync(folder, { recursive: true, force: true });
  }
}
main().catch(error => { console.error(error); process.exitCode = 1; });
