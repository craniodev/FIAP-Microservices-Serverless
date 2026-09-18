# 01 - Setup e configuração de ambiente

Este laboratório prepara todo o ambiente usado ao longo da disciplina.

## Objetivo

Ao final deste setup, você terá:

- uma conta ativa no AWS Academy
- um Codespaces pronto para executar os laboratórios da disciplina
- as credenciais da AWS configuradas no Codespaces
- um bucket `base-config-<SEU RM>` criado no S3

> [!WARNING]
> Antes de começar, confirme que você tem: (1) uma conta do GitHub, crie em [github.com](https://github.com) se ainda não tiver; (2) acesso ao seu e-mail da FIAP (`rm<SEU RM>@fiap.com.br`) para o convite do AWS Academy; (3) um navegador com pop-ups liberados, pois o AWS Academy abre a conta AWS em uma nova aba. Tempo estimado: **20 a 30 minutos** (a criação do Codespaces por si só pode levar até 15 minutos).

> [!IMPORTANT]
> Guarde este material. Você vai reutilizar parte dele em toda aula, principalmente a atualização das credenciais no Codespaces.

Você irá utilizar 2 ferramentas para desenvolver os laboratórios:

- Conta AWS através da AWS Academy. Conta provisionada para você utilizar durante essa disciplina com 50 dólares de crédito.
- [GitHub Codespaces](https://github.com/features/codespaces). Uma IDE cloud online para todos terem um ambiente igual e com a autorização para executar os comandos dos exercícios.

---

## Parte 1 - Criando o GitHub Codespaces

### Resultado esperado desta parte

Ao final desta etapa, você terá um Codespaces criado a partir do repositório da disciplina e pronto para uso.

<a id="passo-1"></a>

<dl>
<dt>

**1. Crie sua conta do GitHub**

</dt>
<dd>

Você vai utilizar sua conta do GitHub para acessar o Codespaces. Caso não tenha uma conta, crie uma em [github.com](https://github.com).

</dd>
</dl>

---

<a id="passo-2"></a>

<dl>
<dt>

**2. Faça o fork do repositório da disciplina**

</dt>
<dd>

Acesse o repositório [FIAP-Microservices-Serverless](https://github.com/vamperst/FIAP-Microservices-Serverless/tree/master) e, no canto superior da tela, clique no botão `Fork` para copiar o repositório para a sua conta.

![](img/fork1-1.png)

</dd>
</dl>

---

<a id="passo-3"></a>

<dl>
<dt>

**3. Configure e confirme o fork**

</dt>
<dd>

Você será redirecionado para a tela de fork do repositório. Deixe a opção `Copy the master branch only` **desmarcada**, para que sejam copiadas todas as branches do repositório. Clique em `Create Fork`.

![](img/fork2-1.png)

</dd>
</dl>

---

<a id="passo-4"></a>

<dl>
<dt>

**4. Acesse o GitHub Codespaces**

</dt>
<dd>

Acesse o link [GitHub Codespaces](https://github.com/codespaces) e clique em `Get Started for free`.

![](img/codespaces1.png)

</dd>
</dl>

---

<a id="passo-5"></a>

<dl>
<dt>

**5. Crie um novo codespace**

</dt>
<dd>

Clique em `New codespace` no canto superior direito para criar um novo ambiente.

![](img/codespaces2.png)

</dd>
</dl>

---

<a id="passo-6"></a>

<dl>
<dt>

**6. Configure as opções do Codespace**

</dt>
<dd>

Deixe as opções da tela da seguinte forma e clique em `Create Codespace`:

**6.1.** repository: `FIAP-Microservices-Serverless`
**6.2.** Branch: `master`
**6.3.** Dev container configuration: `FIAP Lab`
**6.4.** Region: `US East`
**6.5.** Machine type: `2-core`

![](img/codespaces3.png)

</dd>
</dl>

---

<a id="passo-7"></a>

<dl>
<dt>

**7. Acompanhe a criação do ambiente**

</dt>
<dd>

Após a criação do ambiente, você será redirecionado para o Codespaces. Se quiser acompanhar o processo, clique em `Building codespace`, no canto inferior direito, para abrir os logs de criação.

![](img/codespaces4.png)

</dd>
</dl>

---

<a id="passo-8"></a>

<dl>
<dt>

**8. Aguarde a finalização**

</dt>
<dd>

Essa criação pode demorar até 15 minutos, com tudo o que é necessário já instalado. Ao final, você verá a tela do Codespaces com o repositório clonado e pronto para uso.

</dd>
</dl>

> [!TIP]
> Deixe a aba do Codespaces aberta enquanto executa os próximos passos.

---

## Parte 2 - Acessando a conta AWS Academy

### Resultado esperado desta parte

Ao final desta etapa, você terá uma sessão ativa no laboratório da AWS Academy e acesso à sua conta AWS.

<a id="passo-9"></a>

<dl>
<dt>

**9. Crie sua conta no AWS Academy (se ainda não tiver)**

</dt>
<dd>

**9.1.** Entre no seu e-mail da FIAP pelo endereço [webmail.fiap.com.br](http://webmail.fiap.com.br/).
**9.2.** Seu e-mail é no formato `rm<SEU RM>@fiap.com.br`. Exemplo: se seu RM for `12345`, seu e-mail será `rm12345@fiap.com.br`. A senha é a mesma de portais.
**9.3.** Você terá um e-mail na caixa de entrada com o convite do Academy; siga as instruções.
**9.4.** Ao conseguir entrar na plataforma, aparecerá uma turma que começa com `AWS Academy Learner Lab`. Clique em `Enroll` para aceitar e acessar.

</dd>
</dl>

---

<a id="passo-10"></a>

<dl>
<dt>

**10. Acesse uma conta já existente do Academy**

</dt>
<dd>

Caso já tenha conta, acesse [awsacademy.com/LMS_Login](https://www.awsacademy.com/LMS_Login). Ao entrar na plataforma, localize a turma que começa com `AWS Academy Learner Lab` e clique em `Enroll` para aceitar e acessar.

</dd>
</dl>

---

<a id="passo-11"></a>

<dl>
<dt>

**11. Abra o curso da disciplina**

</dt>
<dd>

Dentro da plataforma, clique em `Cursos` na lateral esquerda e clique no curso da disciplina atual.

![](img/academy1.png)

</dd>
</dl>

---

<a id="passo-12"></a>

<dl>
<dt>

**12. Abra os módulos do curso**

</dt>
<dd>

Dentro do curso, clique em `Módulos` na lateral esquerda.

![](img/academy2.png)

</dd>
</dl>

---

<a id="passo-13"></a>

<dl>
<dt>

**13. Inicie os laboratórios de aprendizagem**

</dt>
<dd>

Clique em `Iniciar os laboratórios de aprendizagem da AWS Academy`.

![](img/academy3.png)

</dd>
</dl>

---

<a id="passo-14"></a>

<dl>
<dt>

**14. Aceite os termos, se for seu primeiro acesso**

</dt>
<dd>

Se for seu primeiro acesso, aparecerão os 2 contratos de termos e condições. Role até o final e aceite após a leitura. Caso já tenha feito isso antes, siga direto para o próximo passo.

![](img/academy4.png)

</dd>
</dl>

---

<a id="passo-15"></a>

<dl>
<dt>

**15. Acesse a conta AWS pelo link do laboratório**

</dt>
<dd>

Clique no link iniciando com `Academy-CUR` para acessar a conta AWS. Caso peça consentimento, clique em `I agree` e execute o passo novamente.

![](img/academy8.png)

</dd>
</dl>

---

<a id="passo-16"></a>

<dl>
<dt>

**16. Inicie a sessão do laboratório**

</dt>
<dd>

Cada sessão terá 4 horas. Após esse tempo você terá que iniciar outra sessão, mas os dados gravados na conta AWS ficam salvos até o final do curso ou entrega do trabalho final da disciplina. Clique em `Start Lab` para iniciar uma sessão. Esse processo pode demorar alguns minutos.

![](img/academy5.png)

![](img/academy6.png)

</dd>
</dl>

---

<a id="passo-17"></a>

<dl>
<dt>

**17. Abra a conta AWS**

</dt>
<dd>

Quando tudo estiver pronto, a bolinha ao lado do texto `AWS`, no canto superior esquerdo da tela, ficará verde. Clique em `AWS` para abrir a conta AWS em outra aba do navegador.

![](img/academy7.png)

</dd>
</dl>

> [!IMPORTANT]
> Se a bolinha ainda não estiver verde, aguarde. Só siga para a próxima parte quando a conta AWS abrir corretamente.

---

## Parte 3 - Criando o bucket base no S3

### Resultado esperado desta parte

Ao final desta etapa, você terá criado o bucket que receberá os arquivos de configuração usados durante o curso.

<a id="passo-18"></a>

<dl>
<dt>

**18. Abra o console do S3**

</dt>
<dd>

Abra uma aba do console AWS no [serviço S3](https://us-east-1.console.aws.amazon.com/s3/home?region=us-east-1#).

</dd>
</dl>

---

<a id="passo-19"></a>

<dl>
<dt>

**19. Clique em Criar bucket**

</dt>
<dd>

Clique em `Criar bucket`.

![](img/s3CreateBucket.png)

</dd>
</dl>

---

<a id="passo-20"></a>

<dl>
<dt>

**20. Nomeie e crie o bucket**

</dt>
<dd>

Dê ao bucket o nome `base-config-<SEU RM>` e clique em `Criar`.

![](img/createBucket.png)

</dd>
</dl>

> [!TIP]
> Esse bucket será usado novamente em outros laboratórios. Confirme com atenção o nome antes de continuar.

---

## Parte 4 - Configurando as credenciais AWS no Codespaces

### Resultado esperado desta parte

Ao final desta etapa, o comando `aws s3 ls` deverá funcionar dentro do Codespaces.

<a id="passo-21"></a>

<dl>
<dt>

**21. Volte para o Codespaces**

</dt>
<dd>

Volte para a aba do Codespaces que você criou anteriormente.

</dd>
</dl>

---

<a id="passo-22"></a>

<dl>
<dt>

**22. Abra o terminal**

</dt>
<dd>

Verifique se o terminal do Codespaces está aberto. Caso não esteja, clique em `Terminal` na parte inferior da tela.

</dd>
</dl>

---

<a id="passo-23"></a>

<dl>
<dt>

**23. Abra o arquivo de credenciais da AWS**

</dt>
<dd>

No terminal, execute o comando abaixo para abrir o arquivo de configuração da AWS:

```bash
code ~/.aws/credentials
```

Por enquanto o arquivo estará vazio.

</dd>
</dl>

---

<a id="passo-24"></a>

<dl>
<dt>

**24. Abra os detalhes da AWS no Academy**

</dt>
<dd>

Na aba do AWS Academy onde você acessou a conta AWS, no canto superior direito, clique em `AWS Details` e depois em `Show` nos campos de AWS CLI.

![](img/codespaces6.png)

</dd>
</dl>

---

<a id="passo-25"></a>

<dl>
<dt>

**25. Copie o conteúdo da credencial**

</dt>
<dd>

Copie o conteúdo da credencial para a área de transferência (`Ctrl+C`).

![](img/codespaces7.png)

</dd>
</dl>

---

<a id="passo-26"></a>

<dl>
<dt>

**26. Cole as credenciais no Codespaces**

</dt>
<dd>

Volte para o Codespaces, cole o conteúdo copiado no arquivo `~/.aws/credentials` e salve o arquivo com `Ctrl+S`.

![](img/codespaces8.png)

</dd>
</dl>

---

<a id="passo-27"></a>

<dl>
<dt>

**27. Valide o acesso à AWS**

</dt>
<dd>

Para testar, execute o comando abaixo no terminal do Codespaces:

```bash
aws s3 ls
```

![](img/codespaces9.png)

</dd>
</dl>

> Saída esperada:
> a lista de buckets da sua conta, incluindo o bucket `base-config-<SEU RM>` que você acabou de criar.

<details>
<summary>⚠ Se der erro: o comando não retorna nenhum bucket ou retorna erro de credencial</summary>

Confira se colou o conteúdo completo do arquivo de credenciais (incluindo `[default]`, `aws_access_key_id`, `aws_secret_access_key` e `aws_session_token`) e se salvou o arquivo antes de testar. As credenciais do AWS Academy expiram ao final de cada sessão de 4 horas; se a sua sessão já tiver expirado, repita o passo 16 para iniciar uma nova sessão e depois os passos 24 a 26 para atualizar as credenciais.

</details>

**Pronto! Seu ambiente está configurado e pronto para começar os laboratórios.**

> [!WARNING]
> Esse passo de copiar as credenciais para o Codespaces é necessário para que você consiga executar os comandos da AWS. Caso você feche o Codespaces e abra novamente, terá que repetir esse passo para copiar as credenciais outra vez. Assim como no início de cada aula (veja o [Início de aula](./Inicio-de-aula.md)).

> [!CAUTION]
> **SEMPRE DESLIGUE** o ambiente ao final de cada aula, para não gerar custos extras nem acabar com suas horas gratuitas no Codespaces. Para desligar, acesse [GitHub Codespaces](https://github.com/codespaces), clique nos 3 pontinhos ao lado do ambiente e clique em `Stop Codespace`.

![](img/codespaces10.png)
