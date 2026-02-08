import { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import type { Database, CreateDatabaseData, UpdateDatabaseData, Server } from '../types';
import { toast } from 'sonner';

const databaseSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  serverId: z.string().min(1, 'Server is required'),
  purpose: z.string().max(100).optional(),
  description: z.string().max(500).optional(),
});

type DatabaseFormData = z.infer<typeof databaseSchema>;

interface DatabaseFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: CreateDatabaseData | UpdateDatabaseData) => Promise<void>;
  database?: Database;
  servers: Server[];
  mode: 'create' | 'edit';
}

export default function DatabaseFormModal({
  isOpen,
  onClose,
  onSubmit,
  database,
  servers,
  mode,
}: DatabaseFormModalProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<DatabaseFormData>({
    resolver: zodResolver(databaseSchema),
    defaultValues: database
      ? {
          name: database.name,
          serverId: database.serverId,
          purpose: database.purpose || '',
          description: database.description || '',
        }
      : {
          name: '',
          serverId: servers[0]?.id || '',
          purpose: '',
          description: '',
        },
  });

  useEffect(() => {
    if (isOpen && database) {
      reset({
        name: database.name,
        serverId: database.serverId,
        purpose: database.purpose || '',
        description: database.description || '',
      });
    }
  }, [isOpen, database, reset]);

  const handleFormSubmit = async (data: DatabaseFormData) => {
    try {
      setIsSubmitting(true);
      await onSubmit(data);
      toast.success(mode === 'create' ? 'Database created successfully' : 'Database updated successfully');
      reset();
      onClose();
    } catch (error) {
      toast.error(mode === 'create' ? 'Failed to create database' : 'Failed to update database');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-md mx-4">
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold text-gray-900">
            {mode === 'create' ? 'Add New Database' : 'Edit Database'}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
            disabled={isSubmitting}
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit(handleFormSubmit)} className="p-6 space-y-4">
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-1">
              Database Name *
            </label>
            <input
              {...register('name')}
              type="text"
              id="name"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="customers_db"
            />
            {errors.name && (
              <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="serverId" className="block text-sm font-medium text-gray-700 mb-1">
              Server *
            </label>
            <select
              {...register('serverId')}
              id="serverId"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              {servers.map((server) => (
                <option key={server.id} value={server.id}>
                  {server.name} ({server.rdbmsType})
                </option>
              ))}
            </select>
            {errors.serverId && (
              <p className="mt-1 text-sm text-red-600">{errors.serverId.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="purpose" className="block text-sm font-medium text-gray-700 mb-1">
              Purpose
            </label>
            <input
              {...register('purpose')}
              type="text"
              id="purpose"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Production, Development, Testing..."
            />
            {errors.purpose && (
              <p className="mt-1 text-sm text-red-600">{errors.purpose.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              {...register('description')}
              id="description"
              rows={3}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Optional description..."
            />
            {errors.description && (
              <p className="mt-1 text-sm text-red-600">{errors.description.message}</p>
            )}
          </div>

          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              disabled={isSubmitting}
              className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 disabled:opacity-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="flex-1 px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600 disabled:opacity-50"
            >
              {isSubmitting ? 'Saving...' : mode === 'create' ? 'Create Database' : 'Update Database'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
