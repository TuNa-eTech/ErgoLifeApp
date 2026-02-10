import React, { useEffect, useState, useCallback } from 'react';
import {
  BarChart,
  Bar,
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
import { adminApi, type StreakStats } from '../../../api/admin';

export const StreakStatsChart: React.FC = () => {
  const [data, setData] = useState<StreakStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(false);
    try {
      const response = await adminApi.getStreakStats();
      setData(response.data?.data || null);
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
    if (!data) return <EmptyState message="No streak data available" />;

    return (
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={data.distribution} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
          <CartesianGrid vertical={false} strokeDasharray="3 3" opacity={0.4} />
          <XAxis dataKey="range" axisLine={false} tickLine={false} />
          <YAxis axisLine={false} tickLine={false} />
          <Tooltip cursor={{fill: 'transparent'}} />
          <Bar dataKey="count" name="Users" fill="#F59E0B" radius={[4, 4, 0, 0]} />
        </BarChart>
      </ResponsiveContainer>
    );
  };

  const subtitle = data
    ? `Avg: ${data.avgStreak} days · Max: ${data.maxStreak} days`
    : 'Streak distribution overview';

  return (
    <ChartCard title="Streak Distribution" subtitle={subtitle}>
      {renderContent()}
    </ChartCard>
  );
};
