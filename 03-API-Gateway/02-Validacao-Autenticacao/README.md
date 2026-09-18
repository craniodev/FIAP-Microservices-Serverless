# 03.2 - Validação e Autenticação no API Gateway

**Antes de começar, execute os passos abaixo para configurar o ambiente caso não tenha feito isso ainda na aula de HOJE: [Preparando Credenciais](../../01-create-codespaces/Inicio-de-aula.md)**

> Todos os passos deste laboratório são executados no **console da AWS** (Lambda e API Gateway) e no **Postman**. Não há comandos de terminal — mantenha as duas abas abertas lado a lado.

> [!WARNING]
> **Pré-requisitos obrigatórios antes de começar:**
>
> - [ ] Credenciais AWS do Academy atualizadas — ver [Preparando Credenciais](../../01-create-codespaces/Inicio-de-aula.md)
> - [ ] Acesso ao [console do Lambda](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions)
> - [ ] Acesso ao [console do API Gateway](https://us-east-1.console.aws.amazon.com/apigateway/main/apis?region=us-east-1)
> - [ ] Conta gratuita no [Postman](https://web.postman.co/) já criada
>
> **Valide rapidamente:**
>
> ```bash
> aws sts get-caller-identity
> ```
>
> Se retornar o JSON com seu `Account` e `Arn`, você está pronto. Tempo estimado: **90–120 min** (execução pura ~40 min de cliques no console + tempo para ler, testar no Postman e observar as respostas).

**Terça-feira, 14h.**
Você é engenheira de backend na **Vitalis Academia**, uma rede de academias que está expandindo via parceiros (apps de bem-estar, planos corporativos, marketplaces de assinatura). **Beatriz**, Head de Parcerias, te chama:

> *— "Fechamos com 3 parceiros para pré-cadastro de novos alunos direto pelos apps deles. Só que não posso deixar qualquer JSON malformado cair na nossa Lambda, e cada parceiro precisa ter a própria chave — se um deles decidir bombardear a API, não posso deixar afetar os outros dois."*

Você sabe que o [Amazon API Gateway](https://aws.amazon.com/pt/api-gateway/) resolve os dois problemas sem uma linha de código extra na Lambda: validação de corpo via [JSON Schema](https://json-schema.org/) e controle de acesso por [chave de API](https://docs.aws.amazon.com/pt_br/apigateway/latest/developerguide/api-gateway-setup-api-key-with-console.html). Vamos construir isso juntos.

![](img/rest-api-json-schema.png)

## Principais pontos de aprendizagem

- validar o corpo de uma requisição no API Gateway com JSON Schema, sem código na Lambda
- criar uma resposta de erro padronizada para falha de validação
- usar integração de proxy do Lambda (`AWS_PROXY`)
- criar e exigir chave de API (`x-api-key`) em um método
- criar um plano de uso com taxa, pico e cota, e associar chave + estágio

## O que você terá ao final

Uma API REST (`rest-api-with-validation`) que valida o corpo de `POST /user/create` contra um JSON Schema, responde com mensagem de erro clara quando o corpo é inválido, e só aceita chamadas de quem apresenta uma chave de API vinculada a um plano de uso. **Beatriz vai querer ver uma chamada sem chave sendo rejeitada e uma chamada com chave sendo aceita** — esse é o entregável simbólico do lab.

> [!TIP]
> Sempre que encontrar um bloco com o título **💡 Clique para entender**, abra esse trecho. Ele traz a mecânica por baixo do clique no console (a chamada de API real que a AWS faz) e links oficiais para aprofundamento.

## Mapa do lab

| Parte | O que você faz | Passos | Tempo |
|-------|----------------|--------|-------|
| [Parte 1](#parte-1---criando-a-função-lambda-de-backend) | Criando a função Lambda de backend | [1](#passo-1) · [2](#passo-2) · [3](#passo-3) · [4](#passo-4) | ~10 min |
| [Parte 2](#parte-2---criando-a-api-rest-e-os-recursos) | Criando a API REST e os recursos | [5](#passo-5) · [6](#passo-6) · [7](#passo-7) · [8](#passo-8) · [9](#passo-9) · [10](#passo-10) · [11](#passo-11) · [12](#passo-12) · [13](#passo-13) · [14](#passo-14) | ~15 min |
| [Parte 3](#parte-3---validando-o-corpo-da-requisição-com-json-schema) | Validando o corpo da requisição com JSON Schema | [15](#passo-15) · [16](#passo-16) · [17](#passo-17) · [18](#passo-18) · [19](#passo-19) · [20](#passo-20) · [21](#passo-21) · [22](#passo-22) · [23](#passo-23) · [24](#passo-24) · [25](#passo-25) · [26](#passo-26) · [27](#passo-27) · [28](#passo-28) | ~20 min |
| [Parte 4](#parte-4---implantando-a-api-e-testando-no-postman) | Implantando a API e testando no Postman | [29](#passo-29) · [30](#passo-30) · [31](#passo-31) · [32](#passo-32) · [33](#passo-33) · [34](#passo-34) · [35](#passo-35) · [36](#passo-36) · [37](#passo-37) · [38](#passo-38) · [39](#passo-39) | ~15 min |
| [Parte 5](#parte-5---protegendo-a-api-com-chave-de-api) | Protegendo a API com chave de API | [40](#passo-40) · [41](#passo-41) · [42](#passo-42) · [43](#passo-43) · [44](#passo-44) · [45](#passo-45) · [46](#passo-46) · [47](#passo-47) · [48](#passo-48) | ~10 min |
| [Parte 6](#parte-6---criando-o-plano-de-uso-e-validando-a-autenticação) | Criando o plano de uso e validando a autenticação | [49](#passo-49) · [50](#passo-50) · [51](#passo-51) · [52](#passo-52) · [53](#passo-53) · [54](#passo-54) · [55](#passo-55) · [56](#passo-56) · [57](#passo-57) · [58](#passo-58) · [59](#passo-59) · [60](#passo-60) · [61](#passo-61) | ~15 min |

> [!TIP]
> Se travou em algum passo, você pode pular direto: clique no número do passo na coluna **Passos** acima.

## Contexto

Numa arquitetura de microsserviços serverless, a Lambda deveria fazer só uma coisa: a regra de negócio. Validar formato de campo, checar tipo, ou decidir se um chamador tem permissão para bater na API são responsabilidades de borda — e o API Gateway resolve as duas **antes** do evento chegar na função:

- **Validação de corpo**: um `RequestValidator` associado a um `Model` (JSON Schema) rejeita requisições malformadas com `400 Bad Request` sem invocar a Lambda. Menos custo, menos código defensivo, menos superfície de erro.
- **Autenticação por chave de API**: uma `ApiKey` vinculada a um `UsagePlan` identifica quem está chamando e limita quanto cada parceiro pode chamar (`rate`, `burst`, `quota`) — sem exigir OAuth ou Cognito quando o cenário é "parceiro conhecido com chave fixa", como no caso da Vitalis.

Este laboratório constrói os dois mecanismos na mesma API, na ordem em que você normalmente resolveria esse problema: primeiro garante que o dado que entra é válido, depois garante que só quem tem permissão entra.

---

## Parte 1 - Criando a função Lambda de backend

### Resultado esperado desta parte

Ao final desta etapa, a função `rest-api-validation` existirá e devolverá o corpo recebido acrescido de um campo `Response`.

---

<a id="passo-1"></a>

<dl>
<dt>

**1. Acesse o console do Lambda e clique em "Criar função".**

</dt>
<dd>

Vá para o [console do Lambda](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions).

</dd>
</dl>

---

<a id="passo-2"></a>

<dl>
<dt>

**2. Preencha os campos da função e clique em "Criar função".**

</dt>
<dd>

- Nome da função: `rest-api-validation`
- Tempo de execução: `Python 3.12`
- Permissões: `Usar uma função existente`
- Função existente: `LabRole`

![](img/1.png)

</dd>
</dl>

---

<a id="passo-3"></a>

<dl>
<dt>

**3. Cole o código abaixo no editor da função.**

</dt>
<dd>

```python
import json

def lambda_handler(event, context):
    
    print(json.dumps(event))
    response = json.loads(event["body"])
    response["Response"]="Validated API"
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
```

![](img/2.png)

</dd>
</dl>

---

<a id="passo-4"></a>

<dl>
<dt>

**4. Clique em "Deploy" no lado esquerdo do IDE.**

</dt>
<dd>

Isso publica o código colado — sem esse clique, a Lambda continua com o código de exemplo padrão.

</dd>
</dl>

### Checkpoint

- a função `rest-api-validation` existe e usa `LabRole`
- o código foi colado e implantado (`Deploy`)

---

## Parte 2 - Criando a API REST e os recursos

### Resultado esperado desta parte

Ao final desta etapa, a API `rest-api-with-validation` terá o método `POST /user/create` integrado à Lambda por proxy.

---

<a id="passo-5"></a>

<dl>
<dt>

**5. Acesse o painel do API Gateway e clique em "Criar API".**

</dt>
<dd>

[Painel do API Gateway](https://us-east-1.console.aws.amazon.com/apigateway/main/apis?region=us-east-1), botão no canto superior direito.

</dd>
</dl>

---

<a id="passo-6"></a>

<dl>
<dt>

**6. Em "API REST", clique em "Compilar".**

</dt>
<dd>

![](img/3.png)

</dd>
</dl>

---

<a id="passo-7"></a>

<dl>
<dt>

**7. Preencha os campos da API e clique em "Criar API".**

</dt>
<dd>

- Nome da API: `rest-api-with-validation`
- Tipo de endpoint: `Regional`

![](img/4.png)

</dd>
</dl>

---

<a id="passo-8"></a>

<dl>
<dt>

**8. Clique em "Criar recurso" para criar o caminho de usuários.**

</dt>
<dd>

![](img/5.png)

</dd>
</dl>

---

<a id="passo-9"></a>

<dl>
<dt>

**9. Preencha o recurso e clique em "Criar recurso".**

</dt>
<dd>

- Nome do recurso: `user`
- Ativar CORS do API Gateway: selecionado

![](img/7.png)

</dd>
</dl>

---

<a id="passo-10"></a>

<dl>
<dt>

**10. Com o recurso `user` selecionado, clique novamente em "Criar recurso".**

</dt>
<dd>

![](img/6.png)

</dd>
</dl>

---

<a id="passo-11"></a>

<dl>
<dt>

**11. Preencha o subrecurso e clique em "Criar recurso".**

</dt>
<dd>

- Caminho do recurso: `create`
- Ativar CORS do API Gateway: selecionado

</dd>
</dl>

---

<a id="passo-12"></a>

<dl>
<dt>

**12. Com o recurso `create` selecionado, clique em "Criar Método".**

</dt>
<dd>

![](img/7-2.png)

</dd>
</dl>

---

<a id="passo-13"></a>

<dl>
<dt>

**13. Escolha "POST" na lista de métodos.**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-14"></a>

<dl>
<dt>

**14. Preencha a integração e clique em "Criar Método".**

</dt>
<dd>

- Tipo de Integração: `Função Lambda`
- Região do Lambda: `us-east-1`
- Função Lambda: `rest-api-validation`
- Usar a integração de proxy do Lambda: **selecionado**

![](img/9.png)
![](img/10.png)

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: integração de proxy do Lambda</b></summary>
<blockquote>

Com `Usar a integração de proxy do Lambda` marcado, o API Gateway configura o método como `AWS_PROXY`: ele encaminha o request HTTP inteiro (método, headers, query string, corpo, path params) num único objeto de evento para a Lambda, e espera de volta um objeto com `statusCode`, `headers` e `body` — exatamente o formato que o `lambda_handler` do passo 3 devolve.

A alternativa (integração customizada, sem proxy) exigiria mapear manualmente request e response templates em VTL para cada campo. Com proxy, isso é zero — é por isso que o código da Lambda lê `event["body"]` diretamente.

📚 Documentação oficial: [Configurar integrações de proxy do Lambda para o API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html) — detalha o formato exato do evento de entrada e da resposta esperada pela Lambda.

</blockquote>
</details>

### Checkpoint

- a API `rest-api-with-validation` existe
- o caminho `/user/create` existe com método `POST`
- o método está integrado à função `rest-api-validation` via proxy

---

## Parte 3 - Validando o corpo da requisição com JSON Schema

### Resultado esperado desta parte

Ao final desta etapa, o método `POST /user/create` rejeitará corpos inválidos com uma mensagem de erro clara, sem invocar a Lambda.

---

<a id="passo-15"></a>

<dl>
<dt>

**15. Na lateral esquerda, clique em "Modelos".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-16"></a>

<dl>
<dt>

**16. Clique em "Criar modelo".**

</dt>
<dd>

![](img/12.png)

</dd>
</dl>

---

<a id="passo-17"></a>

<dl>
<dt>

**17. Preencha os campos do modelo.**

</dt>
<dd>

- Nome do modelo: `UserCreateRequest`
- Tipo de conteúdo: `application/json`
- Esquema do modelo:

```json
{
    "title": "Root Schema",
    "type": "object",
    "required": [
        "name",
        "age",
        "dateofregistry"
    ],
    "additionalProperties": false,
    "properties": {
        "name": {
            "title": "The name Schema",
            "type": "string"
        },
        "age": {
            "title": "The age Schema",
            "minimum": 0,
            "maximum": 100,
            "type": "integer"
        },
        "dateofregistry": {
            "title": "The dateofregistry Schema",
            "pattern": "^\\d{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01])$",
            "type": "string"
        }
    }
}       
```

</dd>
</dl>

---

<a id="passo-18"></a>

<dl>
<dt>

**18. Clique em "Criar" para salvar o modelo.**

</dt>
<dd>

Esse modelo não permite nenhum campo além dos descritos (`additionalProperties: false`) e todos são obrigatórios. `age` só aceita inteiro entre 0 e 100, `dateofregistry` precisa bater com o formato `YYYY-mm-DD`, `name` precisa ser texto.

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: modelo de requisição (JSON Schema) no API Gateway</b></summary>
<blockquote>

Um `Model` do API Gateway é um JSON Schema (draft compatível) associado a um `contentType`. Ele fica guardado na definição da API (chamada de API real: `CreateModel`) e é referenciado pelo `RequestValidator` do passo 22 — o modelo por si só não valida nada, ele só descreve o formato esperado.

`additionalProperties: false` é o que impede um parceiro de mandar campos extras não previstos (ex.: um `"admin": true` escondido no corpo). O `pattern` de `dateofregistry` é uma regex aplicada pelo próprio validador do API Gateway, sem custo de invocação da Lambda.

📚 Documentação oficial: [Definir modelos de requisição e mapeamentos de dados para o API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/models-mappings.html) — explica a relação entre `Model`, `contentType` e o schema JSON.

</blockquote>
</details>

---

<a id="passo-19"></a>

<dl>
<dt>

**19. Na lateral esquerda, clique em "Recursos".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-20"></a>

<dl>
<dt>

**20. Clique no método `POST` abaixo do recurso `create`.**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-21"></a>

<dl>
<dt>

**21. Clique em "Solicitação de método" e em "Editar".**

</dt>
<dd>

![](img/13.png)

</dd>
</dl>

---

<a id="passo-22"></a>

<dl>
<dt>

**22. Em "Validador de solicitação", escolha "Validar corpo, parâmetros de string de consulta e cabeçalhos".**

</dt>
<dd>

![](img/14.png)

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: RequestValidator</b></summary>
<blockquote>

Essa opção cria (ou reaproveita) um `RequestValidator` com `validateRequestBody = true` e `validateRequestParameters = true`, associado ao método via `requestValidatorId`. É essa flag que faz o API Gateway checar o corpo contra o `Model` **antes** de decidir se invoca a integração — uma requisição que falha aqui nunca chega na Lambda, nem gera cobrança de invocação.

Existem três variantes de validador: só corpo, só parâmetros/cabeçalhos, ou os dois (a que usamos aqui). A escolha errada é uma causa comum de "por que meu JSON malformado ainda invoca a Lambda".

📚 Documentação oficial: [Habilitar validação de requisição no API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html) — descreve as três combinações de validador e como associá-las a um método.

</blockquote>
</details>

---

<a id="passo-23"></a>

<dl>
<dt>

**23. Clique em "Corpo de solicitação" e depois em "Adicionar modelo".**

</dt>
<dd>

![](img/15.png)

</dd>
</dl>

---

<a id="passo-24"></a>

<dl>
<dt>

**24. Preencha e clique em "Salvar".**

</dt>
<dd>

- Tipo de conteúdo: `application/json`
- Modelo: `UserCreateRequest`

![](img/16.png)

</dd>
</dl>

### Checkpoint

- o método `POST /user/create` tem um validador de corpo ativo
- o validador está associado ao modelo `UserCreateRequest` para `application/json`

---

<a id="passo-25"></a>

<dl>
<dt>

**25. Na lateral esquerda, clique em "Respostas do gateway".**

</dt>
<dd>

Para facilitar a vida de quem integra, vamos criar um padrão de mensagem de erro onde a causa apareça na resposta.

</dd>
</dl>

---

<a id="passo-26"></a>

<dl>
<dt>

**26. Selecione "Corpo de solicitação incorreto", clique em `application/json` e em "Editar".**

</dt>
<dd>

![](img/24.png)

</dd>
</dl>

---

<a id="passo-27"></a>

<dl>
<dt>

**27. Cole o JSON abaixo no "Corpo do modelo de resposta".**

</dt>
<dd>

```json
{"message": "$context.error.message", "error": "$context.error.validationErrorString"}
```

</dd>
</dl>

---

<a id="passo-28"></a>

<dl>
<dt>

**28. Clique em "Salvar alterações".**

</dt>
<dd>

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: GatewayResponse e variáveis de contexto</b></summary>
<blockquote>

`BAD_REQUEST_BODY` é um tipo de `GatewayResponse` pré-definido do API Gateway — dispara sempre que o `RequestValidator` rejeita o corpo, antes de qualquer integração. O template acima é [VTL (Velocity Template Language)](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html) que lê variáveis de contexto (`$context.error.message`, `$context.error.validationErrorString`) preenchidas pelo próprio validador — é aí que aparece, por exemplo, qual campo faltou ou qual regex não bateu.

Sem esse passo, o parceiro recebe só um `400` genérico sem corpo explicativo, e o time dele te manda mensagem perguntando o que está errado.

📚 Documentação oficial: [Tipos de resposta do gateway suportados pelo API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/supported-gateway-response-types.html) — lista todos os tipos de `GatewayResponse` e as variáveis de contexto disponíveis em cada um.

</blockquote>
</details>

---

## Parte 4 - Implantando a API e testando no Postman

### Resultado esperado desta parte

Ao final desta etapa, a API estará publicada no estágio `dev` e você terá confirmado, via Postman, que corpos válidos passam e corpos inválidos são rejeitados com a mensagem customizada.

---

<a id="passo-29"></a>

<dl>
<dt>

**29. Na lateral esquerda, clique em "Recursos".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-30"></a>

<dl>
<dt>

**30. Clique em "Implantar API".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-31"></a>

<dl>
<dt>

**31. Preencha a tela de implantação e clique em "Implantar".**

</dt>
<dd>

- Estágio de implantação: `[Novo estágio]`
- Nome do estágio: `dev`

![](img/18.png)

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: deploy e estágio no API Gateway</b></summary>
<blockquote>

Editar recursos/métodos no console muda só a **definição** da API. Nada disso vale para quem chama a API de fora até você rodar um `CreateDeployment` — que é o que o botão "Implantar" faz — apontando para um `Stage` (aqui, `dev`). Cada novo deploy no mesmo estágio sobrescreve a versão publicada; é por isso que toda mudança de configuração feita mais adiante no lab (exigir chave de API, por exemplo) também vai exigir um novo "Implantar API".

📚 Documentação oficial: [Implantar uma API REST no Amazon API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-deploy-api.html) — explica a relação entre deployment, estágio e a URL de invocação gerada.

</blockquote>
</details>

---

<a id="passo-32"></a>

<dl>
<dt>

**32. Exporte a coleção para o Postman.**

</dt>
<dd>

No estágio `dev` recém-criado, clique em "Ações do estágio" (canto superior direito), aba "Exportar":

- Tipo de especificação de API: `Swagger`
- Formato: `YAML`
- Extensões: `Exportar com extensões Postman`

![](img/19.png)

</dd>
</dl>

---

<a id="passo-33"></a>

<dl>
<dt>

**33. No Postman, clique em "Import" e em "Upload Files", selecionando o arquivo baixado.**

</dt>
<dd>

![](img/20.png)

</dd>
</dl>

---

<a id="passo-34"></a>

<dl>
<dt>

**34. Clique em "Import" para finalizar a importação.**

</dt>
<dd>

![](img/21.png)

</dd>
</dl>

---

<a id="passo-35"></a>

<dl>
<dt>

**35. Na lateral esquerda do Postman, clique em "Collections", expanda `rest-api-with-validation` e clique em `POST /user/create`.**

</dt>
<dd>

![](img/22.png)

</dd>
</dl>

---

<a id="passo-36"></a>

<dl>
<dt>

**36. Clique em "Body" e substitua o JSON pelo conteúdo abaixo.**

</dt>
<dd>

```json
{
    "name": "Jose Silva",
    "age": 43,
    "dateofregistry": "1989-10-13"
}
```

</dd>
</dl>

---

<a id="passo-37"></a>

<dl>
<dt>

**37. Clique em "Send" e observe a resposta.**

</dt>
<dd>

> Saída esperada:
> a resposta traz o mesmo objeto enviado, acrescido do campo `Response` — os campos foram validados e aprovados antes de chegar na Lambda.

![](img/23.png)

</dd>
</dl>

---

<a id="passo-38"></a>

<dl>
<dt>

**38. Remova o campo `age` do corpo e clique em "Send" novamente.**

</dt>
<dd>

> Saída esperada:
> erro `400` com o corpo customizado do passo 27 (`message` + `error`), citando o campo obrigatório ausente — não mais um erro genérico do API Gateway.

![](img/25.png)

</dd>
</dl>

---

<a id="passo-39"></a>

<dl>
<dt>

**39. Teste outros campos e formatos inválidos.**

</dt>
<dd>

Por exemplo, um mês acima de 12 em `dateofregistry`, ou um `age` fora de 0–100. Em todos os casos o `RequestValidator` deve rejeitar antes da Lambda ser invocada.

</dd>
</dl>

### Checkpoint

- a API está publicada no estágio `dev`
- o Postman está importado e chamando a URL do estágio
- corpo válido retorna `200` com `Response`; corpo inválido retorna `400` com a mensagem customizada

---

## Parte 5 - Protegendo a API com chave de API

### Resultado esperado desta parte

Ao final desta etapa, o método `POST /user/create` exigirá uma chave de API válida.

---

<a id="passo-40"></a>

<dl>
<dt>

**40. De volta ao painel da API no API Gateway, clique em "Chaves de API".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-41"></a>

<dl>
<dt>

**41. Clique em "Criar chave de API".**

</dt>
<dd>

![](img/26.png)

</dd>
</dl>

---

<a id="passo-42"></a>

<dl>
<dt>

**42. Preencha o nome com `fiap-api` e clique em "Salvar".**

</dt>
<dd>

![](img/27.png)

</dd>
</dl>

---

<a id="passo-43"></a>

<dl>
<dt>

**43. Clique em "Mostrar" e copie o valor da chave.**

</dt>
<dd>

Você vai precisar desse valor no passo 59. Guarde-o num lugar seguro.

![](img/28.png)

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: ApiKey no API Gateway</b></summary>
<blockquote>

`CreateApiKey` gera um valor opaco de 40 caracteres que identifica o chamador — não é um mecanismo de criptografia nem substitui IAM/Cognito, é um identificador de parceiro que trafega no header `x-api-key`. Isoladamente, uma `ApiKey` não bloqueia nada: ela só passa a ser exigida quando um método tem `apiKeyRequired = true` (próximo passo) **e** a chave está associada a um `UsagePlan` que cobre o estágio chamado (Parte 6). As três peças precisam existir juntas.

📚 Documentação oficial: [Criar e usar chaves de API do API Gateway](https://docs.aws.amazon.com/pt_br/apigateway/latest/developerguide/api-gateway-setup-api-key-with-console.html) — passo a passo de criação e do vínculo com plano de uso.

</blockquote>
</details>

---

<a id="passo-44"></a>

<dl>
<dt>

**44. Na lateral esquerda, clique em "Recursos".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-45"></a>

<dl>
<dt>

**45. Clique no método `POST` do recurso `create`.**

</dt>
<dd>

![](img/29.png)

</dd>
</dl>

---

<a id="passo-46"></a>

<dl>
<dt>

**46. Clique em "Solicitação de método".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-47"></a>

<dl>
<dt>

**47. Marque "Chave de API obrigatória" e salve.**

</dt>
<dd>

![](img/30.png)

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: apiKeyRequired</b></summary>
<blockquote>

Marcar essa opção equivale a um `UpdateMethod` com o patch `apiKeyRequired = true` no método. A partir daí, toda chamada sem o header `x-api-key` (ou com uma chave não associada a um plano de uso válido para aquele estágio) recebe `403 Forbidden` com a mensagem `Missing Authentication Token` — antes mesmo de chegar no `RequestValidator` da Parte 3.

📚 Documentação oficial: [Exigir chaves de API para chamadas de API](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-setup-api-key-with-console.html#api-gateway-usage-plan-create-key) — mostra onde essa flag vive na definição do método.

</blockquote>
</details>

---

<a id="passo-48"></a>

<dl>
<dt>

**48. Reimplante a API (estágio `dev`).**

</dt>
<dd>

Clique em "Ações" → "Implantar API", selecione o estágio `dev` e clique em "Implantar".

![](img/31.png)

</dd>
</dl>

<details>
<summary><b>⚠ Se der erro: chamada sem chave ainda funciona</b></summary>
<blockquote>

Marcar "Chave de API obrigatória" **não** tem efeito até você reimplantar o estágio — assim como qualquer outra mudança de configuração, ela só vale para quem chama depois do próximo deploy. Se o Postman continuar aceitando chamadas sem `x-api-key` depois deste passo, confirme que o "Implantar API" foi de fato executado no estágio `dev` (e não criado um estágio novo por engano).

</blockquote>
</details>

### Checkpoint

- a chave `fiap-api` foi criada e o valor está copiado
- o método `POST /user/create` exige chave de API
- a API foi reimplantada no estágio `dev`

---

## Parte 6 - Criando o plano de uso e validando a autenticação

### Resultado esperado desta parte

Ao final desta etapa, a chave `fiap-api` estará associada a um plano de uso vinculado ao estágio `dev`, e você terá confirmado no Postman que chamadas sem chave falham e chamadas com chave funcionam.

---

<a id="passo-49"></a>

<dl>
<dt>

**49. Na lateral esquerda, clique em "Planos de utilização".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-50"></a>

<dl>
<dt>

**50. Clique em "Criar plano de uso".**

</dt>
<dd>

![](img/32.png)

</dd>
</dl>

---

<a id="passo-51"></a>

<dl>
<dt>

**51. Preencha os campos e clique em "Próximo".**

</dt>
<dd>

- Nome: `api-validation-plan`
- Taxa: `1000`
- Pico: `1500`
- Requisições por mês: `100000`

![](img/33.png)

</dd>
</dl>

<details>
<summary><b>💡 Clique para entender: UsagePlan, taxa, pico e cota</b></summary>
<blockquote>

Um `UsagePlan` combina dois controles independentes: **throttling** (`rateLimit` = requisições/segundo sustentadas, `burstLimit` = pico curto tolerado antes de começar a devolver `429 Too Many Requests`) e **cota** (`quota` = limite mensal/semanal/diário, aqui 100.000 requisições/mês). É exatamente o mecanismo que resolve a preocupação da Beatriz: um parceiro sozinho não consegue consumir a capacidade dos outros, porque o limite é por chave, não por API.

📚 Documentação oficial: [Criar e usar planos de uso com chaves de API](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-usage-plans.html) — detalha a diferença entre `rateLimit`/`burstLimit` (throttling) e `quota` (cota de uso).

</blockquote>
</details>

---

<a id="passo-52"></a>

<dl>
<dt>

**52. Clique em "Criar plano de uso" no final da página.**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-53"></a>

<dl>
<dt>

**53. Na aba "Estágios Associados", clique em "Adicionar estágio".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-54"></a>

<dl>
<dt>

**54. Preencha e confirme.**

</dt>
<dd>

- API: `rest-api-with-validation`
- Estágio: `dev`

![](img/34.png)

</dd>
</dl>

---

<a id="passo-55"></a>

<dl>
<dt>

**55. Na aba "Chaves de API associadas", clique em "Adicionar chave de API".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-56"></a>

<dl>
<dt>

**56. Selecione a chave `fiap-api` e clique em "Adicionar chave de API".**

</dt>
<dd>

![](img/35.png)

</dd>
</dl>

### Checkpoint

- o plano `api-validation-plan` existe, com taxa/pico/cota configurados
- o estágio `dev` da API está associado ao plano
- a chave `fiap-api` está associada ao plano

---

<a id="passo-57"></a>

<dl>
<dt>

**57. No Postman, clique em `POST /user/create`.**

</dt>
<dd>

![](img/39.png)

</dd>
</dl>

---

<a id="passo-58"></a>

<dl>
<dt>

**58. Clique em "Send".**

</dt>
<dd>

> Saída esperada:
> `403 Forbidden` — a chamada ainda não tem chave de API, então é rejeitada mesmo com corpo válido.

![](img/40.png)

</dd>
</dl>

---

<a id="passo-59"></a>

<dl>
<dt>

**59. Na aba "Headers", adicione a chave `x-api-key` com o valor copiado no passo 43.**

</dt>
<dd>

Se perdeu o valor, acesse o [painel de chaves de API](https://us-east-1.console.aws.amazon.com/apigateway/home?region=us-east-1#/api-keys), clique em `fiap-api` e em "Mostrar".

![](img/41.png)

</dd>
</dl>

---

<a id="passo-60"></a>

<dl>
<dt>

**60. Clique em "Save".**

</dt>
<dd>

</dd>
</dl>

---

<a id="passo-61"></a>

<dl>
<dt>

**61. Clique em "Send" novamente.**

</dt>
<dd>

> Saída esperada:
> `200` com o corpo validado e o campo `Response` — a chamada foi bem-sucedida porque agora carrega o `x-api-key` associado ao plano de uso.

</dd>
</dl>

<details>
<summary><b>⚠ Se der erro: 403 mesmo com a chave no header</b></summary>
<blockquote>

Os erros mais comuns nesse ponto:

- a chave foi digitada com espaço em branco extra (copie de novo pelo painel de chaves)
- o plano de uso não tem o estágio `dev` associado (volte ao passo 54)
- a chave não está associada ao plano de uso (volte ao passo 56)
- a API não foi reimplantada depois de marcar "Chave de API obrigatória" (volte ao passo 48)

</blockquote>
</details>

## Conclusão

Se você chegou até aqui, então já executou:

- criação de função Lambda e integração de proxy com o API Gateway
- validação de corpo com JSON Schema (`RequestValidator` + `Model`)
- resposta de erro customizada para corpo inválido (`GatewayResponse`)
- criação de chave de API e exigência dela num método (`apiKeyRequired`)
- criação de plano de uso com taxa, pico e cota, associado a estágio e chave

**Mensagem para Beatriz**: os dois problemas estão resolvidos sem uma linha de código extra na Lambda — corpo malformado nunca chega na função, e cada parceiro tem sua própria chave com limite próprio. Está pronto para os 3 parceiros.

---

## Próximo passo

Continue para o próximo módulo do curso para seguir evoluindo a arquitetura de microsserviços serverless.

---

<details>
<summary><b>💡 Glossário rápido — termos que aparecem neste lab</b></summary>
<blockquote>

| Termo | O que é |
|-------|---------|
| **Integração de proxy do Lambda** | Modo de integração (`AWS_PROXY`) em que o API Gateway encaminha o request HTTP inteiro para a Lambda e espera de volta `statusCode`/`headers`/`body`, sem mapeamento manual de campos. |
| **Model** | JSON Schema associado a um `contentType`, usado pelo `RequestValidator` para descrever o formato esperado do corpo. |
| **RequestValidator** | Configuração do método que decide se o corpo e/ou parâmetros/cabeçalhos são validados antes da integração ser chamada. |
| **GatewayResponse** | Resposta de erro gerada pelo próprio API Gateway (sem passar pela integração), customizável por tipo — ex.: `BAD_REQUEST_BODY`. |
| **Estágio (Stage)** | Versão publicada e nomeada da API (ex.: `dev`), associada a uma URL de invocação. Mudanças só valem depois de um novo deploy no estágio. |
| **Chave de API (`x-api-key`)** | Identificador opaco do chamador, exigido quando o método tem `apiKeyRequired = true`. Não é autenticação forte — é identificação de parceiro. |
| **Plano de uso (Usage Plan)** | Conjunto de limites (taxa, pico, cota) aplicado a uma ou mais chaves de API, associado a um ou mais estágios. |
| **Taxa / Pico (rate / burst)** | Limites de throttling: taxa é o volume sustentado por segundo, pico é a tolerância a picos curtos antes do `429`. |
| **Cota (Quota)** | Limite de requisições por período (dia/semana/mês) definido no plano de uso. |

</blockquote>
</details>

<details>
<summary><b>💡 Como pedir ajuda se travou</b></summary>
<blockquote>

Antes de abrir issue/perguntar no Slack, colete estas 4 informações — elas reduzem o tempo de resposta em 10×:

1. **Em que passo você está** (ex.: "passo 47, marcando Chave de API obrigatória")
2. **Mensagem de erro literal** (copia-cola completo da resposta do Postman, não screenshot — texto é pesquisável)
3. **O que aparece em "Recursos" do API Gateway** para o método em questão (integração, validador, chave obrigatória)
4. **O que você já tentou**

Canais (em ordem de prioridade):

- **Issues do repositório**: [github.com/vamperst/FIAP-Microservices-Serverless/issues](https://github.com/vamperst/FIAP-Microservices-Serverless/issues)
- **E-mail do professor**: `rafael.barbosa@fiap.com.br`
- **Antes de tudo**: confira se a API foi reimplantada no estágio `dev` depois da última mudança — a maioria dos "não bate com o esperado" é configuração antiga ainda publicada.

</blockquote>
</details>
