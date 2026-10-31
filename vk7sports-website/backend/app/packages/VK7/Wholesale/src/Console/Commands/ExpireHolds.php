<?php

namespace VK7\Wholesale\Console\Commands;

use Illuminate\Console\Command;
use VK7\Wholesale\Services\OrderFinance;

class ExpireHolds extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vk7:expire-holds';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Cancel orders whose advance did not arrive in time and release their stock';

    /**
     * Execute the console command.
     */
    public function handle(OrderFinance $finance): int
    {
        $this->components->info($finance->expireOverdue().' orders expired.');

        return self::SUCCESS;
    }
}
