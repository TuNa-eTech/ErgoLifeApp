import React, { useEffect, useState } from 'react';
import {
  adminApi,
  type BadgeDefinition,
} from '../../api/admin';
import {
  Award,
  Plus,
  Pencil,
  Trash2,
  Loader2,
} from 'lucide-react';
import clsx from 'clsx';
import { Link } from 'react-router-dom';

export const BadgesList: React.FC = () => {
  const [badges, setBadges] = useState<BadgeDefinition[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchBadges = async () => {
    setLoading(true);
    try {
      const res = await adminApi.getBadges();
      setBadges(res.data?.data || []);
    } catch (err) {
      console.error('Failed to fetch badges', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBadges();
  }, []);

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this badge?'))
      return;
    try {
      await adminApi.deleteBadge(id);
      fetchBadges();
    } catch (err) {
      console.error('Failed to delete badge', err);
      alert('Failed to delete badge');
    }
  };

  const getName = (b: BadgeDefinition) => {
    const en = b.translations.find(
      (t) => t.locale === 'en',
    );
    const vi = b.translations.find(
      (t) => t.locale === 'vi',
    );
    return en?.name || vi?.name || b.code;
  };

  const rarityColor = (rarity: string) => {
    switch (rarity) {
      case 'COMMON':
        return 'bg-slate-100 text-slate-700';
      case 'RARE':
        return 'bg-blue-100 text-blue-700';
      case 'EPIC':
        return 'bg-purple-100 text-purple-700';
      case 'LEGENDARY':
        return 'bg-amber-100 text-amber-700';
      default:
        return 'bg-slate-100 text-slate-700';
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">
            Badges & Achievements
          </h2>
          <p className="text-slate-500">
            Manage badge definitions and translations
          </p>
        </div>
        <Link
          to="/badges/new"
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors font-medium text-sm"
        >
          <Plus className="w-4 h-4" />
          New Badge
        </Link>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Badge
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Code
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Category
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Rarity
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Condition
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Unlocks
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td
                    colSpan={7}
                    className="text-center py-12 text-slate-400"
                  >
                    <Loader2 className="w-5 h-5 animate-spin mx-auto" />
                  </td>
                </tr>
              ) : badges.length === 0 ? (
                <tr>
                  <td
                    colSpan={7}
                    className="text-center py-12 text-slate-400"
                  >
                    No badges found
                  </td>
                </tr>
              ) : (
                badges.map((b) => (
                  <tr
                    key={b.id}
                    className="hover:bg-slate-50 transition-colors"
                  >
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        <div
                          className="w-8 h-8 rounded-lg flex items-center justify-center text-white text-sm"
                          style={{
                            backgroundColor: b.color,
                          }}
                        >
                          <Award className="w-4 h-4" />
                        </div>
                        <span className="font-medium text-slate-900">
                          {getName(b)}
                        </span>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <code className="text-xs bg-slate-100 px-2 py-0.5 rounded">
                        {b.code}
                      </code>
                    </td>
                    <td className="px-4 py-3 text-slate-600 capitalize">
                      {b.category}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={clsx(
                          'inline-flex px-2 py-0.5 text-xs font-semibold rounded-full',
                          rarityColor(b.rarity),
                        )}
                      >
                        {b.rarity}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-slate-600 text-xs">
                      {b.conditionType} ≥ {b.conditionValue}
                    </td>
                    <td className="px-4 py-3 text-slate-600">
                      {b._count?.userBadges || 0}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex gap-2">
                        <Link
                          to={`/badges/${b.id}`}
                          className="p-1.5 rounded-lg hover:bg-slate-100 text-slate-500 hover:text-primary-600 transition-colors"
                        >
                          <Pencil className="w-4 h-4" />
                        </Link>
                        <button
                          onClick={() =>
                            handleDelete(b.id)
                          }
                          className="p-1.5 rounded-lg hover:bg-red-50 text-slate-500 hover:text-red-600 transition-colors"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
