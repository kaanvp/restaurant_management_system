// sql-wasm.js - SQL.js WebAssembly loader
// This is a simplified version of the SQL.js library loader
var initSqlJs = function(config) {
  config = config || {};
  var wasmBinaryFile = config.wasmBinaryFile || 'sql-wasm.wasm';
  
  var Module = {};
  Module.locateFile = function(url) {
    return wasmBinaryFile;
  };
  
  return new Promise(function(resolve, reject) {
    // We'll load the wasm file dynamically
    var xhr = new XMLHttpRequest();
    xhr.open('GET', wasmBinaryFile, true);
    xhr.responseType = 'arraybuffer';
    xhr.onload = function() {
      if (xhr.status === 200) {
        // This is the binary data of the wasm file
        Module.wasmBinary = xhr.response;
        
        // This function will be called when the wasm module is loaded
        Module.onRuntimeInitialized = function() {
          resolve(Module);
        };
        
        // Load the JavaScript glue code
        var script = document.createElement('script');
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/sql.js/1.8.0/sql-wasm.js';
        script.onload = function() {
          // SQL.js has been loaded, and will automatically use our Module
        };
        script.onerror = function() {
          reject(new Error('Failed to load sql.js'));
        };
        document.body.appendChild(script);
      } else {
        reject(new Error('Failed to load wasm binary file'));
      }
    };
    xhr.onerror = function() {
      reject(new Error('Network error while loading wasm binary file'));
    };
    xhr.send(null);
  });
};
