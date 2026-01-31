import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus, Table as TableIcon, Trash2, Edit, Database as DatabaseIcon, Eye } from 'lucide-react';
import { tableService } from '../services/tableService';
import { databaseService } from '../services/databaseService';
import { useAuth } from '../hooks/useAuth';
import type { Table, Database } from '../types';
import { toast } from 'sonner';
import { formatDate } from '../lib/utils';

export default function TablesPage() {
  const navigate = useNavigate();
  const { hasPermission } = useAuth();
  const [tables, setTables] = useState<Table[]>([]);
  const [databases, setDatabases] = useState<Database[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedDatabase, setSelectedDatabase] = useState<number | undefined>();

  useEffect(() => {
    loadDatabases();
  }, []);

  useEffect(() => {
    loadTables();
  }, [page, selectedDatabase]);

  const loadDatabases = async () => {
    try {
      const response = await databaseService.getAll(1, 100);
      setDatabases(response.data);
    } catch (error) {
      console.error('Failed to load databases:', error);
    }
  };

  const loadTables = async () => {
    try {
      setLoading(true);
      const response = await tableService.getAll(page, 10, selectedDatabase);
      setTables(response.data);
      setTotalPages(response.totalPages);
    } catch (error) {
      toast.error('Failed to load tables');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number, name: string) => {
    if (!confirm(`Are you sure you want to delete table "${name}"?`)) return;

    try {
      await tableService.delete(id);
      toast.success('Table deleted successfully');
      loadTables();
    } catch (error) {
      toast.error('Failed to delete table');
      console.error(error);
    }
  };

  const handleViewDetails = (tableId: number) => {
    navigate(`/tables/${tableId}`);
  };

  const getDatabaseName = (databaseId: number) => {
    return databases.find((d) => d.id === databaseId)?.name || 'Unknown';
  };

  const getTableTypeColor = (type: string) => {
    switch (type) {
      case 'TABLE':
        return 'bg-blue-100 text-blue-800';
      case 'VIEW':
        return 'bg-green-100 text-green-800';
      case 'MATERIALIZED_VIEW':
        return 'bg-purple-100 text-purple-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Tables</h1>
          <p className="text-gray-600 mt-1">Manage database tables and views</p>
        </div>
        {hasPermission('EDITOR') && (
          <button className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
            <Plus className="w-5 h-5" />
            Add Table
          </button>
        )}
      </div>

      {/* Filter by Database */}
      <div className="mb-4 flex gap-2 items-center">
        <label className="text-sm font-medium text-gray-700">Filter by Database:</label>
        <select
          value={selectedDatabase || ''}
          onChange={(e) => {
            setSelectedDatabase(e.target.value ? Number(e.target.value) : undefined);
            setPage(1);
          }}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="">All Databases</option>
          {databases.map((database) => (
            <option key={database.id} value={database.id}>
              {database.name}
            </option>
          ))}
        </select>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary-500 border-r-transparent"></div>
          <p className="mt-2 text-gray-600">Loading tables...</p>
        </div>
      ) : tables.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
          <TableIcon className="w-12 h-12 mx-auto text-gray-400" />
          <p className="mt-2 text-gray-600">
            {selectedDatabase ? 'No tables found for this database' : 'No tables found'}
          </p>
          {hasPermission('EDITOR') && (
            <button className="mt-4 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
              Add your first table
            </button>
          )}
        </div>
      ) : (
        <>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Table Name
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Database
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Type
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Columns
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Created
                  </th>
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {tables.map((table) => (
                  <tr key={table.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <TableIcon className="w-5 h-5 text-gray-400 mr-3" />
                        <div>
                          <div className="text-sm font-medium text-gray-900">{table.name}</div>
                          {table.description && (
                            <div className="text-sm text-gray-500">{table.description}</div>
                          )}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center text-sm text-gray-900">
                        <DatabaseIcon className="w-4 h-4 text-gray-400 mr-2" />
                        {getDatabaseName(table.databaseId)}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getTableTypeColor(table.tableType)}`}>
                        {table.tableType}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {table._count?.elements || 0}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {formatDate(table.createdAt)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button
                        onClick={() => handleViewDetails(table.id)}
                        className="text-primary-600 hover:text-primary-900 mr-3"
                        title="View Details"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      {hasPermission('EDITOR') && (
                        <>
                          <button className="text-primary-600 hover:text-primary-900 mr-3">
                            <Edit className="w-4 h-4" />
                          </button>
                          {hasPermission('ADMIN') && (
                            <button
                              onClick={() => handleDelete(table.id, table.name)}
                              className="text-red-600 hover:text-red-900"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          )}
                        </>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="mt-4 flex justify-center gap-2">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={page === 1}
                className="px-4 py-2 border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
              >
                Previous
              </button>
              <span className="px-4 py-2 text-gray-700">
                Page {page} of {totalPages}
              </span>
              <button
                onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="px-4 py-2 border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-50"
              >
                Next
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
}
