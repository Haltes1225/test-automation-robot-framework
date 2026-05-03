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

    #1. Create new article
    ${response}=  POST  ${BASE_URL} 
    ...    data={"title":"test","content":"test"}  
    ...    headers=${headers}  
    ...    expected_status=201

    #2. Get the id of the new article
    ${id}=    Set Variable    ${response.json()}[id]
    
    Log To Console    \nCreated Article ID: ${id}

    #3. Delete the new article 
    #(to not clutter db and test DELETE endpoint at the same time)
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

Verify List and Detail Data Consistency
    ${headers}=    Create Dictionary    Content-Type=application/json
    
    #1. Get the full list
    ${list_resp}=    GET    ${BASE_URL}    headers=${headers}    expected_status=200

    #2. Check if there are articles in the db
    ${length}=    Get Length    ${list_resp.json()}
    Should Be True    ${length} > 0    msg=No articles found
    
    #3. Pick the first article from the list (index 0)
    ${article_from_list}=    Set Variable    ${list_resp.json()}[0]
    ${target_id}=            Set Variable    ${article_from_list}[id]
    
    Log To Console    \nComparing data for Article ID: ${target_id}

    #4. Get the specific article by ID
    ${detail_resp}=    GET    ${BASE_URL}${target_id}    headers=${headers}    expected_status=200
    ${article_from_detail}=    Set Variable    ${detail_resp.json()}

    #5. Compare the two objects
    Dictionaries Should Be Equal    ${article_from_list}    ${article_from_detail}

Verify Articles
    ${headers}=  Create Dictionary  Content-Type=application/json

    ${response}=  GET  ${BASE_URL}
    ...    headers=${headers}  
    ...    expected_status=200

    ${json}=    Set Variable    ${response.json()}
    Log To Console    \n${json}

Verify Article Lifecycle
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${article_title}=    Set Variable    Unique Lifecycle Test Article 2

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

    ${ids}=    Evaluate    [item['id'] for item in ${response.json()}]
    ${max_id}=    Evaluate    max(${ids})
    ${non_existent_id}=    Evaluate    ${max_id} + 1
    
    Log To Console    \nTrying to delete ID: ${non_existent_id}

    ${del_response}=    DELETE    ${BASE_URL}${non_existent_id}    
    ...    headers=${headers}    
    ...    expected_status=404