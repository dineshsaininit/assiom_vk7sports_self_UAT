<?php

use Illuminate\Support\Facades\Route;
use VK7\Wholesale\Http\Controllers\Api\AccountController;
use VK7\Wholesale\Http\Controllers\Api\Admin\DeskController;
use VK7\Wholesale\Http\Controllers\Api\Admin\StaffAuthController;
use VK7\Wholesale\Http\Controllers\Api\AuthController;
use VK7\Wholesale\Http\Controllers\Api\CartController;
use VK7\Wholesale\Http\Controllers\Api\CatalogController;
use VK7\Wholesale\Http\Controllers\Api\CheckoutController;
use VK7\Wholesale\Http\Controllers\Api\EnquiryController;
use VK7\Wholesale\Http\Controllers\Api\OrderController;
use VK7\Wholesale\Http\Controllers\Api\PaymentController;
use VK7\Wholesale\Http\Controllers\Api\QuoteController;
use VK7\Wholesale\Http\Middleware\AuthenticateRetailer;
use VK7\Wholesale\Http\Middleware\AuthenticateStaff;
use VK7\Wholesale\Http\Middleware\ForceJson;

Route::group([
    'prefix' => 'api/v1',
    'middleware' => [ForceJson::class, 'throttle:vk7-api'],
    'as' => 'vk7.api.',
], function () {
    Route::post('webhooks/razorpay', [PaymentController::class, 'webhook'])->name('webhooks.razorpay');

    Route::post('admin/login', [StaffAuthController::class, 'login'])
        ->middleware('throttle:vk7-login')
        ->name('admin.login');

    /**
     * Staff routes, each limited to an area of the business desk.
     */
    Route::group(['prefix' => 'admin', 'as' => 'admin.'], function () {
        Route::middleware(AuthenticateStaff::class)->group(function () {
            Route::get('me', [StaffAuthController::class, 'me'])->name('me');

            Route::post('logout', [StaffAuthController::class, 'logout'])->name('logout');
        });

        Route::controller(DeskController::class)->group(function () {
            Route::middleware(AuthenticateStaff::class.':dashboard')->get('dashboard', 'dashboard')->name('dashboard');

            Route::middleware(AuthenticateStaff::class.':reports')->get('reports', 'reports')->name('reports');

            Route::middleware(AuthenticateStaff::class.':audit')->get('activity', 'activity')->name('activity');

            Route::middleware(AuthenticateStaff::class.':retailers')->group(function () {
                Route::get('clients', 'clients')->name('clients.index');

                Route::get('clients/{id}', 'client')->name('clients.show');

                Route::post('clients/{id}/decision', 'decideClient')->name('clients.decide');
            });

            Route::middleware(AuthenticateStaff::class.':orders')->group(function () {
                Route::get('orders', 'orders')->name('orders.index');

                Route::get('orders/{id}', 'order')->name('orders.show');

                Route::post('orders/{id}/hold', 'holdOrder')->name('orders.hold');

                Route::post('orders/{id}/resume', 'resumeOrder')->name('orders.resume');

                Route::post('orders/{id}/cancel', 'cancelOrder')->name('orders.cancel');
            });

            Route::middleware(AuthenticateStaff::class.':payments')->group(function () {
                Route::get('payments', 'payments')->name('payments.index');

                Route::post('payments/{id}/review', 'reviewPayment')->name('payments.review');

                Route::post('orders/{id}/collection', 'recordCollection')->name('orders.collection');
            });

            Route::middleware(AuthenticateStaff::class.':dispatch')->group(function () {
                Route::get('dispatch', 'dispatchQueue')->name('dispatch.index');

                Route::post('orders/{id}/stage', 'moveOrder')->name('orders.stage');

                Route::post('orders/{id}/dispatch', 'dispatchOrder')->name('orders.dispatch');

                Route::post('shipments/{id}/refresh', 'refreshShipment')->name('shipments.refresh');
            });
        });
    });

    /**
     * Public routes; a valid token is honoured so approved retailers see their own prices.
     */
    Route::group(['middleware' => AuthenticateRetailer::class.':optional'], function () {
        Route::get('meta', [CatalogController::class, 'meta'])->name('meta');

        Route::get('categories', [CatalogController::class, 'categories'])->name('categories.index');

        Route::get('products', [CatalogController::class, 'products'])->name('products.index');

        Route::get('products/{product}', [CatalogController::class, 'product'])->name('products.show');

        Route::post('auth/register', [AuthController::class, 'register'])
            ->middleware('throttle:vk7-forms')
            ->name('auth.register');

        Route::post('auth/login', [AuthController::class, 'login'])
            ->middleware('throttle:vk7-login')
            ->name('auth.login');

        Route::post('auth/forgot', [AccountController::class, 'forgot'])
            ->middleware('throttle:vk7-forms')
            ->name('auth.forgot');

        Route::post('orders/track', [OrderController::class, 'track'])
            ->middleware('throttle:vk7-forms')
            ->name('orders.track');

        Route::post('enquiries', [EnquiryController::class, 'store'])
            ->middleware('throttle:vk7-forms')
            ->name('enquiries.store');
    });

    /**
     * Routes for approved retailers holding a token.
     */
    Route::group(['middleware' => AuthenticateRetailer::class], function () {
        Route::post('auth/logout', [AuthController::class, 'logout'])->name('auth.logout');

        Route::get('auth/me', [AuthController::class, 'me'])->name('auth.me');

        Route::post('moq/check', [CartController::class, 'check'])->name('moq.check');

        Route::get('enquiries/mine', [EnquiryController::class, 'mine'])->name('enquiries.mine');

        Route::controller(AccountController::class)->prefix('account')->name('account.')->group(function () {
            Route::get('', 'show')->name('show');

            Route::put('', 'update')->name('update');

            Route::put('password', 'password')->name('password');

            Route::post('addresses', 'storeAddress')->name('addresses.store');

            Route::put('addresses/{id}', 'updateAddress')->name('addresses.update');

            Route::delete('addresses/{id}', 'destroyAddress')->name('addresses.destroy');

            Route::post('addresses/{id}/default', 'defaultAddress')->name('addresses.default');
        });

        Route::controller(CartController::class)->prefix('cart')->name('cart.')->group(function () {
            Route::get('', 'show')->name('show');

            Route::post('items', 'store')->name('items.store');

            Route::put('styles/{productId}', 'replaceStyle')->name('styles.replace');

            Route::put('items/{id}', 'update')->name('items.update');

            Route::delete('items/{id}', 'destroy')->name('items.destroy');
        });

        Route::controller(CheckoutController::class)->prefix('checkout')->name('checkout.')->group(function () {
            Route::post('address', 'address')->name('address');

            Route::post('shipping', 'shipping')->name('shipping');

            Route::post('payment', 'payment')->name('payment');

            Route::post('order', 'order')->name('order');
        });

        Route::controller(QuoteController::class)->prefix('quotes')->name('quotes.')->group(function () {
            Route::get('', 'index')->name('index');

            Route::post('', 'store')->name('store');

            Route::get('{id}', 'show')->name('show');

            Route::post('{id}/counter', 'counter')->name('counter');

            Route::post('{id}/messages', 'message')->name('message');

            Route::post('{id}/accept', 'accept')->name('accept');

            Route::post('{id}/reject', 'reject')->name('reject');
        });

        Route::get('account/statement', [AccountController::class, 'statement'])->name('account.statement');

        Route::controller(PaymentController::class)->prefix('orders/{id}/payments')->name('orders.payments.')->group(function () {
            Route::post('', 'start')->name('start');

            Route::post('reference', 'reference')->name('reference');

            Route::post('{paymentId}/confirm', 'confirm')->name('confirm');
        });

        Route::controller(OrderController::class)->prefix('orders')->name('orders.')->group(function () {
            Route::get('', 'index')->name('index');

            Route::get('{id}', 'show')->name('show');

            Route::post('{id}/cancel', 'cancel')->name('cancel');
        });
    });
});
