import React, { useEffect, useState } from 'react';
import { adminApi, type GiftReward, type GiftTransaction } from '../../api/admin';
import { Gift, Plus, Pencil, Trash2, X, Loader2, ChevronLeft, ChevronRight, ArrowRightLeft } from 'lucide-react';
import clsx from 'clsx';

const CATEGORIES = ['PRAISE', 'PRIVILEGE', 'EXPERIENCE', 'MOTIVATION'];

export const GiftRewardsList: React.FC = () => {
  const [rewards, setRewards] = useState<GiftReward[]>([]);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState<'rewards' | 'transactions'>('rewards');
  const [transactions, setTransactions] = useState<GiftTransaction[]>([]);
  const [txPage, setTxPage] = useState(1);
  const [txTotalPages, setTxTotalPages] = useState(1);
  const [txLoading, setTxLoading] = useState(false);
  const [showEditor, setShowEditor] = useState(false);
  const [editing, setEditing] = useState<GiftReward | null>(null);
  const [formKey, setFormKey] = useState('');
  const [formCategory, setFormCategory] = useState('PRAISE');
  const [formIcon, setFormIcon] = useState('favorite');
  const [formCost, setFormCost] = useState(10);
  const [formNameEn, setFormNameEn] = useState('');
  const [formNameVi, setFormNameVi] = useState('');
  const [saving, setSaving] = useState(false);

  const fetchRewards = async () => {
    setLoading(true);
    try {
      const res = await adminApi.getGiftRewards();
      setRewards(res.data?.data || []);
    } catch { /* */ } finally { setLoading(false); }
  };

  const fetchTransactions = async () => {
    setTxLoading(true);
    try {
      const res = await adminApi.getGiftTransactions(txPage, 20);
      const d = res.data?.data;
      setTransactions(d?.data || []);
      setTxTotalPages(d?.meta?.pages || 1);
    } catch { /* */ } finally { setTxLoading(false); }
  };

  useEffect(() => { fetchRewards(); }, []);
  useEffect(() => { if (tab === 'transactions') fetchTransactions(); }, [tab, txPage]);

  const handleDelete = async (id: string) => {
    if (!confirm('Delete this gift reward?')) return;
    try { await adminApi.deleteGiftReward(id); fetchRewards(); } catch { alert('Failed'); }
  };

  const openEditor = (reward?: GiftReward) => {
    if (reward) {
      setEditing(reward); setFormKey(reward.key); setFormCategory(reward.category);
      setFormIcon(reward.icon); setFormCost(reward.cost);
      setFormNameEn(reward.translations.find(t => t.locale === 'en')?.name || '');
      setFormNameVi(reward.translations.find(t => t.locale === 'vi')?.name || '');
    } else {
      setEditing(null); setFormKey(''); setFormCategory('PRAISE');
      setFormIcon('favorite'); setFormCost(10); setFormNameEn(''); setFormNameVi('');
    }
    setShowEditor(true);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const translations = [{ locale: 'en', name: formNameEn }, { locale: 'vi', name: formNameVi }].filter(t => t.name);
      if (editing) {
        await adminApi.updateGiftReward(editing.id, { category: formCategory, icon: formIcon, cost: formCost, translations });
      } else {
        await adminApi.createGiftReward({ key: formKey, category: formCategory, icon: formIcon, cost: formCost, translations });
      }
      setShowEditor(false); fetchRewards();
    } catch { alert('Failed to save'); } finally { setSaving(false); }
  };

  const getName = (r: GiftReward) => r.translations.find(t => t.locale === 'en')?.name || r.translations.find(t => t.locale === 'vi')?.name || r.key;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">Gift Rewards</h2>
          <p className="text-slate-500">Manage gift catalog and view transactions</p>
        </div>
        <button onClick={() => openEditor()} className="inline-flex items-center gap-2 px-4 py-2.5 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors font-medium text-sm">
          <Plus className="w-4 h-4" /> New Gift Reward
        </button>
      </div>

      <div className="flex gap-1 bg-slate-100 p-1 rounded-xl w-fit">
        <button onClick={() => setTab('rewards')} className={clsx('px-4 py-2 rounded-lg text-sm font-medium transition-colors', tab === 'rewards' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500')}>
          <Gift className="w-4 h-4 inline mr-2" />Rewards
        </button>
        <button onClick={() => setTab('transactions')} className={clsx('px-4 py-2 rounded-lg text-sm font-medium transition-colors', tab === 'transactions' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500')}>
          <ArrowRightLeft className="w-4 h-4 inline mr-2" />Transactions
        </button>
      </div>

      {tab === 'rewards' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Reward</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Key</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Category</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Cost</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Sent</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? <tr><td colSpan={6} className="text-center py-12"><Loader2 className="w-5 h-5 animate-spin mx-auto text-slate-400" /></td></tr> : rewards.map(r => (
                <tr key={r.id} className="hover:bg-slate-50">
                  <td className="px-4 py-3 font-medium text-slate-900">{getName(r)}</td>
                  <td className="px-4 py-3"><code className="text-xs bg-slate-100 px-2 py-0.5 rounded">{r.key}</code></td>
                  <td className="px-4 py-3"><span className="text-xs px-2 py-0.5 rounded-full bg-purple-100 text-purple-700 font-semibold">{r.category}</span></td>
                  <td className="px-4 py-3 font-medium">{r.cost} EP</td>
                  <td className="px-4 py-3 text-slate-600">{r._count?.transactions || 0}</td>
                  <td className="px-4 py-3">
                    <div className="flex gap-2">
                      <button onClick={() => openEditor(r)} className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-500"><Pencil className="w-4 h-4" /></button>
                      <button onClick={() => handleDelete(r.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-slate-500 hover:text-red-600"><Trash2 className="w-4 h-4" /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {tab === 'transactions' && (
        <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Sender</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Receiver</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Gift</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Cost</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">House</th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {txLoading ? <tr><td colSpan={6} className="text-center py-12"><Loader2 className="w-5 h-5 animate-spin mx-auto text-slate-400" /></td></tr> : transactions.map(tx => (
                <tr key={tx.id} className="hover:bg-slate-50">
                  <td className="px-4 py-3 font-medium">{tx.sender?.displayName || 'Unknown'}</td>
                  <td className="px-4 py-3 font-medium">{tx.receiver?.displayName || 'Unknown'}</td>
                  <td className="px-4 py-3 text-slate-600">{tx.rewardName}</td>
                  <td className="px-4 py-3 font-medium">{tx.pointsSpent} EP</td>
                  <td className="px-4 py-3 text-slate-600">{tx.house?.name}</td>
                  <td className="px-4 py-3 text-slate-500 text-xs">{new Date(tx.createdAt).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {txTotalPages > 1 && (
            <div className="flex items-center justify-between px-4 py-3 border-t border-slate-200">
              <button onClick={() => setTxPage(p => Math.max(1, p - 1))} disabled={txPage === 1} className="p-2 rounded-lg hover:bg-slate-100 disabled:opacity-40"><ChevronLeft className="w-4 h-4" /></button>
              <span className="text-sm text-slate-500">Page {txPage} of {txTotalPages}</span>
              <button onClick={() => setTxPage(p => Math.min(txTotalPages, p + 1))} disabled={txPage === txTotalPages} className="p-2 rounded-lg hover:bg-slate-100 disabled:opacity-40"><ChevronRight className="w-4 h-4" /></button>
            </div>
          )}
        </div>
      )}

      {showEditor && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4">
            <div className="p-6 space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-bold text-slate-900">{editing ? 'Edit Gift Reward' : 'New Gift Reward'}</h3>
                <button onClick={() => setShowEditor(false)} className="text-slate-400 hover:text-slate-600"><X className="w-5 h-5" /></button>
              </div>
              {!editing && <div><label className="block text-sm font-medium text-slate-700 mb-1">Key</label><input type="text" value={formKey} onChange={e => setFormKey(e.target.value)} className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500" placeholder="praise_great_job" /></div>}
              <div><label className="block text-sm font-medium text-slate-700 mb-1">Category</label><select value={formCategory} onChange={e => setFormCategory(e.target.value)} className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm">{CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}</select></div>
              <div className="grid grid-cols-2 gap-4">
                <div><label className="block text-sm font-medium text-slate-700 mb-1">Icon</label><input type="text" value={formIcon} onChange={e => setFormIcon(e.target.value)} className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm" /></div>
                <div><label className="block text-sm font-medium text-slate-700 mb-1">Cost (EP)</label><input type="number" value={formCost} onChange={e => setFormCost(Number(e.target.value))} className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm" min={1} /></div>
              </div>
              <div><label className="block text-sm font-medium text-slate-700 mb-1">Name (EN)</label><input type="text" value={formNameEn} onChange={e => setFormNameEn(e.target.value)} className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm" /></div>
              <div><label className="block text-sm font-medium text-slate-700 mb-1">Name (VI)</label><input type="text" value={formNameVi} onChange={e => setFormNameVi(e.target.value)} className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm" /></div>
            </div>
            <div className="flex gap-3 px-6 pb-6">
              <button onClick={() => setShowEditor(false)} className="flex-1 px-4 py-2.5 rounded-lg border border-slate-200 text-sm font-medium">Cancel</button>
              <button onClick={handleSave} disabled={saving} className="flex-1 px-4 py-2.5 rounded-lg bg-primary-600 text-white text-sm font-medium disabled:opacity-50">{saving ? 'Saving...' : 'Save'}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
