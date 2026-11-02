*** Settings ***
Documentation    Controlli SEO e link interni tramite la custom library SiteChecks.
Resource         ../resources/common.resource
Library          ../libraries/SiteChecks.py    ${BASE_URL}

*** Test Cases ***
Meta Description Presente
    ${desc}=    Get Meta Content    /    description
    Should Contain    ${desc}    Informatica

Open Graph Locale Italiano Con Alternativa Inglese
    ${locale}=    Get Meta Content    /    og:locale
    Should Be Equal    ${locale}    it_IT
    ${alt}=    Get Meta Content    /    og:locale:alternate
    Should Be Equal    ${alt}    en_US

Canonical Corretto
    ${canonical}=    Get Canonical Url    /
    Should Be Equal    ${canonical}    ${BASE_URL}/

Lingua Dichiarata Correttamente
    [Template]    La Lingua Di ${path} Dovrebbe Essere ${atteso}
    /       it
    /en/    en

Nessun Link Interno Rotto
    Internal Links Should Not Be Broken    /
    Internal Links Should Not Be Broken    /en/

*** Keywords ***
La Lingua Di ${path} Dovrebbe Essere ${atteso}
    ${lang}=    Get Html Lang    ${path}
    Should Start With    ${lang}    ${atteso}
