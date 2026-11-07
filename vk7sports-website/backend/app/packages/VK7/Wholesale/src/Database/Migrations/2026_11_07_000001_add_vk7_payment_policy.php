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
        Schema::table('vk7_order_terms', function (Blueprint $table) {
            $table->string('payment_mode', 20)->default('prepaid')->after('stage');
            $table->boolean('first_order')->default(false)->after('payment_mode');
            $table->string('risk_note')->nullable()->after('first_order');
            $table->string('cancelled_by', 20)->nullable();
            $table->decimal('cancel_deduction', 12, 2)->nullable();
            $table->decimal('refund_due', 12, 2)->nullable();
            $table->string('refund_status', 20)->nullable();
            $table->string('refund_reference')->nullable();
        });

        // Orders placed before this policy were collected after delivery, which is cash on delivery.
        DB::table('vk7_order_terms')->update(['payment_mode' => 'cod']);

        Schema::create('vk7_retailer_score_events', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('customer_id');
            $table->string('type', 40);
            $table->integer('points');
            $table->unsignedInteger('order_id')->nullable();
            $table->string('note')->nullable();
            $table->string('actor');
            $table->timestamps();

            $table->foreign('customer_id')->references('id')->on('customers')->cascadeOnDelete();
            $table->foreign('order_id')->references('id')->on('orders')->nullOnDelete();
            $table->unique(['customer_id', 'type', 'order_id']);
            $table->index(['customer_id', 'created_at']);
        });

        Schema::create('vk7_retailer_policies', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('customer_id')->unique();
            $table->string('cod_override', 10)->default('auto');
            $table->string('note')->nullable();
            $table->string('updated_by')->nullable();
            $table->timestamps();

            $table->foreign('customer_id')->references('id')->on('customers')->cascadeOnDelete();
        });

        // The chartered accountant's rule: never less than a 20 percent advance.
        DB::table('core_config')
            ->where('code', 'vk7.payments.terms.advance_percent')
            ->get()
            ->each(function ($row) {
                if ((float) $row->value < 20) {
                    DB::table('core_config')->where('id', $row->id)->update(['value' => '20', 'updated_at' => now()]);
                }
            });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vk7_retailer_policies');
        Schema::dropIfExists('vk7_retailer_score_events');

        Schema::table('vk7_order_terms', function (Blueprint $table) {
            $table->dropColumn(['payment_mode', 'first_order', 'risk_note', 'cancelled_by', 'cancel_deduction', 'refund_due', 'refund_status', 'refund_reference']);
        });
    }
};
