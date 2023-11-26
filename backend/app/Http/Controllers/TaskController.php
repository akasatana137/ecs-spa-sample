<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
    public function __construct()
    {
        $this->middleware('can:checkUser,task')->only([
            'updateDone',
            'update',
            'destroy'
        ]);
    }
    /**
     * @return Task[] \Illuminate\Database\Eloquent\Collection
     */
    public function index()
    {
        return Task::where('user_id', Auth::id())->orderByDesc('id')->get();
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * @param \App\Http\Requests\StoreTaskRequest $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(StoreTaskRequest $request)
    {
        $request->merge(['user_id' => Auth::id()]);
        $task = Task::create($request->all());

        return $task
            ? response()->json($task, 201)
            : response()->json([], 500);
    }

    /**
     * Display the specified resource.
     */
    public function show(Task $task)
    {
        return $task;
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Task $task)
    {
        //
    }

    /**
     * @param \App\Http\Requests\UpdateTaskRequest $request
     * @param \App\Models\Task $task
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(UpdateTaskRequest $request, Task $task)
    {
        $task->title = $request->title;

        return $task->update()
            ? response()->json($task)
            : response()->json([], 500);
    }

    /**
     * @param \Illuminate\Http\Request $request
     * @param \App\Models\Task $task
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateDone(Request $request, Task $task)
    {
        $task->is_done = $request->is_done;

        return $task->update()
            ? response()->json($task)
            : response()->json([], 500);
    }

    /**
     * @param \App\Models\Task $task
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Task $task)
    {
        return $task->delete($task->id)
            ? response()->json($task)
            : response()->json([], 501);
    }
}
