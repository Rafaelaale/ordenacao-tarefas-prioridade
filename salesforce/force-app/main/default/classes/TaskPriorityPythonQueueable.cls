public class TaskPriorityPythonQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext contexto) {
        List<Task> tarefas = [
            SELECT Id, Status, Priority, ActivityDate, Subject
            FROM Task
            WHERE Status != 'Completed'
        ];

        List<Object> tarefasParaApi = new List<Object>();

        for (Task tarefa : tarefas) {
            Map<String, Object> dadosTarefa = new Map<String, Object>{
                'id' => String.valueOf(tarefa.Id),
                'status' => tarefa.Status,
                'due_date' => tarefa.ActivityDate == null
                    ? null
                    : String.valueOf(tarefa.ActivityDate),
                'priority' => tarefa.Priority,
                'customer_value' => 0,
                'task_type' => tarefa.Subject,
                'urgency' => 0
            };

            tarefasParaApi.add(dadosTarefa);
        }

        Map<String, Object> corpo = new Map<String, Object>{
            'tasks' => tarefasParaApi
        };

        HttpRequest requisicao = new HttpRequest();
        requisicao.setEndpoint(
            'https://outcomes-legendary-flights-brochures.trycloudflare.com/ordenar'
        );
        requisicao.setMethod('POST');
        requisicao.setHeader('Content-Type', 'application/json');
        requisicao.setTimeout(120000);
        requisicao.setBody(JSON.serialize(corpo));

        Http http = new Http();
        HttpResponse resposta = http.send(requisicao);

        System.debug(
            LoggingLevel.INFO,
            'Resposta da API Python: ' +
            resposta.getStatusCode() +
            ' - ' +
            resposta.getBody()
        );

        if (resposta.getStatusCode() < 200 || resposta.getStatusCode() >= 300) {
            throw new CalloutException(
                'API Python retornou HTTP ' + resposta.getStatusCode()
            );
        }

        Map<String, Object> retorno =
            (Map<String, Object>) JSON.deserializeUntyped(resposta.getBody());

        List<Object> idsOrdenados = (List<Object>) retorno.get('task_ids');

        if (idsOrdenados == null) {
            throw new CalloutException(
                'A resposta da API Python não contém o campo task_ids.'
            );
        }

        Map<Id, Task> tarefasPorId = new Map<Id, Task>();

        for (Task tarefa : tarefas) {
            tarefasPorId.put(tarefa.Id, tarefa);
        }

        List<Resultado_Prioridade_Tarefa__c> resultadosAntigos = [
            SELECT Id
            FROM Resultado_Prioridade_Tarefa__c
        ];

        if (!resultadosAntigos.isEmpty()) {
            delete resultadosAntigos;
        }

        List<Resultado_Prioridade_Tarefa__c> novosResultados =
            new List<Resultado_Prioridade_Tarefa__c>();

        Integer ordem = 1;

        for (Object item : idsOrdenados) {
            Id taskId;

            try {
                taskId = Id.valueOf(String.valueOf(item));
            } catch (Exception erroId) {
                System.debug(
                    LoggingLevel.WARN,
                    'ID de tarefa inválido retornado pela API: ' + String.valueOf(item)
                );
                continue;
            }

            Task tarefa = tarefasPorId.get(taskId);

            if (tarefa == null) {
                System.debug(
                    LoggingLevel.WARN,
                    'Tarefa retornada pela API não foi encontrada: ' + taskId
                );
                continue;
            }

            Integer pontuacao = calcularPontuacao(tarefa);

            novosResultados.add(
                new Resultado_Prioridade_Tarefa__c(
                    Task_Id__c = String.valueOf(tarefa.Id),
                    Pontuacao__c = pontuacao,
                    Ordem_Recomendada__c = ordem,
                    Data_Processamento__c = Datetime.now()
                )
            );

            ordem++;
        }

        if (!novosResultados.isEmpty()) {
            insert novosResultados;
        }

        System.debug(
            LoggingLevel.INFO,
            'Resultados de prioridade gravados: ' + novosResultados.size()
        );
    }

    private static Integer calcularPontuacao(Task tarefa) {
        Integer pontuacao = 0;

        if (tarefa.ActivityDate != null) {
            if (tarefa.ActivityDate < Date.today()) {
                pontuacao += 40;
            } else if (tarefa.ActivityDate == Date.today()) {
                pontuacao += 30;
            }
        }

        if (tarefa.Priority == 'High') {
            pontuacao += 30;
        } else if (tarefa.Priority == 'Normal') {
            pontuacao += 15;
        } else if (tarefa.Priority == 'Low') {
            pontuacao += 5;
        }

        return pontuacao;
    }
}
