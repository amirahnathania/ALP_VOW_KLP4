<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class SuperAdminOnly
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $adminUser = Auth::guard('admin')->user();
        if (!Auth::guard('admin')->check() || !$adminUser || !($adminUser instanceof \App\Models\Admin) || !$adminUser->isSuperAdmin()) {
            if ($request->ajax() || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Hanya Super Admin yang dapat mengakses fitur ini',
                ], 403);
            }
            abort(403, 'Hanya Super Admin yang dapat mengakses fitur ini');
        }

        return $next($request);
    }
}
