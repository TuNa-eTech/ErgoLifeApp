import React, { useEffect, useState, useCallback } from 'react';
import { CheckCircle, UserPlus, Gift } from 'lucide-react';
import { ListSkeleton } from '../../../components/Skeletons';
import { ErrorState } from '../../../components/ErrorState';
import { EmptyState } from '../../../components/EmptyState';
import { adminApi, type RecentEvent } from '../../../api/admin';

const EVENT_CONFIG: Record<RecentEvent['type'], {
  icon: React.ElementType;
  bgColor: string;
  iconColor: string;
  badgeColor: string;
  badgeBg: string;
  label: string;
}> = {
  user_registered: {
    icon: UserPlus,
    bgColor: 'bg-blue-100',
    iconColor: 'text-blue-600',
    badgeColor: 'text-blue-600',
    badgeBg: 'bg-blue-50',
    label: 'New User',
  },
  activity_completed: {
    icon: CheckCircle,
    bgColor: 'bg-emerald-100',
    iconColor: 'text-emerald-600',
    badgeColor: 'text-emerald-600',
    badgeBg: 'bg-emerald-50',
    label: 'Activity',
  },
  redemption: {
    icon: Gift,
    bgColor: 'bg-purple-100',
    iconColor: 'text-purple-600',
    badgeColor: 'text-purple-600',
    badgeBg: 'bg-purple-50',
    label: 'Redemption',
  },
};

function formatTimeAgo(timestamp: string): string {
  const seconds = Math.floor(
    (Date.now() - new Date(timestamp).getTime()) / 1000
  );
  if (seconds < 60) return `${seconds}s ago`;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

export const RecentActivityList: React.FC = () => {
  const [events, setEvents] = useState<RecentEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(false);
    try {
      const response = await adminApi.getRecentEvents(10);
      setEvents(response.data?.data || []);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const renderContent = () => {
    if (loading) return <ListSkeleton />;
    if (error) return <ErrorState onRetry={fetchData} />;
    if (events.length === 0) return <EmptyState message="No recent events" />;

    return (
      <div className="flex-1 overflow-auto space-y-2">
        {events.map((event, i) => {
          const config = EVENT_CONFIG[event.type];
          const Icon = config.icon;
          return (
            <div key={i} className="flex items-center gap-4 p-3 hover:bg-slate-50 rounded-lg transition-colors">
              <div className={`w-10 h-10 rounded-full ${config.bgColor} flex items-center justify-center flex-shrink-0`}>
                <Icon className={`w-5 h-5 ${config.iconColor}`} />
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-slate-900 truncate">{event.description}</p>
                <p className="text-xs text-slate-500">{formatTimeAgo(event.timestamp)}</p>
              </div>
              <span className={`text-xs font-medium ${config.badgeColor} ${config.badgeBg} px-2 py-1 rounded-full flex-shrink-0`}>
                {config.label}
              </span>
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col h-[400px]">
       <div className="mb-4">
          <h3 className="text-lg font-bold text-slate-900">Recent System Events</h3>
          <p className="text-sm text-slate-500">Latest actions performed</p>
       </div>
       {renderContent()}
    </div>
  );
};
