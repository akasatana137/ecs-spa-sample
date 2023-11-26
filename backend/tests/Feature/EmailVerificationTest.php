<?php

namespace Tests\Feature;

use App\Mail\EmailVerification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class EmailVerificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_verify_email_content(): void
    {
        $user = User::factory()->create();

        $mailable = new EmailVerification($user);
        $url = "http://localhost:3000/{$user->email}/{$user->email_verification_token}";

        $mailable->assertSeeInHtml($url);
    }

    public function test_verify_email_send(): void
    {
        Mail::fake();

        $data = [
            'name' => 'test_verify_email_send',
            'email' => 'test@gmail.com',
            'password' => 'password'
        ];

        $this->postJson('/api/register', $data);

        Mail::assertSent(EmailVerification::class);
    }

    public function test_verify_email(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => null,
            'email_verification_token' => 'test_token'
        ]);

        $response = $this->getJson("/api/email/verify/{$user->email}/{$user->email_verification_token}");
        $data = [
            'email_verification_token' => null
        ];

        $this->assertNotNull($response['email_verified_at']);
        $response
            ->assertStatus(201)
            ->assertJsonFragment($data);
    }
}
