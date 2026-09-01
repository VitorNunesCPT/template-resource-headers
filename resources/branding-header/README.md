# Header de branding

Pacote drop-in para um repositório [docker-jitsi-meet](https://github.com/jitsi/docker-jitsi-meet).
Copia esta pasta para `resources/branding-header/` do projeto de destino, no mesmo
layout usado neste repositório, e siga os passos abaixo.

O pacote publica um header com logos em todas as telas, customiza a página de
boas-vindas e troca o favicon. Os arquivos gerados vão para
`${CONFIG}/web/branding` e o Nginx os injeta via `custom-meet.conf`, sem rebuild
da imagem `jitsi/web`.

## Pré-requisitos no repositório de destino

O projeto precisa ser um `docker-jitsi-meet` com:

- `docker-compose.yml` montando `${CONFIG}/web` em `/config` no serviço `web`
- o script `web/rootfs/etc/cont-init.d/10-config` concatenando
  `/config/nginx/custom-meet.conf` em `/config/nginx/meet.conf`

As imagens oficiais recentes do Jitsi já atendem esses dois pontos. Confirme
antes de aplicar:

```bash
./scripts/branding-header.sh check
```

## 1. Copiar os arquivos

A partir da raiz do repositório de destino:

```text
resources/branding-header/            ← esta pasta (templates, logos e exemplo de env)
resources/prosody-plugins-custom/     ← lobby (lobby_autostart + token_lobby_bypass)
scripts/branding-header.sh            ← publicação e validação
scripts/apply-branding-header.sh      ← atalho para apply
scripts/prepare-config.sh             ← aplica branding, watermark, app name, plugins e sobe o compose
```

Os scripts e os plugins do Prosody não ficam dentro desta pasta. Copie-os deste
repositório para o destino, mantendo os mesmos caminhos.

## 2. Acrescentar as variáveis no `env.example` e no `.env`

### `env.example`

Cole o bloco de branding no final de `env.example`. Se o destino também for
usar lobby + JWT (como neste projeto), acrescente o bloco de lobby na seção
de autenticação, sem substituir módulos XMPP que o projeto já tenha.

```bash
#
# Managed branding header
#

# Enable automatic publication of the custom header when running scripts/prepare-config.sh
#ENABLE_BRANDING_HEADER=1

# Directory containing the logo files used by scripts/branding-header.sh
#BRANDING_HEADER_LOGOS_DIR=resources/branding-header/logos

#
# Interface branding
#

# Hide the default Jitsi watermark through scripts/prepare-config.sh
#DISABLE_JITSI_WATERMARK=1

# Override the application name used in interface text such as the close page
#JITSI_APP_NAME="Consultorio Virtual"
```

```bash
# Enable lobby infrastructure
#ENABLE_LOBBY=1

# Keep lobby enabled automatically for every room.
# Requires ENABLE_LOBBY=1 and moderator JWTs with context.user.lobby_bypass=true.
# If you already define XMPP_MODULES or XMPP_MUC_MODULES, append these modules instead of replacing your current list.
#XMPP_MODULES=persistent_lobby
#XMPP_MUC_MODULES=lobby_autostart,token_lobby_bypass
#
# Moderator token requirement:
# "context": { "user": { "affiliation": "owner", "lobby_bypass": true } }
```

O lobby precisa de `resources/prosody-plugins-custom/` e do `prepare-config.sh`.
Tokens de moderador devem levar `"lobby_bypass": true`.

### `.env`

No `.env` do ambiente, use o bloco operacional abaixo (o mesmo padrão das
linhas 35–59 deste projeto). Troque `JWT_APP_*` pelos valores do gerador de
token; não copie o secret de exemplo.

```bash
# Local UX
ENABLE_PREJOIN_PAGE=1
ENABLE_WELCOME_PAGE=1
ENABLE_BRANDING_HEADER=1
BRANDING_HEADER_LOGOS_DIR=resources/branding-header/logos
DISABLE_JITSI_WATERMARK=1
JITSI_APP_NAME="Consultório Virtual"

# Local lobby flow
ENABLE_AUTH=1
ENABLE_GUESTS=1
AUTH_TYPE=jwt
ENABLE_LOBBY=1
XMPP_MODULES=persistent_lobby
XMPP_MUC_MODULES=lobby_autostart,token_lobby_bypass
JWT_APP_ID=my_jitsi_app_id
JWT_ACCEPTED_ISSUERS=my_jitsi_app_id
JWT_ACCEPTED_AUDIENCES=my_jitsi_app_id
# Required for HS256 JWTs: set this to the same secret used by the token generator.
JWT_APP_SECRET=my_jitsi_app_secret

ENABLE_RECORDING=0
ENABLE_SERVICE_RECORDING=0
DISABLE_LOCAL_RECORDING=1
TOOLBAR_BUTTONS=microphone,camera,closedcaptions,desktop,fullscreen,fodeviceselection,hangup,profile,chat,raisehand,videoquality,tileview,settings,participants-pane
DISABLE_DEEP_LINKING=1
```

| Variável | Efeito |
| --- | --- |
| `ENABLE_PREJOIN_PAGE` / `ENABLE_WELCOME_PAGE` | mantém prejoin e a welcome page (o header/welcome JS dependem dela) |
| `ENABLE_BRANDING_HEADER` | `prepare-config.sh` publica o header automaticamente |
| `BRANDING_HEADER_LOGOS_DIR` | pasta das logos no repositório |
| `DISABLE_JITSI_WATERMARK` | esconde a watermark padrão (`prepare-config.sh`) |
| `JITSI_APP_NAME` | nome do app na interface (`prepare-config.sh`) |
| `ENABLE_AUTH` / `ENABLE_GUESTS` / `AUTH_TYPE=jwt` | JWT + convidados na sala de espera |
| `ENABLE_LOBBY` / `XMPP_MODULES` / `XMPP_MUC_MODULES` | lobby persistente e bypass por token |
| `JWT_APP_ID` / `JWT_APP_SECRET` / `JWT_ACCEPTED_*` | validação dos tokens HS256 |
| `ENABLE_RECORDING` / `ENABLE_SERVICE_RECORDING` / `DISABLE_LOCAL_RECORDING` | gravação desligada |
| `TOOLBAR_BUTTONS` | botões visíveis na toolbar |
| `DISABLE_DEEP_LINKING` | não empurra o app nativo |

Textos, cores e lista de logos **não** ficam neste `.env`. Eles vão em
`${CONFIG}/web/branding/branding-header.env` (passo 4).

Sem `prepare-config.sh`, use `./scripts/branding-header.sh apply` direto.
`DISABLE_JITSI_WATERMARK` e `JITSI_APP_NAME` só têm efeito com o
`prepare-config.sh`.

## 3. Colocar as logos

1. Copie os SVGs (ou PNGs) para `resources/branding-header/logos/`.
2. Liste os arquivos em `HEADER_DESKTOP_LOGOS` e `HEADER_MOBILE_LOGOS` no env de
   branding (passo 4). A ordem da lista é a ordem de exibição.
3. Para cada logo única, defina `LOGO_N_MAX_HEIGHT`. Use `LOGO_N_WIDTH` só quando
   precisar de largura fixa. A numeração segue a primeira aparição: desktop
   primeiro, depois mobile.

O favicon em `custom-meet.conf` aponta para `fousp.svg`. Se a logo principal
tiver outro nome, ajuste essas duas rotas no arquivo antes de aplicar:

```nginx
location = /images/favicon.svg { ... }
location = /favicon.ico { ... }
```

Detalhes de numeração: [logos/README.md](logos/README.md).

## 4. Configurar textos, cores e layout

Na primeira aplicação o script copia `branding-header.env.example` para:

```text
${CONFIG}/web/branding/branding-header.env
```

Edite **esse** arquivo no host (não o `.tpl`). Ele controla:

| Grupo | Variáveis |
| --- | --- |
| Header | `HEADER_BG`, `HEADER_HEIGHT`, `HEADER_MOBILE_BREAKPOINT`, gaps e paddings |
| Logos | `HEADER_DESKTOP_LOGOS`, `HEADER_MOBILE_LOGOS`, `LOGO_N_*` |
| Welcome | títulos, subtítulo, prompt, botão, cores e os 3 cards / 3 passos |

`CONFIG` vem do `.env` do Jitsi (padrão `~/.jitsi-meet-cfg`).

## 5. Validar e publicar

Na raiz do repositório de destino:

```bash
# Confirma o contrato do repositório e, se o container web estiver no ar, o runtime
./scripts/branding-header.sh check

# Gera CSS/JS, copia logos e custom-meet.conf, reinicia o serviço web
./scripts/branding-header.sh apply
```

Se `ENABLE_BRANDING_HEADER=1` e você usa o fluxo deste repositório:

```bash
./scripts/prepare-config.sh
```

Isso aplica o header, o watermark, o nome do app, copia plugins customizados do
Prosody (se existirem) e executa `docker compose up -d`.

Outras opções:

```bash
./scripts/branding-header.sh apply --no-restart   # só gera arquivos, sem restart
./scripts/branding-header.sh apply --force        # aplica mesmo se o check falhar
./scripts/apply-branding-header.sh                # equivalente a branding-header.sh apply
```

## 6. Conferir no navegador

1. Abra a URL pública (`PUBLIC_URL` / `https://localhost:8443`).
2. Na welcome page: header com as logos, textos e cores do env, cards e passos.
3. Entre em uma sala: o header continua visível; a customização da welcome some.
4. Recarregue com cache desligado se o CSS/JS antigo estiver preso no browser
   (`/branding/` já sai com `Cache-Control: no-store`).

## O que o apply grava

| Origem | Destino em `${CONFIG}` |
| --- | --- |
| `header.css.tpl` / `header.js.tpl` | `web/branding/header.css`, `web/branding/header.js` |
| `welcome.css.tpl` / `welcome.js.tpl` | `web/branding/welcome.css`, `web/branding/welcome.js` |
| `custom-meet.conf` | `web/nginx/custom-meet.conf` |
| logos listadas no env | `web/branding/<arquivo>` |
| `branding-header.env.example` (só se ainda não existir) | `web/branding/branding-header.env` |

Não edite os `.tpl` para conteúdo de um tenant. Altere o env de branding e rode
`apply` de novo.

## Problemas comuns

| Sintoma | O que checar |
| --- | --- |
| `check` falha em `repo.custom_meet_hook` | a imagem/repo não concatena `custom-meet.conf`; o header não será injetado |
| `missing logo: ...` | o arquivo não está em `BRANDING_HEADER_LOGOS_DIR` ou o nome no env não bate |
| header não aparece | `ENABLE_BRANDING_HEADER=1` (se usa `prepare-config.sh`), `apply` rodou, container `web` reiniciou |
| favicon antigo | `custom-meet.conf` ainda aponta para um SVG que não foi copiado |
| welcome customizada dentro da sala | não deve acontecer; `welcome.js` é restrito à rota da welcome page |
