import React from 'react';

export type DateRange = '7d' | '14d' | '30d';

interface DateRangePickerProps {
  value: DateRange;
  onChange: (range: DateRange) => void;
}

const OPTIONS: { value: DateRange; label: string }[] = [
  { value: '7d', label: '7 days' },
  { value: '14d', label: '14 days' },
  { value: '30d', label: '30 days' },
];

export const DateRangePicker: React.FC<DateRangePickerProps> = ({
  value,
  onChange,
}) => (
  <div className="flex items-center gap-1 bg-slate-100 rounded-lg p-1">
    {OPTIONS.map((opt) => (
      <button
        key={opt.value}
        onClick={() => onChange(opt.value)}
        className={`px-3 py-1.5 text-sm font-medium rounded-md transition-colors ${
          value === opt.value
            ? 'bg-white text-slate-900 shadow-sm'
            : 'text-slate-500 hover:text-slate-700'
        }`}
      >
        {opt.label}
      </button>
    ))}
  </div>
);
