'use client';

import { useCallback, useEffect, useState } from 'react';
import { adminFetch, formatBytes } from '@/lib/api';
import type { AdminUser } from '@/lib/types';

function PremiumToggle({
  user,
  onChange,
}: {
  user: AdminUser;
  onChange: (u: AdminUser) => void;
}) {
  const [busy, setBusy] = useState(false);

  async function toggle() {
    setBusy(true);
    try {
      const updated = await adminFetch<AdminUser>(
        `/api/admin/users/${user.id}`,
        {
          method: 'PATCH',
          body: JSON.stringify({ isPremium: !user.isPremium }),
        },
      );
      onChange(updated);
    } catch {
      // keep local state unchanged on failure; the row shows an error banner
    } finally {
      setBusy(false);
    }
  }

  return (
    <button
      role="switch"
      aria-checked={user.isPremium}
      aria-label={`Premium for ${user.id}`}
      disabled={busy}
      onClick={toggle}
      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors disabled:opacity-50 ${
        user.isPremium ? 'bg-violet-600' : 'bg-slate-300'
      }`}
    >
      <span
        className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
          user.isPremium ? 'translate-x-6' : 'translate-x-1'
        }`}
      />
    </button>
  );
}

function QuotaEditor({
  user,
  onChange,
}: {
  user: AdminUser;
  onChange: (u: AdminUser) => void;
}) {
  const [value, setValue] = useState(String(user.quotaMB));
  const [busy, setBusy] = useState(false);
  const [saved, setSaved] = useState(false);
  const dirty = value !== String(user.quotaMB);

  async function save() {
    const quotaMB = Number(value);
    if (!Number.isFinite(quotaMB) || quotaMB < 0) return;
    setBusy(true);
    try {
      const updated = await adminFetch<AdminUser>(
        `/api/admin/users/${user.id}`,
        { method: 'PATCH', body: JSON.stringify({ quotaMB }) },
      );
      onChange(updated);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex items-center gap-2">
      <input
        type="number"
        min={0}
        aria-label={`Quota MB for ${user.id}`}
        value={value}
        onChange={(e) => setValue(e.target.value)}
        className="w-24 rounded-lg border border-slate-300 px-2 py-1.5 text-sm outline-none focus:border-violet-500 focus:ring-2 focus:ring-violet-200"
      />
      <button
        onClick={save}
        disabled={busy || !dirty}
        className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-40"
      >
        {busy ? 'Saving…' : 'Save'}
      </button>
      {saved && !dirty && (
        <span className="text-xs font-medium text-emerald-600">Saved</span>
      )}
    </div>
  );
}

export default function UsersPage() {
  const [users, setUsers] = useState<AdminUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const data = await adminFetch<AdminUser[]>('/api/admin/users');
      setUsers(data);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load users.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  function updateUser(updated: AdminUser) {
    setUsers((us) => us.map((u) => (u.id === updated.id ? updated : u)));
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">
            Users
          </h2>
          <p className="mt-1 text-sm text-slate-500">
            Toggle premium status and adjust storage quotas.
          </p>
        </div>
        <button
          onClick={load}
          disabled={loading}
          className="rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50"
        >
          {loading ? 'Refreshing…' : 'Refresh'}
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
              <th className="px-4 py-3">User ID</th>
              <th className="px-4 py-3">Premium</th>
              <th className="px-4 py-3">Quota (MB)</th>
              <th className="px-4 py-3">Storage used</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={4} className="px-4 py-8 text-center text-slate-500">
                  Loading users…
                </td>
              </tr>
            ) : users.length === 0 ? (
              <tr>
                <td colSpan={4} className="px-4 py-8 text-center text-slate-500">
                  No users found.
                </td>
              </tr>
            ) : (
              users.map((u) => (
                <tr key={u.id} className="border-b border-slate-100 last:border-0">
                  <td className="px-4 py-3 font-mono text-xs text-slate-900">
                    {u.id}
                  </td>
                  <td className="px-4 py-3">
                    <PremiumToggle user={u} onChange={updateUser} />
                  </td>
                  <td className="px-4 py-3">
                    <QuotaEditor user={u} onChange={updateUser} />
                  </td>
                  <td className="px-4 py-3 text-slate-600">
                    {u.storageUsedBytes !== undefined
                      ? formatBytes(u.storageUsedBytes)
                      : '—'}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
