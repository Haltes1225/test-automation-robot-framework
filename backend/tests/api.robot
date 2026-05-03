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

Verify Article Lifecycle
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${article_title}=    Set Variable    Unique Lifecycle Test Article

    ${resp_initial}=    GET    ${BASE_URL}    headers=${headers}    expected_status=200
    ${titles_initial}=  Get Value From Json    ${resp_initial.json()}    $[*].title
    List Should Not Contain Value    ${titles_initial}    ${article_title}

    ${resp_post}=       POST    ${BASE_URL}    
    ...    data={"title":"${article_title}", "content":"Lifecycle Content"}
    ...    headers=${headers}    expected_status=201
    
    ${article_id}=      Set Variable    ${resp_post.json()}[id]

    ${resp_after_post}=  GET    ${BASE_URL}    headers=${headers}    expected_status=200
    ${titles_after}=     Get Value From Json    ${resp_after_post.json()}    $[*].title
    List Should Contain Value    ${titles_after}    ${article_title}

    DELETE    ${BASE_URL}${article_id}    headers=${headers}    expected_status=204

    ${resp_final}=       GET    ${BASE_URL}    headers=${headers}    expected_status=200
    ${titles_final}=     Get Value From Json    ${resp_final.json()}    $[*].title
    List Should Not Contain Value    ${titles_final}    ${article_title}

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