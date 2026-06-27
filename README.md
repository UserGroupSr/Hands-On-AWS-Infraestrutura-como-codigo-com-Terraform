# Workshop 3 — Terraform (AWS User Group São Roque)

Infraestrutura como Código com Terraform na AWS. Neste workshop você vai provisionar um site com alta disponibilidade usando S3, IAM, Security Groups, Launch Template, ALB e Auto Scaling Group.

---

## Estrutura do Projeto

```
Workshop3_Terraform/
├── terraform/                  ← Pasta principal (Parte 1)
│   ├── providers.tf            ← Configuração do provider AWS
│   ├── variables.tf            ← Variáveis do projeto
│   ├── terraform.tfvars        ← Seu nome de bucket (editar aqui)
│   ├── s3.tf                   ← Bucket S3 + upload do site
│   └── templates/
│       └── userdata.sh         ← Script de inicialização das EC2
│
├── parte 2/                    ← Arquivos da segunda etapa
│   ├── iam.tf                  ← Role e Instance Profile
│   ├── security-groups.tf      ← Security Groups (ALB e EC2)
│   ├── launch-template.tf      ← Launch Template das instâncias
│   ├── asg-alb.tf              ← Auto Scaling Group + ALB
│   └── outputs.tf              ← Outputs (DNS do ALB)
│
└── aplicacao/  ← Arquivos do site
    ├── index.html
    ├── app.js
    ├── style.css
    └── img/
```

---

## Pré-requisitos

- **Terraform >= 1.5.0** — [Instruções de instalação](https://developer.hashicorp.com/terraform/install)
- **AWS CLI instalada** — [Instruções de instalação](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Conta AWS** com permissões de AdministratorAccess (fornecida no workshop)

Verifique se está tudo instalado:

```bash
terraform version
aws --version
```

---

## Passo a Passo

### Passo 1 — Configurar credenciais AWS

Execute o comando abaixo e preencha com as credenciais fornecidas pelo instrutor:

```bash
aws configure
```

Será solicitado:

| Campo                   | O que preencher                        |
|-------------------------|----------------------------------------|
| AWS Access Key ID       | Sua Access Key                         |
| AWS Secret Access Key   | Sua Secret Key                         |
| Default region name     | `us-east-1`                            |
| Default output format   | `json`                                 |

Confirme que está funcionando:

```bash
aws s3 ls
```

Se retornar seu Account e UserId, está tudo certo!

---

### Passo 2 — Configurar o nome do seu bucket

Entre na pasta `terraform` e edite o arquivo `terraform.tfvars`:

```bash
cd terraform
```

Abra o arquivo `terraform.tfvars` e coloque um nome **único** para seu bucket:

```hcl
bucket_name = "workshop-ugsr-SEUNOME-2026"
```

> ⚠️ O nome do bucket precisa ser único em toda a AWS. Use seu nome ou apelido para garantir isso.

---

### Passo 3 — Parte 1: Subir o Bucket S3 com o site

Inicialize o Terraform:

```bash
terraform init
```

Veja o que será criado:

```bash
terraform plan
```

Aplique para criar o bucket S3 e fazer upload dos arquivos do site:

```bash
terraform apply
```

Digite `yes` quando solicitado.

✅ Neste momento você terá o bucket S3 criado com os arquivos do site dentro.

---

### Passo 4 — Parte 2: Subir a infraestrutura completa (EC2, ALB, ASG)

Agora copie os arquivos da pasta `parte 2` para dentro da pasta `terraform`:

**Windows (CMD):**
```cmd
copy "..\parte 2\*" .
```

**Windows (PowerShell):**
```powershell
Copy-Item "..\parte 2\*" -Destination . -Force
```

**Linux/Mac:**
```bash
cp ../parte\ 2/* .
```

Rode o plan para ver os novos recursos que serão criados:

```bash
terraform plan
```

Aplique novamente para subir toda a infraestrutura:

```bash
terraform apply
```

Digite `yes` quando solicitado.

✅ Ao final, o Terraform exibirá o **DNS do ALB**. Copie e cole no navegador para ver seu site funcionando!

```
Outputs:

alb_dns_name = "workshop-ugsr-alb-xxxxxxxxx.us-east-1.elb.amazonaws.com"
```

> 💡 Pode levar de 2 a 3 minutos para as instâncias EC2 ficarem healthy no Target Group. Se o site não carregar de imediato, aguarde um pouco e tente novamente.

---

### Passo 5 — Destruir todos os recursos

Ao final do workshop, **remova tudo** para não gerar custos na sua conta:

```bash
terraform destroy
```

Digite `yes` para confirmar. Aguarde até ver:

```
Destroy complete! Resources: X destroyed.
```

> ⚠️ **IMPORTANTE:** Sempre execute o destroy ao final. Os recursos criados (ALB, EC2) geram cobrança por hora de uso.

---

## Observações Finais e Possíveis Problemas

### ❌ Erro: "BucketAlreadyExists" ou "BucketAlreadyOwnedByYou"

**Causa:** O nome do bucket já existe na AWS (buckets são globais).

**Solução:** Altere o `bucket_name` no arquivo `terraform.tfvars` para algo mais único:
```hcl
bucket_name = "workshop-ugsr-seunome-turma2-2026"
```

---

### ❌ Erro: "NoCredentialProviders" ou "ExpiredToken"

**Causa:** Credenciais AWS não configuradas ou expiradas.

**Solução:** Execute novamente:
```bash
aws configure
```
E confirme com:
```bash
aws sts get-caller-identity
```

---

### ❌ Erro: "Error: No valid credential sources found"

**Causa:** O `aws configure` não foi executado ou as chaves estão incorretas.

**Solução:** Verifique se o arquivo `~/.aws/credentials` existe e contém as chaves corretas.

---

### ❌ Erro ao copiar arquivos da parte 2: "O sistema não pode encontrar o caminho especificado"

**Causa:** Você não está dentro da pasta `terraform`.

**Solução:** Certifique-se de estar na pasta correta:
```bash
cd terraform
```

---

### ❌ Site não carrega após o apply (erro 503)

**Causa:** As instâncias EC2 ainda estão inicializando ou o health check não passou.

**Solução:**
1. Aguarde 2-3 minutos e atualize a página
2. Verifique no console AWS se as instâncias estão "healthy" no Target Group
3. Se persistir, verifique se o bucket contém os arquivos do site:
   ```bash
   aws s3 ls s3://SEU-BUCKET-NAME/
   ```

---

### ❌ Erro: "Error deleting S3 bucket" no destroy

**Causa:** O bucket ainda contém objetos.

**Solução:** O `force_destroy = true` já está configurado no código, então isso não deve ocorrer. Se acontecer, esvazie manualmente:
```bash
aws s3 rm s3://SEU-BUCKET-NAME --recursive
terraform destroy
```

---

### ❌ Erro: "UnauthorizedAccess" ou "AccessDenied"

**Causa:** Suas credenciais não têm permissão suficiente.

**Solução:** Confirme com o instrutor se a policy `AdministratorAccess` está anexada ao seu usuário IAM.

---

### 💡 Dica: Ver o estado atual dos recursos

Para verificar o que o Terraform está gerenciando:
```bash
terraform state list
```

---

### 💡 Dica: Refazer tudo do zero

Se algo deu muito errado e você quer recomeçar:
```bash
terraform destroy
```
Depois remova os arquivos da parte 2 da pasta terraform e comece novamente pelo Passo 3.

---

## Resumo dos Comandos

| Etapa | Comando |
|-------|---------|
| Configurar AWS | `aws configure` |
| Inicializar Terraform | `terraform init` |
| Ver plano | `terraform plan` |
| Aplicar (criar recursos) | `terraform apply` |
| Destruir (remover tudo) | `terraform destroy` |

---

**Workshop 3 — AWS User Group São Roque** 🚀
