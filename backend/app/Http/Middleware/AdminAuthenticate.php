<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminAuthenticate
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!Auth::guard('admin')->check()) {
            if ($request->ajax() || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 401);
            }

            return redirect()->route('admin.login')
                ->with('error', 'Silakan login terlebih dahulu');
        }

        // Check if admin is active
        if (!Auth::guard('admin')->user()->is_active) {
            Auth::guard('admin')->logout();

            if ($request->ajax() || $request->wantsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Akun Anda telah dinonaktifkan',
                ], 403);
            }

            return redirect()->route('admin.login')
                ->with('error', 'Akun Anda telah dinonaktifkan');
        }

        return $next($request);
    }
}
