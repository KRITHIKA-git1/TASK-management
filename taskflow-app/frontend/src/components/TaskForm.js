import React, { useState } from 'react';
import './TaskForm.css';

function TaskForm({ onAddTask }) {
  const [taskTitle, setTaskTitle] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!taskTitle.trim()) {
      alert('Please enter a task title');
      return;
    }

    setIsSubmitting(true);
    try {
      await onAddTask(taskTitle);
      setTaskTitle('');
    } catch (err) {
      console.error('Error:', err);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form className="task-form" onSubmit={handleSubmit}>
      <input
        type="text"
        value={taskTitle}
        onChange={(e) => setTaskTitle(e.target.value)}
        placeholder="Add a new task..."
        disabled={isSubmitting}
        className="task-input"
      />
      <button type="submit" disabled={isSubmitting} className="add-btn">
        {isSubmitting ? 'Adding...' : 'Add Task'}
      </button>
    </form>
  );
}

export default TaskForm;
