<?php

use VK7\Wholesale\Couriers\DelhiveryCourier;
use VK7\Wholesale\Couriers\DemoCourier;
use VK7\Wholesale\Payments\DemoGateway;
use VK7\Wholesale\Payments\RazorpayGateway;

return [
    'payments' => [
        'gateway' => env('VK7_PAYMENT_GATEWAY', 'demo'),
        'allow_live' => (bool) env('VK7_PAYMENTS_ALLOW_LIVE', false),
        'allow_demo' => (bool) env('VK7_ALLOW_DEMO_PAYMENTS', false),
        'gateways' => [
            'demo' => DemoGateway::class,
            'razorpay' => RazorpayGateway::class,
        ],
        'razorpay' => [
            'key_id' => env('RAZORPAY_KEY_ID'),
            'key_secret' => env('RAZORPAY_KEY_SECRET'),
            'webhook_secret' => env('RAZORPAY_WEBHOOK_SECRET'),
            'api_url' => 'https://api.razorpay.com/v1',
        ],
    ],

    'admin' => [
        'url' => env('VK7_ADMIN_URL', 'http://127.0.0.1:8080/admin-login.html'),
        'close_bagisto_panel' => (bool) env('VK7_CLOSE_BAGISTO_ADMIN', true),
    ],

    'site' => [
        'url' => env('VK7_SITE_URL', 'http://127.0.0.1:8080'),
        'close_bagisto_shop' => (bool) env('VK7_CLOSE_BAGISTO_SHOP', true),
    ],

    'courier' => [
        'provider' => env('VK7_COURIER', 'demo'),
        'providers' => [
            'demo' => DemoCourier::class,
            'delhivery' => DelhiveryCourier::class,
        ],
        'origin' => ['city' => 'Mumbai', 'state' => 'MH'],
    ],

    'atlas' => [
        'mirror_activity' => (bool) env('VK7_ATLAS_MIRROR', true),
        'connection' => 'mongodb',
        'activity_collection' => 'activity_log',
        'check_collection' => 'connection_checks',
        'cooldown_seconds' => 60,
    ],
];
