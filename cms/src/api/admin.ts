
import { apiClient as axiosClient } from './client';

export interface DashboardStats {
  totalUsers: number;
  totalHouses: number;
  totalActivities: number;
  activeUsers: number;
  trends: {
    users: number;
    houses: number;
    activities: number;
    activeUsers: number;
  };
}

export interface GrowthItem {
  date: string;
  count: number;
}

export interface ActivityStatsItem {
  date: string;
  count: number;
}

export interface HouseDistribution {
  distribution: { name: string; value: number }[];
  avgMembers: number;
  total: number;
}

export interface RecentEvent {
  type: 'user_registered' | 'activity_completed' | 'redemption';
  description: string;
  userName: string;
  timestamp: string;
}

export interface StreakStats {
  distribution: { range: string; count: number }[];
  avgStreak: number;
  maxStreak: number;
}

export interface LeaderboardEntry {
  rank: number;
  userId: string;
  displayName: string;
  avatarId: number | null;
  totalPoints: number;
}

export interface User {
  id: string;
  firebaseUid: string;
  email?: string;
  displayName?: string;
  createdAt: string;
  walletBalance: number;
  _count?: {
    activities: number;
    redemptions: number;
  }
}

export interface House {
  id: string;
  name: string;
  inviteCode: string;
  isPersonal: boolean;
  createdAt: string;
  members: User[];
  createdBy: User;
  _count?: {
    members: number;
  }
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  };
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
}

export const adminApi = {
  // Dashboard stats
  getDashboardStats: () =>
    axiosClient.get<ApiResponse<DashboardStats>>('/admin/stats/dashboard'),

  getGrowthStats: () =>
    axiosClient.get<ApiResponse<GrowthItem[]>>('/admin/stats/growth'),

  getActivityStats: (days = 7) =>
    axiosClient.get<ApiResponse<ActivityStatsItem[]>>('/admin/stats/activities', { params: { days } }),

  getHouseDistribution: () =>
    axiosClient.get<ApiResponse<HouseDistribution>>('/admin/stats/houses'),

  getRecentEvents: (limit = 10) =>
    axiosClient.get<ApiResponse<RecentEvent[]>>('/admin/stats/recent-events', { params: { limit } }),

  getStreakStats: () =>
    axiosClient.get<ApiResponse<StreakStats>>('/admin/stats/streaks'),

  getLeaderboardPreview: (limit = 5) =>
    axiosClient.get<ApiResponse<LeaderboardEntry[]>>('/admin/stats/leaderboard', { params: { limit } }),

  // Users
  getUsers: (page = 1, limit = 20, search = '') =>
    axiosClient.get<ApiResponse<PaginatedResponse<User>>>('/admin/users', { params: { page, limit, search } }),

  getUser: (id: string) => axiosClient.get<ApiResponse<User>>(`/admin/users/${id}`),

  deleteUser: (id: string) => axiosClient.delete<ApiResponse<{ message: string }>>(`/admin/users/${id}`),

  // Houses
  getHouses: (page = 1, limit = 20, search = '') =>
    axiosClient.get<ApiResponse<PaginatedResponse<House>>>('/admin/houses', { params: { page, limit, search } }),

  getHouse: (id: string) => axiosClient.get<ApiResponse<House>>(`/admin/houses/${id}`),
};
