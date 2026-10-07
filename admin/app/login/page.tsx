'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { ADMIN_KEY_STORAGE_KEY } from '@/lib/api';

// TODO replace with real server-side auth — this client-side gate is a placeholder.
// The key comparison happens entirely in the browser and the secret lives in
// NEXT_PUBLIC_ADMIN_KEY (bundled into the client). Fine for an internal tool on a
// trusted network, not for the open internet. A production setup should POST the
// password to the server and receive an HttpOnly session cookie instead.
export default function LoginPage() {
  const router = useRouter();
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const expected = process.env.NEXT_PUBLIC_ADMIN_KEY ?? '';
    if (expected.length === 0) {
      setError('NEXT_PUBLIC_ADMIN_KEY is not configured.');
      return;
    }
    if (password === expected) {
      localStorage.setItem(ADMIN_KEY_STORAGE_KEY, password);
      router.replace('/');
    } else {
      setError('Wrong admin key.');
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-50 px-4">
      <form
        onSubmit={handleSubmit}
        className="w-full max-w-sm rounded-2xl border border-slate-200 bg-white p-8 shadow-sm"
      >
        <h1 className="text-xl font-bold tracking-tight text-slate-900">
          TrendLens Admin
        </h1>
        <p className="mt-1 text-sm text-slate-500">
          Enter the admin key to continue.
        </p>
        <label
          htmlFor="admin-key"
          className="mt-6 block text-sm font-medium text-slate-700"
        >
          Admin key
        </label>
        <input
          id="admin-key"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          autoFocus
          className="mt-1 w-full rounded-lg border border-slate-300 px-3 py-2 text-sm outline-none focus:border-violet-500 focus:ring-2 focus:ring-violet-200"
        />
        {error && (
          <p className="mt-3 text-sm font-medium text-red-600">{error}</p>
        )}
        <button
          type="submit"
          className="mt-5 w-full rounded-lg bg-violet-600 px-4 py-2 text-sm font-semibold text-white hover:bg-violet-700"
        >
          Sign in
        </button>
      </form>
    </div>
  );
}
