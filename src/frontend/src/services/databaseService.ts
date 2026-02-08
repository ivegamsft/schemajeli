import apiClient from '../lib/api';
import type { Database, PaginatedResponse, CreateDatabaseData, UpdateDatabaseData } from '../types';

export const databaseService = {
  /**
   * Get all databases with pagination
   */
  async getAll(page = 1, limit = 10, serverId?: string): Promise<PaginatedResponse<Database>> {
    const params: Record<string, any> = { page, limit };
    if (serverId) params.serverId = serverId;

    const response = await apiClient.get<{ status: string; data: PaginatedResponse<Database> }>(
      '/databases',
      { params }
    );
    return response.data.data;
  },

  /**
   * Get a single database by ID
   */
  async getById(id: string): Promise<Database> {
    const response = await apiClient.get<{ status: string; data: Database }>(
      `/databases/${id}`
    );
    return response.data.data;
  },

  /**
   * Get databases for a specific server
   */
  async getByServerId(serverId: string): Promise<Database[]> {
    const response = await apiClient.get<{ status: string; data: Database[] }>(
      `/servers/${serverId}/databases`
    );
    return response.data.data;
  },

  /**
   * Create a new database
   */
  async create(data: CreateDatabaseData): Promise<Database> {
    const response = await apiClient.post<{ status: string; data: Database }>(
      '/databases',
      data
    );
    return response.data.data;
  },

  /**
   * Update an existing database
   */
  async update(id: string, data: UpdateDatabaseData): Promise<Database> {
    const response = await apiClient.put<{ status: string; data: Database }>(
      `/databases/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Delete a database
   */
  async delete(id: string): Promise<void> {
    await apiClient.delete(`/databases/${id}`);
  },
};
