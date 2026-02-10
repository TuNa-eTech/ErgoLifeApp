import React from 'react';
import clsx from 'clsx';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ElementType;
  color: string;
  trend?: number;
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  icon: Icon,
  color,
  trend,
}) => {
  const trendIcon = () => {
    if (trend === undefined || trend === null) return null;

    if (trend > 0) {
      return (
        <span className="flex items-center gap-1 text-xs font-medium text-emerald-600">
          <TrendingUp className="w-3.5 h-3.5" />
          +{trend}%
        </span>
      );
    }

    if (trend < 0) {
      return (
        <span className="flex items-center gap-1 text-xs font-medium text-red-500">
          <TrendingDown className="w-3.5 h-3.5" />
          {trend}%
        </span>
      );
    }

    return (
      <span className="flex items-center gap-1 text-xs font-medium text-slate-400">
        <Minus className="w-3.5 h-3.5" />
        0%
      </span>
    );
  };

  return (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex items-center gap-4">
      <div className={clsx("p-4 rounded-xl", color)}>
        <Icon className="w-6 h-6 text-white" />
      </div>
      <div>
        <p className="text-sm font-medium text-slate-500">{title}</p>
        <div className="flex items-center gap-2">
          <h3 className="text-2xl font-bold text-slate-900">
            {typeof value === 'number' ? value.toLocaleString() : value}
          </h3>
          {trendIcon()}
        </div>
      </div>
    </div>
  );
};
