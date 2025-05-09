# Passo a Passo Detalhado do Projeto de Monitoramento de Sites

Este documento detalha todas as etapas realizadas no projeto de monitoramento de sites, desenvolvido como parte de um curso de DevSecOps. O objetivo do projeto era criar um script que verifica a disponibilidade de um site local a cada minuto e envia notificações ao Discord se o site estiver fora do ar. O projeto foi executado no Windows Subsystem for Linux (WSL) com Ubuntu, e este documento foi prepararado incluindo todos os comandos.

## 1. Configuração Inicial do Ambiente no WSL com Ubuntu

### 1.1. Verificar a Instalação do WSL
Eu já tinha o WSL instalado no meu Windows 10, com o Ubuntu como distribuição padrão. Para confirmar que estava funcionando:
- **Comando**:
  ```bash
  wsl --list
  ```
## 2. Instalação e Configuração do Nginx

O Nginx foi usado para hospedar uma página web (`index.html`) que seria monitorada pelo script.

### 2.1. Atualizar os Pacotes do Sistema
- **Comando**:
  ```bash
  sudo apt update
  ```
- **Comando**:
  ```bash
  sudo apt upgrade -y
  ```
  
### 2.2. Instalar o Nginx
- **Comando**:
  ```bash
  sudo apt install nginx -y
  ```
  
### 2.3. Verificar o Status do Nginx
- **Comando**:
  ```bash
  sudo systemctl status nginx
  ```
  
## 3. Configuração do Diretório e Permissões para o Site

### 3.1. Criar o Diretório para o Site
- **Comando**:
  ```bash
  sudo mkdir -p /var/www/tkg
  ```

### 3.2. Ajustar as Permissões do Diretório
- **Comando**:
  ```bash
  sudo chown sakae:sakae /opt/scripts
  sudo chmod 755 /opt/scripts
  sudo chown sakae:sakae /opt/scripts/monitor_site.sh
  sudo chmod 755 /opt/scripts/monitor_site.sh
  ```
- **Comando**:
  ```bash
  sudo chmod -R 755 /var/www/tkg
  ```
## 4. Criar e Configurar o Arquivo `index.html`

### 4.1. Criar o Arquivo `index.html`
- **Comando**:
  ```bash
  sudo nano /var/www/tkg/index.html
  ```

- **Conteúdo do `index.html`**:
  ```html
  <!DOCTYPE html>
  <html lang="pt-BR">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Monitoramento de Site</title>
      <style>
          body {
              margin: 0;
              padding: 0;
              font-family: Arial, sans-serif;
              background-image: url('https://images.unsplash.com/photo-....');
              background-size: cover;
              background-position: center;
              height: 100vh;
              display: flex;
              justify-content: center;
              align-items: center;
              color: white;
              text-align: center;
          }
          .container {
              background: rgba(0, 0, 0, 0.5);
              padding: 20px;
              border-radius: 10px;
          }
          h1 {
              font-size: 3em;
              margin-bottom: 10px;
          }
          p {
              font-size: 1.5em;
          }
      </style>
  </head>
  <body>
      <div class="container">
          <h1>Bem-vindo ao Monitoramento de Site</h1>
          <p>Este site é um site para meu projeto compass de monitoramento.</p>
          <h2>Welcome to my Monitoring Site</h2>
          <p>This is a simple site for my monitoring project Compass.</p>
      </div>
  </body>
  </html>
  ```

## 5. Configurar o Nginx para Hospedar o Site

### 5.1. Criar o Arquivo de Configuração do Nginx
- **Comando**:
  ```bash
  sudo nano /etc/nginx/sites-available/tkg.conf
  ```
- **Conteúdo do Arquivo**:
  ```nginx
  server {
      listen 80;
      server_name 127.0.0.1;
      root /var/www/tkg;
      index index.html;
      location / {
          try_files $uri $uri/ /index.html;
      }
  }
  ```

### 5.2. Criar um Link Simbólico para Ativar o Site
- **Comando**:
  ```bash
  sudo ln -s /etc/nginx/sites-available/tkg.conf /etc/nginx/sites-enabled/tkg.conf
  ```

### 5.3. Testar a Configuração do Nginx
- **Comando**:
  ```bash
  sudo nginx -t
  ```
### 5.4. Reiniciar o Nginx
- **Comando**:
  ```bash
  sudo systemctl restart nginx
  ```
## 6. Criar o Script de Monitoramento (`monitor_site.sh`)

### 6.1. Criar o Diretório para o Script
- **Comando**:
  ```bash
  sudo mkdir -p /opt/scripts
  ```
### 6.2. Criar o Script
- **Comando**:
  ```bash
  sudo nano /opt/scripts/monitor_site.sh
  ```
- **Conteúdo do Script**:
  ```bash
  
  #!/bin/bash

  # Variáveis
  URL="http://127.0.0.1"
  LOG_FILE="/var/log/monitoramento.log"
  WEBHOOK_URL="$DISCORD_WEBHOOK_URL"
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Verificar se o arquivo de log existe, se não, criá-lo
  if [ ! -d "/var/log" ]; then
    sudo mkdir -p /var/log
    sudo chmod 755 /var/log
  fi
  # Verificar o status do site
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL" --connect-timeout 5)
  
  # Verificar o status do site
  if [ "$STATUS_CODE" -eq 200 ]; then
    echo "[$TIMESTAMP] Site $URL está OK (Status: $STATUS_CODE)" >> "$LOG_FILE"
  else
    echo "[$TIMESTAMP] Site $URL está FORA DO AR (Status: $STATUS_CODE)" >> "$LOG_FILE"
  
    # Enviar notificação ao Discord
    curl -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\": \">>> ALERTA: Site $URL está FORA DO AR! Status: $STATUS_CODE em $TIMESTAMP\"}" \
         "$WEBHOOK_URL"
  fi
  ```
### 6.3. Ajustar Permissões do Script
- **Comando**:
  ```bash
  sudo chmod +x /opt/scripts/monitor_site.sh
  ```
### 6.4. Testar o Script Manualmente
- **Comando**:
  ```bash
  sudo /opt/scripts/monitor_site.sh
  ```
- **Verificar o Log**:
  ```bash
  cat /var/log/monitoramento.log
  ```
- **Saída do Log** (exemplo):
  ```
  2025-04-21 14:10:01 - Site http://127.0.0.1 está UP (Status: 200)
  ```
## 7. Configurar o Cron para Executar o Script a Cada Minuto

### 7.1. Editar o Crontab
- **Comando**:
  ```bash
  crontab -e
  ```
- **Adicionar a Linha no Crontab**:
  ```
  * * * * * /opt/scripts/monitor_site.sh
  ```
### 7.2. Verificar o Crontab
- **Comando**:
  ```bash
  crontab -l
  ```
## 8. Criar o Diretório do Projeto e Copiar os Arquivos

### 8.1. Criar o Diretório do Projeto
- **Comando**:
  ```bash
  mkdir ~/projeto-devsecops
  cd ~/projeto-devsecops
  ```

### 8.2. Copiar os Arquivos para o Diretório
- **Comandos**:
  ```bash
  cp /var/www/tkg/index.html .
  cp /etc/nginx/sites-available/tkg ./nginx-default.conf
  cp /opt/scripts/monitor_site.sh .
  cp /var/spool/cron/crontabs/$USER ./crontab.txt
  ```
##9. Configurar o Git e Enviar os Arquivos para o GitHub

### 9.1. Inicializar o Repositório Git
- **Comando**:
  ```bash
  git init
  ```
- **Comando**:
  ```bash
  git branch -M main
  ```
### 9.2. Configurar Nome e E-mail no Git
- **Comando**:
  ```bash
  git config --global user.email "sakae@example.com"
  ```
- **Comando**:
  ```bash
  git config --global user.name "Sakae"
  ```
### 9.3. Adicionar e Commitar os Arquivos
- **Comando**:
  ```bash
  git add .
  ```

- **Comando**:
  ```bash
  git commit -m "Adiciona arquivos iniciais do projeto de monitoramento"
  ```
### 9.4. Configurar o Repositório Remoto no GitHub
- **Comando**:
  ```bash
  git remote add origin https://github.com/fabsakae/Linux_Compass.git
  ```

- **Verificar o Remoto**:
  ```bash
  git remote -v
  ```

### 9.5. Enviar os Arquivos para o GitHub
- **Comando**:
  ```bash
  git push -u origin main
  ```
- **Erro Encontrado**:
  Recebi o seguinte erro ao tentar fazer o push:
  ```
  Username for 'https://github.com': fabsakae
  Password for 'https://fabsakae@github.com':
  remote: Support for password authentication was removed on August 13, 2021.
  remote: Please see https://docs.github.com/get-started/getting-started-with-git/about-remote-repositories#cloning-with-https-urls for information on currently recommended modes of authentication.
  fatal: Authentication failed for 'https://github.com/fabsakae/Linux_Compass.git/'
  ```
- **Explicação do Erro**:
  - O GitHub não aceita mais autenticação por senha desde agosto de 2021. Quando digitei meu nome de usuário (`fabsakae`) e minha senha do GitHub, o push falhou.
  - O GitHub recomenda usar um token de acesso pessoal (Personal Access Token) ou autenticação via SSH.

- **Solução: Criar um Token de Acesso Pessoal**:
  1. Acessei o GitHub (`https://github.com`) e fiz login com minha conta (`fabsakae`).
  2. Fui para **Settings > Developer settings > Personal access tokens > Generate new token**.
  3. Configurei o token:
     - **Note**: "Projeto Linux Compass".
     - **Expiration**: 30 dias.
     - **Scopes**: Marquei `repo` (para acesso a repositórios).
     - Cliquei em **Generate token**.
  4. Copiei o token gerado (ex.: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`).

- **Tentar o Push Novamente**:
  ```bash
  git push -u origin main
  ```

### 10. Fazer Upload no GitHub
- Acessei o repositório no GitHub: `https://github.com/fabsakae/Linux_Compass`.
- Cliquei em **Add file > Upload files**.
- Arrastei os arquivos `log_screenshot.png` e `discord_screenshot.png` da área de trabalho para a área de upload.
- Na mensagem de commit, digitei:
  ```
  Adiciona capturas de tela do log e notificações do Discord
  ```
- Cliquei em **Commit changes**.

## 12. Lições Aprendidas e Desafios Superados

- **Configuração do Ambiente**:
  - Aprendi a usar o WSL com Ubuntu para executar comandos Linux no Windows.
  - Descobri como acessar arquivos do Windows a partir do WSL.

- **Nginx**:
  - Instalei e configurei o Nginx para hospedar um site local.
  - Criei um arquivo de configuração e ativei o site com um link simbólico.

- **Script de Monitoramento**:
  - Escrevi um script Bash que usa `curl` para verificar o status de um site e envia notificações ao Discord.
  - Configurei o cron para executar o script a cada minuto.
    
- **Variável de ambiente**:
  ``` bash
  nano ~/.bashrc
  ```
  ```
  export DISCORD_WEBHOOK_URL= "HTTPS://discord..."
  ```
  ```
  sourse ~/.bashrc
  ```
  - **Git e GitHub**:
  - Inicializei um repositório Git, configurei meu nome e e-mail, e enviei os arquivos para o GitHub.
  - Resolvi problemas como:
    - **Erro de autenticação no GitHub**: Criei um token de acesso pessoal para autenticar o `git push`.

- **Documentação**:
  - Criei um `README.md` para documentar o projeto e exibir as capturas de tela.
  - Escrevi este documento detalhado para atender à solicitação do Thiago.

## 13. Conclusão

Este projeto foi uma ótima oportunidade para aprender sobre servidores web (Nginx), automação com scripts Bash, agendamento de tarefas (cron), controle de versão (Git), e colaboração online (GitHub).
