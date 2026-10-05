# Ordenação Automática de Tarefas por Prioridade

Projeto de portfólio com Salesforce e Python para sugerir a ordem de execução de tarefas com base em critérios de prioridade.

## Conceito

O Salesforce é responsável por armazenar e organizar as tarefas. O Python calcula a sequência recomendada e devolve somente os IDs das tarefas ordenados.

> Salesforce é o quadro de tarefas. Python só sugere a ordem.

## Critérios planejados

A ordenação poderá considerar:

- Prazo da tarefa;
- Atraso;
- Valor do cliente;
- Tipo de tarefa;
- Tarefas pendentes do usuário;
- Pontuação de urgência.

## Arquitetura planejada

1. Uma alteração em uma tarefa é identificada no Salesforce.
2. O Salesforce inicia o processamento assíncrono.
3. Uma classe Apex envia os dados necessários para o serviço Python.
4. O Python calcula a ordem recomendada.
5. O serviço devolve somente a sequência dos IDs.
6. O Salesforce registra ou apresenta a recomendação.

## Estrutura do projeto

```text
ordenacao-tarefas-prioridade/
├── docs/
├── python/
├── salesforce/
│   ├── force-app/
│   │   └── main/
│   │       └── default/
│   │           ├── classes/
│   │           ├── flows/
│   │           ├── objects/
│   │           └── triggers/
│   └── sfdx-project.json
└── .gitignore
```

## Status

Estrutura inicial do projeto criada. A implementação das classes Apex, do serviço Python, dos testes e da documentação detalhada será realizada nas próximas etapas.

## Tecnologias planejadas

- Salesforce;
- Apex;
- Salesforce CLI;
- Python;
- Integração HTTP;
- Git.

## Objetivo do projeto

Demonstrar conhecimentos de:

- Desenvolvimento Salesforce;
- Apex e processamento assíncrono;
- Integração entre Salesforce e Python;
- Organização de projetos;
- Testes automatizados;
- Documentação técnica.
