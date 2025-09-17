// merge-json.js
const fs = require('fs');
const path = require('path');
const glob = require('glob');

const NAME = "Wastebin";
const EXPORTED_AT = "2025-01-23T07:21:09+00:00";

const output = {};
const files = glob.sync('**/*.json', { ignore: ['node_modules/**', 'merged.json'] });

files.forEach(file => {
  try {
    const content = fs.readFileSync(file, 'utf8');
    const parsed = JSON.parse(content);
    parsed.name = NAME;
    parsed.exported_at = EXPORTED_AT;
    output[file] = parsed;
  } catch (err) {
    console.error(`Fehler beim Lesen von ${file}:`, err.message);
  }
});

fs.writeFileSync('merged.json', JSON.stringify(output, null, 2));