<?php
// Sandbox fixture: fictional, approved buyer accounts for automated order tests.
use Webkul\Customer\Models\Customer;

foreach (range(1, 12) as $i) {
    Customer::updateOrCreate(
        ['email' => sprintf('buyer%02d@example.test', $i)],
        [
            'first_name' => 'Buyer',
            'last_name' => sprintf('Test%02d', $i),
            'password' => bcrypt(getenv('QA_PASSWORD') ?: throw new RuntimeException('QA_PASSWORD not set')),
            'customer_group_id' => 2,
            'channel_id' => 1,
            'status' => 1,
            'is_verified' => 1,
        ]
    );
}

echo Customer::where('email', 'like', 'buyer%@example.test')->count()." fictional buyers ready\n";
