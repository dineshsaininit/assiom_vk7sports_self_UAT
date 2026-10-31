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
        'advance_percent' => 'float',
        'advance_due' => 'float',
        'total' => 'float',
        'hold_until' => 'datetime',
        'invoiced_at' => 'datetime',
    ];
}
