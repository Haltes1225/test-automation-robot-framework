*** Settings ***
Library    RequestsLibrary 

*** Test Cases ***
Verify Get Request
    ${response}=  GET  http://proxy/health  expected_status=200


#Verify Post Request
#    # ${response}=  POST  http://proxy/articles/  data={"title":"test","content":"test"}  expected_status=201
#
#    ${headers}=  Create Dictionary  Content-Type=application/json
#    ${response}=  POST  http://proxy/articles/  data={"title":"test","content":"test"}  headers=${headers}  expected_status=201
