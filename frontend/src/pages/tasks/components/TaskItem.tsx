/* eslint-disable react/prop-types */
import { useState } from "react";
import { toast } from "react-toastify";
import { useDeleteTask, useUpdateDoneTask, useUpdateTask } from "../../../queries/TaskQuery";
import { Task } from "../../../types/TaskType";

type Props = {
  task: Task
}

const TaskItem: React.FC<Props> = ({task}) => {
  const updateDoneTask = useUpdateDoneTask()
  const updateTask = useUpdateTask()
  const deleteTask = useDeleteTask()

  const [editTitle, setEditTitle] = useState<string|undefined>();

  const handleToggleEdit = () => {
    setEditTitle(task.title)
  }

  const handleOnKey = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (['Escape', 'Tab'].includes(e.key)) {
      setEditTitle(undefined)
    }
  }

  const handleUpdate = (e: React.FormEvent<HTMLFormElement>|React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault()
    const newTask = {...task}
    if (editTitle === undefined) {
      return toast.error("タイトルを入力してください")
    } else if (editTitle === newTask.title) {
      return setEditTitle(undefined)
    }
    newTask.title = editTitle
    updateTask.mutate(newTask)

    setEditTitle(undefined)
  }

  const handleDelete = () => {
    deleteTask.mutate(task.id)
  }

  const itemText = () => {
    return (
      <>
        <div onClick={handleToggleEdit}><span>{task.title}</span></div>
        <button className="btn is-delete" onClick={handleDelete}>削除</button>
      </>
    )
  }

  const itemInput = () => {
    return (
      <>
        <form onSubmit={handleUpdate}>
          <input
            type="text"
            className="input"
            defaultValue={task.title}
            onKeyDown={handleOnKey}
            onChange={e => setEditTitle(e.target.value)}
          />
        </form>
        <button className="btn" onClick={handleUpdate}>更新</button>
      </>
    )
  }

  return (
    <li className={task.is_done ? "done" : ""}>
      <label className="checkbox-label">
          <input
            type="checkbox"
            className="checkbox-input"
            onClick={() => updateDoneTask.mutate(task)}
          />
      </label>
      {editTitle === undefined ? itemText() : itemInput()}
    </li>
  )
}

export default TaskItem;
