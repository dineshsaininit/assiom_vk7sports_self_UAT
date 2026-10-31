<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;

class ShipmentEvent extends Model
{
    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_shipment_events';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'shipment_id',
        'status',
        'location',
        'lat',
        'lng',
        'description',
        'occurred_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'lat' => 'float',
        'lng' => 'float',
        'occurred_at' => 'datetime',
    ];
}
