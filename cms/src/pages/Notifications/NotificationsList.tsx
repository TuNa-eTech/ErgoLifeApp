import React, { useEffect, useState } from 'react';
import {
  adminApi,
  type AdminNotification,
  type NotificationStats,
} from '../../api/admin';
import {
  Send,
  ChevronLeft,
  ChevronRight,
  X,
} from 'lucide-react';
import clsx from 'clsx';

const NOTIFICATION_TYPES = [
  'STREAK_REMINDER',
  'STREAK_LOST',
  'STREAK_MILESTONE',
  'ACTIVITY_COMPLETED',
  'HOUSE_INVITE',
  'MEMBER_JOINED',
  'LEADERBOARD_CHANGE',
  'HOUSE_ACTIVITY',
  'NEW_REWARD',
  'ENOUGH_POINTS',
  'REDEMPTION_APPROVED',
  'REDEMPTION_REJECTED',
  'GIFT_RECEIVED',
  'WELCOME',
  'APP_UPDATE',
  'BADGE_UNLOCKED',
  'RE_ENGAGEMENT',
];

export const NotificationsList: React.FC = () => {
  const [notifications, setNotifications] = useState<
    AdminNotification[]
  >([]);
  const [stats, setStats] = useState<NotificationStats | null>(
    null,
  );
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [typeFilter, setTypeFilter] = useState('');
  const [showBroadcast, setShowBroadcast] = useState(false);
  const [broadcastTitle, setBroadcastTitle] = useState('');
  const [broadcastBody, setBroadcastBody] = useState('');
  const [sending, setSending] = useState(false);

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const res = await adminApi.getNotifications(
        page,
        20,
        typeFilter || undefined,
      );
      const data = res.data?.data;
      setNotifications(data?.data || []);
      setTotalPages(data?.meta?.pages || 1);
    } catch (err) {
      console.error('Failed to fetch notifications', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    try {
      const res = await adminApi.getNotificationStats();
      setStats(res.data?.data || null);
    } catch {
      /* ignore */
    }
  };

  useEffect(() => {
    fetchNotifications();
  }, [page, typeFilter]);

  useEffect(() => {
    fetchStats();
  }, []);

  const handleBroadcast = async () => {
    if (!broadcastTitle || !broadcastBody) return;
    setSending(true);
    try {
      await adminApi.broadcastNotification({
        title: broadcastTitle,
        body: broadcastBody,
      });
      setBroadcastTitle('');
      setBroadcastBody('');
      setShowBroadcast(false);
      fetchNotifications();
      fetchStats();
    } catch (err) {
      console.error('Failed to send broadcast', err);
      alert('Failed to send broadcast');
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-slate-900">
            Notifications
          </h2>
          <p className="text-slate-500">
            Manage and send notifications
          </p>
        </div>
        <button
          onClick={() => setShowBroadcast(true)}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors font-medium text-sm"
        >
          <Send className="w-4 h-4" />
          Send Broadcast
        </button>
      </div>

      {/* Stats Cards */}
      {stats && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            {
              label: 'Total',
              value: stats.total,
              color: 'text-blue-600',
            },
            {
              label: 'Sent',
              value: stats.sent,
              color: 'text-emerald-600',
            },
            {
              label: 'Read',
              value: stats.read,
              color: 'text-purple-600',
            },
            {
              label: 'Unread',
              value: stats.unread,
              color: 'text-amber-600',
            },
          ].map((s) => (
            <div
              key={s.label}
              className="bg-white rounded-xl p-4 border border-slate-200"
            >
              <p className="text-xs text-slate-500 uppercase font-semibold">
                {s.label}
              </p>
              <p
                className={clsx(
                  'text-2xl font-bold mt-1',
                  s.color,
                )}
              >
                {s.value}
              </p>
            </div>
          ))}
        </div>
      )}

      {/* Filter */}
      <div className="bg-white rounded-xl border border-slate-200 p-4">
        <div className="flex gap-4 items-center">
          <select
            value={typeFilter}
            onChange={(e) => {
              setTypeFilter(e.target.value);
              setPage(1);
            }}
            className="px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="">All Types</option>
            {NOTIFICATION_TYPES.map((t) => (
              <option key={t} value={t}>
                {t.replace(/_/g, ' ')}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 border-b border-slate-200">
              <tr>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  User
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Type
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Title
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Status
                </th>
                <th className="text-left px-4 py-3 text-slate-600 font-semibold">
                  Date
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td
                    colSpan={5}
                    className="text-center py-12 text-slate-400"
                  >
                    Loading...
                  </td>
                </tr>
              ) : notifications.length === 0 ? (
                <tr>
                  <td
                    colSpan={5}
                    className="text-center py-12 text-slate-400"
                  >
                    No notifications found
                  </td>
                </tr>
              ) : (
                notifications.map((n) => (
                  <tr
                    key={n.id}
                    className="hover:bg-slate-50 transition-colors"
                  >
                    <td className="px-4 py-3">
                      <span className="font-medium text-slate-900">
                        {n.user?.displayName || 'Unknown'}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <span className="inline-flex px-2 py-0.5 text-xs font-semibold rounded-full bg-blue-100 text-blue-700">
                        {n.type.replace(/_/g, ' ')}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-slate-700 max-w-xs truncate">
                      {n.title}
                    </td>
                    <td className="px-4 py-3">
                      <span
                        className={clsx(
                          'inline-flex px-2 py-0.5 text-xs font-semibold rounded-full',
                          n.isRead
                            ? 'bg-slate-100 text-slate-500'
                            : n.isSent
                              ? 'bg-emerald-100 text-emerald-700'
                              : 'bg-amber-100 text-amber-700',
                        )}
                      >
                        {n.isRead
                          ? 'Read'
                          : n.isSent
                            ? 'Sent'
                            : 'Pending'}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-slate-500 text-xs">
                      {new Date(
                        n.createdAt,
                      ).toLocaleDateString()}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-slate-200">
            <button
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page === 1}
              className="p-2 rounded-lg hover:bg-slate-100 disabled:opacity-40"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <span className="text-sm text-slate-500">
              Page {page} of {totalPages}
            </span>
            <button
              onClick={() =>
                setPage((p) => Math.min(totalPages, p + 1))
              }
              disabled={page === totalPages}
              className="p-2 rounded-lg hover:bg-slate-100 disabled:opacity-40"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        )}
      </div>

      {/* Broadcast Dialog */}
      {showBroadcast && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div className="bg-white rounded-2xl shadow-xl w-full max-w-md mx-4 overflow-hidden">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-bold text-slate-900">
                  Send Broadcast
                </h3>
                <button
                  onClick={() => setShowBroadcast(false)}
                  className="text-slate-400 hover:text-slate-600"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1">
                    Title
                  </label>
                  <input
                    type="text"
                    value={broadcastTitle}
                    onChange={(e) =>
                      setBroadcastTitle(e.target.value)
                    }
                    className="w-full px-3 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500 text-sm"
                    placeholder="Notification title..."
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1">
                    Body
                  </label>
                  <textarea
                    value={broadcastBody}
                    onChange={(e) =>
                      setBroadcastBody(e.target.value)
                    }
                    rows={3}
                    className="w-full px-3 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500 text-sm resize-none"
                    placeholder="Notification body..."
                  />
                </div>
              </div>
            </div>
            <div className="flex gap-3 px-6 pb-6">
              <button
                onClick={() => setShowBroadcast(false)}
                disabled={sending}
                className="flex-1 px-4 py-2.5 rounded-lg border border-slate-200 text-slate-700 hover:bg-slate-50 transition-colors text-sm font-medium"
              >
                Cancel
              </button>
              <button
                onClick={handleBroadcast}
                disabled={
                  !broadcastTitle || !broadcastBody || sending
                }
                className="flex-1 px-4 py-2.5 rounded-lg bg-primary-600 text-white hover:bg-primary-700 transition-colors text-sm font-medium disabled:opacity-50"
              >
                {sending ? 'Sending...' : 'Send to All Users'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
