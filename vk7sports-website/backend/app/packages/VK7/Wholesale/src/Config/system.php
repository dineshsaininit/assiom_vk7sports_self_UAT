<?php

return [
    [
        'key' => 'vk7',
        'name' => 'VK7 Wholesale',
        'info' => 'Wholesale ordering rules (sandbox evaluation).',
        'sort' => 3,
    ], [
        'key' => 'vk7.moq',
        'name' => 'Minimum Order Quantity',
        'info' => 'Server-side minimum order quantity enforced in cart, checkout and order creation.',
        'icon' => 'settings/store.svg',
        'sort' => 1,
    ], [
        'key' => 'vk7.moq.settings',
        'name' => 'Settings',
        'info' => 'Provisional values pending owner confirmation.',
        'sort' => 1,
        'fields' => [
            [
                'name' => 'enabled',
                'title' => 'Enable minimum order quantity',
                'type' => 'boolean',
                'default' => false,
                'channel_based' => true,
            ], [
                'name' => 'min_qty',
                'title' => 'Minimum pieces',
                'type' => 'number',
                'default' => 24,
                'validation' => 'required_if:enabled,1|integer|min:1',
                'channel_based' => true,
            ], [
                'name' => 'mode',
                'title' => 'Count the minimum',
                'type' => 'select',
                'default' => 'per_style',
                'channel_based' => true,
                'options' => [
                    ['title' => 'Per style (all sizes and colours of one product combined)', 'value' => 'per_style'],
                    ['title' => 'Per variant (each size/colour SKU separately)', 'value' => 'per_variant'],
                    ['title' => 'Per order (total pieces in the order)', 'value' => 'per_order'],
                ],
            ], [
                'name' => 'apply_to_admin_orders',
                'title' => 'Also enforce on orders created by staff in admin',
                'type' => 'boolean',
                'default' => true,
                'channel_based' => true,
            ],
        ],
    ],
    [
        'key' => 'vk7.security',
        'name' => 'Security',
        'info' => 'Admin account security rules.',
        'icon' => 'settings/store.svg',
        'sort' => 2,
    ], [
        'key' => 'vk7.security.admin',
        'name' => 'Admin Users',
        'info' => 'Applies to every admin user, including staff roles.',
        'sort' => 1,
        'fields' => [
            [
                'name' => 'require_two_factor',
                'title' => 'Require two-factor authentication for all admin users',
                'type' => 'boolean',
                'default' => false,
            ],
        ],
    ],
    [
        'key' => 'vk7.security.storefront',
        'name' => 'Storefront Accounts',
        'info' => 'Who can open an account on the storefront.',
        'sort' => 2,
        'fields' => [
            [
                'name' => 'personal_account_approval',
                'title' => 'Personal (non-company) accounts need admin approval',
                'info' => 'Off = Bagisto default: personal sign-ups are active immediately. Company sign-ups follow the B2B Suite approval setting.',
                'type' => 'boolean',
                'default' => false,
            ],
        ],
    ],
];
