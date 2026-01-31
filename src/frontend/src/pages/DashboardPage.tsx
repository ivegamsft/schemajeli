import { useState, useEffect } from 'react';
import { Server, Database, Table, BarChart3 } from 'lucide-react';
import { statsService } from '../services/statsService';
import { useAuth } from '../hooks/useAuth';
import type { StatsResponse } from '../types';
import { toast } from 'sonner';

export default function DashboardPage() {
  const { user } = useAuth();
  const [stats, setStats] = useState<StatsResponse | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      setLoading(true);
      const data = await statsService.getDashboardStats();
      setStats(data);
    } catch (error) {
      toast.error('Failed to load dashboard statistics');
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const StatCard = ({
    title,
    value,
    icon: Icon,
    color,
  }: {
    title: string;
    value: number;
    icon: any;
    color: string;
  }) => (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">{value}</p>
        </div>
        <div className={`p-3 rounded-lg ${color}`}>
          <Icon className="w-8 h-8 text-white" />
        </div>
      </div>
    </div>
  );

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900">
          Welcome back, {user?.firstName}!
        </h1>
        <p className="text-gray-600 mt-1">Here's an overview of your database ecosystem</p>
      </div>

      {loading ? (
        <div className="text-center py-12">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-primary-500 border-r-transparent"></div>
          <p className="mt-2 text-gray-600">Loading statistics...</p>
        </div>
      ) : stats ? (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <StatCard
              title="Total Servers"
              value={stats.totalServers || 0}
              icon={Server}
              color="bg-blue-500"
            />
            <StatCard
              title="Total Databases"
              value={stats.totalDatabases || 0}
              icon={Database}
              color="bg-green-500"
            />
            <StatCard
              title="Total Tables"
              value={stats.totalTables || 0}
              icon={Table}
              color="bg-purple-500"
            />
            <StatCard
              title="Total Columns"
              value={stats.totalElements || 0}
              icon={BarChart3}
              color="bg-orange-500"
            />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">
                Server Distribution
              </h2>
              {stats.serversByType && Object.keys(stats.serversByType).length > 0 ? (
                <div className="space-y-3">
                  {Object.entries(stats.serversByType).map(([type, count]) => (
                    <div key={type} className="flex items-center justify-between">
                      <span className="text-sm font-medium text-gray-700">{type}</span>
                      <div className="flex items-center gap-3">
                        <div className="w-32 bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-primary-500 h-2 rounded-full"
                            style={{
                              width: `${Math.min(
                                100,
                                ((count as number) / (stats.totalServers || 1)) * 100
                              )}%`,
                            }}
                          />
                        </div>
                        <span className="text-sm font-semibold text-gray-900 w-8 text-right">
                          {count}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-gray-500 text-sm">No servers yet</p>
              )}
            </div>

            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h2>
              <div className="space-y-2">
                <a
                  href="/servers"
                  className="block p-3 rounded-lg hover:bg-gray-50 border border-gray-200"
                >
                  <div className="flex items-center gap-3">
                    <Server className="w-5 h-5 text-primary-500" />
                    <span className="text-sm font-medium text-gray-900">Manage Servers</span>
                  </div>
                </a>
                <a
                  href="/databases"
                  className="block p-3 rounded-lg hover:bg-gray-50 border border-gray-200"
                >
                  <div className="flex items-center gap-3">
                    <Database className="w-5 h-5 text-primary-500" />
                    <span className="text-sm font-medium text-gray-900">
                      Manage Databases
                    </span>
                  </div>
                </a>
                <a
                  href="/search"
                  className="block p-3 rounded-lg hover:bg-gray-50 border border-gray-200"
                >
                  <div className="flex items-center gap-3">
                    <BarChart3 className="w-5 h-5 text-primary-500" />
                    <span className="text-sm font-medium text-gray-900">
                      Search Schema
                    </span>
                  </div>
                </a>
              </div>
            </div>
          </div>

          <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-start gap-3">
              <BarChart3 className="w-5 h-5 text-blue-600 mt-0.5" />
              <div>
                <h3 className="text-sm font-semibold text-blue-900">System Overview</h3>
                <p className="text-sm text-blue-700 mt-1">
                  You have {stats.totalServers} database servers managing{' '}
                  {stats.totalDatabases} databases with {stats.totalTables} tables and{' '}
                  {stats.totalElements} columns.
                </p>
              </div>
            </div>
          </div>
        </>
      ) : (
        <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
          <p className="text-gray-600">Unable to load statistics</p>
        </div>
      )}
    </div>
  );
}
