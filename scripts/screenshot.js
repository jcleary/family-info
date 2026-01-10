import { chromium } from "playwright";

const url = "http://127.0.0.1:8080/";
const path = "dist/images/screenshot.png";

const width = Number(process.env.SCREENSHOT_WIDTH || "800");
const height = Number(process.env.SCREENSHOT_HEIGHT || "480");

// If you want full-page screenshots, set FULL_PAGE=1 in the workflow env
const fullPage = process.env.FULL_PAGE === "1";

const browser = await chromium.launch({
  args: ["--no-sandbox", "--disable-setuid-sandbox"],
});

const page = await browser.newPage({ viewport: { width, height } });

// Go to page and wait for it to actually finish rendering
await page.goto(url, { waitUntil: "networkidle" });

// Optional: if fonts/icons load late, this helps in CI
await page.waitForTimeout(250);

// Take screenshot
await page.screenshot({ path, fullPage });

await browser.close();
