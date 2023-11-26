import { Task } from "../types/TaskType";
import http from "./axiosInstance";

const getTasks = async () => {
  const { data } = await http.get<Task[]>('/api/tasks');
  return data;
}

const updateDoneTask = async ({ id, is_done }: Task) => {
  const { data } = await http.patch<Task>(
    `/api/tasks/update-done/${id}`,
    {is_done: !is_done}
  )
  return data;
}

const createTask = async (title: string) => {
  const { data } = await http.post<Task>(
    '/api/tasks',
    {title: title}
  )
  return data;
}

const updateTask = async ({ id, title }: Task) => {
  const { data } = await http.put<Task>(
    `/api/tasks/${id}`,
    {title: title}
  )
  return data
}

const deleteTask = async (id: number) => {
  const { data } = await http.delete<Task>(`/api/tasks/${id}`)
  return data
}

export {
  getTasks,
  updateDoneTask,
  createTask,
  updateTask,
  deleteTask
}
