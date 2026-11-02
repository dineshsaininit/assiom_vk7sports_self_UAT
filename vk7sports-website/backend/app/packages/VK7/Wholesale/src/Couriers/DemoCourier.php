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
     * Hub used when a state has no entry below.
     */
    public const CENTRAL_HUB = ['city' => 'Nagpur', 'lat' => 21.1458, 'lng' => 79.0882];

    /**
     * Shipments shorter than this go straight to the destination.
     */
    public const DIRECT_KM = 400;

    /**
     * Shipments longer than this pass through two sorting hubs instead of one.
     */
    public const LONG_HAUL_KM = 1200;

    /**
     * Sample hub per state code.
     */
    public const HUBS = [
        'AP' => ['state' => 'Andhra Pradesh', 'city' => 'Vijayawada', 'lat' => 16.5062, 'lng' => 80.648],
        'AS' => ['state' => 'Assam', 'city' => 'Guwahati', 'lat' => 26.1445, 'lng' => 91.7362],
        'BR' => ['state' => 'Bihar', 'city' => 'Patna', 'lat' => 25.5941, 'lng' => 85.1376],
        'CT' => ['state' => 'Chhattisgarh', 'city' => 'Raipur', 'lat' => 21.2514, 'lng' => 81.6296],
        'DL' => ['state' => 'Delhi', 'city' => 'Delhi', 'lat' => 28.6139, 'lng' => 77.209],
        'GA' => ['state' => 'Goa', 'city' => 'Panaji', 'lat' => 15.4909, 'lng' => 73.8278],
        'GJ' => ['state' => 'Gujarat', 'city' => 'Ahmedabad', 'lat' => 23.0225, 'lng' => 72.5714],
        'HR' => ['state' => 'Haryana', 'city' => 'Gurugram', 'lat' => 28.4595, 'lng' => 77.0266],
        'JH' => ['state' => 'Jharkhand', 'city' => 'Ranchi', 'lat' => 23.3441, 'lng' => 85.3096],
        'KA' => ['state' => 'Karnataka', 'city' => 'Bengaluru', 'lat' => 12.9716, 'lng' => 77.5946],
        'KL' => ['state' => 'Kerala', 'city' => 'Kochi', 'lat' => 9.9312, 'lng' => 76.2673],
        'MH' => ['state' => 'Maharashtra', 'city' => 'Mumbai', 'lat' => 19.076, 'lng' => 72.8777],
        'MP' => ['state' => 'Madhya Pradesh', 'city' => 'Bhopal', 'lat' => 23.2599, 'lng' => 77.4126],
        'OR' => ['state' => 'Odisha', 'city' => 'Bhubaneswar', 'lat' => 20.2961, 'lng' => 85.8245],
        'PB' => ['state' => 'Punjab', 'city' => 'Ludhiana', 'lat' => 30.901, 'lng' => 75.8573],
        'RJ' => ['state' => 'Rajasthan', 'city' => 'Jaipur', 'lat' => 26.9124, 'lng' => 75.7873],
        'SK' => ['state' => 'Sikkim', 'city' => 'Gangtok', 'lat' => 27.3389, 'lng' => 88.6065],
        'TN' => ['state' => 'Tamil Nadu', 'city' => 'Chennai', 'lat' => 13.0827, 'lng' => 80.2707],
        'TG' => ['state' => 'Telangana', 'city' => 'Hyderabad', 'lat' => 17.385, 'lng' => 78.4867],
        'UT' => ['state' => 'Uttarakhand', 'city' => 'Dehradun', 'lat' => 30.3165, 'lng' => 78.0322],
        'UP' => ['state' => 'Uttar Pradesh', 'city' => 'Lucknow', 'lat' => 26.8467, 'lng' => 80.9462],
        'WB' => ['state' => 'West Bengal', 'city' => 'Kolkata', 'lat' => 22.5726, 'lng' => 88.3639],
    ];

    /**
     * Places for larger cities that are not their state's hub.
     */
    public const CITIES = [
        'agra' => ['lat' => 27.1767, 'lng' => 78.0081],
        'amritsar' => ['lat' => 31.634, 'lng' => 74.8723],
        'chandigarh' => ['lat' => 30.7333, 'lng' => 76.7794],
        'coimbatore' => ['lat' => 11.0168, 'lng' => 76.9558],
        'indore' => ['lat' => 22.7196, 'lng' => 75.8577],
        'kanpur' => ['lat' => 26.4499, 'lng' => 80.3319],
        'madurai' => ['lat' => 9.9252, 'lng' => 78.1198],
        'mysuru' => ['lat' => 12.2958, 'lng' => 76.6394],
        'nagpur' => ['lat' => 21.1458, 'lng' => 79.0882],
        'nashik' => ['lat' => 19.9975, 'lng' => 73.7898],
        'noida' => ['lat' => 28.5355, 'lng' => 77.391],
        'pune' => ['lat' => 18.5204, 'lng' => 73.8567],
        'rajkot' => ['lat' => 22.3039, 'lng' => 70.8022],
        'surat' => ['lat' => 21.1702, 'lng' => 72.8311],
        'thiruvananthapuram' => ['lat' => 8.5241, 'lng' => 76.9366],
        'vadodara' => ['lat' => 22.3072, 'lng' => 73.1812],
        'varanasi' => ['lat' => 25.3176, 'lng' => 82.9739],
        'visakhapatnam' => ['lat' => 17.6868, 'lng' => 83.2185],
    ];

    /**
     * The code stored against shipments booked through this provider.
     */
    public function code(): string
    {
        return 'demo';
    }

    /**
     * Book a simulated pickup along a route of sample hubs.
     */
    public function book(array $shipment): array
    {
        $from = $this->hubFor($shipment['origin']);

        $to = $this->hubFor($shipment['destination']);

        $stops = [$from, ...$this->viaHubs($from, $to), $to];

        $route = array_map(fn ($stop) => ['lat' => $stop['lat'], 'lng' => $stop['lng'], 'label' => $stop['city']], $stops);

        return [
            'courier' => self::COURIER_NAME,
            'waybill' => 'DEMO'.strtoupper(Str::random(10)),
            'tracking_url' => null,
            'expected_on' => now()->addDays(5)->toDateString(),
            'route' => $route,
            'events' => array_slice($this->journey($route), 0, 1),
        ];
    }

    /**
     * Return one more scan each time it is called, standing in for a courier's progress.
     */
    public function track(string $waybill, array $context = []): array
    {
        return array_slice($this->journey($context['route'] ?? []), 0, ($context['scans'] ?? 1) + 1);
    }

    /**
     * Find the sample hub for a place, keeping the place's own city as its name.
     */
    protected function hubFor(array $place): array
    {
        $state = trim((string) ($place['state'] ?? ''));

        $hub = self::HUBS[strtoupper($state)]
            ?? collect(self::HUBS)->first(fn ($hub) => strcasecmp($hub['state'], $state) === 0)
            ?? self::CENTRAL_HUB;

        $city = trim((string) ($place['city'] ?? ''));

        return array_merge($hub, self::CITIES[strtolower($city)] ?? [], ['city' => $city ?: $hub['city']]);
    }

    /**
     * Pick the sorting hubs that add the least distance to the journey, in travel order.
     */
    protected function viaHubs(array $from, array $to): array
    {
        $direct = $this->distance($from, $to);

        if ($direct < self::DIRECT_KM) {
            return [];
        }

        return collect(self::HUBS)
            ->reject(fn ($hub) => in_array($hub['city'], [$from['city'], $to['city']], true))
            ->reject(fn ($hub) => $this->distance($from, $hub) < 100 || $this->distance($hub, $to) < 100)
            ->sortBy(fn ($hub) => $this->distance($from, $hub) + $this->distance($hub, $to))
            ->take($direct > self::LONG_HAUL_KM ? 2 : 1)
            ->sortBy(fn ($hub) => $this->distance($from, $hub))
            ->values()
            ->all();
    }

    /**
     * Straight-line distance between two places in kilometres.
     */
    protected function distance(array $a, array $b): float
    {
        $latitude = deg2rad($b['lat'] - $a['lat']);

        $longitude = deg2rad($b['lng'] - $a['lng']);

        $arc = sin($latitude / 2) ** 2
            + cos(deg2rad($a['lat'])) * cos(deg2rad($b['lat'])) * sin($longitude / 2) ** 2;

        return 6371 * 2 * asin(min(1, sqrt($arc)));
    }

    /**
     * Build every simulated scan of a journey along the route, in order.
     */
    protected function journey(array $route): array
    {
        $stops = array_map(fn ($stop) => ['city' => $stop['label'], 'lat' => $stop['lat'], 'lng' => $stop['lng']], $route);

        $from = $stops[0];

        $to = $stops[count($stops) - 1];

        $scans = [
            ['Picked up', $from, 'Picked up from the VK7SPORTS warehouse'],
            ['In transit', $from, 'Left the '.$from['city'].' origin hub'],
        ];

        foreach (array_slice($stops, 1, -1) as $hub) {
            $scans[] = ['Reached hub', $hub, 'Arrived at the '.$hub['city'].' sorting hub'];
            $scans[] = ['In transit', $hub, 'Left the '.$hub['city'].' sorting hub'];
        }

        array_push(
            $scans,
            ['Reached destination', $to, 'Arrived at the '.$to['city'].' delivery hub'],
            ['Out for delivery', $to, 'With the delivery agent, arriving today'],
            ['Delivered', $to, 'Delivered to the retailer'],
        );

        return array_map(fn ($scan) => [
            'status' => $scan[0],
            'location' => $scan[1]['city'],
            'lat' => $scan[1]['lat'],
            'lng' => $scan[1]['lng'],
            'description' => $scan[2],
            'occurred_at' => now()->toDateTimeString(),
        ], $scans);
    }
}
