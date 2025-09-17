const fs = require('fs');
const glob = require('glob');

const EXPORTED_AT = new Date().toISOString();
const output = {};

// Alle JSON-Dateien finden (außer node_modules und merged.json selbst)
const files = glob.sync('**/*.json', { 
  ignore: [
    'node_modules/**',
    'merged.json'
  ]
});

files.forEach(file => {
  try {
    const content = JSON.parse(fs.readFileSync(file, 'utf8'));

    // Name auslesen
    const nameValue = content.name || "Unknown";

    // Version rudimentär prüfen
    let versionValue = "Unknown";
    if (typeof content.version === "string") {
      if (content.version.startsWith("PLCN")) {
        versionValue = "pelican";
      } else if (content.version.startsWith("PTDL")) {
        versionValue = "pterodactyl";
      }
    }

    output[file] = {
      name: nameValue,
      version: versionValue,
      exported_at: EXPORTED_AT
    };
  } catch (err) {
    console.error(`Fehler beim Lesen von ${file}:`, err.message);
  }
});

fs.writeFileSync('merged.json', JSON.stringify(output, null, 2));
console.log(`merged.json mit ${Object.keys(output).length} Einträgen erstellt`);