<?php

namespace VK7\Wholesale\Couriers;

use Illuminate\Support\Str;

class DemoCourier implements CourierProvider
{
    /**
     * Name shown for simulated shipments.
     */
    public const COURIER_NAME = 'Demo Courier';

    /**
     * Hub used when a state has no entry below, and as the mid-route scan.
     */
    public const CENTRAL_HUB = ['city' => 'Nagpur', 'lat' => 21.1458, 'lng' => 79.0882];

    /**
     * Sample hub per state code.
     */
    public const HUBS = [
        'AP' => ['city' => 'Vijayawada', 'lat' => 16.5062, 'lng' => 80.648],
        'AS' => ['city' => 'Guwahati', 'lat' => 26.1445, 'lng' => 91.7362],
        'BR' => ['city' => 'Patna', 'lat' => 25.5941, 'lng' => 85.1376],
        'CG' => ['city' => 'Raipur', 'lat' => 21.2514, 'lng' => 81.6296],
        'DL' => ['city' => 'Delhi', 'lat' => 28.6139, 'lng' => 77.209],
        'GA' => ['city' => 'Panaji', 'lat' => 15.4909, 'lng' => 73.8278],
        'GJ' => ['city' => 'Ahmedabad', 'lat' => 23.0225, 'lng' => 72.5714],
        'HR' => ['city' => 'Gurugram', 'lat' => 28.4595, 'lng' => 77.0266],
        'JH' => ['city' => 'Ranchi', 'lat' => 23.3441, 'lng' => 85.3096],
        'KA' => ['city' => 'Bengaluru', 'lat' => 12.9716, 'lng' => 77.5946],
        'KL' => ['city' => 'Kochi', 'lat' => 9.9312, 'lng' => 76.2673],
        'MH' => ['city' => 'Mumbai', 'lat' => 19.076, 'lng' => 72.8777],
        'MP' => ['city' => 'Bhopal', 'lat' => 23.2599, 'lng' => 77.4126],
        'OD' => ['city' => 'Bhubaneswar', 'lat' => 20.2961, 'lng' => 85.8245],
        'PB' => ['city' => 'Ludhiana', 'lat' => 30.901, 'lng' => 75.8573],
        'RJ' => ['city' => 'Jaipur', 'lat' => 26.9124, 'lng' => 75.7873],
        'SK' => ['city' => 'Gangtok', 'lat' => 27.3389, 'lng' => 88.6065],
        'TN' => ['city' => 'Chennai', 'lat' => 13.0827, 'lng' => 80.2707],
        'TS' => ['city' => 'Hyderabad', 'lat' => 17.385, 'lng' => 78.4867],
        'UK' => ['city' => 'Dehradun', 'lat' => 30.3165, 'lng' => 78.0322],
        'UP' => ['city' => 'Lucknow', 'lat' => 26.8467, 'lng' => 80.9462],
        'WB' => ['city' => 'Kolkata', 'lat' => 22.5726, 'lng' => 88.3639],
    ];

    /**
     * The code stored against shipments booked through this provider.
     */
    public function code(): string
    {
        return 'demo';
    }

    /**
     * Book a simulated pickup between the sample hubs.
     */
    public function book(array $shipment): array
    {
        $from = self::HUBS[$shipment['origin']['state']] ?? self::CENTRAL_HUB;

        $to = self::HUBS[$shipment['destination']['state']] ?? self::CENTRAL_HUB;

        return [
            'courier' => self::COURIER_NAME,
            'waybill' => 'DEMO'.strtoupper(Str::random(10)),
            'tracking_url' => null,
            'expected_on' => now()->addDays(5)->toDateString(),
            'route' => [
                ['lat' => $from['lat'], 'lng' => $from['lng'], 'label' => $from['city']],
                ['lat' => self::CENTRAL_HUB['lat'], 'lng' => self::CENTRAL_HUB['lng'], 'label' => self::CENTRAL_HUB['city']],
                ['lat' => $to['lat'], 'lng' => $to['lng'], 'label' => $to['city']],
            ],
            'events' => [$this->scan(0, $from, $to)],
        ];
    }

    /**
     * Return one more scan each time it is called, standing in for a courier's progress.
     */
    public function track(string $waybill, array $context = []): array
    {
        $route = $context['route'] ?? [];

        $from = ['city' => $route[0]['label'], 'lat' => $route[0]['lat'], 'lng' => $route[0]['lng']];

        $to = ['city' => $route[2]['label'], 'lat' => $route[2]['lat'], 'lng' => $route[2]['lng']];

        $next = min(($context['scans'] ?? 1) + 1, 5);

        return array_map(fn ($step) => $this->scan($step, $from, $to), range(0, $next - 1));
    }

    /**
     * Build one simulated scan of the five-step journey.
     */
    protected function scan(int $step, array $from, array $to): array
    {
        [$status, $place, $description] = [
            ['Picked up', $from, 'Picked up from the VK7SPORTS warehouse'],
            ['In transit', self::CENTRAL_HUB, 'Reached the sorting hub'],
            ['Reached destination', $to, 'Reached the destination hub'],
            ['Out for delivery', $to, 'Out for delivery'],
            ['Delivered', $to, 'Delivered to the retailer'],
        ][$step];

        return [
            'status' => $status,
            'location' => $place['city'],
            'lat' => $place['lat'],
            'lng' => $place['lng'],
            'description' => $description,
            'occurred_at' => now()->toDateTimeString(),
        ];
    }
}
