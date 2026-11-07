<?php

namespace VK7\Wholesale\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Webkul\User\Models\AdminProxy;
use Webkul\User\Models\RoleProxy;

class SetupStore extends Command
{
    /**
     * Staff roles and the business desk areas each one uses.
     */
    public const ROLES = [
        'Sales' => ['dashboard', 'retailers', 'enquiries', 'support', 'quotes', 'orders'],
        'Inventory' => ['dashboard', 'products', 'inventory', 'orders'],
        'Warehouse' => ['dashboard', 'orders', 'dispatch'],
        'Finance' => ['dashboard', 'payments', 'orders', 'retailers', 'reports'],
    ];

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vk7:setup {--owner-email= : Email the owner signs in with} {--owner-name=Owner : Name shown for the owner}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Prepare a fresh database: business rules, staff roles and the owner sign-in';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $email = $this->option('owner-email');

        if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->components->error('Give the owner a real email with --owner-email.');

            return self::FAILURE;
        }

        Artisan::call('vk7:apply-policy');

        foreach (self::ROLES as $name => $areas) {
            RoleProxy::query()->updateOrCreate(['name' => $name], [
                'description' => $name.' staff',
                'permission_type' => 'custom',
                'permissions' => array_map(fn ($area) => 'vk7_desk.'.$area, $areas),
            ]);
        }

        $password = Str::password(16, symbols: false);

        $owner = AdminProxy::query()->where('email', $email)->first() ?? AdminProxy::query()->orderBy('id')->first();

        $details = [
            'name' => $this->option('owner-name'),
            'email' => $email,
            'password' => Hash::make($password),
            'status' => 1,
        ];

        $owner
            ? $owner->update($details)
            : AdminProxy::query()->create(array_merge($details, ['role_id' => RoleProxy::query()->where('permission_type', 'all')->value('id')]));

        $this->components->info('Store ready. Sign in as '.$email.' with this password, shown only once:');

        $this->line($password);

        return self::SUCCESS;
    }
}
