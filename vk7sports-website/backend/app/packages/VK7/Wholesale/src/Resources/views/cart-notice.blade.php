@php
    $cartError = \Webkul\Checkout\Facades\Cart::getErrors();
@endphp

@if (in_array($cartError['error_code'] ?? null, ['MOQ_NOT_MET', 'INSUFFICIENT_QUANTITY']))
    <div
        class="mt-5 w-full gap-12 rounded-lg bg-[#FFF3CD] px-5 py-3 text-[#383D41] max-sm:px-3 max-sm:py-2 max-sm:text-sm"
        role="alert"
    >
        {{ $cartError['message'] }}
    </div>
@endif
