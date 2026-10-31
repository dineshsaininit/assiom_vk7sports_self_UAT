<?php

namespace VK7\Wholesale\Providers;

use Illuminate\Contracts\Debug\ExceptionHandler;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\ServiceProvider;
use VK7\Wholesale\Cart;
use VK7\Wholesale\Console\Commands\ResetAdminTwoFactor;
use VK7\Wholesale\Exceptions\Handler;
use VK7\Wholesale\Http\Middleware\Bouncer;
use VK7\Wholesale\Moq;
use VK7\Wholesale\Repositories\CustomerQuoteRepository;
use Webkul\B2BSuite\Repositories\CustomerQuoteRepository as BaseCustomerQuoteRepository;
use Webkul\Checkout\Cart as BaseCart;
use Webkul\User\Http\Middleware\Bouncer as BaseBouncer;

class WholesaleServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->mergeConfigFrom(dirname(__DIR__).'/Config/system.php', 'core');

        $this->app->singleton(BaseCart::class, Cart::class);

        $this->app->bind(BaseBouncer::class, Bouncer::class);

        $this->app->bind(BaseCustomerQuoteRepository::class, CustomerQuoteRepository::class);
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        $this->app->bind(ExceptionHandler::class, Handler::class);

        $this->loadMigrationsFrom(dirname(__DIR__).'/Database/Migrations');

        if ($this->app->runningInConsole()) {
            $this->commands([ResetAdminTwoFactor::class]);
        }

        $this->loadViewsFrom(dirname(__DIR__).'/Resources/views', 'vk7');

        Event::listen('checkout.order.save.before', [Moq::class, 'assertOrder']);

        Event::listen('customer.registration.after', function ($customer) {
            if (
                request()->routeIs('shop.customers.register.store')
                && core()->getConfigData('vk7.security.storefront.personal_account_approval')
            ) {
                $customer->update(['status' => 0]);
            }
        });

        Event::listen(
            'bagisto.shop.checkout.cart.breadcrumbs.after',
            fn ($viewRenderEventManager) => $viewRenderEventManager->addTemplate('vk7::cart-notice')
        );
    }
}
