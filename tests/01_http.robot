*** Settings ***
Documentation     Test HTTP sulle pagine principali del sito.
Library           RequestsLibrary
Resource          ../resources/common.resource
Suite Setup       Create Session    site    ${BASE_URL}    headers=${HEADERS}    timeout=15
Suite Teardown    Delete All Sessions

*** Test Cases ***
Home Italiana Risponde 200 In HTML
    ${resp}=    GET On Session    site    /    expected_status=200
    Should Contain    ${resp.headers}[Content-Type]    text/html

Home Inglese Risponde 200
    GET On Session    site    /en/    expected_status=200

Demo LavaFieldJS Raggiungibile
    GET On Session    site    /lavafieldjs/    expected_status=200

Immagine Open Graph Raggiungibile
    ${resp}=    GET On Session    site    /assets/og-image.jpg    expected_status=200
    Should Start With    ${resp.headers}[Content-Type]    image/

Pagina Inesistente Risponde 404
    [Documentation]    Se fallisce, il sito restituisce 200 su pagine inesistenti
    ...                (soft 404): è un bug reale da segnalare in una issue.
    GET On Session    site    /pagina-che-non-esiste    expected_status=404
