<?php

namespace VK7\Wholesale\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class ApplyPolicy extends Command
{
    /**
     * Planning-default settings; owner confirmation is still pending for each of them.
     */
    public const SETTINGS = [
        'vk7.moq.settings.enabled' => ['1', 'default'],
        'vk7.moq.settings.min_qty' => ['24', 'default'],
        'vk7.moq.settings.mode' => ['per_style', 'default'],
        'vk7.moq.settings.apply_to_admin_orders' => ['1', 'default'],
        'vk7.pricing.visibility.hide_from_guests' => ['1', null],
        'b2b.general.settings.active' => ['1', 'default'],
        'b2b.general.settings.require_company_approval' => ['1', 'default'],
        'b2b.quotes.settings.default_expiration_period' => ['7', 'default'],
        'b2b.quotes.settings.expiration_period_unit' => ['days', 'default'],
        'customer.settings.create_new_account_options.default_group' => ['general', null],
        'sales.order_settings.order_number.order_number_prefix' => ['VK7-', 'default'],
        'sales.order_settings.order_number.order_number_length' => ['6', 'default'],
        'sales.payment_methods.cashondelivery.active' => ['1', 'default'],
        'sales.payment_methods.moneytransfer.active' => ['1', 'default'],
    ];

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vk7:apply-policy';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Apply the VK7 planning-default business rules to the store settings';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        foreach (self::SETTINGS as $code => [$value, $channel]) {
            DB::table('core_config')->where('code', $code)->delete();

            DB::table('core_config')->insert([
                'code' => $code,
                'value' => $value,
                'channel_code' => $channel,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        $this->components->info('VK7 planning defaults applied. They are not owner-confirmed.');

        return self::SUCCESS;
    }
}
