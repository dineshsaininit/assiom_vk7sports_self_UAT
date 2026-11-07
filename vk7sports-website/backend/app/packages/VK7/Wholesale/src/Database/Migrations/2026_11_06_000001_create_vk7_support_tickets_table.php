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
        Schema::create('vk7_support_tickets', function (Blueprint $table) {
            $table->id();
            $table->unsignedInteger('customer_id')->nullable();
            $table->string('name');
            $table->string('business_name')->nullable();
            $table->string('email')->nullable();
            $table->string('phone', 30)->nullable();
            $table->string('preferred_contact', 20)->default('phone');
            $table->string('category', 40);
            $table->string('order_number', 40)->nullable();
            $table->string('subject');
            $table->text('message');
            $table->string('priority', 20)->default('normal');
            $table->string('status', 20)->default('open');
            $table->string('assigned_to')->nullable();
            $table->text('reply')->nullable();
            $table->timestamp('replied_at')->nullable();
            $table->json('notes')->nullable();
            $table->timestamp('contact_by')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['status', 'created_at']);
            $table->index('email');
            $table->foreign('customer_id')->references('id')->on('customers')->nullOnDelete();
        });

        // Sales staff look after customer support.
        foreach (DB::table('roles')->where('name', 'Sales')->get() as $role) {
            $permissions = json_decode($role->permissions ?? '[]', true) ?: [];

            if (! in_array('vk7_desk.support', $permissions)) {
                $permissions[] = 'vk7_desk.support';

                DB::table('roles')->where('id', $role->id)->update(['permissions' => json_encode($permissions)]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vk7_support_tickets');
    }
};
