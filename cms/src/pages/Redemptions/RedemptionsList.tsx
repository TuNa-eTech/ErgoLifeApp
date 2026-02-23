import React, { useEffect, useState } from 'react';
import { adminApi, type AdminRedemption } from '../../api/admin';
import { ChevronLeft, ChevronRight, Loader2, Check, X } from 'lucide-react';
import clsx from 'clsx';

const STATUSES = ['', 'PENDING', 'USED', 'EXPIRED'];

export const RedemptionsList: React.FC = () => {
  const [redemptions, setRedemptions] = useState<AdminRedemption[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [statusFilter, setStatusFilter] = useState('');

  const fetchRedemptions = async () => {
    setLoading(true);
    try {
      const res = await adminApi.getRedemptions(page, 20, statusFilter || undefined);
      const d = res.data?.data;
      setRedemptions(d?.data || []);
      setTotalPages(d?.meta?.pages || 1);
    } catch { /* */ } finally { setLoading(false); }
  };

  useEffect(() => { fetchRedemptions(); }, [page, statusFilter]);

  const handleStatusChange = async (id: string, newStatus: string) => {
    try {
      await adminApi.updateRedemptionStatus(id, newStatus);
      fetchRedemptions();
    } catch { alert('Failed to update status'); }
  };

  const statusBadge = (status: string) => {
    switch (status) {
      case 'PENDING': return 'bg-amber-100 text-amber-700';
      case 'USED': return 'bg-emerald-100 text-emerald-700';
      case 'EXPIRED': return 'bg-slate-100 text-slate-500';
      default: return 'bg-slate-100 text-slate-500';
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold text-slate-900">Redemptions</h2>
        <p className="text-slate-500">Manage reward redemptions and update statuses</p>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 p-4">
        <select value={statusFilter} onChange={e => { setStatusFilter(e.target.value); setPage(1); }} className="px-3 py-2 rounded-lg border border-slate-200 text-sm">
          <option value="">All Statuses</option>
          {STATUSES.filter(Boolean).map(s => <option key={s} value={s}>{s}</option>)}
        </select>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-slate-50 border-b border-slate-200">
            <tr>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">User</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Reward</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Points</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Status</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">House</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Date</th>
              <th className="text-left px-4 py-3 text-slate-600 font-semibold">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading ? (
              <tr><td colSpan={7} className="text-center py-12"><Loader2 className="w-5 h-5 animate-spin mx-auto text-slate-400" /></td></tr>
            ) : redemptions.length === 0 ? (
              <tr><td colSpan={7} className="text-center py-12 text-slate-400">No redemptions found</td></tr>
            ) : redemptions.map(r => (
              <tr key={r.id} className="hover:bg-slate-50">
                <td className="px-4 py-3 font-medium text-slate-900">{r.user?.displayName || 'Unknown'}</td>
                <td className="px-4 py-3 text-slate-700">{r.rewardTitle}</td>
                <td className="px-4 py-3 font-medium text-red-600">-{r.pointsSpent} EP</td>
                <td className="px-4 py-3">
                  <span className={clsx('inline-flex px-2 py-0.5 text-xs font-semibold rounded-full', statusBadge(r.status))}>{r.status}</span>
                </td>
                <td className="px-4 py-3 text-slate-600">{r.house?.name || '-'}</td>
                <td className="px-4 py-3 text-slate-500 text-xs">{new Date(r.redeemedAt).toLocaleDateString()}</td>
                <td className="px-4 py-3">
                  {r.status === 'PENDING' && (
                    <div className="flex gap-1">
                      <button onClick={() => handleStatusChange(r.id, 'USED')} className="p-1.5 rounded-lg hover:bg-emerald-50 text-slate-500 hover:text-emerald-600" title="Mark as Used">
                        <Check className="w-4 h-4" />
                      </button>
                      <button onClick={() => handleStatusChange(r.id, 'EXPIRED')} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-500 hover:text-red-600" title="Mark as Expired">
                        <X className="w-4 h-4" />
                      </button>
                    </div>
                  )}
                </td>
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
