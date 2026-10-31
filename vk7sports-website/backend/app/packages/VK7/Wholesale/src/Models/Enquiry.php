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
    ];
}
