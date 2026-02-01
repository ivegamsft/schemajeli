/**
 * Backend API Tests
 * Tests for all endpoints
 */

import http from 'http';

const BASE_URL = 'http://localhost:8080';

// Helper function to make HTTP requests
function makeRequest(path, method = 'GET') {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      timeout: 5000,
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: jsonData,
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            headers: res.headers,
            body: data,
          });
        }
      });
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    req.end();
  });
}

// Test results tracking
let totalTests = 0;
let passedTests = 0;
let failedTests = 0;

async function test(name, fn) {
  totalTests++;
  try {
    await fn();
    console.log(`✅ PASS: ${name}`);
    passedTests++;
  } catch (error) {
    console.log(`❌ FAIL: ${name}`);
    console.log(`   Error: ${error.message}`);
    failedTests++;
  }
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

async function runTests() {
  console.log('\n========================================');
  console.log('  Backend API Tests');
  console.log('========================================\n');

  // Test 1: Health Check Endpoint
  await test('GET /health - returns 200 status', async () => {
    const response = await makeRequest('/health');
    assert(response.status === 200, `Expected status 200, got ${response.status}`);
  });

  await test('GET /health - returns ok status', async () => {
    const response = await makeRequest('/health');
    assert(response.body.status === 'ok', `Expected status "ok", got "${response.body.status}"`);
  });

  await test('GET /health - returns timestamp', async () => {
    const response = await makeRequest('/health');
    assert(response.body.timestamp, 'Expected timestamp in response');
    assert(typeof response.body.timestamp === 'string', 'Timestamp should be a string');
  });

  await test('GET /health - timestamp is valid ISO format', async () => {
    const response = await makeRequest('/health');
    const timestamp = new Date(response.body.timestamp);
    assert(!isNaN(timestamp.getTime()), 'Timestamp should be valid ISO date');
  });

  // Test 2: API Endpoint
  await test('GET /api/v1 - returns 200 status', async () => {
    const response = await makeRequest('/api/v1');
    assert(response.status === 200, `Expected status 200, got ${response.status}`);
  });

  await test('GET /api/v1 - returns correct message', async () => {
    const response = await makeRequest('/api/v1');
    assert(
      response.body.message === 'SchemaJeli API v1',
      `Expected message "SchemaJeli API v1", got "${response.body.message}"`
    );
  });

  await test('GET /api/v1 - returns version', async () => {
    const response = await makeRequest('/api/v1');
    assert(response.body.version, 'Expected version in response');
  });

  await test('GET /api/v1 - version is valid semver', async () => {
    const response = await makeRequest('/api/v1');
    const semverRegex = /^\d+\.\d+\.\d+$/;
    assert(
      semverRegex.test(response.body.version),
      `Expected valid semver format, got "${response.body.version}"`
    );
  });

  // Test 3: Error Handling
  await test('GET / - returns 404 for undefined route', async () => {
    const response = await makeRequest('/');
    assert(
      response.status === 404,
      `Expected status 404, got ${response.status}`
    );
  });

  await test('GET /nonexistent - returns 404 for undefined route', async () => {
    const response = await makeRequest('/nonexistent');
    assert(
      response.status === 404,
      `Expected status 404, got ${response.status}`
    );
  });

  // Test 4: Response Headers
  await test('GET /health - has Content-Type application/json', async () => {
    const response = await makeRequest('/health');
    const contentType = response.headers['content-type'];
    assert(
      contentType && contentType.includes('application/json'),
      `Expected Content-Type: application/json, got "${contentType}"`
    );
  });

  await test('GET /api/v1 - has Content-Type application/json', async () => {
    const response = await makeRequest('/api/v1');
    const contentType = response.headers['content-type'];
    assert(
      contentType && contentType.includes('application/json'),
      `Expected Content-Type: application/json, got "${contentType}"`
    );
  });

  // Print Summary
  console.log('\n========================================');
  console.log('  Test Summary');
  console.log('========================================');
  console.log(`Total Tests:  ${totalTests}`);
  console.log(`✅ Passed:    ${passedTests}`);
  console.log(`❌ Failed:    ${failedTests}`);
  console.log('========================================\n');

  process.exit(failedTests > 0 ? 1 : 0);
}

// Run tests
runTests().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
