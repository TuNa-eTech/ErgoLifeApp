import React, { useEffect, useState } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import { apiClient } from '../api/client';
import { ArrowLeft, Save, Globe, Loader2, Eye, Palette, Clock, Zap } from 'lucide-react';
import clsx from 'clsx';

interface TaskTemplateTranslation {
  locale: string;
  name: string;
  description?: string;
}

interface TaskTemplate {
  id?: string;
  metsValue: number;
  defaultDuration: number;
  icon: string;
  color: string;
  category: string;
  isActive: boolean;
  animation?: string;
  sortOrder: number;
  translations: TaskTemplateTranslation[];
}

const CATEGORIES = [
  { value: 'general', label: 'General', color: 'bg-slate-500' },
  { value: 'household', label: 'Household', color: 'bg-amber-500' },
  { value: 'fitness', label: 'Fitness', color: 'bg-emerald-500' },
  { value: 'wellness', label: 'Wellness', color: 'bg-purple-500' },
  { value: 'cleaning', label: 'Cleaning', color: 'bg-blue-500' },
];

export const TaskTemplateEditor: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEditing = !!id;
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [activeTab, setActiveTab] = useState('en');

  const [formData, setFormData] = useState<TaskTemplate>({
    metsValue: 3.5,
    defaultDuration: 10,
    icon: 'fitness_center',
    color: '#6366f1',
    category: 'general',
    isActive: true,
    sortOrder: 0,
    animation: '',
    translations: [
      { locale: 'en', name: '', description: '' },
      { locale: 'vi', name: '', description: '' },
    ],
  });

  useEffect(() => {
    if (isEditing) {
      fetchTemplate();
    }
  }, [id]);

  const fetchTemplate = async () => {
    setLoading(true);
    try {
      const response = await apiClient.get(`/admin/task-templates/${id}`);
      // API response is wrapped: { success: true, data: {...} }
      const data = response.data.data;
      
      const existingLocales = data.translations.map((t: any) => t.locale);
      const mergedTranslations = [...data.translations];
      if (!existingLocales.includes('en')) mergedTranslations.push({ locale: 'en', name: '', description: '' });
      if (!existingLocales.includes('vi')) mergedTranslations.push({ locale: 'vi', name: '', description: '' });
      
      setFormData({ ...data, translations: mergedTranslations });
    } catch (error) {
      console.error('Failed to fetch', error);
      alert('Failed to load template');
      navigate('/templates');
    } finally {
      setLoading(false);
    }
  };

  const handleTranslationChange = (field: 'name' | 'description', value: string) => {
    const newTranslations = formData.translations.map(t => 
      t.locale === activeTab ? { ...t, [field]: value } : t
    );
    setFormData({ ...formData, translations: newTranslations });
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const enName = formData.translations.find(t => t.locale === 'en')?.name;
    if (!enName) {
      alert('English Name is required');
      return;
    }

    setSaving(true);
    try {
      if (isEditing) {
        await apiClient.put(`/admin/task-templates/${id}`, formData);
      } else {
        await apiClient.post('/admin/task-templates', formData);
      }
      navigate('/templates');
    } catch (error) {
      console.error(error);
      alert('Failed to save template');
    } finally {
      setSaving(false);
    }
  };

  const currentTranslation = formData.translations.find(t => t.locale === activeTab);

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <Loader2 className="w-8 h-8 animate-spin text-primary-600" />
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link 
            to="/templates" 
            className="p-2.5 hover:bg-slate-100 rounded-xl transition-colors text-slate-500 hover:text-slate-700"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-900">
              {isEditing ? 'Edit Template' : 'Create Template'}
            </h1>
            <p className="text-slate-500 text-sm mt-0.5">Configure task properties and translations</p>
          </div>
        </div>
        <button
          onClick={handleSave}
          disabled={saving}
          className="btn btn-primary"
        >
          {saving ? (
            <>
              <Loader2 className="w-5 h-5 animate-spin" />
              Saving...
            </>
          ) : (
            <>
              <Save className="w-5 h-5" />
              Save Changes
            </>
          )}
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Form Inputs */}
        <div className="lg:col-span-2 space-y-6">
          {/* General Settings Card */}
          <div className="card">
            <div className="card-header">
              <h3 className="text-lg font-semibold text-slate-800 flex items-center gap-2">
                <Palette className="w-5 h-5 text-primary-500" />
                Appearance & Behavior
              </h3>
            </div>
            <div className="card-body">
              <div className="grid grid-cols-2 gap-6">
                {/* Icon */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Material Icon Name</label>
                  <input 
                    type="text" 
                    value={formData.icon} 
                    onChange={e => setFormData({...formData, icon: e.target.value})}
                    className="input"
                    placeholder="e.g. fitness_center"
                  />
                  <p className="text-xs text-slate-400">
                    Find icons at <a href="https://fonts.google.com/icons" target="_blank" className="text-primary-600 hover:underline">Material Icons</a>
                  </p>
                </div>

                {/* Color */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Theme Color</label>
                  <div className="flex items-center gap-3">
                    <input 
                      type="color" 
                      value={formData.color}
                      onChange={e => setFormData({...formData, color: e.target.value})}
                      className="h-11 w-16 rounded-lg cursor-pointer border border-slate-200"
                    />
                    <input 
                      type="text" 
                      value={formData.color}
                      onChange={e => setFormData({...formData, color: e.target.value})}
                      className="input flex-1 font-mono text-sm uppercase"
                    />
                  </div>
                </div>

                {/* Duration */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700 flex items-center gap-2">
                    <Clock className="w-4 h-4 text-slate-400" />
                    Duration (minutes)
                  </label>
                  <input 
                    type="number" 
                    value={formData.defaultDuration}
                    onChange={e => setFormData({...formData, defaultDuration: parseInt(e.target.value) || 0})}
                    className="input"
                    min={1}
                  />
                </div>

                {/* METs */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700 flex items-center gap-2">
                    <Zap className="w-4 h-4 text-slate-400" />
                    METs Value
                  </label>
                  <input 
                    type="number" 
                    step="0.1"
                    value={formData.metsValue}
                    onChange={e => setFormData({...formData, metsValue: parseFloat(e.target.value) || 0})}
                    className="input"
                    min={1}
                  />
                </div>

                {/* Category */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Category</label>
                  <select 
                    value={formData.category}
                    onChange={e => setFormData({...formData, category: e.target.value})}
                    className="input"
                  >
                    {CATEGORIES.map(cat => (
                      <option key={cat.value} value={cat.value}>{cat.label}</option>
                    ))}
                  </select>
                </div>

                {/* Sort Order */}
                <div className="space-y-2">
                  <label className="text-sm font-medium text-slate-700">Sort Order</label>
                  <input 
                    type="number" 
                    value={formData.sortOrder}
                    onChange={e => setFormData({...formData, sortOrder: parseInt(e.target.value) || 0})}
                    className="input"
                  />
                </div>

                {/* Animation URL */}
                <div className="col-span-2 space-y-2">
                  <label className="text-sm font-medium text-slate-700">Animation URL (Lottie JSON)</label>
                  <input 
                    type="text" 
                    value={formData.animation || ''}
                    onChange={e => setFormData({...formData, animation: e.target.value})}
                    placeholder="https://assets.lottiefiles.com/..."
                    className="input font-mono text-sm"
                  />
                </div>

                {/* Active Status */}
                <div className="col-span-2 flex items-center gap-3 pt-2">
                  <label className="relative inline-flex items-center cursor-pointer">
                    <input 
                      type="checkbox" 
                      checked={formData.isActive}
                      onChange={e => setFormData({...formData, isActive: e.target.checked})}
                      className="sr-only peer"
                    />
                    <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-primary-500/20 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                  </label>
                  <span className="text-sm font-medium text-slate-700">Template is Active</span>
                </div>
              </div>
            </div>
          </div>

          {/* Localization Card */}
          <div className="card">
            <div className="card-header flex items-center justify-between">
              <h3 className="text-lg font-semibold text-slate-800 flex items-center gap-2">
                <Globe className="w-5 h-5 text-primary-500" />
                Localization
              </h3>
              <div className="flex bg-slate-100 p-1 rounded-lg">
                {[
                  { code: 'en', label: 'English' },
                  { code: 'vi', label: 'Tiếng Việt' }
                ].map(lang => (
                  <button
                    key={lang.code}
                    onClick={() => setActiveTab(lang.code)}
                    className={clsx(
                      "px-4 py-1.5 rounded-md text-sm font-medium transition-all",
                      activeTab === lang.code 
                        ? "bg-white text-primary-600 shadow-sm" 
                        : "text-slate-500 hover:text-slate-700"
                    )}
                  >
                    {lang.label}
                  </button>
                ))}
              </div>
            </div>
            <div className="card-body space-y-4">
              <div className="space-y-2">
                <label className="text-sm font-medium text-slate-700">
                  Display Name <span className="text-red-500">*</span>
                </label>
                <input 
                  type="text" 
                  value={currentTranslation?.name || ''}
                  onChange={e => handleTranslationChange('name', e.target.value)}
                  className="input"
                  placeholder={activeTab === 'en' ? 'e.g. Push Ups' : 'e.g. Hít đất'}
                />
              </div>
              <div className="space-y-2">
                <label className="text-sm font-medium text-slate-700">Description</label>
                <textarea 
                  value={currentTranslation?.description || ''}
                  onChange={e => handleTranslationChange('description', e.target.value)}
                  rows={3}
                  className="input resize-none"
                  placeholder="Optional task description..."
                />
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: Live Preview */}
        <div className="lg:col-span-1">
          <div className="sticky top-28">
            <div className="flex items-center gap-2 mb-4">
              <Eye className="w-4 h-4 text-slate-400" />
              <span className="text-sm font-semibold text-slate-500 uppercase tracking-wider">Live Preview</span>
            </div>
            
            {/* Mobile Frame */}
            <div className="w-full max-w-[300px] mx-auto bg-slate-900 rounded-[2.5rem] p-3 shadow-2xl border-4 border-slate-800">
              {/* Status Bar */}
              <div className="bg-slate-50 rounded-[2rem] overflow-hidden">
                <div className="flex justify-between items-center px-6 py-2 bg-white border-b border-slate-100">
                  <span className="text-xs font-semibold text-slate-900">9:41</span>
                  <div className="flex items-center gap-1">
                    <div className="w-4 h-2 bg-slate-900 rounded-sm" />
                  </div>
                </div>

                {/* App Content */}
                <div className="p-4 space-y-4 min-h-[400px] bg-slate-50">
                  <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Task Card</p>
                  
                  {/* Preview Task Card */}
                  <div className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100">
                    <div className="flex items-center gap-4">
                      <div 
                        className="w-14 h-14 rounded-2xl flex items-center justify-center text-white shadow-lg transition-all"
                        style={{ backgroundColor: formData.color }}
                      >
                        <span className="material-icons text-2xl">{formData.icon}</span>
                      </div>
                      <div className="flex-1">
                        <h4 className="font-bold text-slate-900 text-lg leading-tight">
                          {formData.translations.find(t => t.locale === 'en')?.name || 'Task Name'}
                        </h4>
                        <div className="flex items-center gap-3 mt-1.5">
                          <span className="text-xs text-slate-500 flex items-center gap-1">
                            <Clock className="w-3 h-3" />
                            {formData.defaultDuration} min
                          </span>
                          <span className="text-xs text-slate-500 flex items-center gap-1">
                            <Zap className="w-3 h-3" />
                            {formData.metsValue} METs
                          </span>
                        </div>
                      </div>
                    </div>
                    
                    {currentTranslation?.description && (
                      <p className="text-sm text-slate-500 mt-3 pt-3 border-t border-slate-100 line-clamp-2">
                        {currentTranslation.description}
                      </p>
                    )}
                  </div>

                  {/* Category Badge */}
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-slate-400">Category:</span>
                    <span className={clsx(
                      'badge capitalize',
                      CATEGORIES.find(c => c.value === formData.category)?.color.replace('bg-', 'bg-') + '/10',
                      CATEGORIES.find(c => c.value === formData.category)?.color.replace('bg-', 'text-').replace('-500', '-700')
                    )}>
                      {formData.category}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <p className="text-center text-xs text-slate-400 mt-4">
              * Preview shows English locale
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
