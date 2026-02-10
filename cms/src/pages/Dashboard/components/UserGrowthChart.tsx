import React, { useEffect, useState, useCallback } from 'react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer
} from 'recharts';
import { ChartCard } from '../../../components/ChartCard';
import { ChartSkeleton } from '../../../components/Skeletons';
import { ErrorState } from '../../../components/ErrorState';
import { EmptyState } from '../../../components/EmptyState';
import { adminApi, type GrowthItem } from '../../../api/admin';

export const UserGrowthChart: React.FC = () => {
  const [data, setData] = useState<GrowthItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(false);
    try {
      const response = await adminApi.getGrowthStats();
      setData(response.data?.data || []);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const renderContent = () => {
    if (loading) return <ChartSkeleton />;
    if (error) return <ErrorState onRetry={fetchData} />;
    if (data.length === 0) return <EmptyState message="No user registrations yet" />;

    return (
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={data} margin={{ top: 10, right: 30, left: 0, bottom: 0 }}>
          <defs>
            <linearGradient id="colorUsers" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#3B82F6" stopOpacity={0.8}/>
              <stop offset="95%" stopColor="#3B82F6" stopOpacity={0}/>
            </linearGradient>
          </defs>
          <XAxis dataKey="date" axisLine={false} tickLine={false} tickFormatter={(d) => new Date(d).toLocaleDateString('en', { month: 'short', day: 'numeric' })} />
          <YAxis axisLine={false} tickLine={false} />
          <CartesianGrid vertical={false} strokeDasharray="3 3" opacity={0.4} />
          <Tooltip labelFormatter={(d) => new Date(d as string).toLocaleDateString()} />
          <Area type="monotone" dataKey="count" name="New Users" stroke="#3B82F6" fillOpacity={1} fill="url(#colorUsers)" />
        </AreaChart>
      </ResponsiveContainer>
    );
  };

  return (
    <ChartCard title="User Growth" subtitle="New users over the last 30 days">
      {renderContent()}
    </ChartCard>
  );
};
