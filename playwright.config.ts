import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/frontend/e2e',
  timeout: 30_000,
  expect: {
    timeout: 10_000,
  },
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL || 'http://localhost:8081',
    trace: 'on-first-retry',
  },
  reporter: [['list']],
});
