<?php

namespace VK7\Wholesale\Exceptions;

use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Webkul\Core\Exceptions\Handler as CoreHandler;
use Webkul\Sales\Exceptions\InsufficientInventoryException;

class Handler extends CoreHandler
{
    /**
     * Status codes the core handler would otherwise report to the visitor as a 500.
     */
    public const PASSTHROUGH_STATUSES = [419, 429];

    /**
     * Register rejected-order and pass-through statuses ahead of the core catch-all callbacks.
     */
    public function register(): void
    {
        if (! config('app.debug')) {
            $this->renderable(fn (InsufficientInventoryException|MoqNotMetException $e, Request $request) => $this->rejectOrder($e, $request));

            $this->renderable(fn (HttpExceptionInterface $e, Request $request) => in_array($e->getStatusCode(), self::PASSTHROUGH_STATUSES)
                ? ($request->expectsJson() ? $this->prepareJsonResponse($request, $e) : $this->renderHttpException($e))
                : null);
        }

        parent::register();
    }

    /**
     * Turn a rejected order into a readable 422 instead of a server error.
     */
    protected function rejectOrder(InsufficientInventoryException|MoqNotMetException $e, Request $request)
    {
        if ($request->expectsJson()) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return back()->with('error', $e->getMessage());
    }
}
