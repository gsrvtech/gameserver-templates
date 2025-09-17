const fs = require('fs');
const glob = require('glob');

// Read "name" from package.json
let NAME = "Unknown";
try {
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  if (pkg.name) {
    NAME = pkg.name;
  }
} catch (err) {
  console.error("Could not read package.json:", err.message);
}

const EXPORTED_AT = new Date().toISOString(); // dynamic timestamp

const output = {};
const files = glob.sync('**/*.json', { 
  ignore: [
    'node_modules/**',
    'merged.json',
    'package-lock.json',
    'package.json',
    './package.json'
  ]
});

files.forEach(file => {
  output[file] = {
    name: NAME,
    exported_at: EXPORTED_AT
  };
});

fs.writeFileSync('merged.json', JSON.stringify(output, null, 2));