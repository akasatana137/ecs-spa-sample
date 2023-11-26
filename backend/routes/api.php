<?php

use App\Http\Controllers\LoginController;
use App\Http\Controllers\RegisterController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\VerificationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::post('login', [LoginController::class, 'login']);
Route::post('logout', [LoginController::class, 'logout']);
Route::post('register', [RegisterController::class, 'register']);

Route::group(['middleware' => ['auth:sanctum', 'verified']], function () {
    Route::apiResource('tasks', TaskController::class);
    Route::patch('tasks/update-done/{task}', [TaskController::class, 'updateDone']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});

Route::get('/email/verify/{email}/{token}', [VerificationController::class, 'verify'])->name('verification.verify');

// API test用ルート
Route::get('test', function () {
    return 'Test';
});

Route::get('health_check', static function () {
    $status = ['status' => 200, 'message' => 'success'];
    return compact('status');
});
