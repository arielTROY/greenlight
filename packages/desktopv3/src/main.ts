import { app, BrowserWindow, protocol } from 'electron'
import path from 'path'
import fs from 'fs'
import mime from 'mime'
// const __dirname = import.meta.dirname;

const createWindow = () => {
    const win = new BrowserWindow({
      width: 800,
      height: 600,
      backgroundColor: '#1a1b1e'
    })
  
    win.loadURL('file://web/index.html');
}

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit()
})

app.whenReady().then(async () => {

    await protocol.handle('file', async (request:any) => {
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
        console.error('Failed to load', filePath, err);
        return new Response('File not found', { status: 404 });
      }
    });

    createWindow()
  
    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) createWindow()
    })
})