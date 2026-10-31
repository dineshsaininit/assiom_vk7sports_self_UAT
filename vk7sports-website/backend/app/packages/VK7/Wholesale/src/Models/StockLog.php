<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;

class StockLog extends Model
{
    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_stock_log';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'product_id',
        'product',
        'variant',
        'change',
        'on_hand',
        'reason',
        'note',
        'actor',
    ];
}
