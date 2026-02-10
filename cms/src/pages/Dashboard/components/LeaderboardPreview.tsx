import React, { useEffect, useState, useCallback } from 'react';
import { Trophy, Crown, Medal } from 'lucide-react';
import { ListSkeleton } from '../../../components/Skeletons';
import { ErrorState } from '../../../components/ErrorState';
import { EmptyState } from '../../../components/EmptyState';
import { adminApi, type LeaderboardEntry } from '../../../api/admin';

const RANK_CONFIG: Record<number, { icon: React.ElementType; color: string }> = {
  1: { icon: Crown, color: 'text-amber-500' },
  2: { icon: Medal, color: 'text-slate-400' },
  3: { icon: Medal, color: 'text-amber-700' },
};

export const LeaderboardPreview: React.FC = () => {
  const [entries, setEntries] = useState<LeaderboardEntry[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(false);
    try {
      const response = await adminApi.getLeaderboardPreview(5);
      setEntries(response.data?.data || []);
    } catch {
      setError(true);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const renderContent = () => {
    if (loading) return <ListSkeleton rows={5} />;
    if (error) return <ErrorState onRetry={fetchData} />;
    if (entries.length === 0) return <EmptyState message="No leaderboard data" />;

    return (
      <div className="flex-1 overflow-auto space-y-2">
        {entries.map((entry) => {
          const rankConfig = RANK_CONFIG[entry.rank];
          const RankIcon = rankConfig?.icon || Trophy;
          const rankColor = rankConfig?.color || 'text-slate-400';

          return (
            <div key={entry.userId} className="flex items-center gap-4 p-3 hover:bg-slate-50 rounded-lg transition-colors">
              <div className="w-8 flex items-center justify-center">
                {entry.rank <= 3 ? (
                  <RankIcon className={`w-5 h-5 ${rankColor}`} />
                ) : (
                  <span className="text-sm font-bold text-slate-400">#{entry.rank}</span>
                )}
              </div>
              <div className="w-9 h-9 rounded-full bg-gradient-to-br from-indigo-400 to-purple-500 flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                {entry.displayName?.charAt(0)?.toUpperCase() || '?'}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-slate-900 truncate">{entry.displayName}</p>
              </div>
              <span className="text-sm font-bold text-indigo-600">
                {entry.totalPoints.toLocaleString()} pts
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
          <h3 className="text-lg font-bold text-slate-900">Top Users</h3>
          <p className="text-sm text-slate-500">Leaderboard by total points</p>
       </div>
       {renderContent()}
    </div>
  );
};
