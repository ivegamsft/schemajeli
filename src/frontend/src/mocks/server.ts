import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api/v1';

export const handlers = [
  // Login
  http.post(`${API_BASE_URL}/auth/login`, async ({ request }) => {
    const body = await request.json() as { email: string; password: string };

    if (body.email === 'admin@schemajeli.com' && body.password === 'Admin@123') {
      return HttpResponse.json({
        status: 'success',
        data: {
          user: {
            id: '1',
            email: 'admin@schemajeli.com',
            firstName: 'Admin',
            lastName: 'User',
            role: 'Admin',
            isActive: true,
            lastLogin: null,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          },
          tokens: {
            accessToken: 'mock-access-token',
            refreshToken: 'mock-refresh-token',
          },
        },
      });
    }

    return HttpResponse.json(
      {
        status: 'error',
        message: 'Invalid credentials',
      },
      { status: 401 }
    );
  }),

  // Logout
  http.post(`${API_BASE_URL}/auth/logout`, () => {
    return HttpResponse.json({
      status: 'success',
      message: 'Logged out successfully',
    });
  }),

  // Refresh token
  http.post(`${API_BASE_URL}/auth/refresh`, () => {
    return HttpResponse.json({
      status: 'success',
      data: {
        accessToken: 'new-access-token',
      },
    });
  }),

  // Get current user
  http.get(`${API_BASE_URL}/auth/me`, ({ request }) => {
    const authHeader = request.headers.get('Authorization');
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return HttpResponse.json(
        {
          status: 'error',
          message: 'Unauthorized',
        },
        { status: 401 }
      );
    }

    return HttpResponse.json({
      status: 'success',
      data: {
        id: '1',
        email: 'admin@schemajeli.com',
        firstName: 'Admin',
        lastName: 'User',
        role: 'Admin',
        isActive: true,
        lastLogin: null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
    });
  }),
];

export const server = setupServer(...handlers);
