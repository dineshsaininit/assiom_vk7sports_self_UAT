<?php

namespace VK7\Wholesale\Payments;

use Illuminate\Support\Facades\Http;
use VK7\Wholesale\Exceptions\BusinessRuleException;
use VK7\Wholesale\Models\Payment;

class RazorpayGateway implements PaymentGateway
{
    /**
     * Key prefix of accounts that move real money.
     */
    public const LIVE_KEY_PREFIX = 'rzp_live_';

    /**
     * The code stored against payments made through this gateway.
     */
    public function code(): string
    {
        return 'razorpay';
    }

    /**
     * Create a Razorpay order for the amount the server calculated.
     */
    public function createOrder(Payment $payment, string $receipt): string
    {
        $response = Http::withBasicAuth($this->keyId(), $this->keySecret())
            ->acceptJson()
            ->timeout(20)
            ->post(config('vk7.payments.razorpay.api_url').'/orders', [
                'amount' => self::paise($payment->amount),
                'currency' => 'INR',
                'receipt' => $receipt,
            ]);

        if (
            ! $response->successful()
            || ! $response->json('id')
        ) {
            throw new BusinessRuleException(trans('The payment service is not available. Please try again.'), 'GATEWAY_ERROR', 502);
        }

        return $response->json('id');
    }

    /**
     * Return the public values Razorpay Checkout needs; the secret never leaves the server.
     */
    public function clientOptions(Payment $payment, array $context): array
    {
        return [
            'key' => $this->keyId(),
            'amount' => self::paise($payment->amount),
            'currency' => 'INR',
            'order_id' => $payment->gateway_order_id,
            'name' => 'VK7SPORTS',
            'description' => $context['description'] ?? '',
            'prefill' => $context['prefill'] ?? [],
        ];
    }

    /**
     * Check Razorpay's signature over this payment's order id and return the payment id.
     */
    public function verify(Payment $payment, array $result): string
    {
        $paymentId = (string) ($result['razorpay_payment_id'] ?? '');

        $expected = hash_hmac('sha256', $payment->gateway_order_id.'|'.$paymentId, $this->keySecret());

        if (
            $paymentId === ''
            || ($result['razorpay_order_id'] ?? null) !== $payment->gateway_order_id
            || ! hash_equals($expected, (string) ($result['razorpay_signature'] ?? ''))
        ) {
            throw new BusinessRuleException(trans('We could not verify this payment.'), 'PAYMENT_NOT_VERIFIED');
        }

        return $paymentId;
    }

    /**
     * Read a signed notification, ignoring anything that is not a captured payment.
     */
    public function parseWebhook(string $body, ?string $signature): ?array
    {
        $secret = (string) config('vk7.payments.razorpay.webhook_secret');

        if (
            $secret === ''
            || ! $signature
            || ! hash_equals(hash_hmac('sha256', $body, $secret), $signature)
        ) {
            throw new BusinessRuleException(trans('Invalid signature.'), 'INVALID_SIGNATURE', 400);
        }

        $payload = json_decode($body, true);

        $entity = $payload['payload']['payment']['entity'] ?? null;

        if (
            ($payload['event'] ?? null) !== 'payment.captured'
            || ! $entity
        ) {
            return null;
        }

        return [
            'order_id' => $entity['order_id'] ?? null,
            'payment_id' => $entity['id'] ?? null,
            'paise' => (int) ($entity['amount'] ?? 0),
        ];
    }

    /**
     * Convert rupees to the whole paise Razorpay works in.
     */
    public static function paise(float $amount): int
    {
        return (int) round($amount * 100);
    }

    /**
     * The key id, refusing a live key unless real payments have been authorised.
     */
    protected function keyId(): string
    {
        $key = (string) config('vk7.payments.razorpay.key_id');

        if ($key === '') {
            throw new BusinessRuleException(trans('Online payment is not set up yet.'), 'GATEWAY_UNAVAILABLE');
        }

        if (
            str_starts_with($key, self::LIVE_KEY_PREFIX)
            && ! config('vk7.payments.allow_live')
        ) {
            throw new BusinessRuleException(trans('Live payments are not authorised.'), 'GATEWAY_UNAVAILABLE');
        }

        return $key;
    }

    /**
     * The key secret.
     */
    protected function keySecret(): string
    {
        return (string) config('vk7.payments.razorpay.key_secret');
    }
}
