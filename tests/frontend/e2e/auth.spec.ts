import { test, expect } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.addInitScript(() => {
    localStorage.clear();
  });
});

test('login with valid credentials navigates to dashboard', async ({ page }) => {
  await page.goto('/login');

  await page.fill('input[name="email"]', 'admin@schemajeli.com');
  await page.fill('input[name="password"]', 'Admin@123');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL(/\/dashboard/);
  await expect(page.getByRole('heading', { name: /welcome back/i })).toBeVisible();
});

test('invalid login shows an error', async ({ page }) => {
  await page.goto('/login');

  await page.fill('input[name="email"]', 'admin@schemajeli.com');
  await page.fill('input[name="password"]', 'wrongpass');
  await Promise.all([
    page.waitForResponse((response) =>
      response.url().includes('/auth/login') && response.status() === 401
    ),
    page.click('button[type="submit"]'),
  ]);

  await expect(page).toHaveURL(/\/login/);
  await expect(page.getByRole('button', { name: /sign in/i })).toBeVisible();
});
