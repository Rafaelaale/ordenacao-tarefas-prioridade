trigger OpportunityAnomalyTrigger on Opportunity (after insert, after update) {
    Set<Id> opportunityIds = new Set<Id>();

    for (Opportunity opp : Trigger.new) {
        if (Trigger.isInsert ||
            opp.Amount != Trigger.oldMap.get(opp.Id).Amount) {
            opportunityIds.add(opp.Id);
        }
    }

    if (!opportunityIds.isEmpty()) {
        System.enqueueJob(new AnomalyDetectionService(opportunityIds));
    }
}