<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Webkul\Sales\Models\OrderProxy;

class Payment extends Model
{
    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_payments';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'order_id',
        'kind',
        'amount',
        'method',
        'status',
        'gateway',
        'gateway_order_id',
        'gateway_payment_id',
        'reference',
        'reviewed_by',
        'reject_reason',
        'paid_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'amount' => 'float',
        'paid_at' => 'datetime',
    ];

    /**
     * The order this payment belongs to.
     */
    public function order(): BelongsTo
    {
        return $this->belongsTo(OrderProxy::modelClass(), 'order_id');
    }
}
