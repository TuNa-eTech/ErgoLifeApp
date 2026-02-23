import React from 'react';
import { Info } from 'lucide-react';

const CONFIG_ITEMS = [
  { section: 'Point System', items: [
    { label: 'Base EP per minute', value: '1 EP/min', desc: 'Base earning rate for activities' },
    { label: 'Streak bonus multiplier', value: '1.5x at 7 days', desc: 'Bonus applied for maintaining streaks' },
    { label: 'Max streak freeze', value: '2 per user', desc: 'Maximum streak freeze tokens' },
  ]},
  { section: 'Daily Goals (Defaults)', items: [
    { label: 'Target EP', value: '500 EP', desc: 'Default daily EP target for new users' },
    { label: 'Target Duration', value: '30 minutes', desc: 'Default daily activity duration target' },
    { label: 'Target Activities', value: '2 sessions', desc: 'Default daily activity count target' },
  ]},
  { section: 'Notifications', items: [
    { label: 'Streak reminder window', value: '6 PM - 9 PM', desc: 'Personalized based on user activity patterns' },
    { label: 'Re-engagement threshold', value: '3 days inactive', desc: 'Days before sending re-engagement notification' },
    { label: 'Leaderboard change alerts', value: 'Enabled', desc: 'Notify users when their rank changes' },
  ]},
  { section: 'Houses', items: [
    { label: 'Max members per house', value: 'Unlimited', desc: 'Maximum number of members in a house' },
    { label: 'Auto-create personal house', value: 'Yes', desc: 'Create personal house on user registration' },
  ]},
];

export const Settings: React.FC = () => {
  return (
    <div className="space-y-6 max-w-3xl">
      <div>
        <h2 className="text-2xl font-bold text-slate-900">Settings</h2>
        <p className="text-slate-500">Application configuration reference</p>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 flex gap-3">
        <Info className="w-5 h-5 text-blue-600 shrink-0 mt-0.5" />
        <p className="text-sm text-blue-800">
          These settings are currently configured in the backend environment. 
          Future updates will allow editing directly from this page.
        </p>
      </div>

      {CONFIG_ITEMS.map(section => (
        <div key={section.section} className="bg-white rounded-2xl border border-slate-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-slate-100 bg-slate-50">
            <h3 className="font-bold text-slate-900">{section.section}</h3>
          </div>
          <div className="divide-y divide-slate-100">
            {section.items.map(item => (
              <div key={item.label} className="px-6 py-4 flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-slate-900">{item.label}</p>
                  <p className="text-xs text-slate-500 mt-0.5">{item.desc}</p>
                </div>
                <span className="text-sm font-medium text-slate-700 bg-slate-100 px-3 py-1 rounded-lg">{item.value}</span>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
};
