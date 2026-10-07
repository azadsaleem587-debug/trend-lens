/** Admin API client for the TrendLens backend. */

/** localStorage key holding the admin key after login. */
export const ADMIN_KEY_STORAGE_KEY = 'trendlens_admin_key';

function getBaseUrl(): string {
  const base =
    process.env.NEXT_PUBLIC_ADMIN_API_URL ?? process.env.ADMIN_API_URL ?? '';
  return base.replace(/\/$/, '');
}

export function getAdminKey(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(ADMIN_KEY_STORAGE_KEY);
}

/**
 * Fetch helper for the backend's /api/admin/* endpoints.
 * Attaches the x-admin-key header from localStorage and throws an Error
 * carrying the server's { error } message on non-2xx responses.
 */
export async function adminFetch<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const key = getAdminKey();
  const res = await fetch(`${getBaseUrl()}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(key ? { 'x-admin-key': key } : {}),
      ...(options.headers ?? {}),
    },
  });

  if (!res.ok) {
    let message = `Request failed (${res.status})`;
    try {
      const body = await res.json();
      if (body && typeof body.error === 'string' && body.error.length > 0) {
        message = body.error;
      }
    } catch {
      // fall back to the generic message
    }
    throw new Error(message);
  }

  if (res.status === 204) return undefined as T;
  return (await res.json()) as T;
}

/** Backend health endpoint (no admin key required). */
export async function fetchHealth(): Promise<Record<string, unknown>> {
  const res = await fetch(`${getBaseUrl()}/api/health`);
  if (!res.ok) throw new Error(`Health check failed (${res.status})`);
  return (await res.json()) as Record<string, unknown>;
}

/** Format bytes as a human-readable MB/GB string. */
export function formatBytes(bytes: number): string {
  if (!Number.isFinite(bytes) || bytes < 0) return '—';
  if (bytes === 0) return '0 B';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  const i = Math.min(units.length - 1, Math.floor(Math.log(bytes) / Math.log(1024)));
  const value = bytes / Math.pow(1024, i);
  return `${value >= 100 ? Math.round(value) : value.toFixed(1)} ${units[i]}`;
}
