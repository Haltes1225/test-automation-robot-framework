*** Settings ***
Library    RequestsLibrary 

*** Test Cases ***
Verify Get Request
    ${response}=  GET  http://proxy/health  expected_status=200


Verify Post Request
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=  POST  http://proxy/articles/  data={"title":"test","content":"test"}  headers=${headers}  expected_status=201

Verify Article List
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response1}=  GET  http://proxy/articles/  headers=${headers}  expected_status=200
    ${response2}=  GET  http://proxy/articles/  headers=${headers}  expected_status=200

    Should Be Equal    ${response1.json()}    ${response2.json()}