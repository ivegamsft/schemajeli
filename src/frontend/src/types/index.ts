// User and Authentication Types
export type UserRole = 'Admin' | 'Maintainer' | 'Viewer';

export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  isActive: boolean;
  lastLogin: string | null;
  createdAt: string;
  updatedAt: string;
}

// Server Types
export type RDBMSType = 'POSTGRESQL' | 'MYSQL' | 'ORACLE' | 'DB2' | 'INFORMIX';

export interface Server {
  id: string;
  name: string;
  host: string;
  port: number;
  rdbmsType: RDBMSType;
  description?: string;
  purpose?: string;
  location?: string;
  adminContact?: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string | null;
}

// Database Types
export interface Database {
  id: string;
  serverId: string;
  name: string;
  description?: string;
  purpose?: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string | null;
  server?: Server;
}

// Table Types
export type TableType = 'TABLE' | 'VIEW' | 'MATERIALIZED_VIEW';

export interface Table {
  id: string;
  databaseId: string;
  name: string;
  tableType: TableType;
  description?: string;
  rowCount?: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string | null;
  database?: Database;
  elements?: Element[];
}

// Element/Column Types
export interface Element {
  id: string;
  tableId: string;
  name: string;
  dataType: string;
  length?: number;
  precision?: number;
  scale?: number;
  position: number;
  isPrimaryKey: boolean;
  isForeignKey: boolean;
  isNullable: boolean;
  defaultValue?: string;
  description?: string;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string | null;
  table?: Table;
}

// Abbreviation Types
export interface Abbreviation {
  id: string;
  abbreviation: string;
  sourceWord: string;
  primeClass: string;
  category?: string;
  definition?: string;
  isPrimeClass: boolean;
  createdAt: string;
  updatedAt: string;
}

// Search Types
export interface SearchResults {
  servers: Server[];
  databases: Database[];
  tables: Table[];
  elements: Element[];
  abbreviations: Abbreviation[];
  total: number;
}

// API Response Types
export interface ApiResponse<T> {
  status: 'success' | 'error';
  data: T;
  message?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface StatsResponse {
  total: number;
  byType?: Record<string, number>;
  byStatus?: Record<string, number>;
}

// Form Types
export interface ServerFormData {
  name: string;
  host: string;
  port: number;
  rdbmsType: RDBMSType;
  description?: string;
  purpose?: string;
  location?: string;
  adminContact?: string;
}

export interface DatabaseFormData {
  serverId: string;
  name: string;
  description?: string;
  purpose?: string;
}

export interface TableFormData {
  databaseId: string;
  name: string;
  tableType: TableType;
  description?: string;
  rowCount?: number;
}

export interface ElementFormData {
  tableId: string;
  name: string;
  dataType: string;
  length?: number;
  precision?: number;
  scale?: number;
  position: number;
  isPrimaryKey: boolean;
  isForeignKey: boolean;
  isNullable: boolean;
  defaultValue?: string;
  description?: string;
}

// Create/Update Types
export type CreateServerData = ServerFormData;
export type UpdateServerData = Partial<ServerFormData>;

export type CreateDatabaseData = DatabaseFormData;
export type UpdateDatabaseData = Partial<DatabaseFormData>;

export type CreateTableData = TableFormData;
export type UpdateTableData = Partial<TableFormData>;

export type CreateElementData = ElementFormData;
export type UpdateElementData = Partial<ElementFormData>;

// UI State Types
export interface FilterState {
  search?: string;
  status?: 'active' | 'inactive';
  type?: string;
  page?: number;
  limit?: number;
}
