'use client';

import { useCallback, useEffect, useState } from 'react';
import { fetchHealth } from '@/lib/api';

const API_URL =
  process.env.NEXT_PUBLIC_ADMIN_API_URL ?? process.env.ADMIN_API_URL ?? '';

export default function SettingsPage() {
  const [health, setHealth] = useState<Record<string, unknown> | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      setHealth(await fetchHealth());
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Health check failed.');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  return (
    <div>
      <h2 className="text-2xl font-bold tracking-tight text-slate-900">
        Settings
      </h2>
      <p className="mt-1 text-sm text-slate-500">
        Environment and backend status (read-only).
      </p>

      <div className="mt-6 space-y-4">
        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h3 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
            Backend URL
          </h3>
          <p className="mt-2 font-mono text-sm text-slate-900">
            {API_URL || '(not configured — set NEXT_PUBLIC_ADMIN_API_URL)'}
          </p>
          <p className="mt-1 text-xs text-slate-400">
            From NEXT_PUBLIC_ADMIN_API_URL / ADMIN_API_URL. Restart the dev
            server after changing env vars.
          </p>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
              Backend health — GET /api/health
            </h3>
            <button
              onClick={load}
              disabled={loading}
              className="rounded-lg border border-slate-300 px-3 py-1.5 text-xs font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50"
            >
              {loading ? 'Checking…' : 'Re-check'}
            </button>
          </div>
          {error ? (
            <p className="mt-3 text-sm font-medium text-red-600">{error}</p>
          ) : health ? (
            <pre className="mt-3 overflow-x-auto rounded-lg bg-slate-900 p-4 text-xs text-slate-100">
              {JSON.stringify(health, null, 2)}
            </pre>
          ) : null}
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h3 className="text-sm font-semibold uppercase tracking-wide text-slate-500">
            Storage & deployment
          </h3>
          <p className="mt-2 text-sm text-slate-600">
            The backend stores uploads on disk (Servarica VPS). For{' '}
            <code className="rounded bg-slate-100 px-1 text-xs">UPLOAD_DIR</code>{' '}
            location, volume mounts, and reverse-proxy config, see the server
            repo’s <code className="rounded bg-slate-100 px-1 text-xs">DEPLOY.md</code> —
            this panel only reads data through the backend’s admin API and does
            not manage disks directly.
          </p>
        </div>
      </div>
    </div>
  );
}
