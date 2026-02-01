import { useState, useEffect } from 'react';
import { Plus, Database as DatabaseIcon, Trash2, Edit, Server as ServerIcon } from 'lucide-react';
import { databaseService } from '../services/databaseService';
import { serverService } from '../services/serverService';
import { useAuth } from '../hooks/useAuth';
import type { Database, Server, CreateDatabaseData, UpdateDatabaseData } from '../types';
import { toast } from 'sonner';
import { formatDate } from '../lib/utils';
import DatabaseFormModal from '../components/DatabaseFormModal';

export default function DatabasesPage() {
  const { hasPermission } = useAuth();
  const [databases, setDatabases] = useState<Database[]>([]);
  const [servers, setServers] = useState<Server[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [selectedServer, setSelectedServer] = useState<number | undefined>();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingDatabase, setEditingDatabase] = useState<Database | undefined>();
  const [modalMode, setModalMode] = useState<'create' | 'edit'>('create');

  useEffect(() => {
    loadServers();
  }, []);

  useEffect(() => {
    loadDatabases();
  }, [page, selectedServer]);

  const loadServers = async () => {
    try {
      const response = await serverService.getAll(1, 100);
      setServers(response.data);
    } catch (error) {
      console.error('Failed to load servers:', error);
    }
  };

  const loadDatabases = async () => {
    try {
      setLoading(true);
      const response = await databaseService.getAll(page, 10, selectedServer);
      setDatabases(response.data);
      setTotalPages(response.totalPages);
    } catch (error) {
      toast.error('Failed to load databases');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number, name: string) => {
    if (!confirm(`Are you sure you want to delete database "${name}"?`)) return;

    try {
      await databaseService.delete(id);
      toast.success('Database deleted successfully');
      loadDatabases();
    } catch (error) {
      toast.error('Failed to delete database');
      console.error(error);
    }
  };

  const getServerName = (serverId: number) => {
    return servers.find((s) => s.id === serverId)?.name || 'Unknown';
  };

  const handleCreate = () => {
    setEditingDatabase(undefined);
    setModalMode('create');
    setIsModalOpen(true);
  };

  const handleEdit = (database: Database) => {
    setEditingDatabase(database);
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleSubmit = async (data: CreateDatabaseData | UpdateDatabaseData) => {
    if (modalMode === 'create') {
      await databaseService.create(data as CreateDatabaseData);
    } else if (editingDatabase) {
      await databaseService.update(editingDatabase.id, data as UpdateDatabaseData);
    }
    loadDatabases();
  };

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Databases</h1>
          <p className="text-gray-600 mt-1">Manage your database schemas and metadata</p>
        </div>
        {hasPermission('EDITOR') && (
          <button className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
            <Plus className="w-5 h-5" />
            Add Database
          </button>
        )}
      </div>

      {/* Filter by Server */}
      <div className="mb-4 flex gap-2 items-center">
        <label className="text-sm font-medium text-gray-700">Filter by Server:</label>
        <select
          value={selectedServer || ''}
          onChange={(e) => {
            setSelectedServer(e.target.value ? Number(e.target.value) : undefined);
            setPage(1);
          }}
          className="px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
        >
          <option value="">All Servers</option>
          {servers.map((server) => (
            <option key={server.id} value={server.id}>
              {server.name}
            </option>
          ))}
        </select>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary-500 border-r-transparent"></div>
          <p className="mt-2 text-gray-600">Loading databases...</p>
        </div>
      ) : databases.length === 0 ? (
        <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
          <DatabaseIcon className="w-12 h-12 mx-auto text-gray-400" />
          <p className="mt-2 text-gray-600">
            {selectedServer ? 'No databases found for this server' : 'No databases found'}
          </p>
          {hasPermission('EDITOR') && (
            <button className="mt-4 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
              Add your first database
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
                    Database Name
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Server
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Purpose
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Tables
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Created
                  </th>
                  {hasPermission('EDITOR') && (
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  )}
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {databases.map((database) => (
                  <tr key={database.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <DatabaseIcon className="w-5 h-5 text-gray-400 mr-3" />
                        <div>
                          <div className="text-sm font-medium text-gray-900">{database.name}</div>
                          {database.description && (
                            <div className="text-sm text-gray-500">{database.description}</div>
                          )}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center text-sm text-gray-900">
                        <ServerIcon className="w-4 h-4 text-gray-400 mr-2" />
                        {getServerName(database.serverId)}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      {database.purpose && (
                        <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                          {database.purpose}
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {database._count?.tables || 0}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {formatDate(database.createdAt)}
                    </td>
                    {hasPermission('EDITOR') && (
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <button 
                          onClick={() => handleEdit(database)}
                          className="text-primary-600 hover:text-primary-900 mr-3"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        {hasPermission('ADMIN') && (
                          <button
                            onClick={() => handleDelete(database.id, database.name)}
                            className="text-red-600 hover:text-red-900"
                          >
                            <Trash2 className="w-4 h-4" />
                          </button>
                        )}
                      </td>
                    )}
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

      <DatabaseFormModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSubmit={handleSubmit}
        database={editingDatabase}
        servers={servers}
        mode={modalMode}
      />
                Next
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
}
