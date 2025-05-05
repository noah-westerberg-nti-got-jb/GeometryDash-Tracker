import { test, expect } from '@playwright/test';

function sleep(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

test('wsp slutprojekt test', async ({ page }) => {
  await page.goto('http://localhost:9292/');

  await sleep(30)

  // Click the get started link.
  await page.getByRole('link', { name: 'create an account' }).click();

  await sleep(500);
  
  // create an account
  await expect(page).toHaveURL(/.*\/users\/new.*/);

  const username = "username"
  const password = "password"
  await page.fill('input[name=username]', username);
  await page.fill('input[name=password]', password);

  await sleep(500);

  await page.getByRole('button', { name: 'Create Account' }).click();

  await sleep(20);

  // login
  await expect(page).toHaveURL(/.*\/users\/login.*/);

  await page.fill('input[name=username]', username);
  await page.fill('input[name=password]', password);

  await sleep(500);

  await page.getByRole('button', { name: 'Login' }).click();

  // home page
  await expect(page).toHaveURL(/.*\/.*/);
  await expect(page.getByText("GD-Tracker")).toBeVisible();
  await expect(page.getByText(username)).toBeVisible();

  // go to levels
  await page.getByRole('link', { name: 'Levels' }).click();
  await expect(page).toHaveURL(/.*\/levels.*/);

  // go to level
  const levelElement = page.locator('.level').first();
  const levelName = await levelElement.locator('.name').textContent();

  await sleep(500);

  await levelElement.click();
  
  await sleep(500);

  // add level to collection
  await page.getByRole('button', { name: 'Add to collection' }).click();
  await expect(page).toHaveURL(/.*\/collections.*/);
  await sleep(500);

  // create new collection
  await page.getByRole('button', { name: 'New collection' }).click();
  await expect(page.getByText("Create a new collection")).toBeVisible();

  const collectionName = "new collection"
  const collectionDescription = "collection description"
  await page.fill('input[name=name]', collectionName);
  await page.fill('input[name=description]', collectionDescription);

  await sleep(500);

  await page.getByRole('button', { name: 'Create' }).click();

  await expect(page.getByText(collectionName)).toBeVisible();
  await expect(page.getByText(collectionDescription)).toBeVisible();
  await expect(page.getByText(`${levelName}`)).toBeVisible();

  await sleep(500);

  // go to user page
  await page.locator('#profile-link a').click();
  await expect(page).toHaveURL(/.*\/users\/\d+.*/);

  await sleep(500);

  // go to edit user page
  await page.getByRole('button', { name: 'Edit' }).click();
  await expect(page).toHaveURL(/.*\/users\/\d+\/edit.*/);

  await sleep(500);

  // delete user
  await page.getByRole('button', { name: 'Delete Account' }).click();
  
  await expect(page).toHaveURL(/.*\/.*/);

  await sleep(500);

  // go to leaderboard
  await page.getByRole('link', { name: 'Leaderboard' }).click();
  await expect(page).toHaveURL(/.*\/leaderboard.*/);

  await sleep(500);

  // check if user was deleted
  await expect(page.getByText(username)).not.toBeVisible();

  // go to collections
  await page.getByRole('link', { name: 'Collections' }).click();
  await expect(page).toHaveURL(/.*\/collections.*/);

  await sleep(500);

  // check if collection was deleted
  await expect(page.getByText(collectionName)).not.toBeVisible();
  await expect(page.getByText(collectionDescription)).not.toBeVisible();
});