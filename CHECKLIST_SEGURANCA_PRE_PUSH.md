# Checklist de Segurança Pré-Push (EcoBike)

Use este checklist **antes de cada `git push`** para evitar vazamento de dados sensíveis.

---

## 1) Arquivos que NÃO devem ir para o Git

Verifique se estes padrões estão no `.gitignore`:

- `.env*`
- `*.pem`
- `*.key`
- `*.log`
- `*.tar`
- `logs/`

Comando rápido:

```bash
grep -nE "(\.env\*|\*\.pem|\*\.key|\*\.log|\*\.tar|/logs)" .gitignore
```

---

## 2) Revisar mudanças staged

Veja exatamente o que será enviado:

```bash
git status
git diff --staged
```

Checklist humano:

- [ ] Não tem domínio/IP interno desnecessário
- [ ] Não tem caminho absoluto de servidor (`/root`, `/etc/nginx`, `/opt/...`)
- [ ] Não tem credenciais, tokens, segredos
- [ ] Não tem arquivos de dump/backup

---

## 3) Scanner rápido de conteúdo sensível

Execute no projeto antes de subir:

```bash
git grep -nEi "password|secret|token|api[_-]?key|private[_-]?key|BEGIN RSA|BEGIN OPENSSH|DB_PASSWORD|MINIO_ROOT_PASSWORD" -- .
```

Se aparecer algo, revisar antes do push.

---

## 4) Verificar tamanho de arquivos

GitHub bloqueia arquivos > 100MB:

```bash
find . -type f -size +95M -not -path "./.git/*"
```

Se aparecer arquivo grande:

1. remover do versionamento (`git rm --cached <arquivo>`)
2. adicionar padrão no `.gitignore`
3. novo commit

---

## 5) Fluxo padrão seguro de publicação

```bash
git add .
git status
git diff --staged
git commit -m "mensagem clara"
git push
```

---

## 6) Se vazou algo por engano

Ações imediatas:

1. Revogar/rotacionar segredo exposto
2. Remover do estado atual do branch
3. Reescrever histórico (quando necessário)
4. `git push --force` com alinhamento do time

---

## 7) Política para o time

- Nunca commitar `.env` ou credenciais
- Nunca publicar detalhes internos de infraestrutura em docs públicas
- Revisar `git diff --staged` antes de todo push
- Em dúvida: abrir PR e pedir revisão

---

## 8) Comandos de auditoria periódica

```bash
# Busca no estado atual
git grep -nEi "password|secret|token|api[_-]?key|private[_-]?key|BEGIN RSA|BEGIN OPENSSH" -- .

# Busca no histórico
git rev-list --all | while read c; do
  git grep -nEi "password|secret|token|api[_-]?key|private[_-]?key|BEGIN RSA|BEGIN OPENSSH" "$c" -- .
done
```

Se esses comandos retornarem vazio, ótimo sinal.
