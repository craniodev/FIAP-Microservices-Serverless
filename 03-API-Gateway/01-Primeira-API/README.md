# 03.1 - Primeira API

**Antes de começar, execute os passos abaixo para configurar o ambiente caso não tenha feito isso ainda na aula de HOJE: [Preparando Credenciais](../../01-create-codespaces/Inicio-de-aula.md)**

**Neste laboratório não há comandos de terminal.** Todos os passos rodam no console da AWS ([Amazon API Gateway](https://aws.amazon.com/pt/api-gateway/)) e no Postman, direto pelo navegador.

> [!WARNING]
> **Antes de começar, confirme:**
> - Setup inicial da aula concluído (Learner Lab da AWS Academy iniciado) — validação: abra o [console do API Gateway](https://us-east-1.console.aws.amazon.com/apigateway/main/apis?region=us-east-1) e confirme que ele carrega sem pedir login de novo.
> - Navegador sem bloqueio de pop-up/download para a região `us-east-1` do console AWS.
> - Conta gratuita no [Postman Web](https://web.postman.co/) criada (ou crie no passo 15, se ainda não tiver).
>
> Tempo estimado: **cerca de 35 minutos** (execução guiada ~15 min + tempo de leitura, cliques e comparação com as imagens do lab).

Na startup fictícia **PetHub Commerce**, a gerente de produto Marina Alves resume o pedido do time mobile:

> "Precisamos de uma API funcionando ainda hoje para o time mobile testar as chamadas de cadastro e listagem de pets. Não precisa ser definitiva, só precisa estar de pé."

Vamos usar a API de exemplo que o próprio console do API Gateway oferece — a clássica *PetStore* — para sair do zero a uma API implantada e testável externamente, sem escrever nenhuma linha de infraestrutura.

## Principais pontos de aprendizagem

- Criar uma REST API no API Gateway a partir de um template de exemplo (PetStore)
- Entender a diferença entre testar no console e implantar (deploy) a API
- Publicar uma API em um stage e obter a URL pública de invocação
- Exportar a especificação OpenAPI/Swagger da API para uso no Postman
- Testar a API implantada externamente via Postman e via navegador

## O que você terá ao final

Uma REST API implantada no API Gateway, com URL pública, testada tanto no console quanto externamente via Postman e navegador.

Sempre que encontrar um bloco com o título **💡 Clique para entender**, abra esse trecho: ele traz a mecânica real por baixo do clique (a API do API Gateway que está sendo chamada) e o link para a documentação oficial correspondente.

## Mapa do lab

| Parte | Descrição | Tempo | Passos |
|---|---|---|---|
| [Parte 1 — Criando a API de exemplo](#parte-1) | Importa o template PetStore e conhece a estrutura da API | ~6 min | [1](#passo-1)–[5](#passo-5) |
| [Parte 2 — Testando no console](#parte-2) | Testa o método `POST /pets` sem precisar implantar nada | ~5 min | [6](#passo-6)–[9](#passo-9) |
| [Parte 3 — Implantando a API](#parte-3) | Cria o stage `test` e obtém a URL pública de invocação | ~6 min | [10](#passo-10)–[13](#passo-13) |
| [Parte 4 — Exportando a especificação](#parte-4) | Gera o arquivo Swagger com extensões do Postman | ~4 min | [14](#passo-14) |
| [Parte 5 — Testando via Postman](#parte-5) | Chama a API implantada de fora da AWS, como um cliente real | ~12 min | [15](#passo-15)–[22](#passo-22) |
| [Parte 6 — Testando pelo navegador](#parte-6) | Confirma o comportamento do método `GET` na raiz da API | ~2 min | [23](#passo-23) |

---

## Contexto

O Amazon API Gateway é o serviço gerenciado que expõe APIs REST, HTTP e WebSocket sem que você precise operar servidor algum. Antes de conectar um backend próprio (é o que você fará no próximo laboratório, com Lambda), vale entender a mecânica básica do serviço — recurso, método, integração, stage, implantação — usando um exemplo pronto. É exatamente para isso que o console oferece a API de exemplo *PetStore*: um jeito de ver a engrenagem inteira funcionando antes de montar a sua.

---

<a id="parte-1"></a>

## Parte 1 - Criando a API de exemplo no API Gateway

### Resultado esperado desta parte

Ao final desta etapa, você terá importado a API de exemplo PetStore no API Gateway e reconhecido sua estrutura de recursos.

<a id="passo-1"></a>

<dl><dt>

**1. Abra o API Gateway e inicie a criação de uma API**

</dt><dd>

Abra o serviço [API Gateway](https://us-east-1.console.aws.amazon.com/apigateway/main/apis?region=us-east-1) e clique em `Criar API` no canto superior direito da tela.

![](img/1.png)

</dd></dl>

---

<a id="passo-2"></a>

<dl><dt>

**2. Escolha importar uma API REST**

</dt><dd>

Desça nas opções da tela até `API REST` e clique em `Importar`.

![](img/2.png)

</dd></dl>

---

<a id="passo-3"></a>

<dl><dt>

**3. Selecione a API de exemplo**

</dt><dd>

Clique em `API de exemplo`.

![](img/3.png)

</dd></dl>

---

<a id="passo-4"></a>

<dl><dt>

**4. Confirme a criação**

</dt><dd>

No canto inferior direito da tela, clique em `Criar API`.

</dd></dl>

<details>
<summary><b>💡 Clique para entender: como a "API de exemplo" é montada por baixo dos panos</b></summary>
<blockquote>

Ao clicar em `Criar API`, o console chama `CreateRestApi` e, em seguida, importa uma definição OpenAPI 2.0 (Swagger) pré-pronta — a clássica API **PetStore** usada nos tutoriais oficiais da AWS. Essa definição já vem com os recursos e métodos:

- `GET /` — integração do tipo **MOCK** (não chama backend nenhum; retorna uma página HTML estática configurada na integration response)
- `GET /pets` e `POST /pets` — integração do tipo **HTTP** (não é `AWS_PROXY`/Lambda), apontando para o backend público de demonstração `http://petstore-demo-endpoint.execute-api.com/petstore/pets`
- `GET /pets/{petId}` — também **HTTP**, usando `petId` como variável de path para buscar um pet específico no mesmo backend

É por isso que a API funciona de ponta a ponta sem você escrever nenhuma função Lambda: o "backend" já existe, hospedado pela própria AWS para fins didáticos.

📚 Documentação oficial: [Tutorial: Create a REST API by importing an example](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-from-example.html) — detalha cada recurso/método da PetStore e o tipo de integração exato de cada um.

</blockquote>
</details>

---

<a id="passo-5"></a>

<dl><dt>

**5. Confira a estrutura de recursos criada**

</dt><dd>

Sua API ficará com a seguinte estrutura:

![](img/4.png)

</dd></dl>

### Checkpoint

Se você chegou até aqui, então:

- a API de exemplo (PetStore) foi criada no API Gateway
- você reconhece os recursos `/`, `/pets` e `/pets/{petId}` na árvore de recursos

---

<a id="parte-2"></a>

## Parte 2 - Testando a API dentro do console

### Resultado esperado desta parte

Ao final desta etapa, você terá testado o método `POST /pets` direto no console, sem precisar implantar a API.

<a id="passo-6"></a>

<dl><dt>

**6. Selecione o método POST do recurso /pets**

</dt><dd>

Antes de implantar a API, vamos testá-la direto no console. Na árvore de recursos, abra `/pets` e selecione o método `POST`.

![](img/5.png)

</dd></dl>

---

<a id="passo-7"></a>

<dl><dt>

**7. Abra a aba de teste do método**

</dt><dd>

Clique em `Teste`.

</dd></dl>

---

<a id="passo-8"></a>

<dl><dt>

**8. Cole o corpo da requisição de teste**

</dt><dd>

No campo `Corpo de solicitação`, cole o seguinte conteúdo:

``` json
{"type": "dog", "price": 249.99}
```

![](img/6.png)

</dd></dl>

---

<a id="passo-9"></a>

<dl><dt>

**9. Execute o teste e confira o resultado**

</dt><dd>

Na parte inferior da tela, clique em `Teste`. Você acabou de executar o teste dessa chamada da sua API. A resposta aparece em `Corpo de resposta`, e todos os logs da chamada em `Logs`.

![](img/7.png)

</dd></dl>

<details>
<summary><b>💡 Clique para entender: o que o botão "Teste" faz por baixo dos panos</b></summary>
<blockquote>

O botão `Teste` chama a operação `TestInvokeMethod` da API de controle do API Gateway (a mesma usada pelo comando `test-invoke-method` da AWS CLI). Ela executa o método de verdade contra a integração configurada — no caso do `POST /pets`, o corpo que você colou é de fato enviado ao backend HTTP da PetStore — e devolve, além da resposta, os logs que apareceriam no CloudWatch Logs. Ou seja: o teste é real, só o destino do log é que é simulado.

📚 Documentação oficial: [Use the API Gateway console to test a REST API method](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-test-method.html) — explica o que cada campo do resultado do teste (Status, Latency, Response body/headers, Logs) representa.

</blockquote>
</details>

### Checkpoint

Se você chegou até aqui, então:

- você testou o método `POST /pets` direto no console
- viu o corpo de resposta e os logs da chamada, sem ter implantado a API ainda

---

<a id="parte-3"></a>

## Parte 3 - Implantando (deploy) a API

### Resultado esperado desta parte

Ao final desta etapa, sua API estará implantada em um stage público, com uma URL de invocação em mãos.

<a id="passo-10"></a>

<dl><dt>

**10. Inicie a implantação da API**

</dt><dd>

Agora sim é hora de implantar a API para ter uma URL a ser chamada. Para isso, clique em `Implantar API` no canto superior direito da tela.

![](img/8.png)

</dd></dl>

---

<a id="passo-11"></a>

<dl><dt>

**11. Preencha o formulário de implantação**

</dt><dd>

Preencha os campos do formulário como na imagem abaixo:

![](img/9.png)

</dd></dl>

---

<a id="passo-12"></a>

<dl><dt>

**12. Confirme a implantação**

</dt><dd>

Clique em `Implantar`.

</dd></dl>

---

<a id="passo-13"></a>

<dl><dt>

**13. Copie a URL da API implantada**

</dt><dd>

Pronto: você criou sua primeira API no API Gateway, e a URL para chamá-la está no topo da tela.

</dd></dl>

<details>
<summary><b>💡 Clique para entender: o que "Implantar API" faz por baixo dos panos</b></summary>
<blockquote>

`Implantar` chama a operação `CreateDeployment`, que congela a configuração atual da API (recursos, métodos, integrações) em um snapshot e o associa a um **stage** — no seu caso, o stage que você nomeou no formulário. É esse stage que fica exposto na URL `https://<api-id>.execute-api.<região>.amazonaws.com/<stage>`. Sem uma implantação, a API existe só dentro do console — nenhuma chamada externa consegue alcançá-la.

Você pode implantar novamente sempre que quiser: cada `Implantar` gera uma nova revisão no mesmo stage, sem duplicar recursos nem exigir limpeza antes. Se algo der errado num passo seguinte, é só corrigir e implantar de novo.

📚 Documentação oficial: [Deploy REST APIs in API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-deploy-api.html) — explica a relação entre deployment e stage e como a URL final é montada.

</blockquote>
</details>

<details>
<summary>⚠ Se der erro: <code>{"message":"Missing Authentication Token"}</code> ao abrir a URL</summary>

Esse erro quase sempre significa que a URL está incompleta — faltou o nome do stage (ex.: `/test`) ou o caminho do recurso. Confira, no painel **Stages** do API Gateway, a **Invoke URL** completa e copie exatamente o que está lá, sem cortar nem completar de memória.

</details>

### Checkpoint

Se você chegou até aqui, então:

- a API foi implantada em um stage
- você tem em mãos a URL de invocação pública da API

---

<a id="parte-4"></a>

## Parte 4 - Exportando a especificação para o Postman

### Resultado esperado desta parte

Ao final desta etapa, você terá em mãos o arquivo com a especificação da API, pronto para importar no Postman.

<a id="passo-14"></a>

<dl><dt>

**14. Exporte a especificação do stage com extensões do Postman**

</dt><dd>

Vamos executar chamadas de teste via Postman para testar a API externamente. No canto superior direito, clique em `Ações do estágio` e, na aba `Exportar` do estágio `test` recém-criado, escolha as opções:

- Tipo de especificação de API: `Swagger`
- Formato: `YAML`
- Extensões: `Exportar com extensões Postman`

![](img/10.png)

![](img/10-2.png)

</dd></dl>

<details>
<summary><b>💡 Clique para entender: o que a exportação gera por baixo dos panos</b></summary>
<blockquote>

`Exportar` chama a API `GetExport`, que devolve a definição da sua API no formato **OpenAPI 2.0 (Swagger)** ou **OpenAPI 3.0**, em JSON ou YAML, conforme você escolher. Marcar `Exportar com extensões Postman` acrescenta ao arquivo as extensões `x-postman-*`, que o Postman usa para já preencher exemplos de corpo de requisição ao importar — é por isso que, no próximo passo, o `POST Create Pet` aparece com um JSON de exemplo pronto no editor.

📚 Documentação oficial: [Export a REST API from API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-export-api.html) — lista todas as combinações de formato/versão/extensões disponíveis na exportação.

</blockquote>
</details>

<details>
<summary>⚠ Se der erro: o Postman importou a API mas os métodos vieram sem exemplo de corpo</summary>

Provavelmente a exportação foi feita sem marcar `Exportar com extensões Postman`. Refaça a exportação marcando essa opção e importe o novo arquivo no Postman.

</details>

### Checkpoint

Se você chegou até aqui, então:

- você tem em mãos o arquivo Swagger/YAML exportado, com extensões do Postman

---

<a id="parte-5"></a>

## Parte 5 - Testando a API externamente via Postman

### Resultado esperado desta parte

Ao final desta etapa, você terá chamado a API implantada de fora da AWS, como um cliente real faria.

<a id="passo-15"></a>

<dl><dt>

**15. Abra o Postman e crie uma conta, se ainda não tiver**

</dt><dd>

Abra o Postman no seu [navegador](https://web.postman.co/). Caso não tenha cadastro, crie sua conta gratuitamente.

</dd></dl>

---

<a id="passo-16"></a>

<dl><dt>

**16. Inicie a importação**

</dt><dd>

Dentro do Postman, clique em `Import`.

![](img/11.png)

</dd></dl>

---

<a id="passo-17"></a>

<dl><dt>

**17. Carregue o arquivo exportado do API Gateway**

</dt><dd>

Carregue o arquivo recém-baixado do API Gateway. Depois de carregado, o Postman ficará como na imagem abaixo:

![](img/12.png)

</dd></dl>

---

<a id="passo-18"></a>

<dl><dt>

**18. Abra a chamada de criação de pet e cole o corpo da requisição**

</dt><dd>

Expanda os campos até chegar em `POST Create Pet` e clique para abrir no editor. Copie o JSON abaixo no corpo da requisição:

``` json
{
"type": "bird",
"price": 234.98
}
```

![](img/13.png)

</dd></dl>

---

<a id="passo-19"></a>

<dl><dt>

**19. Envie a chamada de criação**

</dt><dd>

Clique em `Send` na lateral direita da tela. Você acabou de fazer uma chamada para sua API via Postman.

![](img/14.png)

</dd></dl>

---

<a id="passo-20"></a>

<dl><dt>

**20. Abra a chamada de listagem de pets**

</dt><dd>

Agora você fará uma chamada de listagem. Para isso, clique em `Get /pets` para abrir no editor.

![](img/15.png)

</dd></dl>

---

<a id="passo-21"></a>

<dl><dt>

**21. Ajuste os parâmetros da listagem**

</dt><dd>

Edite o valor do campo `type` para `cat` e o valor do campo `page` para `1`.

![](img/16.png)

</dd></dl>

---

<a id="passo-22"></a>

<dl><dt>

**22. Envie a chamada de listagem**

</dt><dd>

Clique em `Send` no canto superior direito para executar a listagem.

![](img/17.png)

</dd></dl>

### Checkpoint

Se você chegou até aqui, então:

- você importou a API no Postman
- fez uma chamada `POST /pets` e uma chamada `GET /pets` com sucesso, fora do console AWS

---

<a id="parte-6"></a>

## Parte 6 - Testando a API pelo navegador

### Resultado esperado desta parte

Ao final desta etapa, você terá confirmado o comportamento do método `GET` na raiz da API, direto no navegador.

<a id="passo-23"></a>

<dl><dt>

**23. Chame a raiz da API pelo navegador**

</dt><dd>

Como último teste: o path principal da sua API retorna um HTML quando chamado via método `GET` (é o caso dos navegadores). Volte ao API Gateway, copie a URL da sua API e cole no navegador.

![](img/18.png)

![](img/19.png)

</dd></dl>

### Checkpoint

Se você chegou até aqui, então:

- você confirmou que a raiz da API (`GET /`) responde com HTML, via navegador

---

## Conclusão

Se você chegou até aqui, você:

- criou uma REST API a partir de um template de exemplo (PetStore)
- testou um método direto no console, antes de implantar
- implantou a API em um stage e obteve a URL pública de invocação
- exportou a especificação da API e a importou no Postman
- chamou a API de fora da AWS, via Postman e via navegador

Esse laboratório serve como base para os próximos: a partir daqui, você já sabe navegar pelo console do API Gateway, testar métodos, implantar stages e validar chamadas externamente — só falta trocar o backend de demonstração por uma função Lambda sua.

## Próximo passo

No próximo laboratório, [Validação e Autenticação](../02-Validacao-Autenticacao/README.md), você vai construir uma API com backend em Lambda, validação de schema JSON diretamente no API Gateway e autenticação por chave de API.

<details>
<summary><b>💡 Glossário rápido</b></summary>

| Termo | Significado |
|---|---|
| REST API | Tipo de API do API Gateway baseada em recursos e métodos HTTP |
| Recurso (Resource) | Um caminho da API, como `/pets` ou `/pets/{petId}` |
| Método (Method) | Um verbo HTTP (`GET`, `POST`...) associado a um recurso |
| Integração MOCK | Integração que responde sem chamar backend nenhum |
| Integração HTTP | Integração que encaminha a chamada para um endpoint HTTP externo |
| Stage | Um ambiente nomeado (`test`, `prod`...) onde a API fica publicada |
| Implantação (Deployment) | O snapshot da configuração da API publicado em um stage |
| Invoke URL | A URL pública para chamar a API implantada |
| OpenAPI/Swagger | Formato de especificação usado para exportar/importar a API |

</details>

<details>
<summary><b>💡 Como pedir ajuda se travou</b></summary>

Antes de chamar o professor, tenha em mãos:

1. Em qual passo você travou (o número, ex.: "passo 14")
2. A mensagem de erro completa (print ou texto copiado)
3. O que você já tentou
4. Se o erro apareceu no console AWS, no Postman ou no navegador

Canais, em ordem de prioridade:

1. Chame o professor durante a aula (mais rápido)
2. Grupo/fórum da turma
3. Documentação oficial linkada nos blocos 💡 deste README

</details>
