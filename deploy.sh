#!/bin/bash

###############################################################################
# Script de Deploy - EcoBike
# Desenvolvido por: Luis Mesquitela com Windsurf AI
# 
# Este script automatiza o processo de deploy no servidor
###############################################################################

echo "🚀 Iniciando deploy do EcoBike..."
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar Node.js
echo "📦 Verificando Node.js..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js não encontrado. Instale Node.js 18+ primeiro.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js $(node --version) encontrado${NC}"
echo ""

# Verificar npm
echo "📦 Verificando npm..."
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm não encontrado.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm $(npm --version) encontrado${NC}"
echo ""

# Instalar dependências
echo "📥 Instalando dependências..."
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao instalar dependências${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dependências instaladas${NC}"
echo ""

# Build do projeto
echo "🔨 Compilando projeto..."
npm run build
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao compilar projeto${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Projeto compilado com sucesso${NC}"
echo ""

# Verificar PM2
echo "🔍 Verificando PM2..."
if ! command -v pm2 &> /dev/null; then
    echo -e "${YELLOW}⚠️  PM2 não encontrado. Instalando...${NC}"
    npm install -g pm2
fi
echo -e "${GREEN}✅ PM2 disponível${NC}"
echo ""

# Criar pasta de logs
mkdir -p logs

# Iniciar/Reiniciar com PM2
echo "🚀 Iniciando aplicação com PM2..."
if pm2 list | grep -q "ecobike"; then
    echo "♻️  Reiniciando aplicação existente..."
    pm2 restart ecobike
else
    echo "🆕 Iniciando nova aplicação..."
    pm2 start ecosystem.config.js
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Erro ao iniciar com PM2${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Aplicação iniciada com sucesso${NC}"
echo ""

# Salvar configuração PM2
pm2 save

# Mostrar status
echo "📊 Status da aplicação:"
pm2 status

echo ""
echo -e "${GREEN}✅ Deploy concluído com sucesso!${NC}"
echo ""
echo "📍 Acesse a aplicação em:"
echo "   http://localhost:3000"
echo ""
echo "📝 Comandos úteis:"
echo "   pm2 logs ecobike     - Ver logs"
echo "   pm2 restart ecobike  - Reiniciar"
echo "   pm2 stop ecobike     - Parar"
echo "   pm2 monit            - Monitorar"
echo ""
