import React from 'react';

export const ChartSkeleton: React.FC = () => (
  <div className="animate-pulse flex flex-col h-full">
    <div className="flex-1 flex items-end gap-2 px-4 pb-4">
      {[40, 65, 50, 80, 55, 70, 45].map((h, i) => (
        <div
          key={i}
          className="flex-1 bg-slate-200 rounded-t"
          style={{ height: `${h}%` }}
        />
      ))}
    </div>
    <div className="flex justify-between px-4">
      {[1, 2, 3, 4, 5, 6, 7].map((i) => (
        <div key={i} className="w-6 h-3 bg-slate-200 rounded" />
      ))}
    </div>
  </div>
);

export const ListSkeleton: React.FC<{ rows?: number }> = ({ rows = 5 }) => (
  <div className="animate-pulse space-y-4">
    {Array.from({ length: rows }).map((_, i) => (
      <div key={i} className="flex items-center gap-4 p-3">
        <div className="w-10 h-10 rounded-full bg-slate-200" />
        <div className="flex-1 space-y-2">
          <div className="h-4 bg-slate-200 rounded w-3/4" />
          <div className="h-3 bg-slate-200 rounded w-1/2" />
        </div>
        <div className="w-16 h-6 bg-slate-200 rounded-full" />
      </div>
    ))}
  </div>
);

export const StatCardSkeleton: React.FC = () => (
  <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center gap-4 animate-pulse">
    <div className="w-14 h-14 rounded-xl bg-slate-200" />
    <div className="flex-1 space-y-2">
      <div className="h-4 bg-slate-200 rounded w-24" />
      <div className="h-7 bg-slate-200 rounded w-16" />
    </div>
  </div>
);
