import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { X } from 'lucide-react';
import type { Table, CreateTableData, UpdateTableData } from '../types';

const tableSchema = z.object({
  name: z.string().min(1, 'Table name is required').max(100, 'Name too long'),
  databaseId: z.string().min(1, 'Database is required'),
  tableType: z.enum(['TABLE', 'VIEW', 'MATERIALIZED_VIEW']),
  description: z.string().optional(),
});

type TableFormData = z.infer<typeof tableSchema>;

interface TableFormModalProps {
  isOpen: boolean;
  mode: 'create' | 'edit';
  databaseId: string;
  editingTable?: Table;
  onClose: () => void;
  onSubmit: (data: CreateTableData | UpdateTableData) => Promise<void>;
}

export default function TableFormModal({
  isOpen,
  mode,
  databaseId,
  editingTable,
  onClose,
  onSubmit,
}: TableFormModalProps) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<TableFormData>({
    resolver: zodResolver(tableSchema),
    defaultValues: {
      databaseId,
      tableType: 'TABLE',
    },
  });

  useEffect(() => {
    if (mode === 'edit' && editingTable) {
      reset({
        name: editingTable.name,
        databaseId: editingTable.databaseId,
        tableType: editingTable.tableType as 'TABLE' | 'VIEW' | 'MATERIALIZED_VIEW',
        description: editingTable.description || undefined,
      });
    } else {
      reset({
        databaseId,
        tableType: 'TABLE',
      });
    }
  }, [mode, editingTable, databaseId, reset]);

  const handleFormSubmit = async (data: TableFormData) => {
    try {
      await onSubmit(data as CreateTableData | UpdateTableData);
      reset();
      onClose();
    } catch (error) {
      console.error('Form submission error:', error);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg max-w-2xl w-full mx-4">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">
            {mode === 'create' ? 'Create Table' : 'Edit Table'}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit(handleFormSubmit)} className="p-6 space-y-4">
          {/* Table Name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Table Name
            </label>
            <input
              type="text"
              {...register('name')}
              className={`w-full px-4 py-2 border rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                errors.name ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="e.g., users"
            />
            {errors.name && (
              <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
            )}
          </div>

          {/* Table Type */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Type
            </label>
            <select
              {...register('tableType')}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="TABLE">Table</option>
              <option value="VIEW">View</option>
              <option value="MATERIALIZED_VIEW">Materialized View</option>
            </select>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              {...register('description')}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none"
              placeholder="Optional description of this table"
              rows={3}
            />
          </div>

          {/* Buttons */}
          <div className="flex gap-3 justify-end pt-4 border-t border-gray-200">
            <button
              type="button"
              onClick={onClose}
              disabled={isSubmitting}
              className="px-4 py-2 text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 disabled:opacity-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 disabled:opacity-50 flex items-center gap-2"
            >
              {isSubmitting ? (
                <>
                  <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  {mode === 'create' ? 'Creating...' : 'Saving...'}
                </>
              ) : mode === 'create' ? (
                'Create Table'
              ) : (
                'Save Changes'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
