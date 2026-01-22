
import React, { useEffect, useState } from 'react';
import { adminApi, type DashboardStats } from '../api/admin';
import { Users, Home, Activity, Zap } from 'lucide-react';
import clsx from 'clsx';

const StatCard: React.FC<{
  title: string;
  value: string | number;
  icon: React.ElementType;
  color: string;
}> = ({ title, value, icon: Icon, color }) => (
  <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center gap-4">
    <div className={clsx("p-4 rounded-xl", color)}>
      <Icon className="w-6 h-6 text-white" />
    </div>
    <div>
      <p className="text-sm font-medium text-slate-500">{title}</p>
      <h3 className="text-2xl font-bold text-slate-900">{value}</h3>
    </div>
  </div>
);

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await adminApi.getDashboardStats();
        setStats(response.data?.data || null);
      } catch (error) {
        console.error('Failed to fetch dashboard stats', error);
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  if (loading) return <div>Loading dashboard...</div>;

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-slate-900">Dashboard Overview</h2>
        <p className="text-slate-500">Welcome back to the admin console.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Users"
          value={stats?.totalUsers || 0}
          icon={Users}
          color="bg-blue-500"
        />
        <StatCard
          title="Total Houses"
          value={stats?.totalHouses || 0}
          icon={Home}
          color="bg-emerald-500"
        />
        <StatCard
          title="Activities Completed"
          value={stats?.totalActivities || 0}
          icon={Activity}
          color="bg-purple-500"
        />
        <StatCard
          title="Active Users (7d)"
          value={stats?.activeUsers || 0}
          icon={Zap}
          color="bg-amber-500"
        />
      </div>

      {/* Placeholder for future Charts */}
      <div className="bg-white p-8 rounded-2xl border border-slate-200 text-center py-20">
        <p className="text-slate-400">Charts coming soon...</p>
      </div>
    </div>
  );
};
