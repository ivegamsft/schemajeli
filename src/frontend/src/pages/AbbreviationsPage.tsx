import { useState, useEffect } from 'react';
import { Plus, Trash2, Edit, Search } from 'lucide-react';
import { abbreviationService } from '../services/abbreviationService';
import { useAuth } from '../hooks/useAuth';
import type { Abbreviation } from '../types';
import { toast } from 'sonner';
import { formatDate } from '../lib/utils';

export default function AbbreviationsPage() {
  const { hasPermission } = useAuth();
  const [abbreviations, setAbbreviations] = useState<Abbreviation[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchQuery, setSearchQuery] = useState('');
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingAbbr, setEditingAbbr] = useState<Abbreviation | undefined>();
  const [formData, setFormData] = useState({ abbreviation: '', meaning: '' });

  useEffect(() => {
    loadAbbreviations();
  }, [page, searchQuery]);

  const loadAbbreviations = async () => {
    try {
      setLoading(true);
      const response = await abbreviationService.getAll(page, 20);
      setAbbreviations(response.data);
      setTotalPages(response.totalPages);
    } catch (error) {
      toast.error('Failed to load abbreviations');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Are you sure you want to delete this abbreviation?')) return;

    try {
      await abbreviationService.delete(id);
      toast.success('Abbreviation deleted successfully');
      loadAbbreviations();
    } catch (error) {
      toast.error('Failed to delete abbreviation');
      console.error(error);
    }
  };

  const handleOpenCreate = () => {
    setEditingAbbr(undefined);
    setFormData({ abbreviation: '', meaning: '' });
    setIsFormOpen(true);
  };

  const handleOpenEdit = (abbr: Abbreviation) => {
    setEditingAbbr(abbr);
    setFormData({ abbreviation: abbr.abbreviation, meaning: abbr.meaning });
    setIsFormOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!formData.abbreviation.trim() || !formData.meaning.trim()) {
      toast.error('Both fields are required');
      return;
    }

    try {
      if (editingAbbr) {
        await abbreviationService.update(editingAbbr.id, formData);
        toast.success('Abbreviation updated successfully');
      } else {
        await abbreviationService.create(formData);
        toast.success('Abbreviation created successfully');
      }
      setIsFormOpen(false);
      loadAbbreviations();
    } catch (error) {
      toast.error(editingAbbr ? 'Failed to update abbreviation' : 'Failed to create abbreviation');
      console.error(error);
    }
  };

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Abbreviations</h1>
          <p className="text-gray-600 mt-1">Manage database abbreviations and acronyms</p>
        </div>
        {hasPermission('EDITOR') && (
          <button
            onClick={handleOpenCreate}
            className="flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
          >
            <Plus className="w-5 h-5" />
            Add Abbreviation
          </button>
        )}
      </div>

      {/* Search Bar */}
      <div className="mb-6">
        <div className="relative">
          <Search className="absolute left-4 top-3 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search abbreviations..."
            value={searchQuery}
            onChange={(e) => {
              setSearchQuery(e.target.value);
              setPage(1);
            }}
            className="w-full pl-12 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>
      </div>

      {/* Content */}
      {loading ? (
        <div className="p-8">
          <div className="text-center py-12">
            <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary-500 border-r-transparent"></div>
            <p className="mt-2 text-gray-600">Loading abbreviations...</p>
          </div>
        </div>
      ) : abbreviations.length === 0 ? (
        <div className="p-8">
          <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
            <p className="text-gray-600 mb-4">No abbreviations found</p>
            {hasPermission('EDITOR') && (
              <button
                onClick={handleOpenCreate}
                className="inline-flex items-center gap-2 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
              >
                <Plus className="w-4 h-4" />
                Create First Abbreviation
              </button>
            )}
          </div>
        </div>
      ) : (
        <>
          <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Abbreviation
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Meaning
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
                {abbreviations.map((abbr) => (
                  <tr key={abbr.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-3 py-1 text-sm font-mono font-semibold rounded bg-gray-100 text-gray-800">
                        {abbr.abbreviation}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <p className="text-sm text-gray-900">{abbr.meaning}</p>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {formatDate(new Date(abbr.createdAt))}
                    </td>
                    {hasPermission('EDITOR') && (
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        <button
                          onClick={() => handleOpenEdit(abbr)}
                          className="text-primary-600 hover:text-primary-900 mr-3 p-2 hover:bg-primary-50 rounded"
                          title="Edit"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        {hasPermission('ADMIN') && (
                          <button
                            onClick={() => handleDelete(abbr.id)}
                            className="text-red-600 hover:text-red-900 p-2 hover:bg-red-50 rounded"
                            title="Delete"
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
          <div className="mt-6 flex justify-center gap-2">
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
        </>
      )}

      {/* Form Modal */}
      {isFormOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg shadow-lg max-w-md w-full mx-4">
            <div className="flex items-center justify-between p-6 border-b border-gray-200">
              <h2 className="text-xl font-semibold text-gray-900">
                {editingAbbr ? 'Edit Abbreviation' : 'Add Abbreviation'}
              </h2>
              <button
                onClick={() => setIsFormOpen(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Abbreviation
                </label>
                <input
                  type="text"
                  value={formData.abbreviation}
                  onChange={(e) => setFormData({ ...formData, abbreviation: e.target.value.toUpperCase() })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg font-mono font-semibold focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="e.g., PK"
                  maxLength={20}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Meaning
                </label>
                <textarea
                  value={formData.meaning}
                  onChange={(e) => setFormData({ ...formData, meaning: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none"
                  placeholder="e.g., Primary Key"
                  rows={3}
                />
              </div>

              <div className="flex gap-3 justify-end pt-4 border-t border-gray-200">
                <button
                  type="button"
                  onClick={() => setIsFormOpen(false)}
                  className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600"
                >
                  {editingAbbr ? 'Save Changes' : 'Add Abbreviation'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
