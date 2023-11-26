<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class VerificationController extends Controller
{
    public function verify($email, $token)
    {
        $user = User::where('email', $email)->first();

        if ($user && $user->email_verification_token == $token) {
            $user->email_verified_at = now();
            $user->email_verification_token = null;
            $user->save();

            return response()->json($user, 201);
        } else {
            return response()->json([], 500);
        }
    }
}
