<?php

namespace VK7\Wholesale;

use Webkul\Checkout\Cart as BaseCart;

class Cart extends BaseCart
{
    /**
     * Get cart errors, adding the minimum order quantity check after the core ones.
     */
    public function getErrors()
    {
        $errors = parent::getErrors();

        if (
            $errors
            || ! ($message = app(Moq::class)->cartViolation($this->getCart()))
        ) {
            return $errors;
        }

        return [
            'error_code' => 'MOQ_NOT_MET',
            'message' => $message,
        ];
    }
}
