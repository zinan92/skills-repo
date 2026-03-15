/**
 * x-thread.ts — Post a multi-tweet thread to X
 * Usage: bun x-thread.ts <thread.json> [--profile <dir>]
 *
 * JSON format: [{"tweet": "text", "position": 1}, ...]
 * Opens Chrome with all tweets pre-filled as a thread. User reviews and posts.
 */

import { spawn } from 'node:child_process';
import fs from 'node:fs';
import { mkdir } from 'node:fs/promises';
import process from 'node:process';
import {
  CHROME_CANDIDATES_FULL,
  CdpConnection,
  findChromeExecutable,
  getDefaultProfileDir,
  getFreePort,
  sleep,
  waitForChromeDebugPort,
} from './x-utils.js';

const X_COMPOSE_URL = 'https://x.com/compose/post';

interface ThreadTweet {
  tweet: string;
  position: number;
}

async function postThread(tweets: ThreadTweet[], profileDir: string): Promise<void> {
  const chromePath = findChromeExecutable(CHROME_CANDIDATES_FULL);
  if (!chromePath) throw new Error('Chrome not found. Set X_BROWSER_CHROME_PATH env var.');

  await mkdir(profileDir, { recursive: true });
  const port = await getFreePort();
  console.log(`[x-thread] Launching Chrome with ${tweets.length} tweets (profile: ${profileDir})`);

  const chrome = spawn(chromePath, [
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${profileDir}`,
    '--no-first-run',
    '--no-default-browser-check',
    '--disable-blink-features=AutomationControlled',
    '--start-maximized',
    X_COMPOSE_URL,
  ], { stdio: 'ignore' });

  let cdp: CdpConnection | null = null;

  try {
    const wsUrl = await waitForChromeDebugPort(port, 30_000, { includeLastError: true });
    cdp = await CdpConnection.connect(wsUrl, 30_000, { defaultTimeoutMs: 15_000 });

    const targets = await cdp.send<{ targetInfos: Array<{ targetId: string; url: string; type: string }> }>('Target.getTargets');
    let pageTarget = targets.targetInfos.find((t) => t.type === 'page' && t.url.includes('x.com'));

    if (!pageTarget) {
      const { targetId } = await cdp.send<{ targetId: string }>('Target.createTarget', { url: X_COMPOSE_URL });
      pageTarget = { targetId, url: X_COMPOSE_URL, type: 'page' };
    }

    const { sessionId } = await cdp.send<{ sessionId: string }>('Target.attachToTarget', {
      targetId: pageTarget.targetId,
      flatten: true,
    });

    await cdp.send('Page.enable', {}, { sessionId });
    await cdp.send('Runtime.enable', {}, { sessionId });
    await cdp.send('Input.setIgnoreInputEvents', { ignore: false }, { sessionId });

    // Wait for first editor (handles login)
    console.log('[x-thread] Waiting for X editor...');
    await sleep(3000);

    // Wait until at least `count` tweet slots exist in the DOM
    const waitForTextareaCount = async (count: number, timeoutMs = 30_000): Promise<boolean> => {
      const start = Date.now();
      while (Date.now() - start < timeoutMs) {
        const result = await cdp!.send<{ result: { value: number } }>('Runtime.evaluate', {
          expression: `document.querySelectorAll('[data-testid="tweetTextarea_0"]').length`,
          returnByValue: true,
        }, { sessionId });
        if (result.result.value >= count) return true;
        await sleep(500);
      }
      return false;
    };

    const editorFound = await waitForTextareaCount(1, 60_000);
    if (!editorFound) {
      console.log('[x-thread] Editor not found. Please log in to X in the browser window.');
      console.log('[x-thread] Waiting for login...');
      const loggedIn = await waitForTextareaCount(1, 120_000);
      if (!loggedIn) throw new Error('Timed out waiting for X editor. Please log in first.');
    }

    // Fill each tweet
    for (let i = 0; i < tweets.length; i++) {
      const tweet = tweets[i];
      console.log(`[x-thread] Filling tweet ${i + 1}/${tweets.length}...`);

      if (i > 0) {
        // Give the previous insertText time to settle in React state
        await sleep(800);

        // Click the LAST addButton in DOM (each filled slot has its own "+",
        // querySelector returns the first — we need the last one for the current slot)
        const currentCount = await cdp.send<{ result: { value: number } }>('Runtime.evaluate', {
          expression: `document.querySelectorAll('[data-testid="tweetTextarea_0"]').length`,
          returnByValue: true,
        }, { sessionId });
        const beforeCount = currentCount.result.value;

        const clicked = await cdp.send<{ result: { value: string } }>('Runtime.evaluate', {
          expression: `
            (() => {
              // Always click the LAST addButton (belongs to the last filled slot)
              const btns = [...document.querySelectorAll('[data-testid="addButton"]')];
              const btn = btns.at(-1);
              if (btn) { btn.click(); return 'addButton-last (total btns=' + btns.length + ')'; }
              return 'not-found';
            })()
          `,
          returnByValue: true,
        }, { sessionId });

        console.log(`[x-thread] Add button: ${clicked.result.value}, slots before: ${beforeCount}`);

        // Wait for a new slot to appear (count should increase by 1)
        const appeared = await waitForTextareaCount(beforeCount + 1, 10_000);
        if (!appeared) {
          console.warn(`[x-thread] ⚠️  Slot ${i} not ready yet, waiting extra...`);
          await sleep(2000);
        }
      }

      // Focus the i-th tweet slot by DOM position (all slots share testid "tweetTextarea_0")
      const clickResult = await cdp.send<{ result: { value: string } }>('Runtime.evaluate', {
        expression: `
          (() => {
            const slots = document.querySelectorAll('[data-testid="tweetTextarea_0"]');
            const slot = slots[${i}];
            if (!slot) return 'slot-not-found (total=' + slots.length + ')';
            // Find inner contenteditable if present
            const editable = slot.querySelector('[contenteditable="true"]') || slot;
            editable.click();
            editable.focus();
            // Place cursor at end
            const range = document.createRange();
            range.selectNodeContents(editable);
            range.collapse(false);
            const sel = window.getSelection();
            sel?.removeAllRanges();
            sel?.addRange(range);
            return 'slot-' + ${i} + '-of-' + slots.length;
          })()
        `,
        returnByValue: true,
      }, { sessionId });
      console.log(`[x-thread] Focused: ${clickResult.result.value}`);

      await sleep(300);

      // Insert text into the focused element
      await cdp.send('Runtime.evaluate', {
        expression: `document.execCommand('insertText', false, ${JSON.stringify(tweet.tweet)})`,
      }, { sessionId });

      await sleep(400);
    }

    console.log(`\n[x-thread] ✅ All ${tweets.length} tweets filled.`);
    console.log('[x-thread] Review the thread in Chrome and click "Post all" to publish.');
    console.log('[x-thread] Press Ctrl+C to exit after posting.\n');

    // Keep alive until Chrome closes
    await new Promise<void>((resolve) => {
      const interval = setInterval(async () => {
        try {
          await cdp!.send('Target.getTargets');
        } catch {
          clearInterval(interval);
          resolve();
        }
      }, 2000);
      process.on('SIGINT', () => { clearInterval(interval); resolve(); });
    });

  } finally {
    try { cdp?.close(); } catch {}
    try { chrome.kill(); } catch {}
  }
}

// CLI
const args = process.argv.slice(2);
if (args.length === 0) {
  console.error('Usage: bun x-thread.ts <thread.json> [--profile <dir>]');
  process.exit(1);
}

const jsonFile = args[0];
if (!fs.existsSync(jsonFile)) {
  console.error(`File not found: ${jsonFile}`);
  process.exit(1);
}

const profileIdx = args.indexOf('--profile');
const profileDir = profileIdx >= 0 ? args[profileIdx + 1] : getDefaultProfileDir();

const raw = JSON.parse(fs.readFileSync(jsonFile, 'utf8')) as ThreadTweet[];
const tweets = [...raw].sort((a, b) => a.position - b.position);

console.log(`[x-thread] Loaded ${tweets.length} tweets from ${jsonFile}`);
postThread(tweets, profileDir).catch((err) => {
  console.error('[x-thread] Error:', err.message);
  process.exit(1);
});
