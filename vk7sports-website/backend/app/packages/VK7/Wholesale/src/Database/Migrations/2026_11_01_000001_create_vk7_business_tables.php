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
        Schema::create('vk7_order_terms', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('order_id')->unique();
            $table->string('stage')->default('Awaiting advance');
            $table->string('previous_stage')->nullable();
            $table->decimal('advance_percent', 5, 2);
            $table->decimal('advance_due', 12, 2);
            $table->decimal('total', 12, 2);
            $table->timestamp('hold_until')->nullable();
            $table->timestamps();

            $table->foreign('order_id')->references('id')->on('orders')->cascadeOnDelete();
            $table->index('stage');
        });

        Schema::create('vk7_payments', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('order_id');
            $table->string('kind');
            $table->decimal('amount', 12, 2);
            $table->string('method');
            $table->string('status')->default('created');
            $table->string('gateway')->nullable();
            $table->string('gateway_order_id')->nullable();
            $table->string('gateway_payment_id')->nullable();
            $table->string('reference')->nullable();
            $table->string('reviewed_by')->nullable();
            $table->string('reject_reason')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            $table->foreign('order_id')->references('id')->on('orders')->cascadeOnDelete();
            $table->unique(['gateway', 'gateway_payment_id']);
            $table->index(['status', 'order_id']);
            $table->index('gateway_order_id');
        });

        Schema::create('vk7_shipments', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('order_id');
            $table->string('provider');
            $table->string('courier');
            $table->string('waybill')->unique();
            $table->string('status');
            $table->string('tracking_url')->nullable();
            $table->date('expected_on')->nullable();
            $table->json('route')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamps();

            $table->foreign('order_id')->references('id')->on('orders')->cascadeOnDelete();
        });

        Schema::create('vk7_shipment_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shipment_id')->constrained('vk7_shipments')->cascadeOnDelete();
            $table->string('status');
            $table->string('location')->nullable();
            $table->decimal('lat', 9, 6)->nullable();
            $table->decimal('lng', 9, 6)->nullable();
            $table->string('description')->nullable();
            $table->timestamp('occurred_at');
            $table->timestamps();

            $table->unique(['shipment_id', 'status', 'location']);
        });

        Schema::create('vk7_activity_log', function (Blueprint $table) {
            $table->id();
            $table->string('actor');
            $table->string('action');
            $table->string('target');
            $table->string('detail')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vk7_activity_log');
        Schema::dropIfExists('vk7_shipment_events');
        Schema::dropIfExists('vk7_shipments');
        Schema::dropIfExists('vk7_payments');
        Schema::dropIfExists('vk7_order_terms');
    }
};
