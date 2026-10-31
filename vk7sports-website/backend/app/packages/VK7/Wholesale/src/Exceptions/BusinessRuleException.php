<?php

namespace VK7\Wholesale\Exceptions;

use RuntimeException;

class BusinessRuleException extends RuntimeException
{
    /**
     * Create the exception with a stable code the frontend can branch on.
     */
    public function __construct(string $message, public string $errorCode = 'NOT_ALLOWED', public int $status = 422)
    {
        parent::__construct($message);
    }
}
