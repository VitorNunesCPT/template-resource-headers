Os nomes dos arquivos exibidos em cada breakpoint sao definidos por
`HEADER_DESKTOP_LOGOS` e `HEADER_MOBILE_LOGOS`.

As logos unicas sao numeradas pela primeira aparicao: primeiro na lista desktop e
depois na lista mobile. Para cada `LOGO_N`, configure `LOGO_N_MAX_HEIGHT`; use
`LOGO_N_WIDTH` quando precisar de uma largura fixa. A quantidade de logos nao e
limitada pelo template.

Se `BRANDING_HEADER_LOGOS_DIR` nao for definido, o script procura as imagens
nesta pasta. A configuracao visual fica em
`${CONFIG}/web/branding/branding-header.env`.
