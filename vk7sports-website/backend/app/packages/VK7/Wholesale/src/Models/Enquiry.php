<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;

class Enquiry extends Model
{
    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_enquiries';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'type',
        'name',
        'business_name',
        'email',
        'phone',
        'city',
        'quantity',
        'product_id',
        'message',
        'status',
        'notes',
        'follow_up_on',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'notes' => 'array',
        'follow_up_on' => 'date',
    ];
}
