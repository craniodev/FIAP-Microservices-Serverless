# Resultados dos testes de infraestrutura offline

Validação de infraestrutura/dependências e dos artefatos de código que os READMEs
mandam o aluno criar, **sem credenciais AWS** (não há credenciais AWS configuradas
nesta máquina — `aws sts get-caller-identity` falha com `NoCredentials`; deploy real
na AWS **não foi e não pode ser testado** neste ambiente).

Reproduza com `tests/run-all.sh`.

## 1. Imagem de teste (`.devcontainer/Dockerfile.test`)

Build real via `docker build`, a partir de `mcr.microsoft.com/devcontainers/base:ubuntu`,
reproduzindo as mesmas dependências e versões de `.devcontainer/devcontainer.json` e
`.devcontainer/script.sh` (Python 3, AWS CLI, Terraform, Node LTS, `serverless@3.39.0`).
Build passou sem erros. Versões reais dentro do container:

```
Framework Core: 3.39.0        # sls --version — mesma versão pinada em script.sh
Plugin: 7.2.3
SDK: 4.5.1

aws-cli/2.36.49 Python/3.14.6 Linux/6.12.76-linuxkit exe/aarch64.ubuntu.26

Terraform v1.9.8
on linux_arm64

Python 3.14.4

v24.21.0                       # node -v
11.19.0                        # npm -v
```

Terraform acusa que há versão mais nova disponível (1.16.3) — não é bug, é só aviso;
mantive 1.9.8 fixada no Dockerfile por estabilidade, igual seria com a feature `terraform:1`
sem pin de versão do devcontainer original.

## 2. Validação offline dos labs (PASS/FAIL)

Como os labs de `02-Lambda` e `04-SQS/01,03` colocam o conteúdo real do `serverless.yml`
e do `handler.py` **dentro de imagens PNG** (não em texto no README), esse conteúdo não
pode ser extraído/validado automaticamente — só o scaffold (`sls create`) e o que está em
texto puro foi testado. Já `03-API-Gateway/02-Validacao-Autenticacao` e `05-Atividade-final`
têm código real em texto e foram validados por completo.

| Lab | Artefato | Check | Resultado |
|---|---|---|---|
| 02-Lambda/01-Intro | scaffold `sls create --template aws-python3` | `sls create` | PASS |
| 02-Lambda/01-Intro | `serverless.yml` default gerado | `sls print` (resolve offline) | PASS |
| 02-Lambda/01-Intro | `serverless.yml` default gerado | `sls package` (empacota offline) | PASS |
| 02-Lambda/01-Intro | conteúdo real do yml/handler (passo 4, 8) | — | **NÃO TESTÁVEL** (só existe como imagem `yml1.png`) |
| 02-Lambda/02-Layers | `requirements.txt` com `boto3` | `pip3 install -r requirements.txt -t layer` | PASS (boto3 instalado em `layer/`) |
| 02-Lambda/02-Layers | conteúdo real do yml/handler (passo 4, 9) | — | **NÃO TESTÁVEL** (imagens `topoarquivopython.png`, `yamllayers.png`) |
| 03-API-Gateway/01-Primeira-API | bodies de teste JSON do passo 8/18 | `json.load` | PASS |
| 03-API-Gateway/01-Primeira-API | fluxo (100% console AWS, sem código) | — | não aplicável — nada para validar offline além do JSON |
| 03-API-Gateway/02-Validacao-Autenticacao | `handler.py` (passo 4) | `py_compile` | PASS |
| 03-API-Gateway/02-Validacao-Autenticacao | JSON Schema `UserCreateRequest` (passo 18) | `json.load` | PASS |
| 03-API-Gateway/02-Validacao-Autenticacao | JSON Schema `UserCreateRequest` | validação semântica com `jsonschema` contra body válido | PASS (aceita) |
| 03-API-Gateway/02-Validacao-Autenticacao | JSON Schema `UserCreateRequest` | validação semântica contra body sem `age` | PASS (rejeita corretamente — campo obrigatório funciona) |
| 03-API-Gateway/02-Validacao-Autenticacao | corpo de erro de validação (passo 28) | `json.load` | PASS |
| 04-SQS/01-Standard-Queue | `put.py` / `sqsHandler.py` (já existentes no repo) | `py_compile` | PASS |
| 04-SQS/01-Standard-Queue | conteúdo real do `serverless.yml`/`handler.py` (passo 4, 5) | — | **NÃO TESTÁVEL** (imagens `lambda-01.png`, `lambda-02.png`) |
| 04-SQS/02-DLQ | `put.py` / `consumer.py` / `sqsHandler.py` (já existentes no repo) | `py_compile` | PASS |
| 04-SQS/02-DLQ | script de purge das filas (passo 6) | `bash -n` | PASS |
| 04-SQS/03-Lambda | `put.py` / `sqsHandler.py` (já existentes no repo) | `py_compile` | PASS |
| 04-SQS/03-Lambda | comando de obter ARN da fila (passo 5) | `bash -n` | PASS |
| 04-SQS/03-Lambda | conteúdo real do `serverless.yml`/`handler.py` (passo 3, 5) | — | **NÃO TESTÁVEL** (imagens `lambda-01.png`, `lambda-02.png`) |
| 05-Atividade-final | trecho `serverless.yml` (http event) | `yaml.safe_load` | PASS |
| 05-Atividade-final | trecho `serverless.yml` (json schema request) | `yaml.safe_load` | PASS |
| 05-Atividade-final | função `inserir_feedback` (DynamoDB) | `py_compile` | PASS |
| 05-Atividade-final | 3 exemplos de payload da API | `json.load` | PASS |
| 05-Atividade-final | comandos `aws sqs create-queue` / `aws dynamodb create-table` | `bash -n` | PASS |
| **Deploy real na AWS (qualquer lab)** | — | `sls deploy` / `terraform apply` contra conta real | **NÃO TESTADO — sem credenciais AWS nesta máquina** |

**Resumo: 28/28 checks executáveis passaram. Nenhum bug de sintaxe/estrutura encontrado
nos artefatos testáveis.** As lacunas são só onde o README não expõe o código em texto
(está em screenshot), o que é uma limitação do formato do lab, não um bug.

## 3. Custo para o aluno (P3)

Verificado com grep nos 8 READMEs (Lambda, API Gateway x2, SQS x3, Atividade final)
por menções a cadastro/cartão/trial/token/API key/serviço pago de terceiro:

- **`03-API-Gateway/01-Primeira-API`** e **`03-API-Gateway/02-Validacao-Autenticacao`**
  mandam o aluno abrir conta no **Postman** (`https://web.postman.co/`) — cadastro
  gratuito, sem cartão, plano free cobre o uso do lab (poucas chamadas manuais).
  Não é custo, mas é fricção/cadastro fora do AWS Academy. **Recomendação:** deixar
  explícito no README que a conta Postman é gratuita e opcional (dá pra testar batendo
  direto na URL da API com `curl` também), para não gerar dúvida de "vou precisar pagar
  algo?".
- Nenhum outro lab (Lambda, SQS, Atividade final) exige cadastro, cartão, API key de
  terceiro ou tier pago fora do AWS Academy Learner Lab.

## 4. O que NÃO foi possível testar

- **Deploy real na AWS** (`sls deploy`, criação de fila/tabela/API via console) — esta
  máquina não tem credenciais AWS (`aws sts get-caller-identity` → `NoCredentials`).
  Não simulei nem inventei resultado de deploy.
- **Conteúdo exato do `serverless.yml`/`handler.py`** nos passos que só existem como
  print de tela (`02-Lambda/01-Intro`, `02-Lambda/02-Layers`, `04-SQS/01-Standard-Queue`,
  `04-SQS/03-Lambda`) — não há texto para extrair. O que dava pra testar sem essa
  informação (scaffold do `sls create`, `requirements.txt`, scripts shell) foi testado.
- Passos 100% console AWS (`03-API-Gateway/01-Primeira-API`, boa parte do
  `03-API-Gateway/02-Validacao-Autenticacao`, criação de filas/DLQ via console) não têm
  "sintaxe" pra validar — só a UI da AWS confirma, e isso exige deploy real.

## 5. Achados fora do fluxo de lab (não alterados — fora do meu escopo de arquivo)

Encontrados durante a inspeção, **não corrigidos** porque são `.py` fora do fluxo
testado pelos READMEs (nenhum README referencia esses arquivos) e a alteração de
`README.md` é de outro agente:

- `04-SQS/put_demo.py` tem uma URL de fila SQS **hardcoded com um Account ID real**
  (`https://sqs.us-east-1.amazonaws.com/867061838226/demoqueue`), diferente do
  placeholder `<url da sua fila>` usado nos demais `put.py`. Parece resíduo de teste do
  professor. Recomendo remover o arquivo do repo ou trocar pelo placeholder — não expõe
  credencial, mas expõe um Account ID real sem necessidade.
- `04-SQS/consumer.py` (arquivo solto na raiz de `04-SQS/`, não referenciado por nenhum
  README — o `consumer.py` usado no lab é `04-SQS/02-DLQ/consumer.py`, que é diferente e
  está correto) tem um bug real: dentro do loop `for msg in response['Messages']` chama
  `sqs.deleteMessage(mensagens)` passando a **lista** `mensagens` para um método que
  espera um único `receiptHandle` (string) — isso quebraria em runtime com erro do
  boto3/SQS (parâmetro `ReceiptHandle` inválido). Como não é usado por nenhum passo de
  README, não bloqueia nenhum aluno hoje, mas se for reaproveitado como exemplo, tem que
  ser corrigido (ou usar `sqs.deleteBatch(mensagens)` já existente na classe, ou chamar
  `deleteMessage(msg['ReceiptHandle'])` por mensagem). Recomendo remover ou corrigir junto
  da limpeza dos arquivos soltos de `04-SQS/` (`consumer.py`, `put.py`, `put_demo.py`,
  `sqsHandler.py`, `env.py`, `requirements.txt` na raiz — todos parecem resíduo de
  demonstração do professor, duplicados dos que já existem dentro de
  `01-Standard-Queue/`, `02-DLQ/`, `03-Lambda/`).
