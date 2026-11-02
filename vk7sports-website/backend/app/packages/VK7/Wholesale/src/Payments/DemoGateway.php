<?php

namespace VK7\Wholesale\Payments;

use Illuminate\Support\Str;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Models\Payment;

class DemoGateway implements PaymentGateway
{
    /**
     * The code stored against payments made through this gateway.
     */
    public function code(): string
    {
        return 'demo';
    }

    /**
     * Open a simulated payment.
     */
    public function createOrder(Payment $payment, string $receipt): string
    {
        $this->assertNotProduction();

        return 'demo_order_'.Str::random(14);
    }

    /**
     * Return the values the simulated payment screen shows.
     */
    public function clientOptions(Payment $payment, array $context): array
    {
        return ['simulated' => true];
    }

    /**
     * Accept the simulated result; no money moves, so this never runs in production.
     */
    public function verify(Payment $payment, array $result): string
    {
        $this->assertNotProduction();

        if (($result['simulated_result'] ?? null) !== 'success') {
            throw new BusinessRuleException(trans('The test payment did not go through.'), 'PAYMENT_FAILED');
        }

        return 'demo_pay_'.Str::random(14);
    }

    /**
     * The simulated gateway sends no notifications.
     */
    public function parseWebhook(string $body, ?string $signature): ?array
    {
        return null;
    }

    /**
     * Allow simulated payments only on a developer's computer or an explicitly marked demo server.
     */
    protected function assertNotProduction(): void
    {
        if (
            ! app()->environment(['local', 'testing'])
            && ! config('vk7.payments.allow_demo')
        ) {
            throw new BusinessRuleException(trans('Test payments are not available.'), 'GATEWAY_UNAVAILABLE');
        }
    }
}
