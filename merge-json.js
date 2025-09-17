const fs = require('fs');
const glob = require('glob');

const NAME = "Wastebin";
const EXPORTED_AT = "2025-01-23T07:21:09+00:00";

const output = {};
const files = glob.sync('**/*.json', { ignore: ['node_modules/**', 'merged.json'] });

files.forEach(file => {
  output[file] = {
    name: NAME,
    exported_at: EXPORTED_AT
  };
});

fs.writeFileSync('merged.json', JSON.stringify(output, null, 2));