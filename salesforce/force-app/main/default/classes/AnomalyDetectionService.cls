public class AnomalyDetectionService implements Queueable, Database.AllowsCallouts {
    private Set<Id> opportunityIds;

    public AnomalyDetectionService(Set<Id> opportunityIds) {
        this.opportunityIds = opportunityIds;
    }

    public void execute(QueueableContext context) {
        List<Opportunity> opportunities = [
            SELECT Id, Name, Amount, Probability, ExpectedRevenue
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ];

        Http http = new Http();

        for (Opportunity opp : opportunities) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://suspended-debate-everywhere-theatre.trycloudflare.com/predict');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> payload = new Map<String, Object>{
                'record_id' => opp.Id,
                'nome' => opp.Name,
                'metric_value' => opp.Amount
            };

            req.setBody(JSON.serialize(payload));

            try {
                HttpResponse res = http.send(req);
                System.debug('STATUS: ' + res.getStatusCode());
                System.debug('BODY: ' + res.getBody());
            } catch (Exception e) {
                System.debug('ERRO: ' + e.getMessage());
            }
        }
    }
}