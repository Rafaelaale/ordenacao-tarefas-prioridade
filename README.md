# Ordenação Automática de Tarefas por Prioridade

## Objetivo
Automatizar a recomendação de ordem de execução de tarefas no Salesforce, usando um serviço Python para calcular a pontuação de prioridade.

## Problema que resolve
Quando há várias tarefas pendentes, decidir manualmente qual executar primeiro é demorado e inconsistente. Este projeto automatiza essa decisão com base em critérios objetivos (prazo, atraso, prioridade e status).

## Como funciona a lógica de priorização
1. Uma tarefa é criada ou atualizada no Salesforce.
2. O trigger `TaskPriorityTrigger` identifica a mudança e enfileira o processamento.
3. `TaskPriorityPythonQueueable` consulta as tarefas abertas e envia os dados para a API Python via HTTP.
4. A API Python calcula a pontuação de cada tarefa considerando prazo, atraso, tarefas do dia e prioridade, e retorna apenas a lista de IDs ordenada.
5. O Salesforce grava o resultado no objeto `Resultado_Prioridade_Tarefa__c` (pontuação e ordem recomendada).

Tarefas concluídas não entram na ordenação. A API não cria, atualiza nem exclui tarefas — ela só calcula e devolve a recomendação.

## Tecnologias
Salesforce · Apex · SOQL · Trigger · Queueable Apex · API REST · Python · FastAPI · HTTP/JSON · Git · Salesforce CLI

## Arquitetura
```
Task (Salesforce)
   -> TaskPriorityTrigger
   -> Queueable Apex
   -> HTTP POST para API Python
   -> API retorna IDs ordenados
   -> Resultado_Prioridade_Tarefa__c
```
- **Salesforce** é o sistema principal: armazena tarefas, status e resultados.
- **Python** só recebe dados, aplica a regra de pontuação e devolve a ordem — sem acoplamento com a origem dos dados.
- O uso de **Queueable Apex** mantém o trigger leve e isola o callout em um contexto assíncrono apropriado.

## Testes realizados e resultado
Teste com duas tarefas pendentes:

| Tarefa | Situação | Pontuação | Ordem |
|---|---|---|---|
| 00TgL00000EVtmYUAT | Atrasada, prioridade High | 70 | 1 |
| 00TgL00000EVoy9UAD | Para hoje, prioridade Normal | 45 | 2 |

Execução assíncrona validada: `Status: Completed`, `Erros: 0`. O resultado confirmou que uma tarefa atrasada e de alta prioridade é posicionada antes de uma tarefa normal do dia.

## Prints / demonstração
> Adicionar aqui prints do fluxo: criação da tarefa, job do Queueable em `AsyncApexJob` e registros em `Resultado_Prioridade_Tarefa__c`.

## Como executar / reproduzir
**API Python:**
```powershell
cd python
.\.venv\Scripts\Activate.ps1
# executar conforme configuração de inference.py
```

**Salesforce:**
```powershell
cd salesforce
sf data query --target-org estudo --query "SELECT Id, ApexClass.Name, Status, NumberOfErrors FROM AsyncApexJob WHERE ApexClass.Name = 'TaskPriorityPythonQueueable' ORDER BY CreatedDate DESC LIMIT 5" --result-format human
sf data query --target-org estudo --query "SELECT Id, Task_Id__c, Pontuacao__c, Ordem_Recomendada__c FROM Resultado_Prioridade_Tarefa__c ORDER BY Ordem_Recomendada__c ASC" --result-format human
```

## Decisões técnicas e desafios
- Separar o cálculo (Python) do armazenamento (Salesforce) reduziu o acoplamento entre os dois sistemas.
- O resultado é gravado em um objeto próprio (`Resultado_Prioridade_Tarefa__c`), sem alterar os registros originais de `Task`.
- Principal desafio: garantir que o callout acontecesse fora do contexto do trigger, resolvido com Queueable Apex.
- Para produção, os próximos passos de segurança incluem: hospedagem estável com HTTPS, autenticação por token, variáveis de ambiente para segredos, monitoramento e retry.

## Próximas melhorias
- Autenticação na API
- Testes automatizados para o endpoint `/ordenar`
- Mais critérios de pontuação (valor do cliente, urgência, volume por usuário)
- Logs estruturados e retry para falhas temporárias
- Interface para visualizar a ordem recomendada
- Pipeline de testes no GitHub Actions
- Documentação OpenAPI

## Estrutura do projeto
```
ordenacao-tarefas-prioridade/
├── docs/
├── python/
│   └── inference.py
├── salesforce/
│   └── force-app/main/default/{classes,objects,remoteSiteSettings,triggers}
├── .gitignore
└── README.md
```

## Autor
Rafael Alexandre Oliveira Araújo
LinkedIn: [linkedin.com/in/rafael-araujo-aa10a4232](https://www.linkedin.com/in/rafael-araujo-aa10a4232/) · GitHub: [github.com/Rafaelaale](https://github.com/Rafaelaale)
