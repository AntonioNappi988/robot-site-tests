*** Settings ***
Documentation     Test UI end-to-end con SeleniumLibrary in Chrome headless.
Resource          ../resources/common.resource
Suite Setup       Apri Sito
Suite Teardown    Close All Browsers
Test Setup        Torna Alla Home

*** Test Cases ***
Titolo Della Pagina
    Title Should Be    Antonio Nappi

Link Social Presenti
    Page Should Contain Link    https://github.com/AntonioNappi988
    Page Should Contain Link    https://www.linkedin.com/in/antonio-nappi-7b4194237/

Navigazione Alla Sezione Progetti
    Clicca Primo Link Visibile    css:a[href="#projects"]
    Wait Until Location Contains    \#projects
    Wait Until Page Contains    LavaFieldJS

Cambio Lingua In Inglese
    Clicca Primo Link Visibile    css:a[href$="/en/"]
    Wait Until Location Contains    /en/

*** Keywords ***
Torna Alla Home
    Go To    ${BASE_URL}
    Chiudi Popup Accelerazione Se Presente
