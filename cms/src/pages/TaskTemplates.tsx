import React, { useEffect, useState } from 'react';
import { apiClient } from '../api/client';
import { Plus, Pencil, Trash2, Search, Loader2, AlertCircle } from 'lucide-react';
import { Link } from 'react-router-dom';
import clsx from 'clsx';

interface TaskTemplate {
  id: string;
  metsValue: number;
  defaultDuration: number;
  icon: string;
  color: string;
  category: string;
  isActive: boolean;
  translations: { locale: string; name: string }[];
}

export const TaskTemplates: React.FC = () => {
  const [templates, setTemplates] = useState<TaskTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [deleteLoading, setDeleteLoading] = useState<string | null>(null);

  useEffect(() => {
    fetchTemplates();
  }, []);

  const fetchTemplates = async () => {
    try {
      const response = await apiClient.get('/admin/task-templates');
      // API response is wrapped: { success: true, data: [...] }
      setTemplates(response.data.data);
    } catch (error) {
      console.error('Failed to fetch templates', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to delete this template? This action cannot be undone.')) {
      setDeleteLoading(id);
      try {
        await apiClient.delete(`/admin/task-templates/${id}`);
        fetchTemplates();
      } catch (error) {
        alert('Failed to delete template');
      } finally {
        setDeleteLoading(null);
      }
    }
  };

  const getEnglishName = (t: TaskTemplate) => t.translations.find(tr => tr.locale === 'en')?.name || 'Unnamed';

  const filteredTemplates = templates.filter(t => 
    getEnglishName(t).toLowerCase().includes(searchTerm.toLowerCase()) || 
    t.category.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const categoryColors: Record<string, string> = {
    general: 'bg-slate-100 text-slate-700',
    household: 'bg-amber-50 text-amber-700',
    fitness: 'bg-emerald-50 text-emerald-700',
    wellness: 'bg-purple-50 text-purple-700',
    cleaning: 'bg-blue-50 text-blue-700',
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Task Templates</h1>
          <p className="text-slate-500 mt-1">Manage your exercise and activity library</p>
        </div>
        <Link
          to="/templates/new"
          className="btn btn-primary"
        >
          <Plus className="w-5 h-5" />
          Create Template
        </Link>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-4 gap-4">
        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Total Templates</p>
          <p className="text-3xl font-bold text-slate-900 mt-1">{templates.length}</p>
        </div>
        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Active</p>
          <p className="text-3xl font-bold text-emerald-600 mt-1">{templates.filter(t => t.isActive).length}</p>
        </div>
        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Inactive</p>
          <p className="text-3xl font-bold text-slate-400 mt-1">{templates.filter(t => !t.isActive).length}</p>
        </div>
        <div className="card p-5">
          <p className="text-sm font-medium text-slate-500">Categories</p>
          <p className="text-3xl font-bold text-primary-600 mt-1">{new Set(templates.map(t => t.category)).size}</p>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="card p-4">
        <div className="relative max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
          <input 
            type="text" 
            placeholder="Search templates by name or category..." 
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="input pl-11"
          />
        </div>
      </div>

      {/* Data Table */}
      <div className="card overflow-hidden">
        <table className="table">
          <thead>
            <tr>
              <th className="w-16">Icon</th>
              <th>Name</th>
              <th>Category</th>
              <th className="w-24 text-center">METs</th>
              <th className="w-28 text-center">Duration</th>
              <th className="w-24 text-center">Status</th>
              <th className="w-24 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={7} className="py-16 text-center">
                  <div className="flex flex-col items-center gap-3 text-slate-400">
                    <Loader2 className="w-8 h-8 animate-spin" />
                    <span>Loading templates...</span>
                  </div>
                </td>
              </tr>
            ) : filteredTemplates.length === 0 ? (
              <tr>
                <td colSpan={7} className="py-16 text-center">
                  <div className="flex flex-col items-center gap-3 text-slate-400">
                    <AlertCircle className="w-8 h-8" />
                    <span>No templates found</span>
                    {searchTerm && (
                      <button 
                        onClick={() => setSearchTerm('')}
                        className="text-primary-600 hover:underline text-sm"
                      >
                        Clear search
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            ) : (
              filteredTemplates.map((template, index) => (
                <tr 
                  key={template.id} 
                  className="group"
                  style={{ animationDelay: `${index * 30}ms` }}
                >
                  <td>
                    <div 
                      className="w-11 h-11 rounded-xl flex items-center justify-center text-white shadow-sm transition-transform group-hover:scale-105"
                      style={{ backgroundColor: template.color }}
                    >
                      <span className="material-icons text-xl">{template.icon}</span>
                    </div>
                  </td>
                  <td>
                    <span className="font-medium text-slate-900">{getEnglishName(template)}</span>
                  </td>
                  <td>
                    <span className={clsx(
                      'badge capitalize',
                      categoryColors[template.category] || 'bg-slate-100 text-slate-700'
                    )}>
                      {template.category}
                    </span>
                  </td>
                  <td className="text-center font-mono text-sm">{template.metsValue}</td>
                  <td className="text-center">{template.defaultDuration} min</td>
                  <td className="text-center">
                    <span className={clsx(
                      'badge',
                      template.isActive ? 'badge-success' : 'badge-neutral'
                    )}>
                      {template.isActive ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td className="text-right">
                    <div className="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <Link
                        to={`/templates/${template.id}`}
                        className="p-2 text-slate-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                        title="Edit"
                      >
                        <Pencil className="w-4 h-4" />
                      </Link>
                      <button
                        onClick={() => handleDelete(template.id)}
                        disabled={deleteLoading === template.id}
                        className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
                        title="Delete"
                      >
                        {deleteLoading === template.id ? (
                          <Loader2 className="w-4 h-4 animate-spin" />
                        ) : (
                          <Trash2 className="w-4 h-4" />
                        )}
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
