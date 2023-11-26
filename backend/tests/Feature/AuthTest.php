<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_login(): void
    {
        $user = User::factory()->create([
            'password' => Hash::make('test_password')
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'test_password'
        ]);

        $response->assertOk();
        $this->assertAuthenticated();
    }

    public function test_logout(): void
    {
        $user = User::factory()->create();
        $this->actingAs($user);

        $response = $this->postJson('/api/logout');

        $response->assertOk();
        $this->assertGuest();
    }

    public function test_get_login_user(): void
    {
        $user = User::factory()->create();
        $this->actingAs($user);

        $response = $this->getJson('/api/user');

        $response
            ->assertOk()
            ->assertJsonFragment(['id' => $user->id]);
    }

    public function test_register(): void
    {
        $data = [
            'name' => 'testUser',
            'email' => 'test@gmail.com',
            'password' => 'password'
        ];
        $response = $this->postJson('/api/register', $data);
        unset($data['password']);
        $response
            ->assertCreated()
            ->assertJsonFragment($data);
    }

    public function test_register_same_email(): void
    {
        User::create([
            'name' => 'test',
            'email' => 'same@gmail.com',
            'password' => 'password'
        ]);

        $data = [
            'name' => 'test',
            'email' => 'same@gmail.com',
            'password' => 'password'
        ];

        $response = $this->postJson('/api/register', $data);
        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                "email" => "指定のメールアドレスは既に使用されています。"
            ]);
    }

    public function test_register_over_max_length_password(): void
    {
        $data = [
            'name' => 'test',
            'email' => 'test@gmail.com',
            'password' => str_repeat('a', 256)
        ];
        $response = $this->postJson('/api/register', $data);
        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                "password" => "パスワードは、 128文字以下にしてください。"
            ]);
    }

    public function test_register_less_min_length_password(): void
    {
        $data = [
            'name' => 'test',
            'email' => 'test@gmail.com',
            'password' => '1234567'
        ];
        $response = $this->postJson('/api/register', $data);
        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                "password" => "パスワードは、8文字以上にしてください。"
            ]);
    }

    public function test_register_invalidated_email(): void
    {
        $data = [
            'name' => 'test',
            'email' => 'invalid_email',
            'password' => 'password'
        ];

        $response = $this->postJson('/api/register', $data);
        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                "email" =>  "メールアドレスは、有効なメールアドレス形式で指定してください。"
            ]);
    }
}
