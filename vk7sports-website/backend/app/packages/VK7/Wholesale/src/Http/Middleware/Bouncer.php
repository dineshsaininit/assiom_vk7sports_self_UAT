<?php

namespace VK7\Wholesale\Http\Middleware;

use Webkul\User\Http\Middleware\Bouncer as BaseBouncer;

class Bouncer extends BaseBouncer
{
    /**
     * Routes an admin without two-factor authentication may still reach while enrolment is required.
     */
    public const ENROLMENT_ROUTES = ['admin.account.edit', 'admin.two_factor.enable'];

    /**
     * Require two-factor verification, and enrolment first when the store enforces it for every admin.
     */
    public function isTwoFactorRequired(string $guard): bool
    {
        return parent::isTwoFactorRequired($guard) || $this->mustEnrol($guard);
    }

    /**
     * Send an admin who has not enrolled to the account page, otherwise defer to the core redirect.
     */
    public function handleTwoFactorRedirect(string $guard)
    {
        if ($this->mustEnrol($guard)) {
            session()->flash('warning', trans('Two-factor authentication is required for every admin user. Set it up to continue.'));

            return redirect()->route('admin.account.edit');
        }

        return parent::handleTwoFactorRedirect($guard);
    }

    /**
     * Whether the store requires two-factor authentication and this admin has not enabled it yet.
     */
    protected function mustEnrol(string $guard): bool
    {
        return (bool) core()->getConfigData('vk7.security.admin.require_two_factor')
            && ! auth()->guard($guard)->user()->two_factor_enabled
            && ! request()->routeIs(...self::ENROLMENT_ROUTES);
    }
}
