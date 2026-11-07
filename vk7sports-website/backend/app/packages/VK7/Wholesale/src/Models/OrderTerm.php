<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;

class OrderTerm extends Model
{
    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_order_terms';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'order_id',
        'stage',
        'payment_mode',
        'first_order',
        'risk_note',
        'cancelled_by',
        'cancel_deduction',
        'refund_due',
        'refund_status',
        'refund_reference',
        'previous_stage',
        'advance_percent',
        'advance_due',
        'total',
        'hold_until',
        'invoice_number',
        'invoiced_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'first_order' => 'boolean',
        'cancel_deduction' => 'float',
        'refund_due' => 'float',
        'advance_percent' => 'float',
        'advance_due' => 'float',
        'total' => 'float',
        'hold_until' => 'datetime',
        'invoiced_at' => 'datetime',
    ];
}
