import apiClient from '../lib/api';
import type { StatsResponse } from '../types';

export const statsService = {
  /**
   * Get dashboard statistics
   */
  async getDashboardStats(): Promise<StatsResponse> {
    const response = await apiClient.get<{ status: string; data: StatsResponse }>(
      '/statistics/dashboard'
    );
    return response.data.data;
  },

  /**
   * Get server statistics
   */
  async getServerStats(serverId: string): Promise<StatsResponse> {
    const response = await apiClient.get<{ status: string; data: StatsResponse }>(
      `/statistics/servers/${serverId}`
    );
    return response.data.data;
  },

  /**
   * Get database statistics
   */
  async getDatabaseStats(databaseId: string): Promise<StatsResponse> {
    const response = await apiClient.get<{ status: string; data: StatsResponse }>(
      `/statistics/databases/${databaseId}`
    );
    return response.data.data;
  },
};
