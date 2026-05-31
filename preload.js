const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("overlayAPI", {
  minimize: () => ipcRenderer.invoke("overlay:minimize"),
  close: () => ipcRenderer.invoke("overlay:close"),
  setClickThrough: enabled => ipcRenderer.invoke("overlay:click-through", enabled),
  resetWindow: () => ipcRenderer.invoke("overlay:reset-window"),
  onClickThroughChanged: callback => {
    ipcRenderer.on("overlay:click-through", (_event, enabled) => callback(enabled));
  }
});
