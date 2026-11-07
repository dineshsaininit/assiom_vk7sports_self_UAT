<?php

namespace VK7\Wholesale\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class StoreSettings
{
    /**
     * Settings staff can change, as a form key and the stored code with its channel.
     */
    public const BUSINESS = [
        'moqEnabled' => ['vk7.moq.settings.enabled', 'default'],
        'moq' => ['vk7.moq.settings.min_qty', 'default'],
        'moqMode' => ['vk7.moq.settings.mode', 'default'],
        'advancePct' => ['vk7.payments.terms.advance_percent', null],
        'holdHours' => ['vk7.payments.terms.hold_hours', null],
        'quoteValidityDays' => ['b2b.quotes.settings.default_expiration_period', 'default'],
        'lowStock' => ['vk7.inventory.low_stock', null],
        'taxInvoiceApproved' => ['vk7.invoice.tax_approved', null],
        'codMinScore' => ['vk7.risk.cod_min_score', null],
        'codMinOrders' => ['vk7.risk.cod_min_orders', null],
        'codMaxOrder' => ['vk7.risk.cod_max_order', null],
        'newMidValue' => ['vk7.risk.new_mid_value', null],
        'newMidPct' => ['vk7.risk.new_mid_percent', null],
        'newPrepaidAbove' => ['vk7.risk.new_prepaid_above', null],
        'cancelConfirmedPct' => ['vk7.risk.cancel_confirmed_percent', null],
        'cancelPackingPct' => ['vk7.risk.cancel_packing_percent', null],
        'lateDays' => ['vk7.risk.late_days', null],
    ];

    /**
     * Company details shown on the website and on invoices.
     */
    public const COMPANY = ['legalName', 'address', 'gstin', 'phone', 'whatsapp', 'email', 'hours'];

    /**
     * Payment details shown to signed-in retailers.
     */
    public const BANK = ['upiId', 'bankName', 'accountName', 'accountNumber', 'ifsc'];

    /**
     * Return the settings form values.
     */
    public function all(): array
    {
        $values = [];

        foreach (self::BUSINESS as $key => [$code]) {
            $values[$key] = $this->read($code);
        }

        foreach (RetailerStanding::SETTINGS as $key => [, $default]) {
            $values[$key] ??= (string) $default;
        }

        return array_merge($values, $this->company(), $this->bank());
    }

    /**
     * Return the company details.
     */
    public function company(): array
    {
        return $this->group('company', self::COMPANY);
    }

    /**
     * Return the payment details.
     */
    public function bank(): array
    {
        return $this->group('bank', self::BANK);
    }

    /**
     * The stock level at or below which a size counts as low.
     */
    public function lowStock(): int
    {
        return (int) ($this->read('vk7.inventory.low_stock') ?? 20);
    }

    /**
     * Whether the chartered accountant has approved the invoice format.
     */
    public function taxInvoiceApproved(): bool
    {
        return (bool) $this->read('vk7.invoice.tax_approved');
    }

    /**
     * Save submitted settings and clear the cached copies.
     */
    public function save(array $values): void
    {
        foreach (self::BUSINESS as $key => [$code, $channel]) {
            if (array_key_exists($key, $values)) {
                $this->write($code, $channel, $values[$key]);
            }
        }

        foreach (['company' => self::COMPANY, 'bank' => self::BANK] as $prefix => $keys) {
            foreach ($keys as $key) {
                if (array_key_exists($key, $values)) {
                    $this->write('vk7.'.$prefix.'.'.$key, null, $values[$key]);
                }
            }
        }

        Cache::flush();
    }

    /**
     * Read a group of stored details.
     */
    protected function group(string $prefix, array $keys): array
    {
        $values = [];

        foreach ($keys as $key) {
            $values[$key] = $this->read('vk7.'.$prefix.'.'.$key);
        }

        return $values;
    }

    /**
     * Read one stored value.
     */
    protected function read(string $code): ?string
    {
        return DB::table('core_config')->where('code', $code)->value('value');
    }

    /**
     * Replace one stored value.
     */
    protected function write(string $code, ?string $channel, mixed $value): void
    {
        DB::table('core_config')->where('code', $code)->delete();

        DB::table('core_config')->insert([
            'code' => $code,
            'value' => is_bool($value) ? (string) (int) $value : (string) ($value ?? ''),
            'channel_code' => $channel,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
