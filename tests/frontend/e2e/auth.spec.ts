import { test, expect } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.addInitScript(() => {
    localStorage.clear();
  });
});

test('login page shows Microsoft sign-in button', async ({ page }) => {
  await page.goto('/login');

  await expect(page.getByRole('button', { name: /sign in with microsoft/i })).toBeVisible();
});

test('protected routes redirect to login when unauthenticated', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).toHaveURL(/\/login/);
});
