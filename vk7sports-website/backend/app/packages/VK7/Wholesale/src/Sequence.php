<?php

namespace VK7\Wholesale;

use Illuminate\Support\Facades\DB;

class Sequence
{
    /**
     * Claim the next number of a named counter, never below the highest id of the table it numbers.
     * One locked row serialises numbering for that counter, which suits wholesale volume.
     */
    public function next(string $name, ?string $table = null): int
    {
        return DB::transaction(function () use ($name, $table) {
            $last = (int) DB::table('vk7_sequences')->where('name', $name)->lockForUpdate()->value('value');

            $next = max($last, $table ? (int) DB::table($table)->max('id') : 0) + 1;

            DB::table('vk7_sequences')->updateOrInsert(['name' => $name], ['value' => $next]);

            return $next;
        });
    }
}
