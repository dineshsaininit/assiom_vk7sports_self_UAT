<?php

namespace VK7\Wholesale\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Contracts\Debug\ExceptionHandler;
use Illuminate\Http\Request;
use Illuminate\Routing\Router;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use VK7\Wholesale\Cart;
use VK7\Wholesale\Console\Commands\ApplyPolicy;
use VK7\Wholesale\Console\Commands\DemoData;
use VK7\Wholesale\Console\Commands\ResetAdminTwoFactor;
use VK7\Wholesale\Exceptions\Handler;
use VK7\Wholesale\Http\Middleware\Bouncer;
use VK7\Wholesale\Http\Middleware\HidePricesFromGuests;
use VK7\Wholesale\Moq;
use VK7\Wholesale\OrderNumberSequencer;
use VK7\Wholesale\QuoteLock;
use VK7\Wholesale\Repositories\CustomerQuoteRepository;
use Webkul\B2BSuite\Repositories\CustomerQuoteRepository as BaseCustomerQuoteRepository;
use Webkul\Checkout\Cart as BaseCart;
use Webkul\Sales\Generators\OrderSequencer;
use Webkul\User\Http\Middleware\Bouncer as BaseBouncer;

class WholesaleServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     */
    public function register(): void
    {
        $this->mergeConfigFrom(dirname(__DIR__).'/Config/system.php', 'core');

        $this->mergeConfigFrom(dirname(__DIR__).'/Config/menu.php', 'menu.admin');

        $this->mergeConfigFrom(dirname(__DIR__).'/Config/acl.php', 'acl');

        $this->app->singleton(BaseCart::class, Cart::class);

        $this->app->bind(BaseBouncer::class, Bouncer::class);

        $this->app->bind(BaseCustomerQuoteRepository::class, CustomerQuoteRepository::class);

        $this->app->bind(OrderSequencer::class, OrderNumberSequencer::class);
    }

    /**
     * Bootstrap services.
     */
    public function boot(Router $router): void
    {
        $this->app->bind(ExceptionHandler::class, Handler::class);

        $this->loadMigrationsFrom(dirname(__DIR__).'/Database/Migrations');

        $this->loadRoutesFrom(dirname(__DIR__).'/Routes/api.php');

        $this->loadRoutesFrom(dirname(__DIR__).'/Routes/admin.php');

        $router->pushMiddlewareToGroup('web', HidePricesFromGuests::class);

        $this->registerRateLimits();

        if ($this->app->runningInConsole()) {
            $this->commands([ApplyPolicy::class, DemoData::class, ResetAdminTwoFactor::class]);
        }

        $this->loadViewsFrom(dirname(__DIR__).'/Resources/views', 'vk7');

        Event::listen('checkout.order.save.before', [Moq::class, 'assertOrder']);

        Event::listen('checkout.order.save.before', [QuoteLock::class, 'assertOrder']);

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

    /**
     * Give each API area its own per-address limit, so browsing never uses up the sign-in allowance.
     */
    protected function registerRateLimits(): void
    {
        RateLimiter::for('vk7-api', fn (Request $request) => Limit::perMinute(240)->by($request->ip()));

        RateLimiter::for('vk7-login', fn (Request $request) => Limit::perMinute(20)->by($request->ip()));

        RateLimiter::for('vk7-forms', fn (Request $request) => Limit::perMinute(10)->by($request->ip()));
    }
}
