/** Shared TypeScript types for the TrendLens admin backend API. */

export interface AdminStats {
  templates: number;
  uploads: number;
  /** Total upload storage in bytes. */
  storageBytes: number;
  /** Number of AI (Pollinations) cache entries. */
  aiCacheEntries: number;
  /** AI cache size in bytes. */
  aiCacheBytes: number;
}

export interface TrendTemplate {
  id: string;
  title: string;
  category: string;
  usesCount: number;
  isNewDrop: boolean;
  effectType: string;
  aiPrompt: string;
  thumbnailUrl?: string;
  previewUrl?: string;
  createdAt?: string;
  updatedAt?: string;
}

export interface AdminUser {
  id: string;
  isPremium: boolean;
  /** Storage quota in megabytes. */
  quotaMB: number;
  /** Storage used in bytes, when the backend provides it. */
  storageUsedBytes?: number;
}
