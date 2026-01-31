import axios from '../lib/api';
import type { Abbreviation } from '../types';

export interface PaginatedResponse<T> {
  data: T[];
  totalPages: number;
}

async function getAll(page: number, limit: number): Promise<PaginatedResponse<Abbreviation>> {
  const response = await axios.get(`/abbreviations?page=${page}&limit=${limit}`);
  return response.data;
}

async function getById(id: number): Promise<Abbreviation> {
  const response = await axios.get(`/abbreviations/${id}`);
  return response.data;
}

async function create(data: {
  abbreviation: string;
  meaning: string;
}): Promise<Abbreviation> {
  const response = await axios.post('/abbreviations', data);
  return response.data;
}

async function update(
  id: number,
  data: {
    abbreviation: string;
    meaning: string;
  }
): Promise<Abbreviation> {
  const response = await axios.put(`/abbreviations/${id}`, data);
  return response.data;
}

async function delete_(id: number): Promise<void> {
  await axios.delete(`/abbreviations/${id}`);
}

export const abbreviationService = { getAll, getById, create, update, delete: delete_ };
