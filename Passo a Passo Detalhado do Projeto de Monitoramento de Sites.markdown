# Passo a Passo Detalhado do Projeto de Monitoramento de Sites

Este documento detalha todas as etapas realizadas no projeto de monitoramento de sites, desenvolvido como parte de um curso de DevSecOps. O objetivo do projeto era criar um script que verifica a disponibilidade de um site local a cada minuto e envia notificações ao Discord se o site estiver fora do ar. O projeto foi executado no Windows Subsystem for Linux (WSL) com Ubuntu, e este documento foi preparado para atender à solicitação do instrutor Thiago, incluindo todos os comandos, saídas, erros encontrados, soluções aplicadas e explicações completas.

## 1. Configuração Inicial do Ambiente no WSL com Ubuntu

### 1.1. Verificar a Instalação do WSL
Eu já tinha o WSL instalado no meu Windows 10, com o Ubuntu 20.04 como distribuição padrão. Para confirmar que estava funcionando:
- **Comando**:
  ```bash
  wsl --list
  ```
- **Saída Esperada**:
  ```
    wsl --list
      Ubuntu-20.04 (Default)
  ```
- **Explicação**:
  - `wsl --list` lista as distribuições Linux instaladas no WSL.
  - A saída confirmou que o Ubuntu-20.04 estava instalado e definido como padrão (por causa do "(Default)").

### 1.2. Acessar o Ubuntu no WSL
- **Comando**:
  ```bash
  wsl
  ```
- **Saída Esperada**:
  - O terminal muda para o prompt do Ubuntu, algo como:
    ```
    sakae@Fabola:~$ 
    ```
- **Explicação**:
  - `wsl` inicia a distribuição padrão (Ubuntu) no terminal do Windows (eu usei o Windows Terminal).
  - O prompt `sakae@Fabola` indica que estou logada como o usuário `sakae` na máquina `Fabola`.

## 2. Instalação e Configuração do Nginx

O Nginx foi usado para hospedar uma página web (`index.html`) que seria monitorada pelo script.

### 2.1. Atualizar os Pacotes do Sistema
- **Comando**:
  ```bash
  sudo apt update
  ```
- **Saída Esperada**:
  ```
  Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
  Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
  ...
  Fetched 2,123 kB in 2s (1,234 kB/s)
  Reading package lists... Done
  ```
- **Explicação**:
  - `sudo apt update` atualiza a lista de pacotes disponíveis nos repositórios do Ubuntu.
  - `sudo` dá privilégios de administrador, necessários para instalar pacotes.

- **Comando**:
  ```bash
  sudo apt upgrade -y
  ```
- **Saída Esperada**:
  ```
  Reading package lists... Done
  Building dependency tree       
  Reading state information... Done
  Calculating upgrade... Done
  0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
  ```
- **Explicação**:
  - `sudo apt upgrade` instala as versões mais recentes dos pacotes.
  - O `-y` responde "yes" automaticamente para qualquer confirmação, economizando tempo.

### 2.2. Instalar o Nginx
- **Comando**:
  ```bash
  sudo apt install nginx -y
  ```
- **Saída Esperada**:
  ```
  Reading package lists... Done
  Building dependency tree       
  Reading state information... Done
  The following additional packages will be installed:
    nginx-common nginx-core
  ...
  Setting up nginx-core (1.18.0-0ubuntu1.2) ...
  Setting up nginx (1.18.0-0ubuntu1.2) ...
  ```
- **Explicação**:
  - `sudo apt install nginx` instala o Nginx, um servidor web leve.
  - O `-y` evita que o comando peça confirmação manual.

### 2.3. Verificar o Status do Nginx
- **Comando**:
  ```bash
  sudo systemctl status nginx
  ```
- **Saída Esperada**:
  ```
  ● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-04-21 14:00:00 UTC; 1min ago
     ...
  ```
- **Explicação**:
  - `sudo systemctl status nginx` verifica se o Nginx está rodando.
  - A linha `Active: active (running)` confirma que o serviço está funcionando.
  - Se o Nginx não estivesse ativo, eu usaria `sudo systemctl start nginx` para iniciá-lo.

## 3. Configuração do Diretório e Permissões para o Site

### 3.1. Criar o Diretório para o Site
- **Comando**:
  ```bash
  sudo mkdir -p /var/www/tkg
  ```
- **Saída Esperada**:
  - Nenhuma saída (o comando cria o diretório silenciosamente).
- **Explicação**:
  - `sudo mkdir -p /var/www/tkg` cria o diretório `/var/www/tkg`, que será usado para hospedar o arquivo `index.html`.
  - O `-p` cria os diretórios pai (`/var/www`) se eles não existirem.

### 3.2. Ajustar as Permissões do Diretório
- **Comando**:
  ```bash
  sudo chown -R www-data:www-data /var/www/tkg
  ```
- **Saída Esperada**:
  - Nenhuma saída (o comando muda o dono silenciosamente).
- **Explicação**:
  - `sudo chown -R www-data:www-data /var/www/tkg` muda o dono do diretório para o usuário `www-data` (o usuário padrão do Nginx).
  - O `-R` aplica a mudança recursivamente a todos os arquivos e subdiretórios dentro de `/var/www/tkg`.

- **Comando**:
  ```bash
  sudo chmod -R 755 /var/www/tkg
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - `sudo chmod -R 755 /var/www/tkg` define as permissões do diretório.
  - `755` significa: o dono (`www-data`) tem leitura, escrita e execução (7); outros usuários têm leitura e execução (5). Isso permite que o Nginx acesse o diretório.

## 4. Criar e Configurar o Arquivo `index.html`

### 4.1. Criar o Arquivo `index.html`
- **Comando**:
  ```bash
  sudo nano /var/www/tkg/index.html
  ```
- **Saída Esperada**:
  - O editor Nano abre, permitindo que eu edite o arquivo.
- **Explicação**:
  - `sudo nano /var/www/tkg/index.html` abre o editor Nano para criar o arquivo `index.html` no diretório `/var/www/tkg`.
  - Usei `sudo` porque o diretório pertence ao usuário `www-data`.

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
              background-image: url('https://images.unsplash.com/photo-1507525428034-b723cf961d3e');
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
          <p>Este site está sendo monitorado a cada minuto.</p>
      </div>
  </body>
  </html>
  ```
- **Explicação**:
  - Esse arquivo HTML cria uma página estilizada com um fundo de montanha nevada (usando uma imagem do Unsplash), um título (`h1`), e um parágrafo (`p`).
  - O CSS no `<style>` centraliza o conteúdo, adiciona um fundo semi-transparente ao container, e define fontes e cores.
  - Salvei o arquivo com `Ctrl + O`, pressionei Enter, e saí do Nano com `Ctrl + X`.

## 5. Configurar o Nginx para Hospedar o Site

### 5.1. Criar o Arquivo de Configuração do Nginx
- **Comando**:
  ```bash
  sudo nano /etc/nginx/sites-available/tkg
  ```
- **Saída Esperada**:
  - O editor Nano abre.
- **Explicação**:
  - Isso cria um novo arquivo de configuração chamado `tkg` no diretório `/etc/nginx/sites-available`, onde o Nginx armazena configurações de sites.

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
- **Explicação**:
  - `listen 80`: O Nginx escuta na porta 80 (padrão para HTTP).
  - `server_name 127.0.0.1`: Define que o site será acessado via `http://127.0.0.1`.
  - `root /var/www/tkg`: Especifica o diretório onde o `index.html` está.
  - `index index.html`: Define `index.html` como o arquivo padrão a ser servido.
  - `location / { try_files $uri $uri/ /index.html; }`: Tenta servir o arquivo solicitado; se não encontrar, serve o `index.html`.
  - Salvei com `Ctrl + O`, Enter, e saí com `Ctrl + X`.

### 5.2. Criar um Link Simbólico para Ativar o Site
- **Comando**:
  ```bash
  sudo ln -s /etc/nginx/sites-available/tkg /etc/nginx/sites-enabled/
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - `sudo ln -s` cria um link simbólico do arquivo de configuração no diretório `/etc/nginx/sites-enabled/`, que é onde o Nginx procura configurações ativas.

### 5.3. Testar a Configuração do Nginx
- **Comando**:
  ```bash
  sudo nginx -t
  ```
- **Saída Esperada**:
  ```
  nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
  nginx: configuration file /etc/nginx/nginx.conf test is successful
  ```
- **Explicação**:
  - `sudo nginx -t` verifica se há erros na configuração do Nginx.
  - A saída confirma que a sintaxe está correta.

### 5.4. Reiniciar o Nginx
- **Comando**:
  ```bash
  sudo systemctl restart nginx
  ```
- **Saída Esperada**:
  - Nenhuma saída visível (o comando reinicia o serviço silenciosamente).
- **Explicação**:
  - `sudo systemctl restart nginx` reinicia o Nginx para aplicar as novas configurações.

### 5.5. Testar o Site
- **Comando**:
  ```bash
  curl http://127.0.0.1
  ```
- **Saída Esperada**:
  ```
  <!DOCTYPE html>
  <html lang="pt-BR">
  <head>
      <meta charset="UTF-8">
      ...
      <h1>Bem-vindo ao Monitoramento de Site</h1>
      <p>Este site está sendo monitorado a cada minuto.</p>
      ...
  ```
- **Explicação**:
  - `curl http://127.0.0.1` faz uma requisição HTTP ao site hospedado no Nginx.
  - A saída mostra o conteúdo do `index.html`, confirmando que o site está funcionando.

## 6. Criar o Script de Monitoramento (`monitor_site.sh`)

### 6.1. Criar o Diretório para o Script
- **Comando**:
  ```bash
  sudo mkdir -p /opt/scripts
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - `sudo mkdir -p /opt/scripts` cria o diretório `/opt/scripts`, que será usado para armazenar o script.

### 6.2. Criar o Script
- **Comando**:
  ```bash
  sudo nano /opt/scripts/monitor_site.sh
  ```
- **Saída Esperada**:
  - O editor Nano abre.
- **Explicação**:
  - `sudo nano /opt/scripts/monitor_site.sh` cria o arquivo `monitor_site.sh` no diretório `/opt/scripts`.

- **Conteúdo do Script**:
  ```bash
  #!/bin/bash

  # Variáveis
  URL="http://127.0.0.1"
  LOG_FILE="/var/log/monitoramento.log"
  DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."

  # Verificar se o arquivo de log existe, se não, criá-lo
  if [ ! -f "$LOG_FILE" ]; then
      sudo touch "$LOG_FILE"
      sudo chown www-data:www-data "$LOG_FILE"
      sudo chmod 644 "$LOG_FILE"
  fi

  # Obter o código de status HTTP do site
  STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  # Verificar se o site está UP ou DOWN
  if [ "$STATUS_CODE" -eq 200 ]; then
      echo "$TIMESTAMP - Site $URL está UP (Status: $STATUS_CODE)" >> $LOG_FILE
  else
      echo "$TIMESTAMP - Site $URL está DOWN (Status: $STATUS_CODE)" >> $LOG_FILE
      MESSAGE="Site $URL está DOWN! (Status: $STATUS_CODE) em $TIMESTAMP"
      curl -H "Content-Type: application/json" -d "{\"content\": \"$MESSAGE\"}" $DISCORD_WEBHOOK_URL
  fi
  ```
- **Explicação**:
  - `#!/bin/bash`: Indica que o script é escrito em Bash.
  - `URL="http://127.0.0.1"`: Define o site a ser monitorado.
  - `LOG_FILE="/var/log/monitoramento.log"`: Define o caminho do arquivo de log.
  - `DISCORD_WEBHOOK_URL`: O webhook do Discord para enviar notificações (configurei isso no canal `#boas-vindas-e-regras` no Discord).
  - `if [ ! -f "$LOG_FILE" ]`: Verifica se o arquivo de log existe; se não, cria com permissões adequadas.
  - `STATUS_CODE=$(curl ...)`: Usa `curl` para obter o código de status HTTP do site (`200` significa "OK").
  - `TIMESTAMP=$(date ...)`: Obtém a data e hora atual.
  - `if [ "$STATUS_CODE" -eq 200 ]`: Verifica se o site está funcionando (status 200).
  - `echo ... >> $LOG_FILE`: Registra o resultado (UP ou DOWN) no arquivo de log.
  - `curl -H ...`: Envia uma notificação ao Discord se o site estiver fora do ar.
  - Salvei com `Ctrl + O`, Enter, e saí com `Ctrl + X`.

### 6.3. Ajustar Permissões do Script
- **Comando**:
  ```bash
  sudo chmod +x /opt/scripts/monitor_site.sh
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - `sudo chmod +x /opt/scripts/monitor_site.sh` torna o script executável, permitindo que ele seja rodado como um programa.

### 6.4. Testar o Script Manualmente
- **Comando**:
  ```bash
  sudo /opt/scripts/monitor_site.sh
  ```
- **Saída Esperada**:
  - Nenhuma saída visível no terminal, mas o arquivo `/var/log/monitoramento.log` é atualizado.
- **Verificar o Log**:
  ```bash
  cat /var/log/monitoramento.log
  ```
- **Saída do Log** (exemplo):
  ```
  2025-04-21 14:10:01 - Site http://127.0.0.1 está UP (Status: 200)
  ```
- **Explicação**:
  - Executei o script manualmente para confirmar que ele funcionava.
  - O log mostrou que o site estava UP (status 200).

## 7. Configurar o Cron para Executar o Script a Cada Minuto

### 7.1. Editar o Crontab
- **Comando**:
  ```bash
  crontab -e
  ```
- **Saída Esperada**:
  - O editor Nano (ou o editor padrão) abre o arquivo de configuração do cron.
  - Se for a primeira vez usando `crontab -e`, pode aparecer uma mensagem para escolher o editor:
    ```
    Select an editor.  To change later, run 'select-editor'.
      1. /bin/nano        <---- easiest
      2. /usr/bin/vim.basic
      ...
    ```
    Escolhi a opção 1 (Nano) digitando `1` e pressionando Enter.

- **Adicionar a Linha no Crontab**:
  ```
  * * * * * /opt/scripts/monitor_site.sh
  ```
- **Explicação**:
  - `* * * * *` significa que o script será executado a cada minuto (os cinco asteriscos representam minuto, hora, dia, mês e dia da semana).
  - `/opt/scripts/monitor_site.sh` é o caminho do script a ser executado.
  - Salvei com `Ctrl + O`, Enter, e saí com `Ctrl + X`.

### 7.2. Verificar o Crontab
- **Comando**:
  ```bash
  crontab -l
  ```
- **Saída Esperada**:
  ```
  * * * * * /opt/scripts/monitor_site.sh
  ```
- **Explicação**:
  - `crontab -l` lista as tarefas agendadas no cron, confirmando que a configuração foi aplicada.

## 8. Criar o Diretório do Projeto e Copiar os Arquivos

### 8.1. Criar o Diretório do Projeto
- **Comando**:
  ```bash
  mkdir ~/projeto-devsecops
  cd ~/projeto-devsecops
  ```
- **Saída Esperada**:
  - Nenhuma saída para `mkdir`.
  - O prompt muda para:
    ```
    sakae@Fabola:~/projeto-devsecops$
    ```
- **Explicação**:
  - `mkdir ~/projeto-devsecops` cria o diretório `projeto-devsecops` no meu diretório home (`~`).
  - `cd ~/projeto-devsecops` entra nesse diretório para trabalhar nele.

### 8.2. Copiar os Arquivos para o Diretório
- **Comandos**:
  ```bash
  cp /var/www/tkg/index.html .
  cp /etc/nginx/sites-available/tkg ./nginx-default.conf
  cp /opt/scripts/monitor_site.sh .
  cp /var/spool/cron/crontabs/$USER ./crontab.txt
  ```
- **Saída Esperada**:
  - Nenhuma saída para os comandos `cp`.
- **Explicação**:
  - `cp /var/www/tkg/index.html .`: Copia o arquivo `index.html` para o diretório atual (`.`).
  - `cp /etc/nginx/sites-available/tkg ./nginx-default.conf`: Copia a configuração do Nginx e renomeia para `nginx-default.conf`.
  - `cp /opt/scripts/monitor_site.sh .`: Copia o script de monitoramento.
  - `cp /var/spool/cron/crontabs/$USER ./crontab.txt`: Copia o arquivo de configuração do cron do meu usuário (`$USER` é uma variável que representa meu nome de usuário, `sakae`) e renomeia para `crontab.txt`.

### 8.3. Verificar os Arquivos Copiados
- **Comando**:
  ```bash
  ls -l
  ```
- **Saída Esperada**:
  ```
  total 16
  -rw-r--r-- 1 sakae sakae  39 Apr 19 18:36 crontab.txt
  -rwxr-xr-x 1 sakae sakae 1943 Apr 21 13:52 index.html
  -rwxr-xr-x 1 sakae sakae  872 Apr 19 18:48 monitor_site.sh
  -rw-r--r-- 1 sakae sakae  2412 Apr 19 18:31 nginx-default.conf
  ```
- **Explicação**:
  - `ls -l` lista os arquivos no diretório com detalhes (permissões, dono, tamanho, data).
  - Confirmei que os quatro arquivos foram copiados corretamente.

## 9. Configurar o Git e Enviar os Arquivos para o GitHub

### 9.1. Inicializar o Repositório Git
- **Comando**:
  ```bash
  git init
  ```
- **Saída Esperada**:
  ```
  Initialized empty Git repository in /home/sakae/projeto-devsecops/.git/
  ```
- **Explicação**:
  - `git init` inicializa um novo repositório Git no diretório `projeto-devsecops`, criando a pasta oculta `.git`.

- **Comando**:
  ```bash
  git branch -M main
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - `git branch -M main` renomeia a branch padrão de `master` para `main`, que é a convenção moderna no GitHub.

### 9.2. Configurar Nome e E-mail no Git
- **Comando**:
  ```bash
  git config --global user.email "sakae@example.com"
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - Define meu e-mail como `sakae@example.com` para todos os repositórios no meu computador (`--global`).

- **Comando**:
  ```bash
  git config --global user.name "Sakae"
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - Define meu nome como `Sakae` para todos os repositórios.

- **Erro Encontrado**:
  Quando tentei fazer o primeiro commit sem configurar o nome e e-mail, recebi o erro:
  ```
  Author identity unknown

  *** Please tell me who you are.

  Run

    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"

  to set your account's default identity.
  Omit --global to set the identity only in this repository.

  fatal: empty ident name (for <sakae@Fabola.>) not allowed
  ```
- **Solução**:
  - Executei os comandos `git config` acima para definir meu nome e e-mail, resolvendo o problema.

### 9.3. Adicionar e Commitar os Arquivos
- **Comando**:
  ```bash
  git add .
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - `git add .` adiciona todos os arquivos no diretório (`crontab.txt`, `index.html`, `monitor_site.sh`, `nginx-default.conf`) ao controle de versão do Git.

- **Comando**:
  ```bash
  git commit -m "Adiciona arquivos iniciais do projeto de monitoramento"
  ```
- **Saída Esperada**:
  ```
  [main (root-commit) 1234567] Adiciona arquivos iniciais do projeto de monitoramento
   4 files changed, 100 insertions(+)
   create mode 100644 crontab.txt
   create mode 100644 index.html
   create mode 100644 monitor_site.sh
   create mode 100644 nginx-default.conf
  ```
- **Explicação**:
  - `git commit -m` cria um commit com a mensagem especificada, registrando as mudanças no repositório.

### 9.4. Configurar o Repositório Remoto no GitHub
- **Comando**:
  ```bash
  git remote add origin https://github.com/fabsakae/Linux_Compass
  ```
- **Erro Encontrado**:
  Inicialmente, usei a URL sem `.git` no final, e isso causou problemas mais tarde. A URL correta é:
  ```bash
  git remote add origin https://github.com/fabsakae/Linux_Compass.git
  ```
- **Solução**:
  - Removi o remoto incorreto:
    ```bash
    git remote rm origin
    ```
    Mas recebi o erro:
    ```
    error: No such remote: 'origin'
    ```
    Isso aconteceu porque o comando `git remote add` anterior foi digitado incorretamente (sem o nome `origin`):
    ```bash
    git remote add https://github.com/fabsakae/Linux_Compass.git
    ```
    A sintaxe correta é `git remote add <nome> <URL>`. Corrigi executando o comando correto:
    ```bash
    git remote add origin https://github.com/fabsakae/Linux_Compass.git
    ```
- **Saída Esperada**:
  - Nenhuma saída para `git remote add`.

- **Verificar o Remoto**:
  ```bash
  git remote -v
  ```
- **Saída Esperada**:
  ```
  origin  https://github.com/fabsakae/Linux_Compass.git (fetch)
  origin  https://github.com/fabsakae/Linux_Compass.git (push)
  ```
- **Explicação**:
  - `git remote -v` lista os remotos configurados, confirmando que `origin` aponta para a URL correta.

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
- **Autenticação**:
  - **Username**: Digitei `fabsakae`.
  - **Password**: Colei o token (`ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`).
- **Saída Esperada**:
  ```
  Enumerating objects: 6, done.
  Counting objects: 100% (6/6), done.
  Delta compression using up to 4 threads
  Compressing objects: 100% (5/5), done.
  Writing objects: 100% (6/6), 1.23 KiB | 1.23 MiB/s, done.
  Total 6 (delta 0), reused 0 (delta 0), pack-reused 0
  To https://github.com/fabsakae/Linux_Compass.git
  * [new branch]      main -> main
  Branch 'main' set up to track remote branch 'main' from 'origin'.
  ```
- **Explicação**:
  - O push foi bem-sucedido após usar o token.
  - `-u` configura a branch `main` local para rastrear a branch `main` remota.

### 9.6. Armazenar Credenciais para Futuro
- **Comando**:
  ```bash
  git config --global credential.helper store
  ```
- **Saída Esperada**:
  - Nenhuma saída.
- **Explicação**:
  - `git config --global credential.helper store` salva minhas credenciais (usuário e token) em um arquivo (`~/.git-credentials`), para que eu não precise digitá-las novamente em futuros pushes.

## 10. Criar Capturas de Tela e Fazer Upload para o GitHub

### 10.1. Captura de Tela do Log de Monitoramento
- **Comando**:
  ```bash
  cat /var/log/monitoramento.log
  ```
- **Saída Esperada**:
  ```
  2025-04-21 14:10:01 - Site http://127.0.0.1 está UP (Status: 200)
  2025-04-21 14:11:01 - Site http://127.0.0.1 está DOWN (Status: 503)
  2025-04-21 14:12:01 - Site http://127.0.0.1 está UP (Status: 200)
  ```
- **Explicação**:
  - `cat /var/log/monitoramento.log` exibe o conteúdo do arquivo de log, mostrando o histórico de verificações do script.
  - Para testar o caso de "DOWN", parei o Nginx temporariamente (`sudo systemctl stop nginx`), executei o script manualmente, e reiniciei o Nginx (`sudo systemctl start nginx`).

- **Tirar a Captura de Tela**:
  - Como estou usando o WSL no Windows Terminal, o terminal é exibido no Windows.
  - Pressionei **Print Screen** para capturar a tela do terminal mostrando o log.
  - Abri o Paint (pressionando `Win + S`, digitando "Paint", e abrindo o aplicativo).
  - Colei a captura com `Ctrl + V`.
  - Salvei como `log_screenshot.png` na área de trabalho (`C:\Users\MeuUsuario\Desktop\log_screenshot.png`).

### 10.2. Captura de Tela das Notificações no Discord
- Acessei o Discord no navegador (ou aplicativo do Windows).
- Fui para o servidor e o canal `#boas-vindas-e-regras`, onde configurei o webhook para enviar notificações.
- **Mensagem no Discord** (exemplo):
  ```
  Site http://127.0.0.1 está DOWN! (Status: 503) em 2025-04-21 14:11:01
  ```
- **Tirar a Captura de Tela**:
  - Pressionei **Print Screen** para capturar a tela do Discord.
  - Abri o Paint, colei com `Ctrl + V`, e salvei como `discord_screenshot.png` na área de trabalho (`C:\Users\MeuUsuario\Desktop\discord_screenshot.png`).

### 10.3. Fazer Upload no GitHub
- Acessei o repositório no GitHub: `https://github.com/fabsakae/Linux_Compass`.
- Cliquei em **Add file > Upload files**.
- Arrastei os arquivos `log_screenshot.png` e `discord_screenshot.png` da área de trabalho para a área de upload.
- Na mensagem de commit, digitei:
  ```
  Adiciona capturas de tela do log e notificações do Discord
  ```
- Cliquei em **Commit changes**.

## 11. Criar o `README.md` no GitHub

- Na página principal do repositório, cliquei em **Add a README**.
- Adicionei o seguinte conteúdo:
  ```markdown
  # Projeto Linux Compass

  Este é um projeto de monitoramento de sites desenvolvido como parte de um curso de DevSecOps. O objetivo é monitorar a disponibilidade de um site local e enviar notificações via Discord quando ele está fora do ar.

  ## Funcionalidades
  - **Monitoramento de Site**: Um script Bash (`monitor_site.sh`) verifica a cada minuto se o site `http://127.0.0.1` está disponível.
  - **Notificações no Discord**: Quando o site está fora do ar, uma notificação é enviada para o canal `#boas-vindas-e-regras` no Discord.
  - **Página Web**: Uma página HTML estilizada (`index.html`) é hospedada no Nginx para testes, com um fundo de montanha nevada e design moderno.

  ## Estrutura do Projeto
  - `monitor_site.sh`: Script de monitoramento.
  - `index.html`: Página web de teste.
  - `crontab.txt`: Configuração do cron para agendamento.
  - `nginx-default.conf`: Configuração do Nginx.

  ## Como Executar
  1. Configure o Nginx e coloque o `index.html` em `/var/www/tkg/`.
  2. Copie o `monitor_site.sh` para `/opt/scripts/` e ajuste as permissões.
  3. Configure o cron para executar o script a cada minuto.
  4. Crie um webhook no Discord e configure a variável `DISCORD_WEBHOOK_URL` no script wrapper `run_monitor_site.sh`.

  ## Capturas de Tela
  - **Log de Monitoramento**:
    ![Log de Monitoramento](log_screenshot.png)
  - **Notificação no Discord**:
    ![Notificação no Discord](discord_screenshot.png)
  ```
- Cliquei em **Commit new file**.

## 12. Lições Aprendidas e Desafios Superados

- **Configuração do Ambiente**:
  - Aprendi a usar o WSL com Ubuntu para executar comandos Linux no Windows.
  - Descobri como acessar arquivos do Windows a partir do WSL (ex.: `/mnt/c/Users/MeuUsuario/Desktop`).

- **Nginx**:
  - Instalei e configurei o Nginx para hospedar um site local.
  - Criei um arquivo de configuração e ativei o site com um link simbólico.

- **Script de Monitoramento**:
  - Escrevi um script Bash que usa `curl` para verificar o status de um site e envia notificações ao Discord.
  - Configurei o cron para executar o script a cada minuto.

- **Git e GitHub**:
  - Inicializei um repositório Git, configurei meu nome e e-mail, e enviei os arquivos para o GitHub.
  - Resolvi problemas como:
    - **Erro de identidade no Git**: Configurei `user.name` e `user.email`.
    - **Erro na URL do remoto**: Corrigi a URL adicionando `.git` e usando a sintaxe correta (`git remote add origin`).
    - **Erro de autenticação no GitHub**: Criei um token de acesso pessoal para autenticar o `git push`.

- **Capturas de Tela**:
  - Aprendi a tirar capturas de tela no WSL capturando o terminal do Windows com **Print Screen** e salvando no Paint.
  - Fiz upload das capturas diretamente no GitHub.

- **Documentação**:
  - Criei um `README.md` para documentar o projeto e exibir as capturas de tela.
  - Escrevi este documento detalhado para atender à solicitação do Thiago.

## 13. Conclusão

Este projeto foi uma ótima oportunidade para aprender sobre servidores web (Nginx), automação com scripts Bash, agendamento de tarefas (cron), controle de versão (Git), e colaboração online (GitHub). Superei desafios técnicos, como erros de configuração no Git, e aprendi a documentar meu trabalho de forma clara e detalhada. Estou pronta para apresentar o projeto ao Thiago e responder a quaisquer perguntas!