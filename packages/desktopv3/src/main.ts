import { app, BrowserWindow, protocol, ipcMain } from 'electron'
import { appRouter } from '@greenlight/platform'
import path from 'path'
import fs from 'fs'
import mime from 'mime'

import GreenlightServer from '@greenlight/server'

// Start websocket server
const server = new GreenlightServer();
server.start();


const createWindow = () => {
    const win = new BrowserWindow({
      width: 800,
      height: 600,
      backgroundColor: '#1a1b1e',
      webPreferences: {
        preload: path.join(__dirname, 'preload.js'),
        contextIsolation: true,
        nodeIntegration: false,
      },
    })

    win.loadURL('http://web/');
}

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit()
})

app.whenReady().then(async () => {

    await protocol.handle('http', async (request:any) => {
      const url = new URL(request.url);
      console.log('Loading file: ', url.pathname);
      const filePath = path.join(__dirname, 'web', url.pathname);
    
      try {
        const data = await fs.readFileSync(filePath);
        const mimeType = mime.getType(filePath) || 'text/plain';
        return new Response(data, {
          headers: { 'Content-Type': mimeType }
        });
      } catch (err) {

        if(! url.pathname.includes('.')) {
          // Assume we are using dynamic routing so we load the index.html file
          const indexPath = path.join(__dirname, 'web', 'index.html');
          try {
            const data = await fs.readFileSync(indexPath);
            const mimeType = mime.getType(indexPath) || 'text/plain';
            return new Response(data, {
              headers: { 'Content-Type': mimeType }
            });
          } catch (err) {
            console.error('Failed to load index', indexPath, err);
            return new Response('File not found', { status: 404 });
          }
        } else {
          // If we are not in a directory, we need to load the file as a 404
          console.error('Failed to load', filePath, err);
          return new Response('File not found', { status: 404 });
        }
      }
    });

    createWindow()
  
    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) createWindow()
    })
})