<?php

namespace VK7\Wholesale\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ForceJson
{
    /**
     * Largest JSON or form body accepted, in bytes. Photo uploads are multipart and may be larger.
     */
    public const MAX_BODY = 256 * 1024;

    /**
     * Largest multipart upload accepted, in bytes.
     */
    public const MAX_UPLOAD = 25 * 1024 * 1024;

    /**
     * Make every API response render as JSON, refuse oversized bodies early,
     * and stop browsers and proxies keeping copies of private answers.
     */
    public function handle(Request $request, Closure $next)
    {
        $request->headers->set('Accept', 'application/json');

        $length = (int) $request->server('CONTENT_LENGTH', 0);

        $limit = str_starts_with((string) $request->header('Content-Type'), 'multipart/form-data') ? self::MAX_UPLOAD : self::MAX_BODY;

        if ($length > $limit) {
            return response()->json(['message' => trans('The request is too large.'), 'code' => 'TOO_LARGE'], 413);
        }

        $response = $next($request);

        $response->headers->set('Cache-Control', 'no-store, private');
        $response->headers->set('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
        $response->headers->set('Cross-Origin-Resource-Policy', 'cross-origin');
        $response->headers->remove('X-Built-With');
        $response->headers->remove('X-Powered-By');

        return $response;
    }
}
