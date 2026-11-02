*** Settings ***
Documentation    Variabili e keyword condivise tra le suite.
Library          SeleniumLibrary

*** Variables ***
${BASE_URL}    https://antonionappi.pages.dev
${BROWSER}     headlesschrome
# Cloudflare blocca gli User-Agent "python-requests" e "HeadlessChrome" con un 403
${USER_AGENT}  RobotFramework-SiteTests
&{HEADERS}     User-Agent=${USER_AGENT}
${POPUP_NO}    (//*[normalize-space()="No, continua così"])[last()]

*** Keywords ***
Apri Sito
    Open Browser    ${BASE_URL}    ${BROWSER}
    ...    options=add_argument("--user-agent=${USER_AGENT}")
    Set Window Size    1440    900
    Set Selenium Timeout    10s
    Chiudi Popup Accelerazione Se Presente

Chiudi Popup Accelerazione Se Presente
    [Documentation]    In headless non c'è GPU: il sito mostra il popup
    ...                sull'accelerazione hardware, che va chiuso prima dei test.
    ${presente}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath:${POPUP_NO}    timeout=5s
    IF    ${presente}    Click Element    xpath:${POPUP_NO}

Clicca Primo Link Visibile
    [Documentation]    Lo stesso link può comparire più volte nella pagina (menu,
    ...                pannelli nascosti): clicca la prima occorrenza visibile.
    [Arguments]    ${locator}
    Wait Until Page Contains Element    ${locator}
    ${links}=    Get WebElements    ${locator}
    FOR    ${link}    IN    @{links}
        ${visibile}=    Run Keyword And Return Status    Element Should Be Visible    ${link}
        IF    ${visibile}
            Scroll Element Into View    ${link}
            Click Element    ${link}
            RETURN
        END
    END
    Fail    Nessun elemento visibile per ${locator}
