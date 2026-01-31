import { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { ArrowLeft, Plus, Edit, Trash2, Key, Link as LinkIcon, Download } from 'lucide-react';
import { tableService } from '../services/tableService';
import { elementService } from '../services/elementService';
import { useAuth } from '../hooks/useAuth';
import type { Table, Element } from '../types';
import { toast } from 'sonner';
import { exportTableWithColumns } from '../lib/export';

export default function TableDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { hasPermission } = useAuth();
  const [table, setTable] = useState<Table | null>(null);
  const [elements, setElements] = useState<Element[]>([]);
  const [loading, setLoading] = useState(true);
  const [showExportMenu, setShowExportMenu] = useState(false);

  useEffect(() => {
    if (id) {
      loadTableDetails();
    }
  }, [id]);

  const loadTableDetails = async () => {
    try {
      setLoading(true);
      const tableData = await tableService.getById(Number(id));
      const elementsData = await elementService.getByTableId(Number(id));
      setTable(tableData);
      setElements(elementsData);
    } catch (error) {
      toast.error('Failed to load table details');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteElement = async (elementId: number, name: string) => {
    if (!confirm(`Are you sure you want to delete column "${name}"?`)) return;

    try {
      await elementService.delete(elementId);
      toast.success('Column deleted successfully');
      loadTableDetails();
    } catch (error) {
      toast.error('Failed to delete column');
      console.error(error);
    }
  };

  const handleExport = (format: 'csv' | 'json') => {
    if (!table) return;
    try {
      exportTableWithColumns(table, elements, format);
      toast.success(`Exported table schema as ${format.toUpperCase()}`);
      setShowExportMenu(false);
    } catch (error) {
      toast.error('Export failed');
      console.error(error);
    }
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="text-center py-12">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary-500 border-r-transparent"></div>
          <p className="mt-2 text-gray-600">Loading table details...</p>
        </div>
      </div>
    );
  }

  if (!table) {
    return (
      <div className="p-8">
        <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
          <p className="text-gray-600">Table not found</p>
          <Link
            to="/tables"
            className="mt-4 inline-block px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
          >
            Back to Tables
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-6">
        <button
          onClick={() => navigate('/tables')}
          className="flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Tables
        </button>
        <div className="flex justify-between items-start">
          <div>
            <h1 className="text-3xl font-bold text-gray-900">{table.name}</h1>
          <div className="flex gap-2">
            <div className="relative">
              <button
                onClick={() => setShowExportMenu(!showExportMenu)}
                className="flex items-center gap-2 px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
              >
                <Download className="w-5 h-5" />
                Export
              </button>
              {showExportMenu && (
                <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 z-10">
                  <button
                    onClick={() => handleExport('csv')}
                    className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                  >
                    Export as CSV
                  </button>
                  <button
                    onClick={() => handleExport('json')}
                    className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                  >
                    Export as JSON
                  </button>
                </div>
              )}
            </div>
            {hasPermission('EDITOR') && (
              <button className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
                <Plus className="w-5 h-5" />
                Add Column
              </button>
            )}
          </div>    {table.tableType}
              </span>
              <span className="text-sm text-gray-500">
                {elements.length} columns
              </span>
            </div>
          </div>
          {hasPermission('EDITOR') && (
            <button className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
              <Plus className="w-5 h-5" />
              Add Column
            </button>
          )}
        </div>
      </div>

      {/* Columns Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <h2 className="text-lg font-semibold text-gray-900">Columns</h2>
        </div>
        {elements.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-gray-600">No columns defined yet</p>
            {hasPermission('EDITOR') && (
              <button className="mt-4 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
                Add your first column
              </button>
            )}
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Position
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Column Name
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Data Type
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Length
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Constraints
                </th>
                {hasPermission('EDITOR') && (
                  <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                )}
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {elements.map((element, index) => (
                <tr key={element.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {index + 1}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{element.name}</div>
                      {element.description && (
                        <div className="text-sm text-gray-500">{element.description}</div>
                      )}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="px-2 py-1 text-xs font-mono rounded bg-gray-100 text-gray-800">
                      {element.dataType}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {element.length || '-'}
                    {element.precision && `, ${element.precision}`}
                    {element.scale && `, ${element.scale}`}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center gap-2">
                      {element.isPrimaryKey && (
                        <span className="flex items-center gap-1 px-2 py-1 text-xs font-semibold rounded bg-yellow-100 text-yellow-800">
                          <Key className="w-3 h-3" />
                          PK
                        </span>
                      )}
                      {element.isForeignKey && (
                        <span className="flex items-center gap-1 px-2 py-1 text-xs font-semibold rounded bg-blue-100 text-blue-800">
                          <LinkIcon className="w-3 h-3" />
                          FK
                        </span>
                      )}
                      {!element.isPrimaryKey && !element.isForeignKey && (
                        <span className="text-sm text-gray-400">-</span>
                      )}
                    </div>
                  </td>
                  {hasPermission('EDITOR') && (
                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                      <button className="text-primary-600 hover:text-primary-900 mr-3">
                        <Edit className="w-4 h-4" />
                      </button>
                      {hasPermission('ADMIN') && (
                        <button
                          onClick={() => handleDeleteElement(element.id, element.name)}
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
        )}
      </div>
    </div>
  );
}
