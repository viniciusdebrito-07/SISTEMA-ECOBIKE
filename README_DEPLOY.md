# 🚀 Guia de Deploy - EcoBike

**Sistema de Locação de Bicicletas Elétricas**  
Desenvolvido por: Luis Mesquitela com Windsurf AI

---

## 📋 Pré-requisitos

### Software Necessário

- **Node.js** versão 18.x ou superior
- **npm** ou **yarn**
- **PM2** (gerenciador de processos)
- **Git** (opcional, para clone do repositório)

---

## 🔧 Instalação no Servidor

### 1. Verificar Node.js instalado

```bash
node --version
npm --version
```

Se não estiver instalado:

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# CentOS/RHEL
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs
```

### 2. Instalar PM2 globalmente

```bash
sudo npm install -g pm2
```

### 3. Fazer upload do projeto

Faça upload da pasta completa do projeto para o servidor:

```bash
# Exemplo usando SCP
scp -r prototipagem/ usuario@servidor:/var/www/ecobike/

# Ou usando SFTP, FileZilla, etc.
```

---

## ⚙️ Configuração

### 1. Navegar até a pasta do projeto

```bash
cd /var/www/ecobike/prototipagem
```

### 2. Instalar dependências

```bash
npm install
```

### 3. Configurar porta do servidor

**IMPORTANTE:** Você já tem serviços nas portas 80 e 9000.  
O EcoBike rodará na **porta 3000** por padrão.

Para alterar a porta, crie um arquivo `.env.local`:

```bash
nano .env.local
```

Adicione:

```env
PORT=3000
# Ou outra porta disponível (ex: 3001, 8080, 5000)
```

### 4. Build do projeto

```bash
npm run build
```

Aguarde a compilação finalizar. Você verá:

```
✓ Compiled successfully
Route (app)
┌ ○ /
├ ○ /login
├ ○ /map
...
```

---

## 🚀 Executar o Sistema

### Opção 1: Usando PM2 (Recomendado)

PM2 mantém o processo rodando mesmo após reiniciar o servidor.

#### Criar arquivo de configuração PM2

```bash
nano ecosystem.config.js
```

Cole o seguinte conteúdo:

```javascript
module.exports = {
  apps: [{
    name: 'ecobike',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/ecobike/prototipagem',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
```

#### Iniciar com PM2

```bash
pm2 start ecosystem.config.js
```

#### Verificar status

```bash
pm2 status
pm2 logs ecobike
```

#### Configurar PM2 para iniciar no boot

```bash
pm2 startup
pm2 save
```

### Opção 2: Executar manualmente (Teste)

```bash
npm start
```

O servidor iniciará na porta configurada (padrão: 3000).

---

## 🌐 Configurar Proxy Reverso (Nginx)

Para acessar o EcoBike através de um domínio ou subdomínio sem especificar a porta.

### 1. Instalar Nginx (se não estiver instalado)

```bash
sudo apt-get install nginx
```

### 2. Criar configuração do site

```bash
sudo nano /etc/nginx/sites-available/ecobike
```

Cole:

```nginx
server {
    listen 80;
    server_name ecobike.seudominio.com;  # Altere para seu domínio

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Ativar o site

```bash
sudo ln -s /etc/nginx/sites-available/ecobike /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 4. Configurar SSL (Opcional, mas recomendado)

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d ecobike.seudominio.com
```

---

## 📊 Portas Utilizadas

| Serviço | Porta | Status |
|---------|-------|--------|
| Serviço Existente 1 | 80 | ✅ Em uso |
| Serviço Existente 2 | 9000 | ✅ Em uso |
| **EcoBike** | **3000** | 🆕 Nova |

**Não há conflito de portas!**

---

## 🔍 Verificação e Testes

### 1. Verificar se o servidor está rodando

```bash
pm2 status
```

Você deve ver:

```
┌─────┬──────────┬─────────┬─────────┬─────────┬──────────┐
│ id  │ name     │ status  │ restart │ uptime  │ cpu      │
├─────┼──────────┼─────────┼─────────┼─────────┼──────────┤
│ 0   │ ecobike  │ online  │ 0       │ 5m      │ 0%       │
└─────┴──────────┴─────────┴─────────┴─────────┴──────────┘
```

### 2. Testar acesso local

```bash
curl http://localhost:3000
```

### 3. Testar no navegador

- **Acesso direto por porta**: `http://seu-servidor-ip:3000`
- **Acesso por domínio** (se configurou Nginx): `http://ecobike.seudominio.com`

### 4. Testar funcionalidades

1. Login: `http://seu-servidor:3000/login`
2. Mapa: `http://seu-servidor:3000/map`
3. Admin: `http://seu-servidor:3000/admin/login`

---

## 🛠️ Comandos Úteis PM2

```bash
# Ver status de todos os processos
pm2 status

# Ver logs em tempo real
pm2 logs ecobike

# Reiniciar aplicação
pm2 restart ecobike

# Parar aplicação
pm2 stop ecobike

# Remover aplicação
pm2 delete ecobike

# Monitorar recursos
pm2 monit

# Salvar configuração atual
pm2 save
```

---

## 🔄 Atualizar o Sistema

Quando precisar atualizar o código:

```bash
# 1. Navegar até a pasta
cd /var/www/ecobike/prototipagem

# 2. Fazer backup (opcional)
cp -r . ../backup-$(date +%Y%m%d)

# 3. Atualizar arquivos (upload novos arquivos)

# 4. Reinstalar dependências (se necessário)
npm install

# 5. Rebuild
npm run build

# 6. Reiniciar com PM2
pm2 restart ecobike
```

---

## 🐛 Troubleshooting

### Erro: Porta já em uso

```bash
# Verificar o que está usando a porta
sudo lsof -i :3000

# Mudar para outra porta no .env.local
PORT=3001
```

### Erro: Módulos não encontrados

```bash
# Reinstalar dependências
rm -rf node_modules package-lock.json
npm install
```

### Erro: Build falhou

```bash
# Verificar versão do Node
node --version  # Deve ser 18.x ou superior

# Limpar cache
npm cache clean --force
npm install
npm run build
```

### PM2 não inicia no boot

```bash
pm2 unstartup
pm2 startup
pm2 save
```

### Logs de erro

```bash
# Ver logs do PM2
pm2 logs ecobike --lines 100

# Ver logs do Nginx
sudo tail -f /var/log/nginx/error.log
```

---

## 📁 Estrutura de Pastas no Servidor

```
/var/www/ecobike/
├── prototipagem/          # Projeto principal
│   ├── .next/             # Build do Next.js
│   ├── node_modules/      # Dependências
│   ├── src/               # Código fonte
│   ├── public/            # Arquivos públicos
│   ├── package.json
│   ├── .env.local         # Variáveis de ambiente
│   └── ecosystem.config.js # Configuração PM2
└── backup-YYYYMMDD/       # Backups (opcional)
```

---

## 🔒 Segurança

### 1. Firewall

```bash
# Permitir apenas portas necessárias
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

### 2. Permissões de arquivos

```bash
# Definir proprietário correto
sudo chown -R $USER:$USER /var/www/ecobike

# Permissões seguras
chmod -R 755 /var/www/ecobike
```

### 3. Variáveis de ambiente sensíveis

Nunca commite arquivos `.env` ou `.env.local` no Git.  
Adicione ao `.gitignore`:

```
.env
.env.local
.env.production
```

---

## 📞 Suporte

**Desenvolvedor:** Luis Mesquitela  
**Assistência:** Windsurf AI  
**Ano:** 2026

---

## ✅ Checklist de Deploy

- [ ] Node.js 18+ instalado
- [ ] PM2 instalado globalmente
- [ ] Projeto enviado para o servidor
- [ ] Dependências instaladas (`npm install`)
- [ ] Build realizado (`npm run build`)
- [ ] Porta configurada (padrão: 3000)
- [ ] PM2 configurado e rodando
- [ ] PM2 configurado para iniciar no boot
- [ ] Nginx configurado (opcional)
- [ ] SSL configurado (opcional)
- [ ] Testes realizados
- [ ] Backup configurado

---

**Sistema pronto para produção! 🚀**
