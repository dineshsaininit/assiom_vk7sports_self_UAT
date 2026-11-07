<?php

namespace VK7\Wholesale\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use MongoDB\BSON\UTCDateTime;
use Throwable;
use VK7\Wholesale\Services\AtlasMirror;

class AtlasCheck extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vk7:atlas-check {--report= : Also save the result as JSON under storage/app, e.g. atlas/check.json}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Prove the MongoDB Atlas connection: ping, write, read back and delete one check document';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $name = config('vk7.atlas.connection');

        $dsn = config("database.connections.{$name}.dsn");

        $result = [
            'checked_at' => now()->toIso8601String(),
            'app_env' => app()->environment(),
            'hosts' => AtlasMirror::hosts($dsn),
            'database' => config("database.connections.{$name}.database"),
            'ok' => false,
        ];

        if (blank($dsn)) {
            $this->components->error('MONGODB_URI is not set in .env, so there is nothing to check.');

            return self::FAILURE;
        }

        try {
            $result = array_merge($result, $this->roundTrip($name));
        } catch (Throwable $e) {
            $result['error'] = AtlasMirror::redact($e->getMessage());
        }

        $this->components->twoColumnDetail('Hosts', $result['hosts']);
        $this->components->twoColumnDetail('Database', $result['database']);

        foreach (['server_version', 'ping', 'insert', 'read_back', 'delete', 'round_trip_ms', 'mirrored_activity'] as $key) {
            $this->components->twoColumnDetail(Str::headline($key), $this->display($result[$key] ?? '-'));
        }

        if ($path = $this->option('report')) {
            Storage::disk('local')->put($path, json_encode($result, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

            $this->components->info('Report saved to storage/app/'.ltrim($path, '/'));
        }

        if (! $result['ok']) {
            $this->components->error('Atlas check failed: '.($result['error'] ?? 'unknown error'));

            return self::FAILURE;
        }

        $this->components->info('Atlas connection verified: write, read back and delete all succeeded.');

        return self::SUCCESS;
    }

    /**
     * Ping the server, then write, read back and delete one uniquely tagged document.
     */
    protected function roundTrip(string $name): array
    {
        $connection = DB::connection($name);

        $database = $connection->getDatabase();

        $started = microtime(true);

        $ping = (int) ($database->command(['ping' => 1])->toArray()[0]['ok'] ?? 0) === 1;

        $version = $database->command(['buildInfo' => 1])->toArray()[0]['version'] ?? '-';

        $token = (string) Str::uuid();

        $collection = $connection->table(config('vk7.atlas.check_collection'));

        $inserted = $collection->insert(['token' => $token, 'app_env' => app()->environment(), 'checked_at' => new UTCDateTime]);

        $found = $connection->table(config('vk7.atlas.check_collection'))->where('token', $token)->first();

        $deleted = $connection->table(config('vk7.atlas.check_collection'))->where('token', $token)->delete();

        return [
            'server_version' => $version,
            'ping' => $ping,
            'insert' => (bool) $inserted,
            'read_back' => $found !== null,
            'delete' => $deleted === 1,
            'round_trip_ms' => (int) round((microtime(true) - $started) * 1000),
            'mirrored_activity' => $connection->table(config('vk7.atlas.activity_collection'))->count(),
            'ok' => $ping
                && $inserted
                && $found !== null
                && $deleted === 1,
        ];
    }

    /**
     * Turn a check value into text for the console.
     */
    protected function display(mixed $value): string
    {
        return is_bool($value) ? ($value ? 'OK' : 'FAILED') : (string) $value;
    }
}
