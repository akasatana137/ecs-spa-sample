import React from "react";
import TaskInput from "./components/TaskInput";
import TaskList from "./components/TaskList";

const TaskPage: React.FC = () => {

  return (
    <>
      <TaskInput />
      <TaskList />
    </>
  )
}
export default TaskPage;
