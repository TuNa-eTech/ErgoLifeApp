import React, { useEffect, useState, useCallback } from 'react';
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';
import { ChartCard } from '../../../components/ChartCard';
import { ChartSkeleton } from '../../../components/Skeletons';
import { ErrorState } from '../../../components/ErrorState';
import { EmptyState } from '../../../components/EmptyState';
import { adminApi, type HouseDistribution } from '../../../api/admin';

const PIE_COLORS = ['#6366F1', '#10B981'];

export const HousePieChart: React.FC = () => {
  const [data, setData] = useState<HouseDistribution | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(false);
    try {
      const response = await adminApi.getHouseDistribution();
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
    if (!data || data.total === 0) return <EmptyState message="No houses created yet" />;

    return (
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={data.distribution}
            cx="50%"
            cy="50%"
            innerRadius={60}
            outerRadius={80}
            paddingAngle={5}
            dataKey="value"
          >
            {data.distribution.map((_, index) => (
              <Cell key={`cell-${index}`} fill={PIE_COLORS[index % PIE_COLORS.length]} />
            ))}
          </Pie>
          <Tooltip />
          <Legend verticalAlign="bottom" height={36}/>
        </PieChart>
      </ResponsiveContainer>
    );
  };

  const subtitle = data
    ? `${data.total} houses · Avg ${data.avgMembers} members/group`
    : 'Distribution of house types';

  return (
    <ChartCard title="House Types" subtitle={subtitle}>
      {renderContent()}
    </ChartCard>
  );
};
