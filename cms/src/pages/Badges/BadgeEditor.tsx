import React, { useEffect, useState } from 'react';
import { useNavigate, useParams, Link } from 'react-router-dom';
import { adminApi } from '../../api/admin';
import {
  ArrowLeft,
  Save,
  Loader2,
  Globe,
} from 'lucide-react';
import clsx from 'clsx';

interface Translation {
  locale: string;
  name: string;
  description: string;
}

const CATEGORIES = ['streak', 'ep', 'activity', 'special'];
const RARITIES = ['COMMON', 'RARE', 'EPIC', 'LEGENDARY'];
const CONDITION_TYPES = [
  'streak_days',
  'total_ep',
  'total_activities',
  'perfect_days',
  'longest_streak',
];

export const BadgeEditor: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const isEditing = !!id && id !== 'new';

  const [code, setCode] = useState('');
  const [category, setCategory] = useState('streak');
  const [icon, setIcon] = useState('emoji_events');
  const [color, setColor] = useState('#FF6A00');
  const [sortOrder, setSortOrder] = useState(0);
  const [conditionType, setConditionType] =
    useState('streak_days');
  const [conditionValue, setConditionValue] = useState(1);
  const [rarity, setRarity] = useState('COMMON');
  const [isActive, setIsActive] = useState(true);
  const [currentLocale, setCurrentLocale] = useState('en');
  const [translations, setTranslations] = useState<
    Translation[]
  >([
    { locale: 'en', name: '', description: '' },
    { locale: 'vi', name: '', description: '' },
  ]);
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isEditing) {
      setLoading(true);
      adminApi
        .getBadge(id)
        .then((res) => {
          const b = res.data?.data;
          if (b) {
            setCode(b.code);
            setCategory(b.category);
            setIcon(b.icon);
            setColor(b.color);
            setSortOrder(b.sortOrder);
            setConditionType(b.conditionType);
            setConditionValue(b.conditionValue);
            setRarity(b.rarity);
            setIsActive(b.isActive);
            if (b.translations.length > 0) {
              setTranslations(
                b.translations.map((t) => ({
                  locale: t.locale,
                  name: t.name,
                  description: t.description || '',
                })),
              );
            }
          }
        })
        .catch(console.error)
        .finally(() => setLoading(false));
    }
  }, [id, isEditing]);

  const handleTranslationChange = (
    field: 'name' | 'description',
    value: string,
  ) => {
    setTranslations((prev) =>
      prev.map((t) =>
        t.locale === currentLocale
          ? { ...t, [field]: value }
          : t,
      ),
    );
  };

  const currentTranslation = translations.find(
    (t) => t.locale === currentLocale,
  ) || { name: '', description: '' };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      const data = {
        code,
        category,
        icon,
        color,
        sortOrder,
        conditionType,
        conditionValue,
        rarity,
        isActive,
        translations: translations.filter((t) => t.name),
      };

      if (isEditing) {
        await adminApi.updateBadge(id, data);
      } else {
        await adminApi.createBadge(data);
      }
      navigate('/badges');
    } catch (err) {
      console.error('Failed to save badge', err);
      alert('Failed to save badge');
    } finally {
      setSaving(false);
    }
  };

  if (loading)
    return (
      <div className="flex items-center justify-center h-64">
        <Loader2 className="w-6 h-6 animate-spin text-primary-600" />
      </div>
    );

  return (
    <div className="space-y-6 max-w-3xl">
      <Link
        to="/badges"
        className="flex items-center gap-2 text-slate-500 hover:text-slate-900 transition-colors text-sm"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Badges
      </Link>

      <h2 className="text-2xl font-bold text-slate-900">
        {isEditing ? 'Edit Badge' : 'Create Badge'}
      </h2>

      <form onSubmit={handleSave} className="space-y-6">
        {/* Preview */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200">
          <div className="flex items-center gap-4 mb-6">
            <div
              className="w-14 h-14 rounded-xl flex items-center justify-center text-white text-2xl shadow-lg"
              style={{ backgroundColor: color }}
            >
              🏆
            </div>
            <div>
              <p className="font-bold text-slate-900">
                {currentTranslation.name || 'Badge Name'}
              </p>
              <p className="text-sm text-slate-500">
                {code || 'badge_code'}
              </p>
            </div>
          </div>
        </div>

        {/* Basic Info */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200 space-y-4">
          <h3 className="font-bold text-slate-900">
            Basic Info
          </h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Code
              </label>
              <input
                type="text"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="streak_3"
                required
                disabled={isEditing}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Category
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Color
              </label>
              <input
                type="color"
                value={color}
                onChange={(e) => setColor(e.target.value)}
                className="w-full h-10 rounded-lg border border-slate-200 cursor-pointer"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Rarity
              </label>
              <select
                value={rarity}
                onChange={(e) => setRarity(e.target.value)}
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {RARITIES.map((r) => (
                  <option key={r} value={r}>
                    {r}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Condition Type
              </label>
              <select
                value={conditionType}
                onChange={(e) =>
                  setConditionType(e.target.value)
                }
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
              >
                {CONDITION_TYPES.map((c) => (
                  <option key={c} value={c}>
                    {c.replace(/_/g, ' ')}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Condition Value
              </label>
              <input
                type="number"
                value={conditionValue}
                onChange={(e) =>
                  setConditionValue(Number(e.target.value))
                }
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                min={1}
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Sort Order
              </label>
              <input
                type="number"
                value={sortOrder}
                onChange={(e) =>
                  setSortOrder(Number(e.target.value))
                }
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
              />
            </div>
            {isEditing && (
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={isActive}
                  onChange={(e) =>
                    setIsActive(e.target.checked)
                  }
                  className="rounded"
                  id="isActive"
                />
                <label
                  htmlFor="isActive"
                  className="text-sm text-slate-700"
                >
                  Active
                </label>
              </div>
            )}
          </div>
        </div>

        {/* Translations */}
        <div className="bg-white rounded-2xl p-6 border border-slate-200 space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="font-bold text-slate-900 flex items-center gap-2">
              <Globe className="w-4 h-4" />
              Translations
            </h3>
            <div className="flex gap-1">
              {translations.map((t) => (
                <button
                  key={t.locale}
                  type="button"
                  onClick={() =>
                    setCurrentLocale(t.locale)
                  }
                  className={clsx(
                    'px-3 py-1 rounded-lg text-xs font-medium transition-colors',
                    currentLocale === t.locale
                      ? 'bg-primary-600 text-white'
                      : 'bg-slate-100 text-slate-600 hover:bg-slate-200',
                  )}
                >
                  {t.locale.toUpperCase()}
                </button>
              ))}
            </div>
          </div>
          <div className="space-y-3">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Name ({currentLocale.toUpperCase()})
              </label>
              <input
                type="text"
                value={currentTranslation.name}
                onChange={(e) =>
                  handleTranslationChange(
                    'name',
                    e.target.value,
                  )
                }
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500"
                placeholder="Badge name..."
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Description ({currentLocale.toUpperCase()})
              </label>
              <textarea
                value={currentTranslation.description}
                onChange={(e) =>
                  handleTranslationChange(
                    'description',
                    e.target.value,
                  )
                }
                rows={2}
                className="w-full px-3 py-2 rounded-lg border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none"
                placeholder="Badge description..."
              />
            </div>
          </div>
        </div>

        {/* Submit */}
        <div className="flex justify-end">
          <button
            type="submit"
            disabled={saving}
            className="inline-flex items-center gap-2 px-6 py-2.5 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors font-medium text-sm disabled:opacity-50"
          >
            {saving ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <Save className="w-4 h-4" />
            )}
            {isEditing ? 'Update Badge' : 'Create Badge'}
          </button>
        </div>
      </form>
    </div>
  );
};
