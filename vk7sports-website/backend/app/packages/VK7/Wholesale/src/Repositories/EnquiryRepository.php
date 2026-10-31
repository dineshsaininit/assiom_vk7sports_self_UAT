<?php

namespace VK7\Wholesale\Repositories;

use VK7\Wholesale\Models\Enquiry;
use Webkul\Core\Eloquent\Repository;

class EnquiryRepository extends Repository
{
    /**
     * Specify model class name.
     */
    public function model(): string
    {
        return Enquiry::class;
    }
}
