import apiClient from '../lib/api';
import type { Server, PaginatedResponse, CreateServerData, UpdateServerData } from '../types';

export const serverService = {
  /**
   * Get all servers with pagination
   */
  async getAll(page = 1, limit = 10): Promise<PaginatedResponse<Server>> {
    const response = await apiClient.get<{ status: string; data: PaginatedResponse<Server> }>(
      '/servers',
      { params: { page, limit } }
    );
    return response.data.data;
  },

  /**
   * Get a single server by ID
   */
  async getById(id: number): Promise<Server> {
    const response = await apiClient.get<{ status: string; data: Server }>(`/servers/${id}`);
    return response.data.data;
  },

  /**
   * Create a new server
   */
  async create(data: CreateServerData): Promise<Server> {
    const response = await apiClient.post<{ status: string; data: Server }>('/servers', data);
    return response.data.data;
  },

  /**
   * Update an existing server
   */
  async update(id: number, data: UpdateServerData): Promise<Server> {
    const response = await apiClient.put<{ status: string; data: Server }>(
      `/servers/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Delete a server
   */
  async delete(id: number): Promise<void> {
    await apiClient.delete(`/servers/${id}`);
  },
};
