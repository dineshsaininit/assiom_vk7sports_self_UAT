<?php

namespace VK7\Wholesale\Payments;

use VK7\Wholesale\Models\Payment;

interface PaymentGateway
{
    /**
     * The code stored against payments made through this gateway.
     */
    public function code(): string;

    /**
     * Open a payment at the gateway and return its order id.
     */
    public function createOrder(Payment $payment, string $receipt): string;

    /**
     * Return the public values the browser needs to open the gateway's payment screen.
     */
    public function clientOptions(Payment $payment, array $context): array;

    /**
     * Prove the browser's result is genuine and return the gateway's payment id.
     */
    public function verify(Payment $payment, array $result): string;

    /**
     * Read a signed gateway notification, returning its order id, payment id and paise.
     */
    public function parseWebhook(string $body, ?string $signature): ?array;
}
