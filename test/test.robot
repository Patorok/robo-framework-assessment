*** Settings ***
Library    SeleniumLibrary
Library    ./libraries/Users.py
Library    ./env/lib/python3.12/site-packages/robot/libraries/Collections.py
Variables    ./variables/variable.py

Suite Setup    Launch Browser    https://marmelab.com/react-admin-demo/
Suite Teardown    Close All Browsers

*** Variables ***
# Suite Variable == Global Variable
${var_name}    Patrick
${USERS}    Set Variable    None
${CUSTOMERS}    Set Variable    None
${CUSTOMERS_WITH_ZERO_ORDERS}    None

*** Test Cases ***
Test Case 1
    # Input Text    id:APjFqb    Munggo Recipe Panlasang Pinoy
    # Sleep    5s
    # ${query}    Get Element Attribute    id:APjFqb    value
    # Should Be Equal As Strings    ${query}    Ang pogi ni Jacinto Sobra!

    # Press Keys    id:APjFqb    ENTER
    # Sleep    5s
    # Login User    demo    demo
    # Go To Link    Customers
    # Display All Names
    # Sleep     5s
    
    # Go To Link    Customers
    # Open Add Identity
    # Add User    ${USERS}[0]
    # Log To Console    ${USERS}[0]
    Fetch Data
    Login User    demo    demo
    Add All User    ${USERS}
    Sleep    3s
    Display All Names
    Verify Users
    Sleep     3s

Test Case 2
    Login User    demo    demo
    Go To Link    Customers
    Display All Names
    Check Customers With Zero Orders
    Sleep    3s
    

*** Keywords ***        
Launch Browser
    [Arguments]    ${url}="https://www.google.com/"
    ${options}    Set Variable    add_argument("--start-maximized")
    Open Browser    ${url}    chrome    remote_url=http://172.17.0.1:4444    options=${options}

Login User
    [Arguments]    ${user}    ${password}
    Input Text    name:username    ${user}
    Input Text    name:password    ${password}
    Click Button    //button

Display All Names
    Wait Until Page Contains Element    //tbody//tr    timeout=10
    
    ${name_list}    Create List
    ${elements}    Get WebElements    //tbody//tr
    ${length}    Get Length    ${elements}

    FOR   ${i}   IN RANGE   1   ${length}+1
        ${locator}    Set Variable    ((//tbody//tr)[${i}]//td)[2]//a//div
        ${name_text}    Get Text    ${locator}

        ${status}    Run Keyword And Return Status    Page Should Contain Element    ${locator}//img
        IF  not ${status}
            ${name_text}    Evaluate    r"""${name_text}""".replace("\\n","")[1:]
        END
        Append To List    ${name_list}    ${name_text}
    END
    Set Global Variable    ${CUSTOMERS}    ${name_list}

Add All User
    [Arguments]    ${users}
    FOR  ${user}  IN  @{users}
        Go To Link    Customers
        Open Add Identity
        Add User    ${user}
        Wait Until Page Contains    Delete
    END
    Go To Link    Customers

Verify Users
    Check If All Users Created
    Display All Customers

Check If All Users Created
    ${all_users_are_created}    Set Variable    True
    FOR  ${user}  IN  @{USERS}
        FOR  ${customer}  IN  @{CUSTOMERS}
            ${found}    Set Variable    False
            IF  "${user['name']}" == "${customer}"
                ${found}    Set Variable    True
                BREAK
            END
        END
        IF  not ${found}
            ${all_users_are_created}    Set Variable    False
            Log To Console    User ${user['name']} is not found in customers.
        END
    END
    IF  ${all_users_are_created}
        Log To Console    \nAll Users Created Are Displayed
    ELSE
        Log To Console    \nNot All Users Are Created
        Fail    Not All Users Are Created
    END

Display All Customers
    ${length}    Get Length    ${CUSTOMERS}
    ${users_with_zero_orders}    Create List

    FOR   ${i}   IN RANGE   1   ${length}+1
        ${index}=    Evaluate    ${i} - 1
        ${last_seen_text}    Get Text   ((//tbody//tr)[${i}]//td)[3]
        ${order_text}    Get Text   ((//tbody//tr)[${i}]//td)[4]
        ${total_spent_text}    Get Text   ((//tbody//tr)[${i}]//td)[5]
        ${latest_purchase_text}    Get Text    ((//tbody//tr)[${i}]//td)[6]
        ${news_text}    Get Element Attribute    ((//tbody//tr)[${i}]//td)[7]//span//*[name()='svg']    aria-label
        ${segments_text}    Get Text    ((//tbody//tr)[${i}]//td)[8]
        
        ${is_new_user}    Set Variable    False

        FOR  ${user}   IN   @{USERS}
            IF  "${user['name']}" == "${CUSTOMERS}[${index}]"
                ${is_new_user}    Set Variable    True
                BREAK
            END
        END

        Log To Console    ----------User ${i}----------

        IF  ${is_new_user}
            Log To Console    Test Created User: ${CUSTOMERS}[${index}]
        ELSE
            Log To Console    Existing User: ${CUSTOMERS}[${index}]
        END

        Log To Console    Last Seen: ${last_seen_text}
        Log To Console    Orders: ${order_text}
        Log To Console    Total Spent: ${total_spent_text}
        Log To Console    Latest Purchase: ${latest_purchase_text}
        Log To Console    News.: ${news_text}
        Log To Console    Segments: ${segments_text}

        IF   "${order_text}" == "0"
            Append To List    ${users_with_zero_orders}    ${CUSTOMERS}[${index}]
        END
    END
    Set Global Variable    ${CUSTOMERS_WITH_ZERO_ORDERS}    ${users_with_zero_orders}

Go To Link
    [Arguments]    ${text}
    Click Element    //a[text()="${text}"]
    Wait Until Element Is Visible     //tbody//tr    5s
    
Fetch Data
    ${users}    Get Users Via Api
    Set Suite Variable    ${USERS}    ${users}

Open Add Identity
    Click Element    //a[@aria-label="Create"]
    Wait Until Element Is Visible    ${indentity_txt_firstname}    10s

Add User
    [Arguments]    ${user}
    ${firstname}    Evaluate    " ".join("${user['name']}".split()[:-1]).strip()
    ${lastname}    Evaluate    " ".join("${user['name']}".split()[-1:]).strip()
    ${address}    Evaluate    f"${user['address']['street']}"
    ${password}    Set Variable    P@ssWord456

    Input Text    ${indentity_txt_firstname}    ${firstname}
    Input Text    ${indentity_txt_lastname}    ${lastname}

    Input Text    ${indentity_txt_email}    ${user['email']}
    Input Date   ${indentity_txt_birthday}    ${user['birthday']}
    Input Text    ${indentity_txt_address}    ${address}
    Input Text    ${indentity_txt_city}    ${user['address']['city']}
    Input Text    ${indentity_txt_stateAbbr}    ${user['address']['state']}
    Input Text    ${indentity_txt_zipcode}    ${user['address']['zipcode']}
    Input Text    ${indentity_txt_password}    ${password}
    Input Text    ${indentity_txt_confirm_password}    ${password}

    Press Keys    //button[@type="submit"]    ENTER

Input Date
    [Arguments]    ${locator}    ${date}
    Click Element At Coordinates    ${locator}    0    0
    Press Keys    None    ${date}

Check Customers With Zero Orders
    ${length}    Get Length    ${CUSTOMERS}
    ${users_with_zero_orders}    Create List
    FOR   ${i}   IN RANGE   1   ${length}+1
        ${index}=    Evaluate    ${i} - 1
        ${order_text}    Get Text   ((//tbody//tr)[${i}]//td)[4]
        IF   "${order_text}" == "0"
            Append To List    ${users_with_zero_orders}    ${CUSTOMERS}[${index}]
        END
    END
    Set Global Variable    ${CUSTOMERS_WITH_ZERO_ORDERS}    ${users_with_zero_orders}
    Run Keyword If   ${CUSTOMERS_WITH_ZERO_ORDERS} is not None    Fail    Users With 0 Orders Found: ${CUSTOMERS_WITH_ZERO_ORDERS}