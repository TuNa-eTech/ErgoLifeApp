import React, { useEffect, useState } from 'react';
import { adminApi, type DashboardStats } from '../api/admin';
import { Users, Home, Activity, Zap } from 'lucide-react';
import { StatCard } from '../components/StatCard';
import { StatCardSkeleton } from '../components/Skeletons';
import { ErrorState } from '../components/ErrorState';
import { UserGrowthChart } from './Dashboard/components/UserGrowthChart';
import { ActivityOverviewChart } from './Dashboard/components/ActivityOverviewChart';
import { HousePieChart } from './Dashboard/components/HousePieChart';
import { RecentActivityList } from './Dashboard/components/RecentActivityList';
import { StreakStatsChart } from './Dashboard/components/StreakStatsChart';
import { LeaderboardPreview } from './Dashboard/components/LeaderboardPreview';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const fetchStats = async () => {
    setLoading(true);
    setError(false);
    try {
      const response = await adminApi.getDashboardStats();
      setStats(response.data?.data || null);
    } catch (err) {
      console.error('Failed to fetch dashboard stats', err);
      setError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchStats(); }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">Dashboard Overview</h2>
          <p className="text-slate-500">Welcome back to the admin console.</p>
        </div>
      </div>

      {/* Stats Grid */}
      {error ? (
        <div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
          <ErrorState message="Failed to load dashboard stats" onRetry={fetchStats} />
        </div>
      ) : loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[1, 2, 3, 4].map((i) => <StatCardSkeleton key={i} />)}
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard
            title="Total Users"
            value={stats?.totalUsers || 0}
            icon={Users}
            color="bg-blue-500"
            trend={stats?.trends?.users}
          />
          <StatCard
            title="Total Houses"
            value={stats?.totalHouses || 0}
            icon={Home}
            color="bg-emerald-500"
            trend={stats?.trends?.houses}
          />
          <StatCard
            title="Activities Completed"
            value={stats?.totalActivities || 0}
            icon={Activity}
            color="bg-purple-500"
            trend={stats?.trends?.activities}
          />
          <StatCard
            title="Active Users (7d)"
            value={stats?.activeUsers || 0}
            icon={Zap}
            color="bg-amber-500"
            trend={stats?.trends?.activeUsers}
          />
        </div>
      )}

      {/* Charts Grid - Row 1 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <UserGrowthChart />
        <ActivityOverviewChart />
      </div>

      {/* Charts Grid - Row 2 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <HousePieChart />
        <StreakStatsChart />
      </div>

      {/* Charts Grid - Row 3 */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <RecentActivityList />
        <LeaderboardPreview />
      </div>
    </div>
  );
};
