<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken as Middleware;

class VerifyCsrfToken extends Middleware
{
    /**
     * The URIs that should be excluded from CSRF verification.
     *
     * @var array<int, string>
     */
    protected $except = [
        // 後で削除
        'api/*'
    ];

    // debug
    // public function handle($request, Closure $next)
    // {
    //     // CSRFトークンを取得し、ログに出力
    //     $token = $request->input('_token');
    //     \Log::debug('CSRF Token received: ' . $token);

    //     return parent::handle($request, $next);
    // }
}
