import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './index.css';
import App from './App.tsx';
import { initializeMsal } from './config/auth';

const rootElement = document.getElementById('root');

if (rootElement) {
  void initializeMsal().then(() => {
    createRoot(rootElement).render(
      <StrictMode>
        <App />
      </StrictMode>
    );
  });
}
