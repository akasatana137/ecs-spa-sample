<?php

namespace Tests\Feature;

use App\Models\Task;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TaskTest extends TestCase
{
    use RefreshDatabase;

    private $authenticatedUser;
    private $unAuthorizedUser;

    public function setUp(): void
    {
        parent::setUp();

        $users = User::factory()->count(2)->create();
        $this->authenticatedUser = $users[0];
        $this->unAuthorizedUser = $users[1];
        $this->actingAs($this->authenticatedUser);
    }

    public function test_get_task_list(): void
    {
        $authenticatedUserId = $this->authenticatedUser->id;
        $unAuthorizedUserId = $this->unAuthorizedUser->id;
        $tasks = Task::factory()->count(5)->create([
            'user_id' => fake()->numberBetween($authenticatedUserId, $unAuthorizedUserId)
        ]);
        $response = $this->getJson('/api/tasks');

        $response
            ->assertStatus(200)
            ->assertJsonCount($tasks->where('user_id', $this->authenticatedUser->id)->count());
    }

    public function test_register_task(): void
    {
        $data = ['title' => 'テスト'];

        $response = $this->postJson('/api/tasks', $data);

        $response
            ->assertCreated()
            ->assertJsonFragment($data);
    }

    public function test_update_task(): void
    {
        $task = Task::create([
            'title' => '書き換え前',
            'user_id' => $this->authenticatedUser->id
        ]);
        $task->title = '書き換え後';

        $response = $this->patchJson("/api/tasks/{$task->id}", $task->toArray());

        $response
            ->assertOk()
            ->assertJsonFragment(['title' => $task->title]);
    }

    public function test_updateDone_task(): void
    {
        $task = Task::create([
            'title' => 'check Done',
            'user_id' => $this->authenticatedUser->id
        ]);

        $this->patchJson("/api/tasks/update-done/{$task->id}", [
            'is_done' => !$task->is_done
        ]);

        $response = $this->getJson("/api/tasks/{$task->id}");
        $response->assertJsonFragment([
            'is_done' => true
        ]);
    }

    public function test_delete_task(): void
    {
        $authenticatedUserId = $this->authenticatedUser->id;
        $unAuthorizedUserId = $this->unAuthorizedUser->id;
        $tasks = Task::factory()->count(5)->create([
            'user_id' => fake()->numberBetween($authenticatedUserId, $unAuthorizedUserId)
        ]);
        $canDeleteTask = Task::create([
            'title' => 'be deleted',
            'user_id' => $this->authenticatedUser->id
        ]);
        $canGetTasks = $tasks->where('user_id', $this->authenticatedUser->id);
        $response = $this->getJson('/api/tasks');
        $response->assertJsonCount($canGetTasks->count() + 1);

        // $canDeleteTaskId = $canGetTasks[0]->id;
        $response = $this->deleteJson("/api/tasks/{$canDeleteTask->id}");
        $response->assertOk();

        $response = $this->getJson('/api/tasks');
        $response->assertJsonCount($canGetTasks->count());
    }

    public function test_register_task_null_title(): void
    {
        $data = ['title' => ''];
        $response = $this->postJson('/api/tasks', $data);
        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                "title" => "タイトルは、必ず指定してください。"
            ]);
    }

    public function test_update_task_null_title(): void
    {
        $task = Task::create([
            'title' => 'test',
            'user_id' => $this->authenticatedUser->id
        ]);
        $data = ['title' => ''];
        $response = $this->patchJson("/api/tasks/{$task->id}", $data);
        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                "title" => "タイトルは、必ず指定してください。"
            ]);
    }

    public function test_register_task_over_max_length_title(): void
    {
        $data = ['title' => str_repeat('あ', 256)];
        $response = $this->postJson('/api/tasks', $data);
        $response
            ->assertStatus(422)
            ->assertJsonValidationErrors([
                "title" => "タイトルは、255文字以下にしてください。"
            ]);
    }

    public function test_update_task_by_unauthorized_user(): void
    {
        $task = Task::create([
            'title' => '書き換え前',
            'user_id' => $this->unAuthorizedUser->id
        ]);
        $task->title = '書き換え後';

        $response = $this->patchJson("/api/tasks/{$task->id}", $task->toArray());

        $response->assertForbidden();
    }


    public function test_updateDone_task_by_unauthorized_user(): void
    {
        $task = Task::create([
            'title' => 'check Done',
            'user_id' => $this->unAuthorizedUser->id
        ]);

        $response = $this->patchJson("/api/tasks/update-done/{$task->id}", [
            'is_done' => !$task->is_done
        ]);

        $response->assertForbidden();
    }

    public function test_delete_task_by_unauthorized_user(): void
    {
        $task = Task::create([
            'title' => 'can not delete',
            'user_id' => $this->unAuthorizedUser->id
        ]);
        $response = $this->deleteJson("/api/tasks/{$task->id}");

        $response->assertForbidden();
    }
}
