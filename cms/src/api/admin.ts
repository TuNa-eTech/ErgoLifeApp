
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
  currentStreak?: number;
  longestStreak?: number;
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
    activities?: number;
    rewards?: number;
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

// Notification types
export interface AdminNotification {
  id: string;
  userId: string;
  type: string;
  priority: string;
  title: string;
  body: string;
  isRead: boolean;
  isSent: boolean;
  sentAt?: string;
  createdAt: string;
  user: {
    id: string;
    displayName?: string;
    email?: string;
  };
}

export interface NotificationStats {
  total: number;
  sent: number;
  read: number;
  unread: number;
  byType: { type: string; count: number }[];
}

// Badge types
export interface BadgeDefinition {
  id: string;
  code: string;
  category: string;
  icon: string;
  color: string;
  sortOrder: number;
  conditionType: string;
  conditionValue: number;
  rarity: string;
  isActive: boolean;
  createdAt: string;
  translations: BadgeTranslation[];
  _count?: { userBadges: number };
}

export interface BadgeTranslation {
  id?: string;
  locale: string;
  name: string;
  description?: string;
}

export interface BadgeStats {
  total: number;
  active: number;
  totalUnlocks: number;
  topBadges: { badgeId: string; _count: { id: number } }[];
}

// Gift Reward types
export interface GiftReward {
  id: string;
  key: string;
  category: string;
  icon: string;
  cost: number;
  sortOrder: number;
  isActive: boolean;
  createdAt: string;
  translations: GiftRewardTranslation[];
  _count?: { transactions: number };
}

export interface GiftRewardTranslation {
  id?: string;
  locale: string;
  name: string;
  description?: string;
}

export interface GiftTransaction {
  id: string;
  rewardName: string;
  rewardIcon: string;
  pointsSpent: number;
  message?: string;
  createdAt: string;
  sender: { id: string; displayName?: string; email?: string };
  receiver: { id: string; displayName?: string; email?: string };
  house: { id: string; name: string };
}

// Activity types
export interface AdminActivity {
  id: string;
  taskName: string;
  durationSeconds: number;
  metsValue: number;
  pointsEarned: number;
  bonusMultiplier: number;
  completedAt: string;
  user: { id: string; displayName?: string; email?: string };
  house: { id: string; name: string };
}

// Redemption types
export interface AdminRedemption {
  id: string;
  rewardTitle: string;
  pointsSpent: number;
  status: string;
  redeemedAt: string;
  usedAt?: string;
  user: { id: string; displayName?: string; email?: string };
  reward: { id: string; title: string; cost: number; icon: string };
  house: { id: string; name: string };
}

export const adminApi = {
  // Dashboard stats
  getDashboardStats: () =>
    axiosClient.get<ApiResponse<DashboardStats>>('/admin/stats/dashboard'),

  getGrowthStats: () =>
    axiosClient.get<ApiResponse<GrowthItem[]>>('/admin/stats/growth'),

  getActivityStats: (days = 7) =>
    axiosClient.get<ApiResponse<ActivityStatsItem[]>>(
      '/admin/stats/activities',
      { params: { days } },
    ),

  getHouseDistribution: () =>
    axiosClient.get<ApiResponse<HouseDistribution>>(
      '/admin/stats/houses',
    ),

  getRecentEvents: (limit = 10) =>
    axiosClient.get<ApiResponse<RecentEvent[]>>(
      '/admin/stats/recent-events',
      { params: { limit } },
    ),

  getStreakStats: () =>
    axiosClient.get<ApiResponse<StreakStats>>('/admin/stats/streaks'),

  getLeaderboardPreview: (limit = 5) =>
    axiosClient.get<ApiResponse<LeaderboardEntry[]>>(
      '/admin/stats/leaderboard',
      { params: { limit } },
    ),

  // Users
  getUsers: (page = 1, limit = 20, search = '') =>
    axiosClient.get<ApiResponse<PaginatedResponse<User>>>(
      '/admin/users',
      { params: { page, limit, search } },
    ),

  getUser: (id: string) =>
    axiosClient.get<ApiResponse<User>>(`/admin/users/${id}`),

  updateUser: (
    id: string,
    data: { displayName?: string; walletBalance?: number },
  ) =>
    axiosClient.put<ApiResponse<User>>(
      `/admin/users/${id}`,
      data,
    ),

  toggleBan: (id: string, banned: boolean) =>
    axiosClient.put<
      ApiResponse<{ message: string; banned: boolean }>
    >(`/admin/users/${id}/ban`, { banned }),

  deleteUser: (id: string) =>
    axiosClient.delete<ApiResponse<{ message: string }>>(
      `/admin/users/${id}`,
    ),

  // Houses
  getHouses: (page = 1, limit = 20, search = '') =>
    axiosClient.get<ApiResponse<PaginatedResponse<House>>>(
      '/admin/houses',
      { params: { page, limit, search } },
    ),

  getHouse: (id: string) =>
    axiosClient.get<ApiResponse<House>>(`/admin/houses/${id}`),

  updateHouse: (id: string, data: { name?: string }) =>
    axiosClient.put<ApiResponse<House>>(
      `/admin/houses/${id}`,
      data,
    ),

  deleteHouse: (id: string) =>
    axiosClient.delete<ApiResponse<{ message: string }>>(
      `/admin/houses/${id}`,
    ),

  // Notifications
  getNotifications: (
    page = 1,
    limit = 20,
    type?: string,
    userId?: string,
  ) =>
    axiosClient.get<
      ApiResponse<PaginatedResponse<AdminNotification>>
    >('/admin/notifications', {
      params: { page, limit, type, userId },
    }),

  getNotificationStats: () =>
    axiosClient.get<ApiResponse<NotificationStats>>(
      '/admin/notifications/stats',
    ),

  broadcastNotification: (data: {
    title: string;
    body: string;
    type?: string;
    priority?: string;
  }) =>
    axiosClient.post<
      ApiResponse<{ message: string; count: number }>
    >('/admin/notifications/broadcast', data),

  // Badges
  getBadges: () =>
    axiosClient.get<ApiResponse<BadgeDefinition[]>>(
      '/admin/badges',
    ),

  getBadge: (id: string) =>
    axiosClient.get<ApiResponse<BadgeDefinition>>(
      `/admin/badges/${id}`,
    ),

  createBadge: (data: {
    code: string;
    category: string;
    icon: string;
    color?: string;
    sortOrder?: number;
    conditionType: string;
    conditionValue: number;
    rarity?: string;
    translations: BadgeTranslation[];
  }) =>
    axiosClient.post<ApiResponse<BadgeDefinition>>(
      '/admin/badges',
      data,
    ),

  updateBadge: (
    id: string,
    data: {
      category?: string;
      icon?: string;
      color?: string;
      sortOrder?: number;
      conditionType?: string;
      conditionValue?: number;
      rarity?: string;
      isActive?: boolean;
      translations?: BadgeTranslation[];
    },
  ) =>
    axiosClient.put<ApiResponse<BadgeDefinition>>(
      `/admin/badges/${id}`,
      data,
    ),

  deleteBadge: (id: string) =>
    axiosClient.delete<ApiResponse<{ message: string }>>(
      `/admin/badges/${id}`,
    ),

  getBadgeStats: () =>
    axiosClient.get<ApiResponse<BadgeStats>>(
      '/admin/badges/stats',
    ),

  // Gift Rewards
  getGiftRewards: () =>
    axiosClient.get<ApiResponse<GiftReward[]>>(
      '/admin/gift-rewards',
    ),

  getGiftReward: (id: string) =>
    axiosClient.get<ApiResponse<GiftReward>>(
      `/admin/gift-rewards/${id}`,
    ),

  createGiftReward: (data: {
    key: string;
    category: string;
    icon: string;
    cost: number;
    sortOrder?: number;
    translations: GiftRewardTranslation[];
  }) =>
    axiosClient.post<ApiResponse<GiftReward>>(
      '/admin/gift-rewards',
      data,
    ),

  updateGiftReward: (
    id: string,
    data: {
      category?: string;
      icon?: string;
      cost?: number;
      sortOrder?: number;
      isActive?: boolean;
      translations?: GiftRewardTranslation[];
    },
  ) =>
    axiosClient.put<ApiResponse<GiftReward>>(
      `/admin/gift-rewards/${id}`,
      data,
    ),

  deleteGiftReward: (id: string) =>
    axiosClient.delete<ApiResponse<{ message: string }>>(
      `/admin/gift-rewards/${id}`,
    ),

  getGiftTransactions: (page = 1, limit = 20) =>
    axiosClient.get<
      ApiResponse<PaginatedResponse<GiftTransaction>>
    >('/admin/gift-rewards/transactions', {
      params: { page, limit },
    }),

  // Activities
  getActivities: (
    page = 1,
    limit = 20,
    userId?: string,
    houseId?: string,
    from?: string,
    to?: string,
  ) =>
    axiosClient.get<
      ApiResponse<PaginatedResponse<AdminActivity>>
    >('/admin/activities', {
      params: { page, limit, userId, houseId, from, to },
    }),

  // Redemptions
  getRedemptions: (
    page = 1,
    limit = 20,
    status?: string,
    userId?: string,
  ) =>
    axiosClient.get<
      ApiResponse<PaginatedResponse<AdminRedemption>>
    >('/admin/redemptions', {
      params: { page, limit, status, userId },
    }),

  updateRedemptionStatus: (id: string, status: string) =>
    axiosClient.put<ApiResponse<AdminRedemption>>(
      `/admin/redemptions/${id}/status`,
      { status },
    ),
};
