'use strict';
const fs = require('node:fs');
const path = require('node:path');

// One server process owns this store. Persist each complete transition atomically.
class Store {
  constructor(file) {
    this.file = file;
    this.data = file && fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) :
      { sessions: {}, bartender: {}, rubik: {}, presence: {} };
  }
  save() {
    if (!this.file) return;
    fs.mkdirSync(path.dirname(this.file), { recursive: true });
    fs.writeFileSync(`${this.file}.tmp`, JSON.stringify(this.data));
    fs.renameSync(`${this.file}.tmp`, this.file);
  }
}
module.exports = { Store };
