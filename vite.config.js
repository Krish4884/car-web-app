// ~/car-web-app/vite.config.js

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  root: 'public', // <--- ADD THIS LINE
  build: {
    outDir: '../dist' // <--- ADD THIS LINE: This tells Vite to output compiled files to a 'dist' folder outside 'public'
  }
});
