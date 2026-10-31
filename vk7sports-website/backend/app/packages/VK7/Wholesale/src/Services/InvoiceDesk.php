<?php

namespace VK7\Wholesale\Services;

use VK7\Wholesale\Sequence;
use Webkul\Customer\Models\CustomerProxy;

class InvoiceDesk
{
    /**
     * Stages before payment, shown as a proforma.
     */
    public const PROFORMA_STAGES = ['Awaiting advance', 'Cancelled', 'Expired'];

    /**
     * Create a new service instance.
     */
    public function __construct(
        protected OrderFinance $finance,
        protected StoreSettings $settings,
        protected Sequence $sequence,
    ) {}

    /**
     * Build an order's invoice, numbering it once the order is confirmed.
     */
    public function build($order): array
    {
        $term = $this->finance->terms($order);

        $proforma = in_array($term->stage, self::PROFORMA_STAGES);

        if (
            ! $proforma
            && ! $term->invoice_number
        ) {
            $term->update([
                'invoice_number' => 'INV-'.str_pad((string) $this->sequence->next('invoice'), 6, '0', STR_PAD_LEFT),
                'invoiced_at' => now(),
            ]);
        }

        $billing = $order->billing_address ?? $order->shipping_address;

        $client = CustomerProxy::query()->find($order->customer_id);

        $money = $this->finance->summary($order);

        return [
            'proforma' => $proforma,
            'tax_invoice' => $this->settings->taxInvoiceApproved(),
            'number' => $proforma ? $order->increment_id : $term->invoice_number,
            'issued_at' => $term->invoiced_at ?? $order->created_at,
            'order_number' => $order->increment_id,
            'order_date' => $order->created_at,
            'company' => $this->settings->company(),
            'bill_to' => [
                'name' => $client?->businessName() ?: $order->customer_full_name,
                'contact' => $order->customer_full_name,
                'address' => $billing?->address,
                'city' => $billing?->city,
                'state' => $billing?->state,
                'pin' => $billing?->postcode,
                'phone' => $billing?->phone,
                'gstin' => $billing?->vat_id ?: $client?->addresses->pluck('vat_id')->filter()->first(),
            ],
            'lines' => $order->items->whereNull('parent_id')->map(fn ($item) => [
                'name' => $item->name,
                'sku' => $item->sku,
                'options' => $item->additional['attributes'] ?? [],
                'qty' => (int) $item->qty_ordered,
                'price' => (float) $item->base_price,
                'total' => (float) $item->base_total,
            ])->values(),
            'sub_total' => (float) $order->base_sub_total,
            'shipping' => (float) $order->base_shipping_amount,
            'tax' => (float) $order->base_tax_amount,
            'total' => $money['total'],
            'paid' => $money['paid'],
            'outstanding' => $money['outstanding'],
            'status' => $money['stage'],
        ];
    }
}
