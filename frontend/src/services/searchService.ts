import apiClient from '../lib/api';
import type { Element, Table, Abbreviation } from '../types';

export interface SearchResults {
  elements: Element[];
  tables: Table[];
  abbreviations: Abbreviation[];
  totalResults: number;
}

export const searchService = {
  /**
   * Search across all entities
   */
  async search(query: string): Promise<SearchResults> {
    const response = await apiClient.get<{ status: string; data: SearchResults }>(
      '/search',
      { params: { q: query } }
    );
    return response.data.data;
  },

  /**
   * Search elements (columns)
   */
  async searchElements(query: string): Promise<Element[]> {
    const response = await apiClient.get<{ status: string; data: Element[] }>(
      '/elements/search',
      { params: { q: query } }
    );
    return response.data.data;
  },

  /**
   * Search tables
   */
  async searchTables(query: string): Promise<Table[]> {
    const response = await apiClient.get<{ status: string; data: Table[] }>(
      '/tables/search',
      { params: { q: query } }
    );
    return response.data.data;
  },

  /**
   * Search abbreviations
   */
  async searchAbbreviations(query: string): Promise<Abbreviation[]> {
    const response = await apiClient.get<{ status: string; data: Abbreviation[] }>(
      '/abbreviations/search',
      { params: { q: query } }
    );
    return response.data.data;
  },
};
