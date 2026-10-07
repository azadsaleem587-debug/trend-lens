'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import { ADMIN_KEY_STORAGE_KEY } from '@/lib/api';

const NAV = [
  { href: '/', label: 'Dashboard' },
  { href: '/templates', label: 'Templates' },
  { href: '/users', label: 'Users' },
  { href: '/settings', label: 'Settings' },
];

/** App shell: sidebar nav + auth gate. Hidden on the login page. */
export function Shell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [authed, setAuthed] = useState<boolean | null>(null);
  const isLogin = pathname === '/login';

  useEffect(() => {
    if (isLogin) {
      setAuthed(true);
      return;
    }
    // TODO replace with real server-side auth — this client-side gate is a placeholder.
    // Currently any visitor who knows NEXT_PUBLIC_ADMIN_KEY can set this localStorage
    // value and walk past the gate. A production setup should verify the key (or a
    // session cookie/JWT) on the server, e.g. in middleware.ts, before rendering pages.
    setAuthed(localStorage.getItem(ADMIN_KEY_STORAGE_KEY) !== null);
  }, [isLogin]);

  useEffect(() => {
    if (authed === false && !isLogin) router.replace('/login');
  }, [authed, isLogin, router]);

  function logout() {
    localStorage.removeItem(ADMIN_KEY_STORAGE_KEY);
    router.replace('/login');
  }

  if (authed === null) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-50">
        <p className="text-sm text-slate-500">Loading…</p>
      </div>
    );
  }

  if (isLogin) {
    return <main className="min-h-screen">{children}</main>;
  }

  return (
    <div className="flex min-h-screen">
      <aside className="w-60 shrink-0 border-r border-slate-200 bg-white">
        <div className="border-b border-slate-200 px-6 py-5">
          <h1 className="text-lg font-bold tracking-tight text-slate-900">
            TrendLens <span className="font-normal text-slate-400">Admin</span>
          </h1>
        </div>
        <nav className="space-y-1 px-3 py-4">
          {NAV.map((item) => {
            const active =
              item.href === '/'
                ? pathname === '/'
                : pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={`block rounded-lg px-3 py-2 text-sm font-medium ${
                  active
                    ? 'bg-violet-100 text-violet-800'
                    : 'text-slate-600 hover:bg-slate-100'
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
        <div className="px-6 py-4">
          <button
            onClick={logout}
            className="text-sm font-medium text-slate-500 hover:text-slate-800"
          >
            Log out
          </button>
        </div>
      </aside>
      <main className="flex-1 p-6 lg:p-10">{children}</main>
    </div>
  );
}
