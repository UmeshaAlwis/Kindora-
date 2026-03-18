const { contextBridge } = require('electron');

// Preload script - provides safe IPC to renderer process
contextBridge.exposeInMainWorld('electron', {
  platform: process.platform
});
