# GangeVinne

Øv på ganging så du kan vinne matteprøven!

Bruk den her: https://jhf.github.io/GangeVinne

## Hvordan programmere på din egen maskin

Gjør klar maskina:

- Installer Node.js (bruk versjonen i [.nvmrc](.nvmrc), f.eks. med [nvm](https://github.com/nvm-sh/nvm) eller [fnm](https://github.com/Schniz/fnm))
- Installer [Yarn](https://yarnpkg.com/) - `corepack enable`
- Installer Elm: `yarn global add elm` (eller se <https://guide.elm-lang.org/install.html>)

Installer avhengigheter:

- `yarn install`

For å utvikle lokalt (med hot reload på <http://localhost:4000>):

- `yarn dev`

Kjør tester:

- `yarn test`

Bygg for publisering (legges i `wwwroot/`):

- `yarn prod`

## Publisering

Appen publiseres to steder fra `master`:

- **GitHub Pages**: <https://jhf.github.io/GangeVinne> - bygges og publiseres av
  [.github/workflows/pages.yml](.github/workflows/pages.yml) ved hver push til `master`.
- **Netlify**: <https://gangevinne.heneld.no> - Netlify bygger repoet og publiserer
  `wwwroot/` (se [netlify.toml](netlify.toml)).
