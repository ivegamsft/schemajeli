import apiClient from '../lib/api';
import type { Table, PaginatedResponse, CreateTableData, UpdateTableData } from '../types';

export const tableService = {
  /**
   * Get all tables with pagination
   */
  async getAll(page = 1, limit = 10, databaseId?: string): Promise<PaginatedResponse<Table>> {
    const params: Record<string, any> = { page, limit };
    if (databaseId) params.databaseId = databaseId;

    const response = await apiClient.get<{ status: string; data: PaginatedResponse<Table> }>(
      '/tables',
      { params }
    );
    return response.data.data;
  },

  /**
   * Get a single table by ID
   */
  async getById(id: string): Promise<Table> {
    const response = await apiClient.get<{ status: string; data: Table }>(`/tables/${id}`);
    return response.data.data;
  },

  /**
   * Get tables for a specific database
   */
  async getByDatabaseId(databaseId: string): Promise<Table[]> {
    const response = await apiClient.get<{ status: string; data: Table[] }>(
      `/databases/${databaseId}/tables`
    );
    return response.data.data;
  },

  /**
   * Create a new table
   */
  async create(data: CreateTableData): Promise<Table> {
    const response = await apiClient.post<{ status: string; data: Table }>('/tables', data);
    return response.data.data;
  },

  /**
   * Update an existing table
   */
  async update(id: string, data: UpdateTableData): Promise<Table> {
    const response = await apiClient.put<{ status: string; data: Table }>(
      `/tables/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Delete a table
   */
  async delete(id: string): Promise<void> {
    await apiClient.delete(`/tables/${id}`);
  },
};
