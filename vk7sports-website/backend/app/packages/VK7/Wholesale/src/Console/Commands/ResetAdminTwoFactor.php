<?php

namespace VK7\Wholesale\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;
use Webkul\User\Models\Admin;

class ResetAdminTwoFactor extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'vk7:admin-2fa-reset {email : Admin user email} {--reason= : Why the reset is needed, kept in the log}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Lockout recovery: clear an admin user\'s two-factor secret and backup codes so they must enrol again.';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $admin = Admin::where('email', $this->argument('email'))->first();

        if (! $admin) {
            $this->error('No admin user with that email.');

            return self::FAILURE;
        }

        if (! $this->option('reason')) {
            $this->error('A --reason is required for the audit log.');

            return self::FAILURE;
        }

        if (! $this->confirm("Reset two-factor authentication for {$admin->email}?")) {
            return self::FAILURE;
        }

        $admin->forceFill(two_factor_authentication()->getDisableValues())->save();

        Log::warning('Admin two-factor authentication reset from the console.', [
            'admin_id' => $admin->id,
            'email' => $admin->email,
            'reason' => $this->option('reason'),
            'os_user' => get_current_user(),
        ]);

        $this->info('Two-factor authentication cleared. The admin must enrol again at next login.');

        return self::SUCCESS;
    }
}
