trigger TaskPriorityTrigger on Task (after insert, after update) {
    System.enqueueJob(new TaskPriorityPythonQueueable());
}