import React, { useState } from 'react';
import './TaskItem.css';

function TaskItem({ task, onDelete }) {
  const [isDeleting, setIsDeleting] = useState(false);

  const handleDelete = async () => {
    if (window.confirm('Are you sure you want to delete this task?')) {
      setIsDeleting(true);
      try {
        await onDelete(task._id);
      } catch (err) {
        console.error('Error:', err);
        setIsDeleting(false);
      }
    }
  };

  const createdDate = new Date(task.createdAt).toLocaleDateString();

  return (
    <div className="task-item">
      <div className="task-content">
        <h3 className="task-title">{task.title}</h3>
        <p className="task-date">Created: {createdDate}</p>
      </div>
      <button
        className="delete-btn"
        onClick={handleDelete}
        disabled={isDeleting}
        title="Delete task"
      >
        {isDeleting ? '...' : '×'}
      </button>
    </div>
  );
}

export default TaskItem;
