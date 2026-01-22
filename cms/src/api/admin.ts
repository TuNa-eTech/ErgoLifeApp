
import { apiClient as axiosClient } from './client';

export interface DashboardStats {
  totalUsers: number;
  totalHouses: number;
  totalActivities: number;
  activeUsers: number;
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
  getDashboardStats: () => axiosClient.get<ApiResponse<DashboardStats>>('/admin/stats/dashboard'),
  
  getUsers: (page = 1, limit = 20, search = '') => 
    axiosClient.get<ApiResponse<PaginatedResponse<User>>>('/admin/users', { params: { page, limit, search } }),
  
  getUser: (id: string) => axiosClient.get<ApiResponse<User>>(`/admin/users/${id}`),
  
  getHouses: (page = 1, limit = 20, search = '') => 
    axiosClient.get<ApiResponse<PaginatedResponse<House>>>('/admin/houses', { params: { page, limit, search } }),
  
  getHouse: (id: string) => axiosClient.get<ApiResponse<House>>(`/admin/houses/${id}`),
};
