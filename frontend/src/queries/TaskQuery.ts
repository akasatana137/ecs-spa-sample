import { useQuery, useMutation, useQueryClient } from "react-query";
import * as api from "../api/TaskApi";
import { toast } from "react-toastify";
import { AxiosError } from "axios";

const useTasks = () => {
  return useQuery('tasks', api.getTasks)
}

const useUpdateDoneTask = () => {
  const queryClient = useQueryClient();

  return useMutation(
    api.updateDoneTask,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('tasks')
      },
      onError: () => {
        toast.error('更新に失敗しました')
      }
  })
}

const useCreateTask = () => {
  const queryClient = useQueryClient();

  return useMutation(
    api.createTask,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('tasks')
        toast.success('新規作成に成功しました')
      },
      onError: (error: AxiosError) => {
        const data: any = error.response?.data
        if (data.errors) {
          Object.values(data.errors).map((messages: any) => {
            messages.map((message: string) => {
              toast.error(message)
            })
          })
        } else {
          toast.error('新規作成に失敗しました')
        }
      }
  })
}

const useUpdateTask = () => {
  const queryClient = useQueryClient();

  return useMutation(
    api.updateTask,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('tasks')
        toast.success('編集に成功しました')
      },
      onError: (error: AxiosError) => {
        const data: any = error.response?.data
        if (data.errors) {
          Object.values(data.errors).map((messages: any) => {
            messages.map((message: string) => {
              toast.error(message)
            })
          })
        } else {
          toast.error('編集に失敗しました')
        }
      }
  })
}

const useDeleteTask = () => {
  const queryClient = useQueryClient();

  return useMutation(
    api.deleteTask,
    {
      onSuccess: () => {
        queryClient.invalidateQueries('tasks')
        toast.success('タスクを削除しました')
      },
      onError: () => {
        toast.error('タスクの削除に失敗しました')
      }
  })
}

export {
  useTasks,
  useUpdateDoneTask,
  useCreateTask,
  useUpdateTask,
  useDeleteTask
}
