"""Custom library Robot Framework per verificare SEO, lingua e link del sito."""

from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup
from robot.api import logger
from robot.api.deco import keyword, library


@library(scope="SUITE")
class SiteChecks:
    """Keyword personalizzate per meta tag, lingua, canonical e link interni."""

    def __init__(self, base_url="https://antonionappi.pages.dev"):
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.session.headers["User-Agent"] = "RobotFramework-SiteTests"
        self._cache = {}

    # --- helper interni -------------------------------------------------

    def _url(self, path):
        return urljoin(self.base_url + "/", path.lstrip("/"))

    def _soup(self, path):
        """Scarica e analizza una pagina una sola volta per suite."""
        url = self._url(path)
        if url not in self._cache:
            resp = self.session.get(url, timeout=15)
            resp.raise_for_status()
            self._cache[url] = BeautifulSoup(resp.text, "html.parser")
        return self._cache[url]

    # --- keyword pubbliche ----------------------------------------------

    @keyword
    def get_meta_content(self, path, name):
        """Restituisce il content di un meta tag cercato per name o property."""
        soup = self._soup(path)
        tag = soup.find("meta", attrs={"name": name}) or soup.find(
            "meta", attrs={"property": name}
        )
        if tag is None:
            raise AssertionError(f"Meta tag '{name}' non trovato in {path}")
        return tag.get("content", "")

    @keyword
    def get_html_lang(self, path):
        """Restituisce l'attributo lang del tag <html>."""
        return self._soup(path).html.get("lang", "")

    @keyword
    def get_canonical_url(self, path):
        """Restituisce l'href del <link rel="canonical">."""
        tag = self._soup(path).find("link", rel="canonical")
        if tag is None:
            raise AssertionError(f"Link canonical non trovato in {path}")
        return tag.get("href", "")

    @keyword
    def url_should_respond_ok(self, url):
        """Verifica che un URL assoluto risponda con uno status < 400."""
        status = self.session.get(url, timeout=15).status_code
        if status >= 400:
            raise AssertionError(f"{url} ha risposto {status}")
        logger.info(f"{url} -> {status}")

    @keyword
    def internal_links_should_not_be_broken(self, path="/"):
        """Controlla tutti i link interni della pagina e fallisce se uno risponde >= 400."""
        soup = self._soup(path)
        host = urlparse(self.base_url).netloc
        checked, broken = set(), []
        for a in soup.find_all("a", href=True):
            url = urljoin(self._url(path), a["href"]).split("#")[0]
            if not url or urlparse(url).netloc != host or url in checked:
                continue
            checked.add(url)
            status = self.session.get(url, timeout=15).status_code
            if status >= 400:
                broken.append(f"{url} -> {status}")
        logger.info(f"Controllati {len(checked)} link interni su {path}")
        if broken:
            raise AssertionError("Link interni rotti:\n" + "\n".join(broken))
