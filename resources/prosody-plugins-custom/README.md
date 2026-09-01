Custom Prosody plugins copied by scripts/prepare-config.sh.

The lobby modules in this directory are based on jitsi-contrib/prosody-plugins,
licensed under Apache-2.0:

- lobby_autostart/mod_lobby_autostart.lua
- token_lobby_bypass/mod_token_lobby_bypass.lua

They are mounted into the Prosody container through:

    ${CONFIG}/prosody/prosody-plugins-custom:/prosody-plugins-custom

Enable them with:

    ENABLE_LOBBY=1
    XMPP_MODULES=persistent_lobby
    XMPP_MUC_MODULES=lobby_autostart,token_lobby_bypass

Moderator tokens must use a boolean lobby_bypass flag:

    "lobby_bypass": true
