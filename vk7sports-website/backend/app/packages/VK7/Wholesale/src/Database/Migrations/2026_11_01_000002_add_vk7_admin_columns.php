<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('vk7_order_terms', function (Blueprint $table) {
            $table->string('invoice_number')->nullable()->unique();
            $table->timestamp('invoiced_at')->nullable();
        });

        Schema::table('vk7_enquiries', function (Blueprint $table) {
            $table->json('notes')->nullable();
            $table->date('follow_up_on')->nullable();
        });

        Schema::create('vk7_stock_log', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('product_id');
            $table->string('product');
            $table->string('variant');
            $table->integer('change');
            $table->integer('on_hand');
            $table->string('reason');
            $table->string('note')->nullable();
            $table->string('actor');
            $table->timestamps();

            $table->foreign('product_id')->references('id')->on('products')->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vk7_stock_log');

        Schema::table('vk7_enquiries', function (Blueprint $table) {
            $table->dropColumn(['notes', 'follow_up_on']);
        });

        Schema::table('vk7_order_terms', function (Blueprint $table) {
            $table->dropUnique(['invoice_number']);
            $table->dropColumn(['invoice_number', 'invoiced_at']);
        });
    }
};
