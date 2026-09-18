# Arquitetura de Microservices e Serverless

Repositório oficial dos laboratórios práticos da disciplina **Arquitetura de Microservices e Serverless** do MBA da FIAP. Aqui você encontrará todos os exercícios guiados, scripts de apoio e instruções para evoluir de uma função Lambda isolada até uma arquitetura orientada a eventos, integrando API Gateway e SQS.

---

## Visão geral

Os laboratórios foram desenhados para serem executados em um ambiente padronizado (GitHub Codespaces + AWS Academy), garantindo que todos os alunos tenham a mesma experiência, sem precisar instalar nada localmente.

Você irá percorrer um caminho que evolui do bloco de computação serverless até a composição de uma arquitetura orientada a eventos, fechando com uma atividade final que consolida tudo:

1. **Preparação do ambiente** — configuração do Codespaces, AWS Academy e credenciais.
2. **AWS Lambda** — primeira função serverless e uso de Layers para compartilhar dependências entre funções.
3. **Amazon API Gateway** — exposição de uma API HTTP com backend Lambda, validação de payload e autenticação.
4. **Amazon SQS** — filas standard, Dead Letter Queue (DLQ) e consumo assíncrono via Lambda.
5. **Atividade final** — projeto que integra os serviços vistos em aula para resolver um problema de negócio real.

---

## Pré-requisitos

Antes de iniciar qualquer laboratório, você precisa de:

- uma conta no [GitHub](https://github.com) (para fork do repositório e Codespaces)
- uma conta ativa no [AWS Academy](https://www.awsacademy.com/LMS_Login) com a turma `AWS Academy Learner Lab`
- acesso ao email institucional da FIAP (`rm<SEU RM>@fiap.com.br`)

> [!IMPORTANT]
> **SEMPRE DESLIGUE** o Codespaces ao final da aula para não consumir créditos desnecessariamente. Acesse [github.com/codespaces](https://github.com/codespaces), clique nos três pontinhos ao lado do ambiente e selecione `Stop Codespace`.

---

## Como usar este repositório

### 1. Faça o fork

Clique em `Fork` no canto superior direito da página do repositório no GitHub e copie-o para sua conta. Mantenha a opção `Copy the master branch only` **desmarcada** para ter acesso a todas as branches.

### 2. Crie o Codespaces

A partir do seu fork, crie um Codespace usando a configuração `FIAP Lab` na região `US East` com máquina `2-core`. O ambiente já vem com todas as dependências necessárias (AWS CLI, Terraform, Python, Node LTS e o `serverless` framework).

### 3. Configure as credenciais AWS

A cada sessão do AWS Academy, copie as credenciais em `AWS Details → AWS CLI` para o arquivo `~/.aws/credentials` do Codespaces. Valide com:

```bash
aws s3 ls
```

### 4. Siga os laboratórios na ordem

Comece pelo setup e avance sequencialmente. Cada laboratório tem seu próprio `README.md` com instruções passo a passo, explicações contextuais (blocos `💡 Clique para entender`) e prints de referência.

> [!TIP]
> O passo a passo completo de configuração está em [01-create-codespaces/README.md](01-create-codespaces/README.md). Guarde também o [Inicio-de-aula.md](01-create-codespaces/Inicio-de-aula.md) — você vai reutilizá-lo em toda aula ao atualizar as credenciais.

---

## Demos disponíveis

| # | Laboratório | Descrição | Link |
|---|-------------|-----------|------|
| 01 | **Setup e configuração do ambiente** | Fork do repositório, criação do Codespaces, acesso à conta AWS Academy e configuração inicial de credenciais. | [01-create-codespaces](01-create-codespaces/README.md) |
| 02.1 | **Lambda — Introdução** | Criação da primeira função AWS Lambda a partir do Codespaces, deploy via `serverless` e primeiras invocações. | [02-Lambda/01-Intro](02-Lambda/01-Intro/README.md) |
| 02.2 | **Lambda Layers** | Empacotamento de dependências compartilhadas em uma Layer e reuso entre múltiplas funções Lambda. | [02-Lambda/02-Layers](02-Lambda/02-Layers/README.md) |
| 03.1 | **API Gateway — Primeira API** | Criação de uma API HTTP no Amazon API Gateway com integração a uma função Lambda de backend. | [03-API-Gateway/01-Primeira-API](03-API-Gateway/01-Primeira-API/README.md) |
| 03.2 | **API Gateway — Validação e Autenticação** | Validação de payload de requisição e configuração de autenticação na API criada no lab anterior. | [03-API-Gateway/02-Validacao-Autenticacao](03-API-Gateway/02-Validacao-Autenticacao/README.md) |
| 04.1 | **SQS — Standard Queue** | Criação de uma fila SQS padrão, envio de mensagens e leitura via script Python. | [04-SQS/01-Standard-Queue](04-SQS/01-Standard-Queue/README.md) |
| 04.2 | **SQS — Dead Letter Queue** | Configuração de uma DLQ para tratar mensagens que falham repetidamente no consumo. | [04-SQS/02-DLQ](04-SQS/02-DLQ/README.md) |
| 04.3 | **SQS — Consumo via Lambda** | Integração da fila SQS com uma função Lambda como consumidor assíncrono. | [04-SQS/03-Lambda](04-SQS/03-Lambda/README.md) |
| 05 | **Atividade final** | Projeto que integra Lambda, API Gateway e SQS para resolver um problema de negócio de atendimento e gestão de feedbacks de e-commerce. | [05-Atividade-final](05-Atividade-final/README.md) |

---

## Estrutura do repositório

```
.
├── 01-create-codespaces/                        # Setup do ambiente (Codespaces, AWS Academy, credenciais)
│   └── Inicio-de-aula.md                        #   checklist reutilizável para reconfigurar credenciais a cada aula
├── 02-Lambda/
│   ├── 01-Intro/                                # Lab 02.1 — primeira função Lambda
│   └── 02-Layers/                               # Lab 02.2 — Lambda Layers
├── 03-API-Gateway/
│   ├── 01-Primeira-API/                         # Lab 03.1 — API HTTP com backend Lambda
│   └── 02-Validacao-Autenticacao/               # Lab 03.2 — validação de payload e autenticação
├── 04-SQS/
│   ├── 01-Standard-Queue/                       # Lab 04.1 — fila SQS padrão
│   ├── 02-DLQ/                                  # Lab 04.2 — Dead Letter Queue
│   └── 03-Lambda/                               # Lab 04.3 — consumo da fila via Lambda
├── 05-Atividade-final/                          # Atividade final — integração dos serviços
│   ├── Instrucoes/                              #   material de apoio do problema de negócio
│   └── Resposta/                                #   pasta para entrega da resolução
└── .devcontainer/                               # Configuração do GitHub Codespaces (devcontainer.json + script.sh)
```

---

## Fluxo recomendado

```
01 Setup
   │
   ▼
02.1 Lambda intro ──▶ 02.2 Lambda Layers
   │
   ▼
03.1 Primeira API ──▶ 03.2 Validação e autenticação
   │
   ▼
04.1 Standard Queue ──▶ 04.2 DLQ ──▶ 04.3 Consumo via Lambda
   │
   ▼
05 Atividade final
```

Cada laboratório assume que os anteriores foram concluídos. Em especial:

- Os labs de **API Gateway (03.x)** dependem da função Lambda criada no bloco 02 como backend da API.
- Os labs de **SQS (04.x)** reaproveitam os conceitos de função Lambda do bloco 02 para consumir mensagens da fila.
- A **Atividade final (05)** integra Lambda, API Gateway e SQS vistos nos blocos anteriores para resolver o problema de negócio proposto.

---

## Dicas gerais

- **Blocos `💡 Clique para entender`**: sempre que encontrar nos READMEs, abra — eles trazem o contexto técnico e a motivação pedagógica de cada comando.
- **Deploy e limpeza com o `serverless`**: cada lab que usa o framework é implantado com `serverless deploy` e, ao final da aula, deve ser removido com `serverless remove` para não deixar recursos (Lambda, API Gateway, filas) provisionados sem necessidade.
- **Credenciais expiradas?** Cada sessão do AWS Academy dura 4 horas. Basta iniciar uma nova sessão no Learner Lab e recopiar as credenciais para `~/.aws/credentials`.
- **Terminou o laboratório?** Confirme que rodou `serverless remove` (ou removeu manualmente os recursos criados) antes de desligar o Codespaces — recurso provisionado e esquecido consome o crédito do AWS Academy mesmo sem uso.

---

## Suporte

Caso encontre algum problema:

1. Releia atentamente o passo em que você está — os READMEs trazem os erros mais comuns sinalizados com `> [!IMPORTANT]` ou `> [!WARNING]`.
2. Valide os pré-requisitos listados no início de cada laboratório.
3. Consulte o professor ou monitores durante a aula.

### Contato

Ficou com alguma dúvida ou quer trocar uma ideia sobre os laboratórios?

- 📧 **Email:** [Rafael@rfbarbosa.com](mailto:Rafael@rfbarbosa.com)
- 💼 **LinkedIn:** [Rafael Barbosa](https://www.linkedin.com/in/rafael-barbosa-serverless/)

---

**Bons estudos!** 🎓
