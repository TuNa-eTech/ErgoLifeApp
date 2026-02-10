import React from 'react';
import { Inbox } from 'lucide-react';

interface EmptyStateProps {
  message?: string;
  icon?: React.ElementType;
}

export const EmptyState: React.FC<EmptyStateProps> = ({
  message = 'No data available yet',
  icon: Icon = Inbox,
}) => (
  <div className="flex flex-col items-center justify-center h-full gap-3 text-slate-300">
    <Icon className="w-12 h-12" />
    <p className="text-sm font-medium text-slate-400">{message}</p>
  </div>
);
