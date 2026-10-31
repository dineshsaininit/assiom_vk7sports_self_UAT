<?php

namespace VK7\Wholesale\Services;

use VK7\Wholesale\Models\ActivityLog;

class ActivityRecorder
{
    /**
     * Record who changed what.
     */
    public function record(string $actor, string $action, string $target, ?string $detail = null): void
    {
        ActivityLog::create(['actor' => $actor, 'action' => $action, 'target' => $target, 'detail' => $detail]);
    }

    /**
     * The most recent entries.
     */
    public function latest(int $limit = 200)
    {
        return ActivityLog::query()->latest('id')->limit($limit)->get();
    }
}
