<?php

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use VK7\Wholesale\Models\ActivityLog;
use VK7\Wholesale\Services\ActivityRecorder;
use VK7\Wholesale\Services\AtlasMirror;

/**
 * Point the mongodb connection at the given server and a throwaway database.
 */
function useMongo(?string $dsn, int $timeout = 2000): string
{
    $database = 'vk7_test_'.Str::lower(Str::random(8));

    config([
        'database.connections.mongodb.dsn' => $dsn,
        'database.connections.mongodb.database' => $database,
        'database.connections.mongodb.options.serverSelectionTimeoutMS' => $timeout,
        'database.connections.mongodb.options.connectTimeoutMS' => $timeout,
    ]);

    DB::purge('mongodb');

    Cache::forget(AtlasMirror::COOLDOWN_KEY);

    return $database;
}

/**
 * The live MongoDB server for round-trip tests, if one was provided.
 */
function liveMongo(): ?string
{
    return getenv('VK7_TEST_MONGODB_URI') ?: null;
}

// ============================================================================
// SQL Stays The Source Of Truth
// ============================================================================

it('keeps activity in SQL only when no MongoDB connection string is set', function () {
    useMongo(null);

    app(ActivityRecorder::class)->record('qa', 'atlas.off', 'target-off');

    expect(app(AtlasMirror::class)->enabled())->toBeFalse();

    $this->assertDatabaseHas('vk7_activity_log', ['action' => 'atlas.off', 'target' => 'target-off']);
});

it('never lets an unreachable MongoDB server break activity logging', function () {
    useMongo('mongodb://vk7-user:not-a-real-secret@127.0.0.1:1/?directConnection=true', 300);

    Log::spy();

    app(ActivityRecorder::class)->record('qa', 'atlas.down', 'target-down');

    $this->assertDatabaseHas('vk7_activity_log', ['action' => 'atlas.down']);

    expect(Cache::has(AtlasMirror::COOLDOWN_KEY))->toBeTrue();

    Log::shouldHaveReceived('warning')->once()->withArgs(
        fn ($message, $context) => str_contains($message, 'Atlas')
            && ! str_contains(json_encode($context), 'not-a-real-secret')
    );
});

it('skips MongoDB during the cooldown after a failure', function () {
    useMongo('mongodb://127.0.0.1:1/?directConnection=true', 300);

    Cache::put(AtlasMirror::COOLDOWN_KEY, true, 60);

    $entry = ActivityLog::create(['actor' => 'qa', 'action' => 'atlas.cooldown', 'target' => 't']);

    expect(app(AtlasMirror::class)->write($entry))->toBeFalse();
});

it('hides credentials when describing a connection string', function () {
    expect(AtlasMirror::hosts('mongodb+srv://user:p%40ss@cluster0.ab12c.mongodb.net/?retryWrites=true'))
        ->toBe('cluster0.ab12c.mongodb.net')
        ->and(AtlasMirror::redact('failed for mongodb+srv://user:secret@cluster0.ab12c.mongodb.net/db'))
        ->toBe('failed for mongodb+srv://***@cluster0.ab12c.mongodb.net/db');
});

// ============================================================================
// Atlas Check Command
// ============================================================================

it('fails the atlas check clearly when no connection string is set', function () {
    useMongo(null);

    $this->artisan('vk7:atlas-check')
        ->expectsOutputToContain('MONGODB_URI is not set')
        ->assertFailed();
});

it('fails the atlas check when the server cannot be reached', function () {
    useMongo('mongodb://127.0.0.1:1/?directConnection=true', 300);

    $this->artisan('vk7:atlas-check')->assertFailed();
});

// ============================================================================
// Live MongoDB Round Trip
// ============================================================================

it('mirrors a committed activity entry to MongoDB', function () {
    useMongo(liveMongo());

    app(ActivityRecorder::class)->record('qa', 'atlas.live', 'target-live', 'mirror test');

    $entry = ActivityLog::query()->where('action', 'atlas.live')->latest('id')->firstOrFail();

    $document = DB::connection('mongodb')->table('activity_log')->where('sql_id', $entry->id)->first();

    expect($document)->not->toBeNull()
        ->and($document->action)->toBe('atlas.live')
        ->and($document->detail)->toBe('mirror test');

    DB::connection('mongodb')->getDatabase()->drop();
})->skip(! liveMongo(), 'Set VK7_TEST_MONGODB_URI to run against a real MongoDB server.');

it('passes the atlas check against a live MongoDB server and leaves no check document', function () {
    useMongo(liveMongo());

    $this->artisan('vk7:atlas-check')
        ->expectsOutputToContain('Atlas connection verified')
        ->assertSuccessful();

    expect(DB::connection('mongodb')->table('connection_checks')->count())->toBe(0);

    DB::connection('mongodb')->getDatabase()->drop();
})->skip(! liveMongo(), 'Set VK7_TEST_MONGODB_URI to run against a real MongoDB server.');
