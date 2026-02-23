import React, { useEffect, useState } from 'react';
import { adminApi, type AdminActivity } from '../../api/admin';
import { ChevronLeft, ChevronRight, Loader2 } from 'lucide-react';

export const ActivitiesList: React.FC = () => {
  const [activities, setActivities] = useState<AdminActivity[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [fromDate, setFromDate] = useState('');
  const [toDate, setToDate] = useState('');

  const fetchActivities = async () => {
    setLoading(true);
    try {
      const res = await adminApi.getActivities(page, 20, undefined, undefined, fromDate || undefined, toDate || undefined);
      const d = res.data?.data;
      setActivities(d?.data || []);
      setTotalPages(d?.meta?.pages || 1);
    } catch { /* */ } finally { setLoading(false); }
  };

  useEffect(() => { fetchActivities(); }, [page, fromDate, toDate]);

  const formatDuration = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m}m ${s}s`;
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-slate-900">Activities Log</h2>
        <p className="text-slate-500">View all completed activities across the platform</p>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 p-4 flex gap-4 items-end flex-wrap">
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">From</label>
          <input type="date" value={fromDate} onChange={e => { setFromDate(e.target.value); setPage(1); }} className="px-3 py-2 rounded-lg border border-slate-200 text-sm" />
        </div>
        <div>
          <label className="block text-xs font-medium text-slate-500 mb-1">To</label>
          <input type="date" value={toDate} onChange={e => { setToDate(e.target.value); setPage(1); }} className="px-3 py-2 rounded-lg border border-slate-200 text-sm" />
        </div>
        {(fromDate || toDate) && (
          <button onClick={() => { setFromDate(''); setToDate(''); setPage(1); }} className="px-3 py-2 text-sm text-slate-500 hover:text-slate-700">Clear</button>
        )}
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-slate-50 border-b border-slate-200">
            <tr>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">User</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Task</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Duration</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Points</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">House</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Completed</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr><td colSpan={6} className="text-center py-12"><Loader2 className="w-5 h-5 animate-spin mx-auto text-slate-400" /></td></tr>
            ) : activities.length === 0 ? (
              <tr><td colSpan={6} className="text-center py-12 text-slate-400">No activities found</td></tr>
            ) : activities.map(a => (
              <tr key={a.id} className="hover:bg-slate-50">
                <td className="px-4 py-3 font-medium text-slate-900">{a.user?.displayName || 'Unknown'}</td>
                <td className="px-4 py-3 text-slate-700">{a.taskName}</td>
                <td className="px-4 py-3 text-slate-600">{formatDuration(a.durationSeconds)}</td>
                <td className="px-4 py-3">
                  <span className="font-medium text-emerald-600">+{a.pointsEarned} EP</span>
                  {a.bonusMultiplier > 1 && <span className="ml-1 text-xs text-amber-600">×{a.bonusMultiplier}</span>}
                </td>
                <td className="px-4 py-3 text-slate-600">{a.house?.name || '-'}</td>
                <td className="px-4 py-3 text-slate-500 text-xs">{new Date(a.completedAt).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-slate-200">
            <button onClick={() => setPage(p => Math.max(1, p - 1))} disabled={page === 1} className="p-2 rounded-lg hover:bg-slate-100 disabled:opacity-40"><ChevronLeft className="w-4 h-4" /></button>
            <span className="text-sm text-slate-500">Page {page} of {totalPages}</span>
            <button onClick={() => setPage(p => Math.min(totalPages, p + 1))} disabled={page === totalPages} className="p-2 rounded-lg hover:bg-slate-100 disabled:opacity-40"><ChevronRight className="w-4 h-4" /></button>
          </div>
        )}
      </div>
    </div>
  );
};
