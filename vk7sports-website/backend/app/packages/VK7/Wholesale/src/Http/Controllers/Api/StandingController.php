<?php

namespace VK7\Wholesale\Http\Controllers\Api;

use Illuminate\Http\JsonResponse;
use VK7\Wholesale\Services\RetailerStanding;
use Webkul\Checkout\Facades\Cart;

class StandingController extends Controller
{
    /**
     * Create a new controller instance.
     */
    public function __construct(protected RetailerStanding $standing) {}

    /**
     * The signed-in retailer's payment score, cash on delivery access and the rules that apply.
     */
    public function show(): JsonResponse
    {
        $companyId = $this->standing->companyId($this->customer()->id);

        return response()->json(['data' => array_merge($this->standing->standing($companyId), [
            'rules' => $this->rules(),
        ])]);
    }

    /**
     * The payment choices for the current order list: the advance, and whether cash on delivery is offered.
     */
    public function checkout(): JsonResponse
    {
        $cart = Cart::getCart();

        if (! $cart) {
            return $this->fail(trans('The cart is empty.'), 'CART_EMPTY');
        }

        Cart::collectTotals();

        $total = (float) Cart::getCart()->base_grand_total;

        $policy = $this->standing->policy($this->standing->companyId($this->customer()->id), $total);

        return response()->json(['data' => [
            'total' => $total,
            'advance_percent' => $policy['advance_percent'],
            'advance_due' => round($total * $policy['advance_percent'] / 100, 2),
            'first_order' => $policy['first_order'],
            'note' => $policy['first_order'] || $policy['advance_percent'] > $this->standing->baseAdvance() ? $this->retailerNote($policy) : null,
            'cod' => $policy['cod'],
        ]]);
    }

    /**
     * Plain-language rules shown on the account page.
     */
    protected function rules(): array
    {
        $s = fn ($key) => $this->standing->setting($key);

        return [
            'advance_percent' => $this->standing->baseAdvance(),
            'new_mid_value' => $s('newMidValue'),
            'new_mid_percent' => $s('newMidPct'),
            'new_prepaid_above' => $s('newPrepaidAbove'),
            'cod_min_score' => $s('codMinScore'),
            'cod_min_orders' => $s('codMinOrders'),
            'cod_max_order' => $s('codMaxOrder'),
            'cancel_confirmed_percent' => $s('cancelConfirmedPct'),
            'cancel_packing_percent' => $s('cancelPackingPct'),
            'late_days' => $s('lateDays'),
        ];
    }

    /**
     * Why a higher advance applies, in words for the retailer.
     */
    protected function retailerNote(array $policy): string
    {
        if ($policy['advance_percent'] >= 100) {
            return 'For this order the full amount is paid before dispatch.';
        }

        return $policy['first_order']
            ? 'As this is one of your first orders, a '.rtrim(rtrim(number_format($policy['advance_percent'], 2), '0'), '.').'% advance applies.'
            : 'Based on your payment history, a '.rtrim(rtrim(number_format($policy['advance_percent'], 2), '0'), '.').'% advance applies.';
    }
}
