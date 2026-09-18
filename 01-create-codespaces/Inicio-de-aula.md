# 01.1 - Início de toda aula

Toda aula começa com o mesmo procedimento.

Você pode pular esta parte caso já tenha feito isso na aula de **HOJE**.

> [!IMPORTANT]
> Durante o setup inicial você criou uma conta AWS Academy e um Codespaces. Caso ainda não tenha feito isso, siga o [tutorial de setup](./README.md) antes de continuar.

## Objetivo

Ao final deste roteiro, o seu Codespaces estará sincronizado com o repositório remoto e com as credenciais AWS atualizadas para a aula.

---

## Passo 1 - Atualizar o fork no GitHub

<a id="passo-1"></a>

<dl>
<dt>

**1. Acesse o seu fork no GitHub**

</dt>
<dd>

Acesse o seu repositório no GitHub que fez fork do repositório da disciplina **FIAP-Microservices-Serverless**.

</dd>
</dl>

---

<a id="passo-2"></a>

<dl>
<dt>

**2. Sincronize o fork**

</dt>
<dd>

Clique em `Sync Fork` no meio da tela para sincronizar o repositório com o repositório original. Caso tenha algo para sincronizar, clique em `Update branch`.

![](img/sync1.png)

![](img/sync2.png)

</dd>
</dl>

> [!NOTE]
> Caso não tenha nada para sincronizar, a mensagem será `This branch is not behind the upstream` e não será necessário fazer nada.

![](img/sync3.png)

---

## Passo 2 - Abrir o Codespaces

<a id="passo-3"></a>

<dl>
<dt>

**3. Acesse o GitHub Codespaces**

</dt>
<dd>

Acesse o link [GitHub Codespaces](https://github.com/codespaces).

</dd>
</dl>

---

<a id="passo-4"></a>

<dl>
<dt>

**4. Abra o Codespaces da disciplina**

</dt>
<dd>

Clique no nome do Codespaces que você criou para as aulas, derivado do repositório FIAP-Microservices-Serverless.

![](img/codespacess11.png)

</dd>
</dl>

---

<a id="passo-5"></a>

<dl>
<dt>

**5. Atualize o repositório local**

</dt>
<dd>

No terminal do Codespaces, execute o comando abaixo para atualizar o repositório local com as alterações do repositório remoto:

```bash
git pull origin master
```

</dd>
</dl>

---

## Passo 3 - Atualizar as credenciais AWS no Codespaces

<a id="passo-6"></a>

<dl>
<dt>

**6. Abra o arquivo de credenciais**

</dt>
<dd>

Execute o comando abaixo para abrir o arquivo de credenciais do AWS CLI:

```bash
code ~/.aws/credentials
```

</dd>
</dl>

---

<a id="passo-7"></a>

<dl>
<dt>

**7. Acesse o AWS Academy**

</dt>
<dd>

Com o arquivo `credentials` aberto, clique nele e acesse o [AWS Academy](https://www.awsacademy.com/vforcesite/LMS_Login) para entrar na conta AWS Academy no laboratório informado pelo professor.

![](img/ac1.png)

</dd>
</dl>

---

<a id="passo-8"></a>

<dl>
<dt>

**8. Abra os módulos do curso**

</dt>
<dd>

Na lateral esquerda, clique em `AWS Academy Learner Lab` e clique em `Módulos`.

![](img/ac2.png)

</dd>
</dl>

---

<a id="passo-9"></a>

<dl>
<dt>

**9. Inicie os laboratórios de aprendizagem**

</dt>
<dd>

Clique em `Iniciar os laboratórios de aprendizagem da AWS Academy`.

![](img/ac3.png)

</dd>
</dl>

---

<a id="passo-10"></a>

<dl>
<dt>

**10. Inicie o laboratório e abra a conta AWS**

</dt>
<dd>

Clique em `Start Lab` para iniciar o laboratório. Aguarde até que a bolinha ao lado do texto `AWS`, no canto superior esquerdo da tela, fique verde. Clique em `AWS` para abrir a conta AWS em outra aba do navegador.

![](img/ac4.png)

</dd>
</dl>

---

<a id="passo-11"></a>

<dl>
<dt>

**11. Abra os detalhes da AWS**

</dt>
<dd>

Ainda na aba do AWS Academy, clique em `AWS Details`, no canto superior direito da tela.

![](img/ac5.png)

</dd>
</dl>

---

<a id="passo-12"></a>

<dl>
<dt>

**12. Exiba as credenciais de acesso**

</dt>
<dd>

Em `AWS CLI`, clique em `Show` para ver as credenciais de acesso à conta AWS Academy.

![](img/ac6.png)

</dd>
</dl>

---

<a id="passo-13"></a>

<dl>
<dt>

**13. Cole as credenciais no Codespaces**

</dt>
<dd>

Copie as credenciais e cole no arquivo `credentials` que você abriu no passo 6, no Codespaces. Depois, salve o arquivo e feche.

![](img/ac7.png)

</dd>
</dl>

---

## Passo 4 - Validar se está tudo certo

<a id="passo-14"></a>

<dl>
<dt>

**14. Valide o acesso à AWS**

</dt>
<dd>

Para testar, execute o comando abaixo no terminal do Codespaces:

```bash
aws s3 ls
```

</dd>
</dl>

> Saída esperada:
> a lista de buckets da sua conta AWS, incluindo o bucket `base-config-<SEU RM>` criado durante o setup.

<details>
<summary>⚠ Se der erro: o comando não retorna buckets ou retorna erro de credencial</summary>

As credenciais do AWS Academy expiram ao final de cada sessão de 4 horas. Repita os passos 9 a 13 para iniciar uma nova sessão e copiar as credenciais atualizadas.

</details>

## Resultado esperado

Ao final deste processo:

- o seu fork estará sincronizado, se necessário
- o repositório local no Codespaces estará atualizado
- as credenciais AWS do dia estarão configuradas
- o comando `aws s3 ls` estará funcionando

**Pronto! Seu ambiente está configurado e pronto para começar os laboratórios.**
