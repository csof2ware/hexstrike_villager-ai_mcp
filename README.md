<div align="center">

<img src="./assets/csoftware-logo.png" width="220" />

# HEXSTRIKE + VILLAGER_AI MCP

<p>AI-Driven Cybersecurity Automation (HexStrike + Villager AI) disponibilizado como servidores MCP.</p>

<p>
  <strong>Empresa:</strong> CSOFTWARE<br/>
  <strong>Autor:</strong> Leonardo Marinho Poeiras<br/>
  <strong>Data:</strong> 29/03/2026
</p>

<p>
  <a href="https://opensource.org/licenses/MIT">MIT</a>
  &nbsp;|&nbsp;
  <a href="https://www.python.org/downloads/">Python</a>
  &nbsp;|&nbsp;
  <a href="https://www.docker.com/">Docker</a>
</p>

</div>

---

## Descricao

este projeto integra um ambiente de automacao e orquestracao (Villager AI) com um arsenal de ferramentas (HexStrike) e disponibiliza tudo como <strong>servidores MCP</strong> para que um LLM (ex.: Cursor AI) escolha e execute as ferramentas adequadas conforme a complexidade do objetivo.

O objetivo e reduzir friccao operacional, melhorar rastreabilidade (health endpoints + logs) e habilitar um fluxo hibrido seguro (quando usado com autorizacao e em ambientes controlados).

---

## Introducao: HexStrike / Villager AI

### HexStrike AI

- Colecao grande de ferramentas de seguranca (scans, enumeracao, utilitarios e rotinas tipicas de pentest).
- Ideal para execucao rapida e operacoes pontuais quando o objetivo e relativamente simples.

### Villager AI

- Camada de orquestracao: decompoe tarefas, coordena acoes e utiliza raciocinio do LLM para planejar e validar resultados.
- E mais adequada para objetivos complexos, multi-etapas e com necessidade de planejamento e encadeamento.

### Papel do MCP

O MCP (Model Context Protocol) atua como uma ponte padronizada entre o cliente (ex.: Cursor) e os servidores que expõem ferramentas.

Neste projeto, normalmente existem dois servidores:

- `villager-proper`: servidor MCP do Villager AI (orquestracao)
- `hexstrike-ai`: servidor MCP do HexStrike (ferramentas diretas)

E o cliente (LLM) escolhe entre as ferramentas, de forma hibrida.

---

## Referencias Oficiais

- HexStrike AI (repositório oficial): https://github.com/0x4m4/hexstrike-ai
- Villager AI (repositório oficial/upstream): https://github.com/gregcmartin/villager
- OpenClaw (documentacao de canais): https://docs.openclaw.ai/channels

---

## Indice

1. [Escopo e responsabilidade](#escopo-e-responsabilidade)
2. [Arquitetura geral](#arquitetura-geral)
3. [Requisitos](#requisitos)
4. [INITIAL CONFIGURATION](#initial-configuration)
5. [Variaveis de ambiente (.env)](#variaveis-de-ambiente-env)
6. [Configuracao do MCP no Cursor](#configuracao-do-mcp-no-cursor)
7. [Como rodar (passo a passo)](#como-rodar-passo-a-passo)
8. [Validacoes rapidas](#validacoes-rapidas)
9. [Troubleshooting](#troubleshooting)
10. [Boas praticas de seguranca](#boas-praticas-de-seguranca)
11. [Testes](#testes)
12. [Licenca](#licenca)

---

## Escopo e responsabilidade

Este framework e destinado a <strong>fins educacionais</strong> e <strong>testes autorizados</strong> (ambientes controlados e com permissao explicita).

Antes de usar em qualquer contexto real:

- obtenha autorizacao formal (escopo, alvos/dominios, regras, limites de tempo)
- use ambientes isolados (laboratorio, staging, containers)
- respeite leis, politicas internas e conformidade

---

## Arquitetura geral

Visao de alto nivel:

- O cliente (ex.: Cursor) chama um tool exposto pelo MCP.
- O servidor `villager-proper` orquestra o fluxo e delega execucao para componentes externos (ex.: Kali Driver, Browser) via MCP client.
- O servidor `hexstrike-ai` executa rotinas e devolve resultados ao cliente.
- Endpoints de health ajudam a verificar conectividade e prontidao.

---

## Requisitos

### Dependencias recomendadas

- Ubuntu (WSL) OU ambiente Linux nativo
- Docker Desktop no Windows com integracao ao WSL
- Python 3.8+ (o projeto usa `venv`)
- Acesso a rede para instalar dependencias e (opcionalmente) acessar provedor de LLM

### Observacao para WSL + Docker Desktop

- Ative integracao do WSL no Docker Desktop (ex.: distro `Ubuntu`).
- No WSL, valide `docker ps`.

---

## INITIAL CONFIGURATION

Esta secao descreve o caminho do zero, de forma pratica.

### 1) Preparar ambiente no WSL

No WSL:

```bash
cd ~
mkdir -p projetos/mcp
cd projetos/mcp
```

### 2) Clonar o repositorio e instalar dependencias

```bash
git clone https://github.com/Yenn503/villager-ai-hexstrike-integration.git
cd villager-ai-hexstrike-integration
./scripts/setup.sh
```

O `setup.sh` executa:

- instalacao de pacotes do sistema
- setup do ambiente Python (venv)
- preparacao do driver/containers
- start dos servicos (conforme a estrutura do projeto)

### 3) Configurar .env

O projeto espera um arquivo `.env` na raiz do repositorio.

```bash
cp .env.example .env
```

Em seguida ajuste:

- provedor de LLM (`LLM_PROVIDER`)
- chaves/enderecos do provedor (quando aplicavel)
- URLs/portas dos servicos (Villager e HexStrike)
- opcoes de permissao (`ALLOW_*`) com cautela

### 4) Subir os servicos do Villager

```bash
./scripts/start_villager_proper.sh
```

### 5) Validar endpoints de health (no WSL)

Exemplo de checagem:

```bash
curl http://127.0.0.1:37695/health
curl http://127.0.0.1:25989/health
curl http://127.0.0.1:1611/health
curl http://127.0.0.1:8080/health
```

O endpoint do `hexstrike-ai` depende de como o servidor HexStrike foi iniciado, mas no fluxo MCP costuma ser algo como:

```bash
curl http://127.0.0.1:8888/health
```

---

## Variaveis de ambiente (.env)

### Principais variaveis

Ao configurar `.env`, considere:

- `LLM_PROVIDER`: `deepseek`, `openai` ou `ollama`
- `DEEPSEEK_API_KEY` / `DEEPSEEK_BASE_URL`: quando `LLM_PROVIDER=deepseek`
- `OPENAI_API_KEY`: quando `LLM_PROVIDER=openai`
- `OLLAMA_BASE_URL` e `OLLAMA_MODEL`: quando `LLM_PROVIDER=ollama`
- `VILLAGER_HOST` / `VILLAGER_PORT`: servidor Villager
- `HEXSTRIKE_BASE_URL`: url/porta do servidor HexStrike acessivel pelo runtime
- `MCP_CLIENT_BASE_URL`: endpoint do componente interno MCP client
- `ALLOW_SHELL`, `ALLOW_APT`, `ALLOW_WRITE`, `ALLOW_BUILD`: habilitacoes de permissao
- `LOG_LEVEL`, `LOG_FILE`: logs

### Exemplo de bloco (Ollama local)

```env
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=deepseek-r1
```

### Exemplo de bloco (DeepSeek API)

```env
LLM_PROVIDER=deepseek
DEEPSEEK_API_KEY=SEU_TOKEN_AQUI
DEEPSEEK_BASE_URL=https://api.deepseek.com
```

---

## Configuracao do MCP no Cursor

### Arquivo de configuracao

Em geral, o Cursor utiliza `mcp.json` ou `mcp_servers.json`, tipicamente em:

- `C:\Users\<usuario>\.cursor\mcp.json`

O JSON deve incluir `mcpServers` com:

- `villager-proper`
- `hexstrike-ai`

### Regras importantes

1. Ordem: `villager-proper` primeiro
2. Para WSL, usar `wsl.exe` e paths Linux absolutos
3. Garantir que a porta do HexStrike no MCP (`--server ...`) corresponde ao `HEXSTRIKE_BASE_URL`

### Template (WSL)

Edite o template para refletir seus paths e nome da distro:

```json
{
  "mcpServers": {
    "villager-proper": {
      "command": "wsl.exe",
      "args": [
        "-d",
        "Ubuntu",
        "-e",
        "/home/leona/projetos/villager-ai-hexstrike-integration/villager-venv-new/bin/python3",
        "/home/leona/projetos/villager-ai-hexstrike-integration/src/villager_ai/mcp/villager_proper_mcp.py",
        "--debug"
      ],
      "description": "Villager AI Framework (WSL Ubuntu)",
      "timeout": 300,
      "alwaysAllow": [],
      "env": {
        "PYTHONUNBUFFERED": "1",
        "PYTHONPATH": "/home/leona/projetos/villager-ai-hexstrike-integration"
      }
    },
    "hexstrike-ai": {
      "command": "wsl.exe",
      "args": [
        "-d",
        "Ubuntu",
        "-e",
        "/home/leona/projetos/hexstrike-ai/hexstrike-env/bin/python3",
        "/home/leona/projetos/hexstrike-ai/hexstrike_mcp.py",
        "--server",
        "http://127.0.0.1:8888",
        "--debug"
      ],
      "description": "HexStrike AI (WSL Ubuntu)",
      "timeout": 300,
      "alwaysAllow": []
    }
  }
}
```

Se o venv do HexStrike nao usar `hexstrike-env`, substitua pelo path real (ex.: `.venv`).

---

## Configuracao do Cursor (Assistente)

Esta secao descreve como preparar o Cursor para usar os MCP servers como suporte ao seu fluxo de trabalho.

### Checklist do Cursor (recomendado)

1. Garanta que o arquivo de configuracao do MCP esteja no local esperado (tipicamente `C:\Users\<usuario>\.cursor\mcp.json`).
2. Confirme que `villager-proper` vem antes de `hexstrike-ai` no JSON (prioridade de carregamento).
3. Reinicie o Cursor (ou use "Reload Window") apos alterar o `mcp.json`, para forcar recarregamento dos servers.
4. Valide pelo menos 1 ferramenta do `villager-proper` e 1 do `hexstrike-ai` no painel de ferramentas do Cursor.

### Sugestao de instrucoes para o assistente (prompt)

Adicione ao seu "Assistente / System prompt" do Cursor um texto curto com a regra de decisao, por exemplo:

```text
Use o HexStrike para tarefas simples e execucao rapida (uma acao/scan direto).
Use o Villager AI para tarefas complexas que exigem decomposicao e orquestracao multi-etapas.
Se houver falha ou necessidade de mais contexto, escale do HexStrike para o Villager.
Sempre registre evidencias (logs/health) e respeite escopo autorizado.
```

---

## Configuracao do OpenClaw (Assistente)

O OpenClaw permite que o seu assistente converse em diversos aplicativos de chat, usando canais diferentes (e roteando via Gateway). A documentacao de canais e lista de conectores esta aqui:
[`https://docs.openclaw.ai/channels`](https://docs.openclaw.ai/channels).

### Como funciona (visao geral)

- O OpenClaw suporta varios canais de comunicacao (por exemplo: Telegram, WhatsApp, Discord, Slack e outros) e cada canal fica conectado ao Gateway.
- Textos funcionam em qualquer canal; recursos de midia e reacoes podem variar por canal.
- Alguns fluxos (especialmente DM) podem exigir pareamento/allowlist para maior seguranca.

### Passo a passo (alto nivel)

1. Escolha o canal principal (ex.: `Telegram` costuma ser o mais rapido para iniciar; `WhatsApp` tipicamente exige QR pairing).
2. Configure as credenciais do canal seguindo a documentacao oficial de canais.
3. Inicie o OpenClaw e confirme a conectividade do Gateway.
4. Realize testes funcionais: envie prompts simples (sem acoes destrutivas) para validar resposta, latencia e estabilidade.

### Rastreabilidade e controle

- Mantenha logs do OpenClaw e dos servers MCP (Villager/HexStrike).
- Defina limites de uso e escopo no seu prompt/instrucoes do assistente para evitar execucoes fora do laboratorio.

---

## Como rodar (passo a passo)

1. No WSL:
   - clone/configure `.env`
   - rode:

```bash
cd ~/projetos/mcp/villager-ai-hexstrike-integration
./scripts/start_villager_proper.sh
```

2. No Cursor:
   - recarregue a janela
   - ative `villager-proper`
   - ative `hexstrike-ai`

3. Verifique:
   - `curl http://127.0.0.1:8888/health` (HexStrike server)
   - health endpoints do Villager

---

## Validacoes rapidas

### 1) Services do Villager

```bash
curl http://127.0.0.1:37695/health
curl http://127.0.0.1:25989/health
curl http://127.0.0.1:1611/health
curl http://127.0.0.1:8080/health
```

### 2) Server do HexStrike (MCP)

```bash
curl http://127.0.0.1:8888/health
```

---

## Troubleshooting

### A) Erro de caminho (WSL) ao iniciar `hexstrike-ai`

Sintoma comum:

- o Cursor falha ao executar o Python no WSL por "No such file or directory"

Causa comum:

- o `command/args` do `mcp.json` esta apontando para um path de venv inexistente.

Correcao:

- confirmar qual venv existe no WSL dentro de `hexstrike-ai`
- atualizar `mcp.json` com o path correto para `python3` e `hexstrike_mcp.py`

### B) Erro de integracao com Docker

Sintomas:

- permissao negada para `/var/run/docker.sock`

Correcao recomendada:

```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
```

---

## Boas praticas de seguranca

### Praticas recomendadas

- execute apenas em ambientes isolados
- evite habilitar `ALLOW_SHELL`/`ALLOW_APT`/`ALLOW_BUILD` fora de laboratorios controlados
- mantenha `.env` fora do Git (confira `.gitignore`)
- registre logs para auditoria interna

### Nota sobre alvos e testes

Este software pode ser usado para automacao de seguranca ofensiva. Use apenas com autorizacao e escopo definido.

---

## Testes

Rodar suite de testes:

```bash
cd ~/projetos/mcp/villager-ai-hexstrike-integration
./tests/run_tests.sh
```

Se os testes exigirem dependencias Python do venv, ative:

```bash
source villager-venv-new/bin/activate
python -m pip install --upgrade pip
python -m pip install pytest pytest-cov
./tests/run_tests.sh
```

---

## Licenca

MIT. Veja o arquivo `LICENSE` para detalhes.
