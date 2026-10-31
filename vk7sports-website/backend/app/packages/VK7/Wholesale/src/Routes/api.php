<?php

use Illuminate\Support\Facades\Route;
use VK7\Wholesale\Http\Controllers\Api\AccountController;
use VK7\Wholesale\Http\Controllers\Api\AuthController;
use VK7\Wholesale\Http\Controllers\Api\CartController;
use VK7\Wholesale\Http\Controllers\Api\CatalogController;
use VK7\Wholesale\Http\Controllers\Api\CheckoutController;
use VK7\Wholesale\Http\Controllers\Api\EnquiryController;
use VK7\Wholesale\Http\Controllers\Api\OrderController;
use VK7\Wholesale\Http\Controllers\Api\QuoteController;
use VK7\Wholesale\Http\Middleware\AuthenticateRetailer;
use VK7\Wholesale\Http\Middleware\ForceJson;

Route::group([
    'prefix' => 'api/v1',
    'middleware' => [ForceJson::class, 'throttle:vk7-api'],
    'as' => 'vk7.api.',
], function () {
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

        Route::controller(OrderController::class)->prefix('orders')->name('orders.')->group(function () {
            Route::get('', 'index')->name('index');

            Route::get('{id}', 'show')->name('show');

            Route::post('{id}/cancel', 'cancel')->name('cancel');
        });
    });
});
