import React from 'react';
import { 
  PieChart, 
  Pie, 
  Cell, 
  Tooltip, 
  Legend, 
  ResponsiveContainer 
} from 'recharts';
import { ChartCard } from '../../../components/ChartCard';
import { houseData, PIE_COLORS } from '../mockData';

export const HousePieChart: React.FC = () => {
  return (
    <ChartCard title="House Types" subtitle="Distribution of house categories">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={houseData}
            cx="50%"
            cy="50%"
            innerRadius={60}
            outerRadius={80}
            paddingAngle={5}
            dataKey="value"
          >
            {houseData.map((_, index) => (
              <Cell key={`cell-${index}`} fill={PIE_COLORS[index % PIE_COLORS.length]} />
            ))}
          </Pie>
          <Tooltip />
          <Legend verticalAlign="bottom" height={36}/>
        </PieChart>
      </ResponsiveContainer>
    </ChartCard>
  );
};
