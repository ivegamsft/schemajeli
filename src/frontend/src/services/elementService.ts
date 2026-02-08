import apiClient from '../lib/api';
import type { Element, PaginatedResponse, CreateElementData, UpdateElementData } from '../types';

export const elementService = {
  /**
   * Get all elements with pagination
   */
  async getAll(page = 1, limit = 10, tableId?: string): Promise<PaginatedResponse<Element>> {
    const params: Record<string, any> = { page, limit };
    if (tableId) params.tableId = tableId;

    const response = await apiClient.get<{ status: string; data: PaginatedResponse<Element> }>(
      '/elements',
      { params }
    );
    return response.data.data;
  },

  /**
   * Get a single element by ID
   */
  async getById(id: string): Promise<Element> {
    const response = await apiClient.get<{ status: string; data: Element }>(
      `/elements/${id}`
    );
    return response.data.data;
  },

  /**
   * Get elements for a specific table
   */
  async getByTableId(tableId: string): Promise<Element[]> {
    const response = await apiClient.get<{ status: string; data: Element[] }>(
      `/tables/${tableId}/elements`
    );
    return response.data.data;
  },

  /**
   * Create a new element
   */
  async create(data: CreateElementData): Promise<Element> {
    const response = await apiClient.post<{ status: string; data: Element }>(
      '/elements',
      data
    );
    return response.data.data;
  },

  /**
   * Update an existing element
   */
  async update(id: string, data: UpdateElementData): Promise<Element> {
    const response = await apiClient.put<{ status: string; data: Element }>(
      `/elements/${id}`,
      data
    );
    return response.data.data;
  },

  /**
   * Delete an element
   */
  async delete(id: string): Promise<void> {
    await apiClient.delete(`/elements/${id}`);
  },

  /**
   * Reorder elements within a table
   */
  async reorder(tableId: string, elementIds: string[]): Promise<void> {
    await apiClient.post(`/tables/${tableId}/elements/reorder`, { elementIds });
  },
};
