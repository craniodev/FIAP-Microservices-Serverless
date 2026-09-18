# 05 - Atividade Final: Central de Feedbacks e Reclamações Serverless

**Antes de começar, execute os passos abaixo para configurar o ambiente caso não tenha feito isso ainda na aula de HOJE: [Preparando Credenciais](../01-create-codespaces/Inicio-de-aula.md)**

Os comandos de terminal deste trabalho rodam no terminal do IDE criado pelo Codespaces — o mesmo ambiente usado nos laboratórios anteriores do módulo.

> [!WARNING]
> **Pré-requisitos obrigatórios antes de começar:**
>
> - [ ] Credenciais AWS do Academy atualizadas — ver [Preparando Credenciais](../01-create-codespaces/Inicio-de-aula.md)
> - [ ] Serverless Framework disponível no terminal — valide com `sls --version`
> - [ ] AWS CLI e `jq` disponíveis — valide com `aws --version` e `jq --version`
> - [ ] Python 3 disponível — valide com `python3 --version`
> - [ ] Laboratórios de Lambda (`02-Lambda`), API Gateway (`03-API-Gateway`) e SQS (`04-SQS`) já concluídos — esta atividade combina os quatro serviços vistos até aqui
>
> **Valide rapidamente:**
>
> ```bash
> aws sts get-caller-identity
> ```
>
> Se retornar o JSON com seu `Account` e `Arn`, você está pronto. Tempo estimado: execução guiada **~2h** (provisionamento + duas funções Lambda + API Gateway + testes) mais o tempo que você levar para escrever a lógica das duas Lambdas por conta própria — **total estimado: 3h-4h**.

**Segunda-feira, 9h, período de Black Friday.**
Você é engenheira de backend na **Zelo Compras**, um e-commerce de médio porte. Aline Ferraz, Head de Atendimento ao Cliente, abre a reunião direto ao ponto:

> *— "Nossa fila de feedbacks e reclamações virou uma planilha que ninguém atualiza a tempo. Preciso de uma API que receba isso automaticamente, filtre qualquer coisa mal formatada, guarde tudo de forma rastreável e avise o time no instante em que cair uma reclamação nova. Isso não pode depender de alguém copiar e colar."*

Esta é a atividade avaliativa final da disciplina: você vai construir, de ponta a ponta, o pipeline serverless que resolve o problema da Aline.

![](img/Atividade-final-autoglass.drawio.png)

## Principais pontos de aprendizagem

- desenhar um pipeline serverless assíncrono com API Gateway, Lambda, SQS e DynamoDB
- validar o corpo de uma requisição com JSON Schema diretamente no API Gateway, sem código de validação na Lambda
- declarar duas funções Lambda (evento HTTP e evento SQS) no mesmo `serverless.yml`
- usar uma fila SQS como buffer de desacoplamento entre recebimento e processamento
- persistir dados no DynamoDB com chave composta (partition key + sort key)

## O que você terá ao final

Uma API REST que recebe feedbacks e reclamações, rejeita qualquer corpo fora do formato esperado, encaminha os dados válidos para uma fila SQS, processa essas mensagens numa segunda Lambda, grava o resultado no DynamoDB e dispara uma notificação para a equipe de atendimento.

> [!TIP]
> Sempre que encontrar um bloco **💡 Clique para entender**, ele é opcional: explica a mecânica por baixo do passo e traz link para a documentação oficial. Não é necessário abri-lo para concluir o passo.

## Mapa do trabalho

| Fase | Parte | Passos | Tempo |
|------|-------|--------|-------|
| 🧰 A · Provisionamento | [Parte 1 - Fila SQS e tabela DynamoDB](#parte-1---fila-sqs-e-tabela-dynamodb) | [1](#passo-1) · [2](#passo-2) · [3](#passo-3) | ~15 min |
| 🛠️ B · Desenvolvimento | [Parte 2 - Lambda de recebimento e API REST com JSON Schema](#parte-2---lambda-de-recebimento-e-api-rest-com-json-schema) | [4](#passo-4) … [10](#passo-10) | ~50 min |
| 🛠️ B · Desenvolvimento | [Parte 3 - Lambda de processamento, armazenamento e notificação](#parte-3---lambda-de-processamento-armazenamento-e-notificação) | [11](#passo-11) … [13](#passo-13) | ~30 min |
| 🛠️ B · Desenvolvimento | [Parte 4 - Teste ponta a ponta e evidências](#parte-4---teste-ponta-a-ponta-e-evidências) | [14](#passo-14) … [16](#passo-16) | ~20 min |
| 📦 C · Entrega | [Parte 5 - Empacotamento e envio](#parte-5---empacotamento-e-envio) | [17](#passo-17) … [19](#passo-19) | ~15 min |

> [!TIP]
> Se travou em algum passo, você pode pular direto: clique no número do passo na coluna **Passos** acima.

## Contexto

O diagrama acima resume o fluxo: o **API Gateway** recebe `POST /feedback`, valida o corpo com um modelo JSON Schema e aciona a primeira **Lambda**. Essa Lambda encaminha o payload validado para a **fila SQS** ("Fila de processamento"), que funciona como buffer entre o recebimento e o processamento — se o processamento atrasar, a mensagem espera na fila em vez de travar a resposta ao cliente. Uma segunda **Lambda**, disparada pelas mensagens da fila, grava o feedback no **DynamoDB** e notifica a equipe de atendimento.

O diagrama marca o DynamoDB como "(Opcional)", mas as dicas do enunciado (mais abaixo) fixam o nome exato da tabela — trate o armazenamento em DynamoDB como parte do entregável desta atividade, não como algo dispensável.

Nenhuma solicitação fora do formato POST com os campos combinados deve avançar no pipeline: tudo o que não passa na validação do API Gateway é rejeitado ali mesmo, sem invocar nenhuma Lambda.

---

## Parte 1 - Fila SQS e tabela DynamoDB

### Resultado esperado desta parte

A fila `FeedbacksReclamacoesQueue` e a tabela `FeedbacksReclamacoes` existem na sua conta, prontas para serem usadas pelas Lambdas das próximas partes.

---

<a id="passo-1"></a>

<dl>
<dt>

**1. Entre na pasta onde vai construir a solução**

</dt>
<dd>

No terminal do IDE criado pelo Codespaces:

```bash
cd /workspaces/FIAP-Microservices-Serverless/05-Atividade-final/Resposta/
```

Todo o código desta atividade (serverless.yml e as duas Lambdas) vai morar dentro de `Resposta/`.

</dd>
</dl>

---

<a id="passo-2"></a>

<dl>
<dt>

**2. Crie a fila SQS**

</dt>
<dd>

```bash
aws sqs create-queue --queue-name FeedbacksReclamacoesQueue
```

Guarde a URL da fila retornada pelo comando — você vai precisar dela na Parte 2. Se perder o valor, recupere com:

```bash
aws sqs get-queue-url --queue-name FeedbacksReclamacoesQueue | jq -r .QueueUrl
```

</dd>
</dl>

---

<a id="passo-3"></a>

<dl>
<dt>

**3. Crie a tabela DynamoDB**

</dt>
<dd>

```bash
aws dynamodb create-table \
   --table-name FeedbacksReclamacoes \
   --attribute-definitions AttributeName=id_cliente,AttributeType=S AttributeName=data_hora,AttributeType=S \
   --key-schema AttributeName=id_cliente,KeyType=HASH AttributeName=data_hora,KeyType=RANGE \
   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

`id_cliente` é a partition key e `data_hora` é a sort key — juntas formam a chave composta que identifica cada feedback.

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: por que console ou CLI aqui, e não Serverless Framework</b></summary>
<blockquote>

Nada te impede de declarar a fila e a tabela no mesmo `serverless.yml` das Lambdas. O enunciado permite as duas formas — CLI/console ou infraestrutura como código — e o critério de nome (`FeedbacksReclamacoesQueue` e `FeedbacksReclamacoes`) é o mesmo nos dois casos.

</blockquote>
</details>

### Checkpoint

- [ ] a fila `FeedbacksReclamacoesQueue` existe e você tem a URL dela salva
- [ ] a tabela `FeedbacksReclamacoes` existe com `id_cliente` (HASH) e `data_hora` (RANGE)

---

## Parte 2 - Lambda de recebimento e API REST com JSON Schema

### Resultado esperado desta parte

Um endpoint `POST` publicado no API Gateway, integrado a uma Lambda que envia os dados válidos para a fila SQS, com um modelo JSON Schema que rejeita qualquer corpo fora do formato combinado.

---

<a id="passo-4"></a>

<dl>
<dt>

**4. Inicialize o projeto serverless**

</dt>
<dd>

```bash
sls create --template "aws-python3"
```

Isso gera `serverless.yml` e `handler.py` na pasta atual. Você vai editar os dois nos próximos passos.

</dd>
</dl>

---

<a id="passo-5"></a>

<dl>
<dt>

**5. Escreva a lógica da função de recebimento e validação**

</dt>
<dd>

Esta é a Lambda do **Requisito 2** do enunciado (Processamento de Feedbacks/Reclamações): ela é invocada pelo API Gateway e precisa enviar os dados recebidos para a fila SQS criada no passo 2.

Escreva o `handler` (em `handler.py` ou em um arquivo próprio, ex.: `recebimento.py`) para que:

- leia o corpo da requisição a partir do evento recebido via integração de proxy do Lambda (o corpo chega em `event["body"]`, como texto)
- envie esse corpo para a fila SQS usando `boto3` (`send_message`, com a `QueueUrl` do passo 2 — recomenda-se ler essa URL de uma variável de ambiente, configurada no passo 7)
- devolva `statusCode: 200` com uma confirmação no `body`

Os exemplos de código deste README estão em Python, mas você pode usar qualquer linguagem nativamente suportada pelo AWS Lambda.

</dd>
</dl>

---

<a id="passo-6"></a>

<dl>
<dt>

**6. Declare a função no `serverless.yml` com um evento HTTP**

</dt>
<dd>

Adapte o padrão abaixo (do próprio guia do Serverless Framework) para o nome da sua função e o path que preferir:

```yaml
# Dentro do serverless.yml
functions:
  hello:
    handler: handler.hello
    events:
      - http:
          path: hello
          method: post
          cors: true
```

O método precisa ser `post` — o Requisito 1 do enunciado exige que a API aceite apenas `POST`.

</dd>
</dl>

---

<a id="passo-7"></a>

<dl>
<dt>

**7. Configure a variável de ambiente da fila e a role de execução**

</dt>
<dd>

No mesmo `serverless.yml`, adicione a URL da fila como variável de ambiente da função (usada pelo código do passo 5) e aponte a execução para a `LabRole`, que já existe na conta do Learner Lab:

```yaml
provider:
  iam:
    role: !Sub arn:aws:iam::${AWS::AccountId}:role/LabRole
  environment:
    QUEUE_URL: !Sub https://sqs.${AWS::Region}.amazonaws.com/${AWS::AccountId}/FeedbacksReclamacoesQueue
```

O `${AWS::AccountId}` e o `${AWS::Region}` são resolvidos pelo próprio CloudFormation no deploy, com os valores da conta e região em que você está. Você não precisa descobrir nem digitar o seu número de conta — o bloco acima é igual para todos.

A linha `iam.role` não é opcional: a conta do AWS Academy não permite criar roles, e sem ela o Serverless Framework tenta criar uma role própria para o serviço e o deploy falha.

</dd>
</dl>

<details>
<summary><b>⚠ Se der erro: "not authorized to perform iam:CreateRole"</b></summary>
<blockquote>

O erro significa que a linha `iam.role` acima não está no `serverless.yml`, ou está fora da seção `provider`. Sem ela o Serverless Framework tenta criar uma role nova para o serviço, e o Learner Lab bloqueia a criação de roles. Acrescente o `iam.role` apontando para a `LabRole` e rode o deploy de novo.

</blockquote>
</details>

---

<a id="passo-8"></a>

<dl>
<dt>

**8. Adicione o modelo de validação JSON Schema**

</dt>
<dd>

Este é o "valide as chamadas via json schema diretamente no gateway" do Requisito 1 — a validação acontece no API Gateway, antes de qualquer invocação da Lambda.

```yaml
# Dentro do serverless.yml
functions:
  create:
    handler: posts.create
    events:
      - http:
          path: posts/create
          method: post
          request:
            schemas:
              application/json: ${file(create_request.json)}
```

📚 Documentação oficial: [request-schema-validators](https://www.serverless.com/framework/docs/providers/aws/events/apigateway#request-schema-validators)

Crie o arquivo de schema (ex.: `create_request.json`) com os campos do Requisito 1 — `id_cliente`, `descricao`, `categoria` e `data_hora` — e:

- exija os quatro campos como obrigatórios
- restrinja `categoria` a exatamente três valores: `elogio`, `reclamação`, `sugestão`
- defina `"additionalProperties": false`, para que nenhum campo fora do schema seja aceito

</dd>
</dl>

---

<a id="passo-9"></a>

<dl>
<dt>

**9. Faça o deploy**

</dt>
<dd>

```bash
sls deploy --verbose
```

Este comando cria a Lambda, a API REST, o modelo de validação e a integração entre os dois em uma única execução. A URL de invocação aparece no final da saída.

</dd>
</dl>

---

<a id="passo-10"></a>

<dl>
<dt>

**10. Teste a rejeição de um corpo inválido**

</dt>
<dd>

```bash
curl -i -X POST "<sua-url-de-invocação>/hello" \
  -H "Content-Type: application/json" \
  -d '{"id_cliente": "1", "categoria": "elogio"}'
```

> Saída esperada:
> `400 Bad Request` — faltam os campos `descricao` e `data_hora`, que o schema do passo 8 exige.

Teste também um campo extra (ex.: acrescente `"admin": true` a um corpo válido) e confirme que também é rejeitado, por conta do `additionalProperties: false`.

</dd>
</dl>

### Checkpoint

- [ ] a função de recebimento está publicada e integrada ao endpoint `POST` via proxy
- [ ] um corpo sem os quatro campos obrigatórios retorna `400`
- [ ] um corpo com campo extra retorna `400`

---

## Parte 3 - Lambda de processamento, armazenamento e notificação

### Resultado esperado desta parte

Uma segunda Lambda, disparada pelas mensagens da fila SQS, grava os dados no DynamoDB e envia uma notificação para a equipe de atendimento.

---

<a id="passo-11"></a>

<dl>
<dt>

**11. Escreva a lógica da função de processamento e armazenamento**

</dt>
<dd>

Esta é a Lambda do **Requisito 3** do enunciado (Armazenamento e Notificação). Ela recebe as mensagens da fila (em `event["Records"]`, um registro por mensagem) e precisa gravar cada uma na tabela `FeedbacksReclamacoes`.

Você pode usar como base o exemplo abaixo — falta completar a leitura dos registros da fila e a chamada da função para cada mensagem recebida:

```python
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('FeedbacksReclamacoes')

def inserir_feedback(id_cliente, descricao, categoria, data_hora):
    response = table.put_item(
        Item={
            'id_cliente': id_cliente,
            'descricao': descricao,
            'categoria': categoria,
            'data_hora': data_hora
        }
    )
    return response
```

Depois de gravar no DynamoDB, envie a notificação para a equipe de atendimento. O enunciado não exige um serviço específico — um e-mail via Amazon SES, uma publicação em um tópico SNS ou qualquer mecanismo equivalente atende ao requisito, desde que a notificação de fato saia.

</dd>
</dl>

---

<a id="passo-12"></a>

<dl>
<dt>

**12. Declare a segunda função no `serverless.yml` com um evento SQS**

</dt>
<dd>

Pegue o ARN da fila (o evento SQS do Serverless Framework precisa do ARN, não da URL):

```bash
queueUrl=$(aws sqs get-queue-url --queue-name FeedbacksReclamacoesQueue | jq -r .QueueUrl)
aws sqs get-queue-attributes --queue-url $queueUrl --attribute-names QueueArn | jq -r .Attributes.QueueArn
```

E declare a função apontando para esse ARN:

```yaml
functions:
  processar:
    handler: processamento.handler
    events:
      - sqs:
          arn: <arn-da-fila-copiado-acima>
```

Garanta que a role usada por esta função (a mesma `LabRole` do passo 7, se foi esse o caminho escolhido) tem permissão para `dynamodb:PutItem` na tabela `FeedbacksReclamacoes`.

</dd>
</dl>

---

<a id="passo-13"></a>

<dl>
<dt>

**13. Faça o deploy novamente**

</dt>
<dd>

```bash
sls deploy --verbose
```

Este deploy atualiza a stack existente, acrescentando a segunda função e o gatilho da fila.

</dd>
</dl>

### Checkpoint

- [ ] a segunda função existe e está associada ao evento SQS da fila `FeedbacksReclamacoesQueue`
- [ ] a função tem permissão para gravar na tabela `FeedbacksReclamacoes`
- [ ] a notificação para a equipe de atendimento está implementada

---

## Parte 4 - Teste ponta a ponta e evidências

### Resultado esperado desta parte

Os três exemplos de chamada do enunciado passam pelo pipeline completo — API Gateway, Lambda de recebimento, SQS, Lambda de processamento e DynamoDB — e você tem os dois prints exigidos na entrega.

---

<a id="passo-14"></a>

<dl>
<dt>

**14. Envie os três exemplos de chamada da API**

</dt>
<dd>

```bash
curl -i -X POST "<sua-url-de-invocação>/hello" \
  -H "Content-Type: application/json" \
  -d '{
    "id_cliente": "12345",
    "descricao": "O produto chegou com defeito e não funciona corretamente.",
    "categoria": "reclamação",
    "data_hora": "2024-07-29T14:48:00Z"
}'
```

```bash
curl -i -X POST "<sua-url-de-invocação>/hello" \
  -H "Content-Type: application/json" \
  -d '{
    "id_cliente": "67890",
    "descricao": "Gostei muito do atendimento rápido e eficiente!",
    "categoria": "elogio",
    "data_hora": "2024-07-29T15:00:00Z"
}'
```

```bash
curl -i -X POST "<sua-url-de-invocação>/hello" \
  -H "Content-Type: application/json" \
  -d '{
    "id_cliente": "54321",
    "descricao": "Seria ótimo se vocês pudessem oferecer mais opções de cores para este produto.",
    "categoria": "sugestão",
    "data_hora": "2024-07-29T16:30:00Z"
}'
```

Cada chamada deve retornar `200`. Dê alguns segundos para a Lambda de processamento consumir a fila antes do próximo passo.

</dd>
</dl>

---

<a id="passo-15"></a>

<dl>
<dt>

**15. Capture o print do DynamoDB**

</dt>
<dd>

Abra o [console do DynamoDB](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#item-explorer?table=FeedbacksReclamacoes), explore os itens da tabela `FeedbacksReclamacoes` e confirme os três feedbacks inseridos.

> 📸 **Print obrigatório** — salve como `prints/01-dynamodb.png`. Capture a tela com os três itens visíveis na tabela.

</dd>
</dl>

---

<a id="passo-16"></a>

<dl>
<dt>

**16. Capture o print da fila SQS**

</dt>
<dd>

Abra o [console do SQS](https://us-east-1.console.aws.amazon.com/sqs/v3/home?region=us-east-1#/queues), selecione `FeedbacksReclamacoesQueue` e vá até a aba de monitoramento.

> 📸 **Print obrigatório** — salve como `prints/02-sqs.png`. Capture a tela mostrando as mensagens processadas pela fila.

</dd>
</dl>

### Checkpoint

- [ ] os três exemplos de chamada retornaram `200` e os três itens aparecem no DynamoDB
- [ ] `prints/01-dynamodb.png` e `prints/02-sqs.png` estão salvos

---

## Parte 5 - Empacotamento e envio

### Resultado esperado desta parte

Um zip com o `serverless.yml`, os arquivos de código das duas Lambdas e os dois prints, pronto para subir no portal da FIAP.

---

<a id="passo-17"></a>

<dl>
<dt>

**17. Monte a pasta de entrega**

</dt>
<dd>

```bash
mkdir -p entrega/prints
cp serverless.yml entrega/
cp *.py entrega/
cp prints/01-dynamodb.png prints/02-sqs.png entrega/prints/
```

Confirme o conteúdo:

```bash
tree entrega
```

```
entrega
├── serverless.yml
├── handler.py
├── recebimento.py
├── processamento.py
└── prints
    ├── 01-dynamodb.png
    └── 02-sqs.png
```

(os nomes exatos dos `.py` variam conforme como você organizou o código nos passos 5 e 11 — o que importa é que todo o código das duas Lambdas esteja na pasta.)

</dd>
</dl>

---

<a id="passo-18"></a>

<dl>
<dt>

**18. Gere o zip**

</dt>
<dd>

```bash
cd entrega
zip -r ../atividade-final.zip .
cd ..
```

</dd>
</dl>

---

<a id="passo-19"></a>

<dl>
<dt>

**19. Envie o zip no portal da FIAP**

</dt>
<dd>

Suba `atividade-final.zip` no portal da FIAP, na atividade correspondente.

</dd>
</dl>

### Checkpoint

- [ ] `atividade-final.zip` contém `serverless.yml`, o código das duas Lambdas e os dois prints
- [ ] o zip foi enviado no portal da FIAP

---

## Conclusão

Se você chegou até aqui, o pipeline está completo: uma API valida o formato do feedback antes de qualquer código rodar, uma fila absorve o pico de chamadas sem travar a resposta ao cliente, e uma segunda Lambda garante que tudo vira registro rastreável no DynamoDB com notificação para o time.

**Mensagem para a Aline**: a planilha manual não é mais o único caminho — todo feedback que chega pela API é validado, filtrado e cai automaticamente na mesa da equipe de atendimento, sem depender de alguém copiar e colar.

<details>
<summary><b>💡 Glossário rápido — termos que aparecem neste trabalho</b></summary>
<blockquote>

| Termo | O que é |
|-------|---------|
| **Integração de proxy do Lambda** | Modo de integração em que o API Gateway encaminha o request HTTP inteiro para a Lambda em um único evento, e espera de volta `statusCode`/`body`. |
| **Model / JSON Schema** | Esquema associado a um `contentType`, usado pelo API Gateway para descrever e validar o formato esperado do corpo da requisição. |
| **`additionalProperties: false`** | Regra do JSON Schema que rejeita qualquer campo não descrito explicitamente no schema. |
| **Fila SQS (Standard Queue)** | Serviço de mensageria que desacopla quem produz uma mensagem de quem a processa, funcionando como buffer entre as duas Lambdas. |
| **Event source mapping** | Associação entre uma fila SQS e uma Lambda, que faz a AWS invocar a função automaticamente a cada lote de mensagens disponível. |
| **Partition key / Sort key** | Par de atributos que forma a chave composta de um item no DynamoDB — aqui, `id_cliente` (partition) e `data_hora` (sort). |
| **`serverless.yml`** | Arquivo que declara funções Lambda e seus eventos (HTTP, SQS) como infraestrutura como código, usado pelo Serverless Framework. |

</blockquote>
</details>

<details>
<summary><b>💡 Como pedir ajuda se travou</b></summary>
<blockquote>

Antes de pedir ajuda, tenha em mãos:

1. **Em que passo você está** (ex.: "passo 12, declarando o evento SQS")
2. **O comando exato que rodou**
3. **A mensagem de erro completa** (copie do terminal, não resuma)
4. **O que você já tentou**

Canais, em ordem de prioridade: sinalize em sala para o professor → grupo da turma → monitoria.

</blockquote>
</details>
</content>
