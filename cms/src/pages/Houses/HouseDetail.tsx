
import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { adminApi, type House } from '../../api/admin';
import { ArrowLeft, Home, User as UserIcon, Hash } from 'lucide-react';

export const HouseDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [house, setHouse] = useState<House | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) {
      adminApi.getHouse(id)
        .then(res => setHouse(res.data?.data))
        .catch(err => console.error(err))
        .finally(() => setLoading(false));
    }
  }, [id]);

  if (loading) return <div>Loading house details...</div>;
  if (!house) return <div>House not found</div>;

  return (
    <div className="space-y-6">
      <Link to="/houses" className="flex items-center gap-2 text-slate-500 hover:text-slate-900 transition-colors">
        <ArrowLeft className="w-4 h-4" />
        Back to Houses
      </Link>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* House Info Card */}
        <div className="lg:col-span-1 bg-white p-6 rounded-2xl shadow-sm border border-slate-200 h-fit">
          <div className="flex flex-col items-center text-center">
            <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-emerald-400 to-emerald-600 flex items-center justify-center mb-4">
              <Home className="w-10 h-10 text-white" />
            </div>
            <h1 className="text-xl font-bold text-slate-900 mb-1">{house.name}</h1>
            <p className="text-slate-500 text-sm mb-6 flex items-center gap-2">
                <Hash className="w-3 h-3" /> {house.inviteCode}
            </p>

            <div className="w-full border-t border-slate-100 pt-6 space-y-4 text-left">
                <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Created By</span>
                    <span className="font-medium text-slate-900">{house.createdBy?.displayName || 'Unknown'}</span>
                </div>
                <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Created At</span>
                    <span className="font-medium text-slate-900">{new Date(house.createdAt).toLocaleDateString()}</span>
                </div>
                <div className="flex justify-between text-sm">
                    <span className="text-slate-500">Type</span>
                    <span className="font-medium text-slate-900">{house.isPersonal ? 'Personal' : 'Group'}</span>
                </div>
            </div>
          </div>
        </div>

        {/* Members List */}
        <div className="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
           <div className="flex items-center justify-between mb-6">
               <h3 className="text-lg font-bold text-slate-900">Members ({house._count?.members || house.members?.length || 0})</h3>
           </div>
           
           <div className="overflow-hidden overflow-x-auto">
             <table className="w-full text-left text-sm">
               <thead className="bg-slate-50 border-b border-slate-200">
                 <tr>
                   <th className="px-4 py-3 font-semibold text-slate-700">Name</th>
                   <th className="px-4 py-3 font-semibold text-slate-700">Joined</th>
                 </tr>
               </thead>
               <tbody className="divide-y divide-slate-100">
                 {house.members && house.members.length > 0 ? (
                    house.members.map((member) => (
                        <tr key={member.id}>
                            <td className="px-4 py-3 flex items-center gap-3">
                                <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-xs text-slate-600">
                                    <UserIcon className="w-4 h-4" />
                                </div>
                                <div>
                                    <p className="font-medium text-slate-900">{member.displayName}</p>
                                    <p className="text-xs text-slate-500">{member.email}</p>
                                </div>
                            </td>
                            <td className="px-4 py-3 text-slate-500">
                                {new Date(member.createdAt).toLocaleDateString()}
                            </td>
                        </tr>
                    ))
                 ) : (
                    <tr><td colSpan={2} className="px-4 py-4 text-center text-slate-500">No members data available or empty</td></tr>
                 )}
               </tbody>
             </table>
           </div>
        </div>
      </div>
    </div>
  );
};
