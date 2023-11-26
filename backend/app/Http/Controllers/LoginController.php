<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    /**
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (Auth::attemptWhen($credentials, function (User $user) {
            return $user->hasVerifiedEmail();
        })) {
            $request->session()->regenerate();

            return response()->json(Auth::user());
        }

        return response()->json([], 401);
    }

    /**
     *@param \Illuminate\Http\Request $request
     *@return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return response()->json(true);
    }
}
