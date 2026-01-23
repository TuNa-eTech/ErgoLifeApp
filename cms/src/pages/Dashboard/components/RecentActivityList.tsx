import React from 'react';
import { CheckCircle } from 'lucide-react';

export const RecentActivityList: React.FC = () => {
  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col h-[400px]">
       <div className="mb-6">
          <h3 className="text-lg font-bold text-slate-900">Recent System Events</h3>
          <p className="text-sm text-slate-500">Latest actions performed</p>
       </div>
       <div className="flex-1 overflow-auto space-y-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="flex items-center gap-4 p-3 hover:bg-slate-50 rounded-lg transition-colors">
              <div className="w-10 h-10 rounded-full bg-emerald-100 flex items-center justify-center">
                <CheckCircle className="w-5 h-5 text-emerald-600" />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-slate-900">New user registration</p>
                <p className="text-xs text-slate-500">2 minutes ago</p>
              </div>
              <span className="text-xs font-medium text-emerald-600 bg-emerald-50 px-2 py-1 rounded-full">Success</span>
            </div>
          ))}
       </div>
    </div>
  );
};
