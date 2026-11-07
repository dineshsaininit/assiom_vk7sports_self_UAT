<?php

namespace VK7\Wholesale\Models;

use Illuminate\Database\Eloquent\Model;

class RetailerPolicy extends Model
{
    /**
     * The table the model maps to.
     *
     * @var string
     */
    protected $table = 'vk7_retailer_policies';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = ['customer_id', 'cod_override', 'note', 'updated_by'];
}
