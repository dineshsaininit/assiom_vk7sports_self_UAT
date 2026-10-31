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
        Schema::create('vk7_enquiries', function (Blueprint $table) {
            $table->id();
            $table->string('type')->default('general');
            $table->string('name');
            $table->string('business_name')->nullable();
            $table->string('email');
            $table->string('phone')->nullable();
            $table->string('city')->nullable();
            $table->unsignedInteger('quantity')->nullable();
            $table->unsignedInteger('product_id')->nullable();
            $table->text('message');
            $table->string('status')->default('new');
            $table->timestamps();

            $table->foreign('product_id')->references('id')->on('products')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('vk7_enquiries');
    }
};
