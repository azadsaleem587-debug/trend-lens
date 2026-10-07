'use client';

import { useCallback, useEffect, useState } from 'react';
import { adminFetch } from '@/lib/api';
import type { TrendTemplate } from '@/lib/types';

const EMPTY_FORM: Omit<TrendTemplate, 'id' | 'usesCount'> & {
  usesCount: number;
} = {
  title: '',
  category: '',
  usesCount: 0,
  isNewDrop: false,
  effectType: '',
  aiPrompt: '',
  thumbnailUrl: '',
  previewUrl: '',
};

function TemplateModal({
  initial,
  onClose,
  onSaved,
}: {
  initial: TrendTemplate | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const [form, setForm] = useState(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (initial) {
      setForm({
        title: initial.title,
        category: initial.category,
        usesCount: initial.usesCount,
        isNewDrop: initial.isNewDrop,
        effectType: initial.effectType,
        aiPrompt: initial.aiPrompt,
        thumbnailUrl: initial.thumbnailUrl ?? '',
        previewUrl: initial.previewUrl ?? '',
      });
    } else {
      setForm(EMPTY_FORM);
    }
  }, [initial]);

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError('');
    try {
      if (initial) {
        await adminFetch(`/api/admin/templates/${initial.id}`, {
          method: 'PUT',
          body: JSON.stringify(form),
        });
      } else {
        await adminFetch('/api/admin/templates', {
          method: 'POST',
          body: JSON.stringify(form),
        });
      }
      onSaved();
      onClose();
    } catch (e2) {
      setError(e2 instanceof Error ? e2.message : 'Save failed.');
    } finally {
      setSaving(false);
    }
  }

  const inputCls =
    'mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-violet-500 focus:ring-2 focus:ring-violet-200';
  const labelCls = 'block text-sm font-medium text-slate-700';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4">
      <div className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white p-6 shadow-xl">
        <h3 className="text-lg font-bold text-slate-900">
          {initial ? 'Edit template' : 'Create template'}
        </h3>
        <form onSubmit={handleSubmit} className="mt-4 space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label className={labelCls} htmlFor="t-title">Title</label>
              <input
                id="t-title"
                required
                className={inputCls}
                value={form.title}
                onChange={(e) => set('title', e.target.value)}
              />
            </div>
            <div>
              <label className={labelCls} htmlFor="t-category">Category</label>
              <input
                id="t-category"
                required
                className={inputCls}
                value={form.category}
                onChange={(e) => set('category', e.target.value)}
              />
            </div>
            <div>
              <label className={labelCls} htmlFor="t-effect">Effect type</label>
              <input
                id="t-effect"
                required
                placeholder="e.g. zoom, glitch, morph"
                className={inputCls}
                value={form.effectType}
                onChange={(e) => set('effectType', e.target.value)}
              />
            </div>
            <div>
              <label className={labelCls} htmlFor="t-uses">Uses count</label>
              <input
                id="t-uses"
                type="number"
                min={0}
                className={inputCls}
                value={form.usesCount}
                onChange={(e) => set('usesCount', Number(e.target.value))}
              />
            </div>
            <div>
              <label className={labelCls} htmlFor="t-thumb">Thumbnail URL</label>
              <input
                id="t-thumb"
                className={inputCls}
                value={form.thumbnailUrl}
                onChange={(e) => set('thumbnailUrl', e.target.value)}
              />
            </div>
            <div>
              <label className={labelCls} htmlFor="t-preview">Preview URL</label>
              <input
                id="t-preview"
                className={inputCls}
                value={form.previewUrl}
                onChange={(e) => set('previewUrl', e.target.value)}
              />
            </div>
          </div>
          <div>
            <label className={labelCls} htmlFor="t-prompt">AI prompt</label>
            <textarea
              id="t-prompt"
              required
              rows={4}
              className={inputCls}
              value={form.aiPrompt}
              onChange={(e) => set('aiPrompt', e.target.value)}
            />
          </div>
          <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
            <input
              type="checkbox"
              checked={form.isNewDrop}
              onChange={(e) => set('isNewDrop', e.target.checked)}
              className="h-4 w-4 rounded border-slate-300 text-violet-600"
            />
            Weekly drop (show “New” badge in the app)
          </label>
          {error && (
            <p className="text-sm font-medium text-red-600">{error}</p>
          )}
          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-slate-300 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={saving}
              className="rounded-lg bg-violet-600 px-4 py-2 text-sm font-semibold text-white hover:bg-violet-700 disabled:opacity-50"
            >
              {saving ? 'Saving…' : initial ? 'Save changes' : 'Create'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default function TemplatesPage() {
  const [templates, setTemplates] = useState<TrendTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [modal, setModal] = useState<'create' | 'edit' | null>(null);
  const [editing, setEditing] = useState<TrendTemplate | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const data = await adminFetch<TrendTemplate[]>('/api/admin/templates');
      setTemplates(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load templates.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  async function handleDelete(t: TrendTemplate) {
    if (!window.confirm(`Delete template “${t.title}”?`)) return;
    try {
      await adminFetch(`/api/admin/templates/${t.id}`, { method: 'DELETE' });
      load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Delete failed.');
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">
            Templates
          </h2>
          <p className="mt-1 text-sm text-slate-500">
            Manage weekly trend templates served to the app.
          </p>
        </div>
        <button
          onClick={() => {
            setEditing(null);
            setModal('create');
          }}
          className="rounded-lg bg-violet-600 px-4 py-2 text-sm font-semibold text-white hover:bg-violet-700"
        >
          New template
        </button>
      </div>

      {error && (
        <div className="mt-6 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
          {error}
        </div>
      )}

      <div className="mt-6 overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-slate-200 bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th className="px-4 py-3">Title</th>
              <th className="px-4 py-3">Category</th>
              <th className="px-4 py-3">Effect</th>
              <th className="px-4 py-3">Uses</th>
              <th className="px-4 py-3">Badge</th>
              <th className="px-4 py-3 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-slate-500">
                  Loading templates…
                </td>
              </tr>
            ) : templates.length === 0 ? (
              <tr>
                <td colSpan={6} className="px-4 py-8 text-center text-slate-500">
                  No templates yet. Create the first one.
                </td>
              </tr>
            ) : (
              templates.map((t) => (
                <tr key={t.id} className="border-b border-slate-100 last:border-0">
                  <td className="px-4 py-3 font-medium text-slate-900">
                    {t.title}
                  </td>
                  <td className="px-4 py-3 text-slate-600">{t.category}</td>
                  <td className="px-4 py-3 text-slate-600">{t.effectType}</td>
                  <td className="px-4 py-3 text-slate-600">
                    {t.usesCount.toLocaleString()}
                  </td>
                  <td className="px-4 py-3">
                    {t.isNewDrop && (
                      <span className="rounded-full bg-emerald-100 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
                        New drop
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-right">
                    <button
                      onClick={() => {
                        setEditing(t);
                        setModal('edit');
                      }}
                      className="mr-3 font-medium text-violet-600 hover:text-violet-800"
                    >
                      Edit
                    </button>
                    <button
                      onClick={() => handleDelete(t)}
                      className="font-medium text-red-600 hover:text-red-800"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {modal && (
        <TemplateModal
          initial={modal === 'edit' ? editing : null}
          onClose={() => {
            setModal(null);
            setEditing(null);
          }}
          onSaved={load}
        />
      )}
    </div>
  );
}
