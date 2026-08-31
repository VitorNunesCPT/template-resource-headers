## Custom branding header

This repository includes `scripts/branding-header.sh` to check compatibility and publish a managed header overlay into `${CONFIG}/web` without editing files inside the `web` container manually.

Place your logos in `resources/branding-header/logos/` or point `BRANDING_HEADER_LOGOS_DIR` to another directory. The visual configuration is kept separately in `${CONFIG}/web/branding/branding-header.env`; it is created from `resources/branding-header/branding-header.env.example` on the first apply.

Check the local and runtime compatibility before publishing:

```bash
./scripts/branding-header.sh check
./scripts/branding-header.sh check --json
```

`check` reports `compatible`, `partial`, or `incompatible`. `partial` means local checks passed but runtime validation is pending because the web container is not running.

Publish the header with:

```bash
./scripts/branding-header.sh apply
./scripts/branding-header.sh apply --force
./scripts/branding-header.sh apply --no-restart
```

If you want the header to be republished automatically whenever you run `./scripts/prepare-config.sh`, enable `ENABLE_BRANDING_HEADER=1` in `.env`. This path uses `scripts/branding-header.sh apply --no-restart`.

`scripts/apply-branding-header.sh` remains available as a compatibility wrapper for existing automation.