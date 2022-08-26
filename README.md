# Repositorio Terraform
## Pré-requisitos

### Instação dos seguintes items: 
- AWS CLI ([Guia de instalação](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- Terraform ([Guia de instalçao](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- Ansible ([Guia de instalaçao](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html))
- Criação de um usuário **Terraform** na aws com *Programatic access* e com acesso de administrador.

### Inicializar AWS Cli com as credencias do usuario Terraform
Utilize o seguinte comando para criar um profile para a AWS Cli:
```
aws configure --profile terraform_user
```
Preecha os campos corretamente!

## Descrição dos projetos

### support-infra: 
- Repositorio que contem recursos de rede como VPC, Subnets, Security Groups, IGW, Route Tables, etc.
- **Atenção**: Deve ser o primeiro a ser aplicado e o ultimo a ser destruido.

### app-infra
- Repositorio que contem os recursos relacionados ao app, frontend e backend, como ECS, Load Balancer, S3, CloudFront
- Depende do projeto *support-infra*, portanto aplique somentes após aplicar o projeto anterior.
- O *output* é o endereço de acesso para o frontend (http://\<CLOUDFRONT_DNS\>/) e para o backend (http://\<CLOUDFRONT_DNS\>/api). 
- **Atenção**: O acesso deve ser feito usando o protocolo **HTTP**.

## Aplicando (implantando) a infraestrutura

**Importante:** Siga exatamente essa ordem de implantação

## support-infra
- Vá até o path do ambiente de integration
```
cd support-infra/integration/
```
- Inicialize o Terraform
```
terraform init
```
- Utilize o comando plan (verifique os recursos a serem criados)
```
terraform plan
```
- Utilize o comando apply (se preferir, pode validar novamente os recursos) e digite yes.
```
terraform apply
```

## app-infra

- Vá até o path do ambiente de integration
```
cd app-infra/integration/
```
- Inicialize o Terraform
```
terraform init
```
- Utilize o comando plan (verifique os recursos a serem criados)
```
terraform plan
```
- Utilize o comando apply (se preferir, pode validar novamente os recursos) e digite yes.
```
terraform apply
```

## Destruindo a infraestrutura
**Importante:** Siga exatamente essa ordem de destruição

## app-infra

- Vá até o path do ambiente de integration
```
cd app-infra/integration/
```
- Utilize o comando destroy (verifique os recursos a serem destruidos) e digite yes
```
terraform destroy
```

## support-infra
- Vá até o path do ambiente de integration
```
cd support-infra/integration/
```
- Utilize o comando destroy (verifique os recursos a serem destruidos) e digite yes
```
terraform destroy
```

