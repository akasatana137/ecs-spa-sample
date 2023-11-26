<?php

namespace App\Http\Controllers;

use App\Http\Requests\RegisterRequest;
use App\Mail\EmailVerification;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class RegisterController extends Controller
{
    public function register(RegisterRequest $request)
    {
        // ユーザーを作成
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'email_verification_token' => Str::random(60)
        ]);

        // 確認メールを送信
        try {
            Mail::to($user->email)->send(new EmailVerification($user));
            return response()->json($user, 201);
        } catch (\Exception $e) {
            User::destroy($user->id);
            return response()->json([], 500);
        }
    }

    // mail送信確認
    public function toMail()
    {
        $user = User::where('id', 10);
        Mail::to($user->email)->send(new EmailVerification($user));

        dd("Send Email Successfully: {$user}");
    }
}
