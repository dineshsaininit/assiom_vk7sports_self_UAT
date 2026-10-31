<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Columns that must hold each document number once.
     */
    protected array $columns = [
        ['b2b_customer_quotes', 'quotation_number'],
        ['b2b_customer_quotes', 'po_number'],
        ['orders', 'increment_id'],
    ];

    /**
     * Run the migrations, stopping with the repeated numbers rather than deleting any record.
     */
    public function up(): void
    {
        foreach ($this->columns as [$table, $column]) {
            $duplicates = DB::table($table)
                ->select($column)
                ->whereNotNull($column)
                ->groupBy($column)
                ->havingRaw('COUNT(*) > 1')
                ->pluck($column);

            if ($duplicates->isNotEmpty()) {
                throw new RuntimeException("Resolve repeated {$table}.{$column} values first: ".$duplicates->implode(', '));
            }
        }

        foreach ($this->columns as [$table, $column]) {
            if (! Schema::hasIndex($table, [$column], 'unique')) {
                Schema::table($table, fn (Blueprint $blueprint) => $blueprint->unique($column, "vk7_{$table}_{$column}_unique"));
            }
        }

        DB::table('vk7_sequences')->insertOrIgnore([
            'name' => 'quote',
            'value' => (int) DB::table('b2b_customer_quotes')->max('id'),
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        foreach ($this->columns as [$table, $column]) {
            if (Schema::hasIndex($table, "vk7_{$table}_{$column}_unique")) {
                Schema::table($table, fn (Blueprint $blueprint) => $blueprint->dropUnique("vk7_{$table}_{$column}_unique"));
            }
        }

        DB::table('vk7_sequences')->where('name', 'quote')->delete();
    }
};
