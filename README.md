# robot-site-tests

Suite di test automatici in **Robot Framework** per il mio portfolio live,
[antonionappi.pages.dev](https://antonionappi.pages.dev).

## Cosa copre

| Suite | Libreria | Cosa verifica |
|---|---|---|
| `01_http.robot` | RequestsLibrary | Status code delle pagine IT/EN, demo LavaFieldJS, immagine Open Graph, gestione 404 |
| `02_seo_links.robot` | **SiteChecks** (custom, Python) | Meta description, Open Graph locale, canonical, `lang` delle pagine, link interni rotti |
| `03_ui.robot` | SeleniumLibrary | Titolo, link social, navigazione alle sezioni, cambio lingua, gestione popup |

La custom library `libraries/SiteChecks.py` espone keyword riutilizzabili
(`Get Meta Content`, `Get Html Lang`, `Get Canonical Url`, `Url Should Respond Ok`,
`Internal Links Should Not Be Broken`) e mette in cache le pagine scaricate.

## Esecuzione in locale

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
robot --outputdir results tests
```

Serve Google Chrome installato (SeleniumLibrary gestisce il driver da solo).
Il report è in `results/report.html`.

Per eseguire una sola suite o vedere il browser:

```bash
robot --outputdir results tests/03_ui.robot
robot --variable BROWSER:chrome --outputdir results tests/03_ui.robot
```

## CI/CD

GitHub Actions esegue la suite a ogni push, a mano (`workflow_dispatch`) e ogni
lunedì mattina. Il report HTML viene caricato come artifact `robot-report`.

## Note

- In headless Chrome non c'è GPU, quindi il sito mostra il popup sull'accelerazione
  hardware: la keyword `Chiudi Popup Accelerazione Se Presente` lo gestisce.
- I bug trovati dai test vengono documentati nelle issue del repository.
