*** Settings ***
Library    RequestsLibrary 
Library    Collections
Library    JSONLibrary

*** Variables ***
${BASE_URL}    http://proxy/articles/

*** Test Cases ***
Verify Health Request
    ${response}=  GET  http://proxy/health  
    ...    expected_status=200

Verify Post/Delete Flow
    ${headers}=  Create Dictionary  Content-Type=application/json

    ${response}=  POST  ${BASE_URL} 
    ...    data={"title":"test","content":"test"}  
    ...    headers=${headers}  
    ...    expected_status=201 

    ${id}=    Set Variable    ${response.json()}[id]
    
    Log To Console    \nCreated Article ID: ${id}

    ${del_response}=    DELETE    ${BASE_URL}${id}
    ...    headers=${headers}
    ...    expected_status=204

    Log To Console    \nSuccessfully deleted article ${id}

Verify Get Request
    ${headers}=  Create Dictionary  Content-Type=application/json

    ${response1}=  GET  ${BASE_URL}
    ...    headers=${headers}  
    ...    expected_status=200
    ${response2}=  GET  ${BASE_URL} 
    ...    headers=${headers}  
    ...    expected_status=200

    Should Be Equal    ${response1.json()}    ${response2.json()}

Verify Articles
    ${headers}=  Create Dictionary  Content-Type=application/json

    ${response}=  GET  ${BASE_URL}
    ...    headers=${headers}  
    ...    expected_status=200

    ${json}=    Set Variable    ${response.json()}
    Log To Console    \n${json}
#Verify Add/Delete Flow
#    ${headers}=  Create Dictionary  Content-Type=application/json
#
#    ${response}=    GET    http://proxy/articles/    headers=${headers} expected_status=200
#    ${exists}=    Evaluate    any(item['title'] == 'Ala' and item['content'] == 'makota' for item in $response.json())
#    Should Be True    ${exists}    msg=Article Ala not found
#
#    Should Not Contain    ${response.json()}    {"title":"X","content":"X"}
#
#    ${response}=  POST  http://proxy/articles/  data={"title":"X","content":"X"}  headers=${headers}  expected_status=201
#
#    ${response}=    GET    http://proxy/articles/    headers=${headers} expected_status=200
#    Should Contain    ${response.json()}    {"title":"X","content":"X"}
#
#    ${response}=  DELETE  http://proxy/articles/  data={"title":"X","content":"X"}  headers=${headers}  expected_status=201
#
#    ${response}=    GET    http://proxy/articles/    headers=${headers} expected_status=200
#    Should Not Contain    ${response.json()}    {"title":"X","content":"X"}

Verify Delete Non Existent Article
    ${headers}=    Create Dictionary    Content-Type=application/json

    ${response}=   GET    ${BASE_URL}
    ...    headers=${headers}    
    ...    expected_status=200
     #edited
    ${ids}=    Evaluate    [item['id'] for item in ${response.json()}]
    ${max_id}=    Evaluate    max(${ids})
    ${non_existent_id}=    Evaluate    ${max_id} + 1
    
    Log To Console    \nTrying to delete ID: ${non_existent_id}

    ${del_response}=    DELETE    http://proxy/articles/${non_existent_id}    
    ...    headers=${headers}    
    ...    expected_status=404