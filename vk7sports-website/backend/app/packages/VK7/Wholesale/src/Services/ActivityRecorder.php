<?php

namespace VK7\Wholesale\Services;

use Illuminate\Database\Eloquent\Collection;
use VK7\Wholesale\Models\ActivityLog;

class ActivityRecorder
{
    /**
     * Create a new recorder.
     */
    public function __construct(protected AtlasMirror $mirror) {}

    /**
     * Record who changed what, then mirror the entry to MongoDB Atlas when it is configured.
     */
    public function record(string $actor, string $action, string $target, ?string $detail = null): void
    {
        $entry = ActivityLog::create(['actor' => $actor, 'action' => $action, 'target' => $target, 'detail' => $detail]);

        $this->mirror->activity($entry);
    }

    /**
     * The most recent entries.
     */
    public function latest(int $limit = 200): Collection
    {
        return ActivityLog::query()->latest('id')->limit($limit)->get();
    }
}
