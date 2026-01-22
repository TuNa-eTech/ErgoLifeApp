
import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { adminApi, type User } from '../../api/admin';
import { ArrowLeft, Wallet, Activity, Calendar } from 'lucide-react';

export const UserDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) {
      adminApi.getUser(id)
        .then(res => setUser(res.data?.data))
        .catch(err => console.error(err))
        .finally(() => setLoading(false));
    }
  }, [id]);

  if (loading) return <div>Loading user details...</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="space-y-6">
      <Link to="/users" className="flex items-center gap-2 text-slate-500 hover:text-slate-900 transition-colors">
        <ArrowLeft className="w-4 h-4" />
        Back to Users
      </Link>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Profile Card */}
        <div className="lg:col-span-1 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
          <div className="flex flex-col items-center text-center">
            <div className="w-24 h-24 rounded-full bg-gradient-to-br from-primary-400 to-primary-600 flex items-center justify-center text-3xl font-bold text-white mb-4">
              {user.displayName?.[0] || 'U'}
            </div>
            <h1 className="text-xl font-bold text-slate-900">{user.displayName || 'No Name'}</h1>
            <p className="text-slate-500 text-sm mb-6">{user.email}</p>

            <div className="w-full grid grid-cols-2 gap-4 border-t border-slate-100 pt-6">
              <div className="text-center">
                <p className="text-2xl font-bold text-emerald-600">{user.walletBalance}</p>
                <p className="text-xs text-slate-500 uppercase font-semibold mt-1">Wallet</p>
              </div>
              <div className="text-center">
                <p className="text-2xl font-bold text-slate-900">{user._count?.activities || 0}</p>
                <p className="text-xs text-slate-500 uppercase font-semibold mt-1">Activities</p>
              </div>
            </div>
          </div>
        </div>

        {/* Details Card */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
           <h3 className="text-lg font-bold text-slate-900 mb-6">Account Details</h3>
           
           <div className="space-y-4">
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500 flex items-center gap-2"><Calendar className="w-4 h-4" /> Joined Date</span>
                <span className="font-medium">{new Date(user.createdAt).toLocaleDateString()}</span>
             </div>
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500 flex items-center gap-2"><Wallet className="w-4 h-4" /> Wallet Balance</span>
                <span className="font-medium">{user.walletBalance} Coins</span>
             </div>
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500 flex items-center gap-2"><Activity className="w-4 h-4" /> Total Activities</span>
                <span className="font-medium">{user._count?.activities || 0} Sessions</span>
             </div>
             <div className="flex items-center justify-between py-3 border-b border-slate-50">
                <span className="text-slate-500">Firebase UID</span>
                <code className="text-xs bg-slate-100 px-2 py-1 rounded">{user.firebaseUid}</code>
             </div>
           </div>
        </div>
      </div>
    </div>
  );
};
