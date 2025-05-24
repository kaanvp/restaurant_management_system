// This file is a copy of the worker script from sqflite_common_ffi_web package
importScripts('sql-wasm.js');
const broadcast = self.postMessage.bind(self);

self.onmessage = async event => {
  const { id, action, params } = event.data;
  try {
    let result = null;
    switch (action) {
      case 'open':
        result = await open(params);
        break;
      case 'execute':
        result = execute(params);
        break;
      case 'batch':
        result = batch(params);
        break;
      default:
        throw new Error(`Unknown action ${action}`);
    }
    broadcast({ id, result });
  } catch (e) {
    broadcast({ id, error: String(e) });
  }
};

let db = null;

async function open(params) {
  if (db) {
    db.close();
  }
  
  const SQL = await initSqlJs();
  
  if (params.data) {
    db = new SQL.Database(params.data);
  } else {
    db = new SQL.Database();
  }
  
  return true;
}

function execute(params) {
  const { sql, arguments: args } = params;
  const stmt = db.prepare(sql);
  
  try {
    if (args && args.length > 0) {
      stmt.bind(args);
    }
    
    const result = [];
    while (stmt.step()) {
      result.push(stmt.getAsObject());
    }
    
    return {
      columns: stmt.getColumnNames(),
      rows: result
    };
  } finally {
    stmt.free();
  }
}

function batch(params) {
  const { operations } = params;
  const results = [];
  
  for (const op of operations) {
    results.push(execute(op));
  }
  
  return results;
}
