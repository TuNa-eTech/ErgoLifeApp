
import React, { useEffect, useState } from 'react';
import { adminApi, type House } from '../../api/admin';
import { Search, ChevronLeft, ChevronRight, Home, Users } from 'lucide-react';
import { Link } from 'react-router-dom';

export const HousesList: React.FC = () => {
  const [houses, setHouses] = useState<House[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  const fetchHouses = async () => {
    setLoading(true);
    try {
      const response = await adminApi.getHouses(page, 10, searchQuery);
      setHouses(response.data?.data?.data || []);
      setTotalPages(response.data?.data?.meta?.pages || 1);
    } catch (error) {
      console.error("Failed to fetch houses:", error);
      setHouses([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchHouses();
  }, [page, searchQuery]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setSearchQuery(search);
    setPage(1);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h2 className="text-2xl font-bold text-slate-900">House Management</h2>
        
        <form onSubmit={handleSearch} className="flex gap-2 w-full sm:w-auto">
          <div className="relative flex-1 sm:flex-none">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <input
              type="text"
              placeholder="Search houses..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-9 pr-4 py-2 rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary-500 w-full sm:w-64"
            />
          </div>
          <button type="submit" className="px-4 py-2 bg-slate-900 text-white rounded-lg hover:bg-slate-800">
            Search
          </button>
        </form>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {loading ? (
           <p className="text-slate-500 col-span-full text-center py-10">Loading houses...</p>
        ) : houses.length === 0 ? (
           <p className="text-slate-500 col-span-full text-center py-10">No houses found</p>
        ) : (
          houses.map((house) => (
            <Link key={house.id} to={`/houses/${house.id}`} className="group relative bg-white p-6 rounded-2xl shadow-sm border border-slate-200 hover:shadow-md transition-all">
               <div className="flex items-start justify-between mb-4">
                  <div className="p-3 bg-emerald-50 rounded-xl text-emerald-600 group-hover:bg-emerald-600 group-hover:text-white transition-colors">
                      <Home className="w-6 h-6" />
                  </div>
                  {house.isPersonal && <span className="px-2 py-1 bg-amber-100 text-amber-700 text-xs font-bold rounded-full">Personal</span>}
               </div>

               <h3 className="text-lg font-bold text-slate-900 mb-1">{house.name}</h3>
               <p className="text-sm text-slate-500 mb-4">Code: <span className="font-mono text-slate-700">{house.inviteCode}</span></p>

               <div className="flex items-center text-sm text-slate-500 gap-2 border-t border-slate-50 pt-3">
                   <Users className="w-4 h-4" />
                   <span>{house._count?.members || 0} Members</span>
               </div>
            </Link>
          ))
        )}
      </div>

      {/* Pagination */}
      <div className="flex justify-center items-center gap-4 py-4">
        <button 
          onClick={() => setPage(p => Math.max(1, p - 1))}
          disabled={page === 1}
          className="p-2 border rounded-lg disabled:opacity-50"
        >
          <ChevronLeft className="w-5 h-5" />
        </button>
        <span className="text-sm text-slate-600">Page {page} of {totalPages}</span>
        <button 
          onClick={() => setPage(p => Math.min(totalPages, p + 1))}
          disabled={page === totalPages}
          className="p-2 border rounded-lg disabled:opacity-50"
        >
          <ChevronRight className="w-5 h-5" />
        </button>
      </div>
    </div>
  );
};
