import React from 'react';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  AreaChart,
  Area,
} from 'recharts';
import { Box, useTheme, useMediaQuery } from '@mui/material';

// Sample data
const barChartData = [
  { name: 'Jan', value: 4000, donated: 2400 },
  { name: 'Feb', value: 3000, donated: 1398 },
  { name: 'Mar', value: 2000, donated: 9800 },
  { name: 'Apr', value: 2780, donated: 3908 },
  { name: 'May', value: 1890, donated: 4800 },
  { name: 'Jun', value: 2390, donated: 3800 },
];

const lineChartData = [
  { name: 'Week 1', users: 400, campaigns: 240 },
  { name: 'Week 2', users: 300, campaigns: 139 },
  { name: 'Week 3', users: 200, campaigns: 980 },
  { name: 'Week 4', users: 278, campaigns: 390 },
  { name: 'Week 5', users: 189, campaigns: 480 },
];

const pieChartData = [
  { name: 'Approved', value: 45 },
  { name: 'Pending', value: 30 },
  { name: 'Rejected', value: 25 },
];

const areaChartData = [
  { name: 'Mon', donations: 1000, beneficiaries: 240 },
  { name: 'Tue', donations: 1200, beneficiaries: 221 },
  { name: 'Wed', donations: 1500, beneficiaries: 229 },
  { name: 'Thu', donations: 1800, beneficiaries: 200 },
  { name: 'Fri', donations: 1400, beneficiaries: 250 },
  { name: 'Sat', donations: 1100, beneficiaries: 210 },
];

const COLORS = ['#4CAF50', '#FFC107', '#F44336'];
const SECONDARY_COLORS = ['#0C0C79', '#FF751F', '#81C784'];

export const BarChartComponent = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  return (
    <ResponsiveContainer width="100%" height={isMobile ? 300 : 400}>
      <BarChart data={barChartData}>
        <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} />
        <XAxis stroke={theme.palette.text.secondary} />
        <YAxis stroke={theme.palette.text.secondary} />
        <Tooltip
          contentStyle={{
            backgroundColor: theme.palette.background.paper,
            border: `1px solid ${theme.palette.divider}`,
          }}
        />
        <Legend />
        <Bar dataKey="value" fill={theme.palette.primary.main} radius={[8, 8, 0, 0]} />
        <Bar dataKey="donated" fill={theme.palette.secondary.main} radius={[8, 8, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
};

export const LineChartComponent = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  return (
    <ResponsiveContainer width="100%" height={isMobile ? 300 : 400}>
      <LineChart data={lineChartData}>
        <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} />
        <XAxis stroke={theme.palette.text.secondary} />
        <YAxis stroke={theme.palette.text.secondary} />
        <Tooltip
          contentStyle={{
            backgroundColor: theme.palette.background.paper,
            border: `1px solid ${theme.palette.divider}`,
          }}
        />
        <Legend />
        <Line
          type="monotone"
          dataKey="users"
          stroke={theme.palette.primary.main}
          strokeWidth={2}
          dot={{ fill: theme.palette.primary.main }}
          activeDot={{ r: 6 }}
        />
        <Line
          type="monotone"
          dataKey="campaigns"
          stroke={theme.palette.secondary.main}
          strokeWidth={2}
          dot={{ fill: theme.palette.secondary.main }}
          activeDot={{ r: 6 }}
        />
      </LineChart>
    </ResponsiveContainer>
  );
};

export const PieChartComponent = () => {
  const theme = useTheme();

  return (
    <ResponsiveContainer width="100%" height={300}>
      <PieChart>
        <Pie
          data={pieChartData}
          cx="50%"
          cy="50%"
          labelLine={false}
          label={({ name, value }) => `${name}: ${value}%`}
          outerRadius={80}
          fill="#8884d8"
          dataKey="value"
        >
          {pieChartData.map((entry, index) => (
            <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
          ))}
        </Pie>
        <Tooltip
          contentStyle={{
            backgroundColor: theme.palette.background.paper,
            border: `1px solid ${theme.palette.divider}`,
          }}
        />
      </PieChart>
    </ResponsiveContainer>
  );
};

export const AreaChartComponent = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));

  return (
    <ResponsiveContainer width="100%" height={isMobile ? 300 : 400}>
      <AreaChart data={areaChartData}>
        <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} />
        <XAxis stroke={theme.palette.text.secondary} />
        <YAxis stroke={theme.palette.text.secondary} />
        <Tooltip
          contentStyle={{
            backgroundColor: theme.palette.background.paper,
            border: `1px solid ${theme.palette.divider}`,
          }}
        />
        <Legend />
        <Area
          type="monotone"
          dataKey="donations"
          stackId="1"
          stroke={theme.palette.primary.main}
          fill={theme.palette.primary.main}
          opacity={0.6}
        />
        <Area
          type="monotone"
          dataKey="beneficiaries"
          stackId="1"
          stroke={theme.palette.secondary.main}
          fill={theme.palette.secondary.main}
          opacity={0.6}
        />
      </AreaChart>
    </ResponsiveContainer>
  );
};

export default {
  BarChartComponent,
  LineChartComponent,
  PieChartComponent,
  AreaChartComponent,
};
