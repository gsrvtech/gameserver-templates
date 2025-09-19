const fs = require('fs');
const glob = require('glob');

const EXPORTED_AT = new Date().toISOString();
const output = {};

const files = glob.sync('**/*.json', {
  ignore: [
    'node_modules/**',
    '**/node_modules/**',
    'merged.json',
    '**/merged.json',
    'package-lock.json',
    '**/package-lock.json',
    'package.json',
    '**/package.json'
  ]
});

files.forEach(file => {
  try {
    const content = JSON.parse(fs.readFileSync(file, 'utf8'));

    const nameValue = typeof content.name === 'string' && content.name.trim()
      ? content.name
      : "Unknown";

    output[file] = {
      name: nameValue,
      exported_at: EXPORTED_AT
    };
  } catch (err) {
    console.error(`Errors when reading ${file}:`, err.message);
  }
});

fs.writeFileSync('merged.json', JSON.stringify(output, null, 2));
console.log(`merged.json with ${Object.keys(output).length} Entries created`);
