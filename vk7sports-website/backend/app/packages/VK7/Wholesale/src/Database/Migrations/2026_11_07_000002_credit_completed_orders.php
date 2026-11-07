<?php

use Illuminate\Database\Migrations\Migration;
use VK7\Wholesale\Models\OrderTerm;
use VK7\Wholesale\Services\RetailerStanding;
use Webkul\Sales\Models\OrderProxy;

return new class extends Migration
{
    /**
     * Give retailers credit for orders they paid in full before the score existed. Safe to run again.
     */
    public function up(): void
    {
        $standing = app(RetailerStanding::class);

        OrderTerm::where('stage', 'Paid in full')->orderBy('id')->each(function ($term) use ($standing) {
            $order = OrderProxy::query()->find($term->order_id);

            if (
                $order
                && $order->customer_id
            ) {
                $standing->recordForOrder($order, 'order_completed', 'System', 'Paid in full before scoring started');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};
