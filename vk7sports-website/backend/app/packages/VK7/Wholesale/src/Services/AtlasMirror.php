<?php

namespace VK7\Wholesale\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use MongoDB\BSON\UTCDateTime;
use Throwable;
use VK7\Wholesale\Models\ActivityLog;

class AtlasMirror
{
    /**
     * Cache key that pauses mirroring for a short while after a failed write.
     */
    public const COOLDOWN_KEY = 'vk7.atlas.cooldown';

    /**
     * Whether a MongoDB connection string is configured and mirroring is switched on.
     */
    public function enabled(): bool
    {
        return config('vk7.atlas.mirror_activity')
            && filled(config('database.connections.'.config('vk7.atlas.connection').'.dsn'));
    }

    /**
     * Copy an activity entry to MongoDB once the SQL write has committed.
     */
    public function activity(ActivityLog $entry): void
    {
        if (! $this->enabled()) {
            return;
        }

        DB::afterCommit(fn () => $this->write($entry));
    }

    /**
     * Write one activity entry, never letting a MongoDB failure reach the caller.
     */
    public function write(ActivityLog $entry): bool
    {
        if (Cache::has(self::COOLDOWN_KEY)) {
            return false;
        }

        try {
            DB::connection(config('vk7.atlas.connection'))
                ->table(config('vk7.atlas.activity_collection'))
                ->insert([
                    'sql_id' => $entry->id,
                    'actor' => $entry->actor,
                    'action' => $entry->action,
                    'target' => $entry->target,
                    'detail' => $entry->detail,
                    'app_env' => app()->environment(),
                    'created_at' => new UTCDateTime($entry->created_at ?? now()),
                ]);

            return true;
        } catch (Throwable $e) {
            Cache::put(self::COOLDOWN_KEY, true, (int) config('vk7.atlas.cooldown_seconds'));

            Log::warning('VK7 Atlas activity mirror failed; the SQL entry is kept.', [
                'sql_id' => $entry->id,
                'error' => self::redact($e->getMessage()),
            ]);

            return false;
        }
    }

    /**
     * Remove any user name and password from a MongoDB connection string inside a message.
     */
    public static function redact(string $text): string
    {
        return preg_replace('#(mongodb(?:\+srv)?://)[^@/\s]+@#i', '$1***@', $text);
    }

    /**
     * The host part of a MongoDB connection string, without credentials, path or options.
     */
    public static function hosts(?string $dsn): string
    {
        if (blank($dsn)) {
            return '-';
        }

        $hosts = preg_replace('#^mongodb(?:\+srv)?://#i', '', $dsn);

        $hosts = str_contains($hosts, '@') ? substr($hosts, strrpos($hosts, '@') + 1) : $hosts;

        return strtok($hosts, '/?') ?: '-';
    }
}
