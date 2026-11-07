<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;

class ScoreEvent extends Model
{
    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_retailer_score_events';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = ['customer_id', 'type', 'points', 'order_id', 'note', 'actor'];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = ['points' => 'integer'];
}
