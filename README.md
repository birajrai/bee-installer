# Bee Installer

This repository contains a simple installer for Nginx Proxy Manager (NPM) using Docker on Ubuntu.

Files added
- scripts/npm.sh — installer script that prepares the host and runs NPM in Docker
- scripts/install.sh — tiny helper intended to be run via curl | bash
- docs/index.html — a small landing page that will be published via GitHub Pages
- .github/workflows/deploy.yml — GitHub Actions workflow that publishes the `docs/` site to GitHub Pages

Usage

1. If you host this repository on GitHub and enable GitHub Pages from the `gh-pages` branch (the workflow does this automatically), you can point a DNS CNAME (for example `installer.raibiraj.com.np`) to GitHub Pages and the site will serve the installer landing page.

2. To run the installer directly from the hosted raw script you can use the standard pattern (replace the URL below with the raw URL of `scripts/npm.sh` in your repository):

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/<OWNER>/<REPO>/main/scripts/install.sh)"
```

Security notes

- Review `scripts/npm.sh` before running it on any system. It requires root and will install packages and enable system services.
- Consider hosting the installer script on HTTPS and pinning checksums if you plan to distribute it widely.

Customization

- Edit `scripts/npm.sh` to change default compose configuration, or to adjust install behavior for your environment.

If you want, I can update the README with the final raw URLs once you push this repo to GitHub (so I can fill in the curl command for you).

Multiple installers

This repo now provides multiple installer wrappers. Each installer follows a consistent interface and downloads a concrete implementation script from the repository (or your configured domain). The current installers included as wrappers are:

- scripts/installer-npm.sh
- scripts/installer-traefik.sh
- scripts/installer-postgres.sh
- scripts/installer-certbot.sh

Each wrapper supports these flags:
- --dry-run    : download and verify but don't execute
- --skip-start : skip starting services (where applicable)
- --yes        : run non-interactively (assume yes to prompts)

By default the wrappers fetch scripts from raw.githubusercontent.com. Update the OWNER and REPO variables in scripts/templates/installer-template.sh if you prefer a different upstream location.
