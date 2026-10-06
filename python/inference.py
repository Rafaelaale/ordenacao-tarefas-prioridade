from datetime import date
from typing import List, Optional

from fastapi import FastAPI
from pydantic import BaseModel


app = FastAPI(
    title="API de Ordenação de Tarefas",
    version="1.0.0"
)


class Tarefa(BaseModel):
    id: str
    status: str = "Not Started"
    due_date: Optional[date] = None
    priority: str = "Normal"
    customer_value: float = 0
    task_type: str = ""
    urgency: int = 0


class PedidoOrdenacao(BaseModel):
    tasks: List[Tarefa]


class RespostaOrdenacao(BaseModel):
    task_ids: List[str]


def calcular_pontuacao(tarefa: Tarefa) -> float:
    if tarefa.status.lower() == "completed":
        return -1

    pontuacao = 0

    if tarefa.due_date:
        hoje = date.today()

        if tarefa.due_date < hoje:
            pontuacao += 40
        elif tarefa.due_date == hoje:
            pontuacao += 30

    prioridade = tarefa.priority.lower()

    if prioridade == "high":
        pontuacao += 30
    elif prioridade == "normal":
        pontuacao += 15
    elif prioridade == "low":
        pontuacao += 5

    pontuacao += tarefa.customer_value
    pontuacao += tarefa.urgency

    return pontuacao


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/ordenar", response_model=RespostaOrdenacao)
def ordenar_tarefas(pedido: PedidoOrdenacao):
    tarefas_pendentes = [
        tarefa
        for tarefa in pedido.tasks
        if tarefa.status.lower() != "completed"
    ]

    tarefas_ordenadas = sorted(
        tarefas_pendentes,
        key=lambda tarefa: (
            -calcular_pontuacao(tarefa),
            tarefa.id
        )
    )

    return RespostaOrdenacao(
        task_ids=[tarefa.id for tarefa in tarefas_ordenadas]
    )
