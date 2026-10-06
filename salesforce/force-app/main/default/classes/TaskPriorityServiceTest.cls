public with sharing class TaskPriorityService {

    public static void recalcular(Set<Id> taskIds) {
        if (taskIds == null || taskIds.isEmpty()) {
            return;
        }

        List<Resultado_Prioridade_Tarefa__c> resultadosAntigos = [
            SELECT Id
            FROM Resultado_Prioridade_Tarefa__c
            WHERE Task_Id__c IN :taskIds
        ];

        if (!resultadosAntigos.isEmpty()) {
            delete resultadosAntigos;
        }

        List<Task> tarefas = [
            SELECT Id, Status, Priority, ActivityDate
            FROM Task
            WHERE Id IN :taskIds
            AND Status != 'Completed'
        ];

        if (tarefas.isEmpty()) {
            return;
        }

        List<TarefaPontuada> tarefasPontuadas = new List<TarefaPontuada>();

        for (Task tarefa : tarefas) {
            Integer pontuacao = calcularPontuacao(tarefa);
            tarefasPontuadas.add(
                new TarefaPontuada(tarefa.Id, pontuacao)
            );
        }

        tarefasPontuadas.sort();

        List<Resultado_Prioridade_Tarefa__c> novosResultados =
            new List<Resultado_Prioridade_Tarefa__c>();

        Integer ordem = 1;

        for (TarefaPontuada tarefaPontuada : tarefasPontuadas) {
            novosResultados.add(
                new Resultado_Prioridade_Tarefa__c(
                    Task_Id__c = String.valueOf(tarefaPontuada.taskId),
                    Pontuacao__c = tarefaPontuada.pontuacao,
                    Ordem_Recomendada__c = ordem,
                    Data_Processamento__c = System.now()
                )
            );

            ordem++;
        }

        if (!novosResultados.isEmpty()) {
            insert novosResultados;
        }
    }

    private static Integer calcularPontuacao(Task tarefa) {
        Integer pontuacao = 0;
        Date hoje = Date.today();

        if (tarefa.ActivityDate != null) {
            if (tarefa.ActivityDate < hoje) {
                pontuacao += 40;
            } else if (tarefa.ActivityDate == hoje) {
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

    private class TarefaPontuada implements Comparable {
        public Id taskId;
        public Integer pontuacao;

        public TarefaPontuada(Id taskId, Integer pontuacao) {
            this.taskId = taskId;
            this.pontuacao = pontuacao;
        }

        public Integer compareTo(Object objeto) {
            TarefaPontuada outraTarefa = (TarefaPontuada) objeto;

            if (this.pontuacao > outraTarefa.pontuacao) {
                return -1;
            }

            if (this.pontuacao < outraTarefa.pontuacao) {
                return 1;
            }

            String idAtual = String.valueOf(this.taskId);
            String idOutro = String.valueOf(outraTarefa.taskId);

            return idAtual.compareTo(idOutro);
        }
    }
}