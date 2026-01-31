import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { X } from 'lucide-react';
import { toast } from 'sonner';
import type { Element, CreateElementData, UpdateElementData } from '../types';

const elementSchema = z.object({
  name: z.string().min(1, 'Column name is required').max(100, 'Name too long'),
  tableId: z.number().positive('Table is required'),
  dataType: z.string().min(1, 'Data type is required'),
  length: z.number().optional().nullable(),
  precision: z.number().optional().nullable(),
  scale: z.number().optional().nullable(),
  isPrimaryKey: z.boolean().optional(),
  isForeignKey: z.boolean().optional(),
  description: z.string().optional(),
});

type ElementFormData = z.infer<typeof elementSchema>;

interface ElementFormModalProps {
  isOpen: boolean;
  mode: 'create' | 'edit';
  tableId: number;
  editingElement?: Element;
  onClose: () => void;
  onSubmit: (data: CreateElementData | UpdateElementData) => Promise<void>;
}

const DATA_TYPES = [
  'BIGINT',
  'BIGSERIAL',
  'BIT',
  'BOOLEAN',
  'BYTEA',
  'CHAR',
  'CHARACTER',
  'DATE',
  'DECIMAL',
  'DOUBLE PRECISION',
  'INTEGER',
  'INTERVAL',
  'JSON',
  'JSONB',
  'MONEY',
  'NUMERIC',
  'REAL',
  'SMALLINT',
  'SMALLSERIAL',
  'SERIAL',
  'TEXT',
  'TIME',
  'TIMESTAMP',
  'TIMESTAMP WITH TIME ZONE',
  'UUID',
  'VARCHAR',
];

export default function ElementFormModal({
  isOpen,
  mode,
  tableId,
  editingElement,
  onClose,
  onSubmit,
}: ElementFormModalProps) {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
    watch,
  } = useForm<ElementFormData>({
    resolver: zodResolver(elementSchema),
    defaultValues: {
      tableId,
      dataType: 'VARCHAR',
      isPrimaryKey: false,
      isForeignKey: false,
    },
  });

  const dataType = watch('dataType');

  useEffect(() => {
    if (mode === 'edit' && editingElement) {
      reset({
        name: editingElement.name,
        tableId: editingElement.tableId,
        dataType: editingElement.dataType,
        length: editingElement.length || undefined,
        precision: editingElement.precision || undefined,
        scale: editingElement.scale || undefined,
        isPrimaryKey: editingElement.isPrimaryKey,
        isForeignKey: editingElement.isForeignKey,
        description: editingElement.description || undefined,
      });
    } else {
      reset({
        tableId,
        dataType: 'VARCHAR',
        isPrimaryKey: false,
        isForeignKey: false,
      });
    }
  }, [mode, editingElement, tableId, reset]);

  const handleFormSubmit = async (data: ElementFormData) => {
    try {
      // Clean up optional numeric fields
      const submitData = {
        ...data,
        length: data.length === null || data.length === undefined ? null : data.length,
        precision: data.precision === null || data.precision === undefined ? null : data.precision,
        scale: data.scale === null || data.scale === undefined ? null : data.scale,
      };

      await onSubmit(submitData as CreateElementData | UpdateElementData);
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
            {mode === 'create' ? 'Add Column' : 'Edit Column'}
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
          {/* Column Name */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Column Name
            </label>
            <input
              type="text"
              {...register('name')}
              className={`w-full px-4 py-2 border rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                errors.name ? 'border-red-500' : 'border-gray-300'
              }`}
              placeholder="e.g., user_id"
            />
            {errors.name && (
              <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
            )}
          </div>

          {/* Data Type */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Data Type
            </label>
            <select
              {...register('dataType')}
              className={`w-full px-4 py-2 border rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500 ${
                errors.dataType ? 'border-red-500' : 'border-gray-300'
              }`}
            >
              <option value="">Select data type</option>
              {DATA_TYPES.map((type) => (
                <option key={type} value={type}>
                  {type}
                </option>
              ))}
            </select>
            {errors.dataType && (
              <p className="mt-1 text-sm text-red-600">{errors.dataType.message}</p>
            )}
          </div>

          {/* Length - for VARCHAR, CHAR, etc */}
          {['VARCHAR', 'CHAR', 'CHARACTER', 'BIT'].includes(dataType) && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Length
              </label>
              <input
                type="number"
                {...register('length', { valueAsNumber: true })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="e.g., 255"
                min="1"
              />
            </div>
          )}

          {/* Precision and Scale - for NUMERIC, DECIMAL */}
          {['NUMERIC', 'DECIMAL'].includes(dataType) && (
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Precision
                </label>
                <input
                  type="number"
                  {...register('precision', { valueAsNumber: true })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="e.g., 10"
                  min="1"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Scale
                </label>
                <input
                  type="number"
                  {...register('scale', { valueAsNumber: true })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500"
                  placeholder="e.g., 2"
                  min="0"
                />
              </div>
            </div>
          )}

          {/* Checkboxes */}
          <div className="grid grid-cols-2 gap-4">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                {...register('isPrimaryKey')}
                className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-2 focus:ring-primary-500"
              />
              <span className="text-sm font-medium text-gray-700">Primary Key</span>
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                {...register('isForeignKey')}
                className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-2 focus:ring-primary-500"
              />
              <span className="text-sm font-medium text-gray-700">Foreign Key</span>
            </label>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              {...register('description')}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg font-sans focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none"
              placeholder="Optional description of this column"
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
                'Add Column'
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
