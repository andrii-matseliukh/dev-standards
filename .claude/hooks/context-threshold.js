#!/usr/bin/env node
'use strict';

// Plan-usage notifier — Stop hook for Claude Code.
// Notifies with SOUND + toast ONLY when model is Opus AND five_hour.utilization > 40%.

const MODEL = 'opus';
const THRESHOLD = 85;
const SOUND = path.join(__dirname, 'Windows Foreground.wav');


const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');
const { spawnSync } = require('child_process');

function readStdin() {
  try { return fs.readFileSync(0, 'utf8'); } catch (_) { return ''; }
}

function getToken() {
  try {
    const c = JSON.parse(fs.readFileSync(path.join(os.homedir(), '.claude', '.credentials.json'), 'utf8'));
    const o = c.claudeAiOauth || c.oauth || c;
    return o.accessToken || o.access_token || null;
  } catch (_) { return null; }
}

// Reads ~/.claude/settings.json — always reflects current /model selection, unlike transcript.
function currentModel() {
  try {
    const s = JSON.parse(fs.readFileSync(path.join(os.homedir(), '.claude', 'settings.json'), 'utf8'));
    return s.model || null;
  } catch (_) { return null; }
}

const TIMEOUT_MS = 8000;
function fetchUsage(token, cb) {
  const req = https.request('https://api.anthropic.com/api/oauth/usage', {
    method: 'GET',
    headers: {
      Authorization: 'Bearer ' + token,
      'Content-Type': 'application/json',
      'anthropic-beta': 'oauth-2025-04-20',
      'User-Agent': 'claude-cli',
    },
    timeout: TIMEOUT_MS,
  }, (res) => {
    let body = '';
    res.on('data', (d) => (body += d));
    res.on('end', () => cb(null, res.statusCode, body));
  });
  req.on('error', (e) => cb(e));
  req.on('timeout', () => { req.destroy(new Error('timeout')); });
  req.end();
}

function notify(title, message) {
  try {
    const ps =
      'Import-Module BurntToast;' +
      `(New-Object System.Media.SoundPlayer '${SOUND}').PlaySync();` +
      `New-BurntToastNotification -Text '${title.replace(/'/g, "''")}', '${message.replace(/'/g, "''")}' -Silent;`;
    spawnSync('powershell', ['-NoProfile', '-Command', ps], { stdio: 'ignore' });
  } catch (_) {}
}

function main() {
  // Drain stdin so Claude Code's pipe doesn't block; payload itself is unused.
  readStdin();

  const model = currentModel();
  const isOpus = !!model && new RegExp(MODEL, 'i').test(model);
  if (!isOpus) { process.exit(0); return; }

  const token = getToken();
  if (!token) { process.exit(0); return; }

  fetchUsage(token, (err, status, body) => {
    if (!err && status === 200) {
      let u;
      try { u = JSON.parse(body); } catch (_) {}
      const pct = u && u.five_hour ? u.five_hour.utilization : null;
      if (pct != null && pct > THRESHOLD) {
        notify('Claude usage', `${pct}% is used, be carefull`);
      }
    }
    process.exit(0);
  });
}

main();
