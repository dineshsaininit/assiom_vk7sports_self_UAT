<?php

namespace VK7\Wholesale;

use Illuminate\Support\Collection;
use VK7\Wholesale\Exceptions\MoqNotMetException;

class Moq
{
    /**
     * Grouping modes the minimum order quantity can be counted by.
     */
    public const MODES = ['per_style', 'per_variant', 'per_order'];

    /**
     * Return the violation message for a cart, or null when the cart meets the minimum.
     */
    public function cartViolation($cart): ?string
    {
        $lines = $cart->items->map(fn ($item) => [
            'style' => $item->product_id,
            'variant' => $item->child?->sku ?? $item->sku,
            'name' => $item->name,
            'qty' => (int) $item->quantity,
        ]);

        return $this->violation($lines);
    }

    /**
     * Reject an order payload that does not meet the minimum, as the last line of defence.
     *
     * @throws MoqNotMetException
     */
    public function assertOrder(array $data): void
    {
        $lines = collect($data['items'] ?? [])->map(fn ($item) => [
            'style' => $item['product_id'],
            'variant' => $item['children'][0]['sku'] ?? $item['sku'],
            'name' => $item['name'],
            'qty' => (int) $item['qty_ordered'],
        ]);

        if ($message = $this->violation($lines)) {
            throw new MoqNotMetException($message);
        }
    }

    /**
     * Group the lines by the configured mode and describe every group below the minimum.
     */
    protected function violation(Collection $lines): ?string
    {
        if (! $this->applies()) {
            return null;
        }

        $min = (int) core()->getConfigData('vk7.moq.settings.min_qty');

        $mode = core()->getConfigData('vk7.moq.settings.mode');

        $groups = match ($mode) {
            'per_variant' => $lines->groupBy('variant'),
            'per_order' => collect(['order' => $lines]),
            default => $lines->groupBy('style'),
        };

        $short = $groups
            ->map(fn ($group, $key) => [
                'label' => $mode === 'per_order' ? 'whole order' : ($mode === 'per_variant' ? $key : $group->first()['name']),
                'qty' => $group->sum('qty'),
            ])
            ->filter(fn ($group) => $group['qty'] < $min);

        if ($short->isEmpty()) {
            return null;
        }

        return trans('Minimum order is :min pieces :unit. Below minimum: :items.', [
            'min' => $min,
            'unit' => str_replace('_', ' ', $mode ?: 'per_style'),
            'items' => $short->map(fn ($group) => $group['label'].' ('.$group['qty'].')')->implode(', '),
        ]);
    }

    /**
     * Whether the minimum applies to the current request.
     */
    protected function applies(): bool
    {
        if (
            ! core()->getConfigData('vk7.moq.settings.enabled')
            || (int) core()->getConfigData('vk7.moq.settings.min_qty') < 1
        ) {
            return false;
        }

        return ! request()->routeIs('admin.*')
            || (bool) core()->getConfigData('vk7.moq.settings.apply_to_admin_orders');
    }
}
