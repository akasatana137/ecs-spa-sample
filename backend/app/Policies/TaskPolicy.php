<?php

namespace App\Policies;

use App\Models\Task;
use App\Models\User;

class TaskPolicy
{
    public function checkUser(User $user, Task $task): bool
    {
        return $user->id === $task->user_id;
    }
}
