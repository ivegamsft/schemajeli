import { useState, useEffect } from 'react';
import { X } from 'lucide-react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import type { Server, CreateServerData, UpdateServerData } from '../types';
import { toast } from 'sonner';

const serverSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  hostName: z.string().min(1, 'Host name is required').max(255),
  portNumber: z.number().min(1).max(65535),
  rdbmsType: z.enum(['INFORMIX', 'POSTGRESQL', 'MYSQL', 'ORACLE', 'SQLSERVER', 'OTHER']),
  description: z.string().max(500).optional(),
});

type ServerFormData = z.infer<typeof serverSchema>;

interface ServerFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: CreateServerData | UpdateServerData) => Promise<void>;
  server?: Server;
  mode: 'create' | 'edit';
}

export default function ServerFormModal({
  isOpen,
  onClose,
  onSubmit,
  server,
  mode,
}: ServerFormModalProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<ServerFormData>({
    resolver: zodResolver(serverSchema),
    defaultValues: server
      ? {
          name: server.name,
          hostName: server.hostName,
          portNumber: server.portNumber,
          rdbmsType: server.rdbmsType,
          description: server.description || '',
        }
      : {
          name: '',
          hostName: '',
          portNumber: 5432,
          rdbmsType: 'POSTGRESQL',
          description: '',
        },
  });

  useEffect(() => {
    if (isOpen && server) {
      reset({
        name: server.name,
        hostName: server.hostName,
        portNumber: server.portNumber,
        rdbmsType: server.rdbmsType,
        description: server.description || '',
      });
    }
  }, [isOpen, server, reset]);

  const handleFormSubmit = async (data: ServerFormData) => {
    try {
      setIsSubmitting(true);
      await onSubmit(data);
      toast.success(mode === 'create' ? 'Server created successfully' : 'Server updated successfully');
      reset();
      onClose();
    } catch (error) {
      toast.error(mode === 'create' ? 'Failed to create server' : 'Failed to update server');
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
            {mode === 'create' ? 'Add New Server' : 'Edit Server'}
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
              Server Name *
            </label>
            <input
              {...register('name')}
              type="text"
              id="name"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="Production DB Server"
            />
            {errors.name && (
              <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="rdbmsType" className="block text-sm font-medium text-gray-700 mb-1">
              Database Type *
            </label>
            <select
              {...register('rdbmsType')}
              id="rdbmsType"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="POSTGRESQL">PostgreSQL</option>
              <option value="MYSQL">MySQL</option>
              <option value="ORACLE">Oracle</option>
              <option value="SQLSERVER">SQL Server</option>
              <option value="INFORMIX">Informix</option>
              <option value="OTHER">Other</option>
            </select>
            {errors.rdbmsType && (
              <p className="mt-1 text-sm text-red-600">{errors.rdbmsType.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="hostName" className="block text-sm font-medium text-gray-700 mb-1">
              Host Name *
            </label>
            <input
              {...register('hostName')}
              type="text"
              id="hostName"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="localhost or db.example.com"
            />
            {errors.hostName && (
              <p className="mt-1 text-sm text-red-600">{errors.hostName.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="portNumber" className="block text-sm font-medium text-gray-700 mb-1">
              Port Number *
            </label>
            <input
              {...register('portNumber', { valueAsNumber: true })}
              type="number"
              id="portNumber"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
              placeholder="5432"
            />
            {errors.portNumber && (
              <p className="mt-1 text-sm text-red-600">{errors.portNumber.message}</p>
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
              {isSubmitting ? 'Saving...' : mode === 'create' ? 'Create Server' : 'Update Server'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
