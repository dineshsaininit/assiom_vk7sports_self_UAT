<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('vk7_sequences', function (Blueprint $table) {
            $table->string('name')->primary();
            $table->unsignedBigInteger('value');
        });

        DB::table('vk7_sequences')->insert([
            'name' => 'order',
            'value' => (int) DB::table('orders')->max('id'),
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vk7_sequences');
    }
};
