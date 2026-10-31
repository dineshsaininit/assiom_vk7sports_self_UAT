<?php

namespace VK7\Wholesale;

use Webkul\Checkout\Cart as BaseCart;

class Cart extends BaseCart
{
    /**
     * Get cart errors, adding the quote lock and minimum order quantity checks after the core ones.
     */
    public function getErrors()
    {
        $errors = parent::getErrors();

        if ($errors) {
            return $errors;
        }

        if ($message = app(QuoteLock::class)->cartViolation($this->getCart())) {
            return [
                'error_code' => 'QUOTE_LOCKED',
                'message' => $message,
            ];
        }

        if ($message = app(Moq::class)->cartViolation($this->getCart())) {
            return [
                'error_code' => 'MOQ_NOT_MET',
                'message' => $message,
            ];
        }

        return $errors;
    }
}
