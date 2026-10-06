trigger TaskPriorityTrigger on Task (after insert, after update) {
    List<Id> taskIds = new List<Id>();

    for (Task tarefa : Trigger.new) {
        taskIds.add(tarefa.Id);
    }

    TaskPriorityService.recalcular(taskIds);
}