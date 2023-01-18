*** Settings ***
Suite Setup       Open Browser To MG Login Page
Suite Teardown    Close All Open Browsers
Test Setup        Run Keywords    Login MG With System Admin And Go To Administrator Mode    Go To Trust IP List
Test Teardown     Run Keywords    Close Other Windows    MG Logout Directly
Resource          ${CURDIR}/../../Global Settings.txt

*** Variables ***
${None}           ${EMPTY}

*** Test Cases ***
Hint Content Display
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」確認提示訊息是否出現
    Log    確認提示訊息是否出現
    Mouse Over On Hint And Verify Content Display    信任 IP 列表    現有信任 IP 列表    信任 IP 列表

Add Trust IP List_CIDR
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增 CIDR 並確認成功新增
    Log    新增一筆資料
    Input New IP Data And Click Add Button    IP_address=1.2.3.4    subnet_mask=255.255.255.0    description=信任 IP 說明設定Description
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在 Trust IP List 確認是否成功新增
    Check Total Number In IP Allowlist    total_num=1
    Verify IP Data Display In Trust IP List    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定Description
    [Teardown]    Delete Trust IP    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定Description

Add Trust IP List_MASK
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增 MASK 並確認成功新增
    Log    新增一筆資料
    Input New IP Data And Click Add Button    IP_address=127.1.1.123    subnet_mask=28    description=IP Address 123123
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在 Trust IP List 確認是否成功新增
    Check Total Number In IP Allowlist    total_num=1
    Verify IP Data Display In Trust IP List    IPv=127.1.1.123/28    description=IP Address 123123
    [Teardown]    Delete Trust IP    IPv=127.1.1.123/28    description=IP Address 123123

Add Trust IP List_SINGLE
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增 SINGLE 並確認成功新增
    Log    新增一筆資料
    Input New IP Data And Click Add Button    IP_address=198.225.1.1    description=測試測試 Test_789
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在 Trust IP List 確認是否成功新增
    Check Total Number In IP Allowlist    total_num=1
    Verify IP Data Display In Trust IP List    IPv=198.225.1.1/32    description=測試測試 Test_789
    [Teardown]    Delete Trust IP    IPv=198.225.1.1/32    description=測試測試 Test_789

Add Trust IP List_IPv6
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增 IPv6 並確認成功新增
    Log    新增一筆資料
    Input New IP Data And Click Add Button    IP_address=fc10:fc20::fc80    description=IPv6 [測試範例]
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在 Trust IP List 確認是否成功新增
    Check Total Number In IP Allowlist    total_num=1
    Verify IP Data Display In Trust IP List    IPv=fc10:fc20::fc80/128    description=IPv6 [測試範例]
    [Teardown]    Delete Trust IP    IPv=fc10:fc20::fc80/128    description=IPv6 [測試範例]

IP Address Input Invalid IP
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增非法 IP 並確認 Alert 顯示 "IP 格式錯誤！"
    Log    新增一筆不合法的 IP 資料
    Input New IP Data    IP_address=127.0.0.777
    Log    點擊新增並驗證是否出現[IP格是錯誤]警告框
    Click Add Button And Check Alert Message    alert_text=IP 格式錯誤！

IP Address Input Text
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增文字 IP 並確認 Alert 顯示 "IP 格式錯誤！"
    Log    新增一筆不合法的 IP 資料
    Input New IP Data    IP_address=hello mailgates
    Log    點擊新增並驗證是否出現[IP格是錯誤]警告框
    Click Add Button And Check Alert Message    alert_text=IP 格式錯誤！

Subnet Mask Input Invalid Value
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增非法 Subnet Mask 並確認 Alert 顯示 "MASK 格式錯誤！"
    Log    新增一筆不合法的 IP 資料
    Input New IP Data    IP_address=120.1.2.3    subnet_mask=127.0.0.888
    Log    點擊新增並驗證是否出現[IP格是錯誤]警告框
    Click Add Button And Check Alert Message    alert_text=MASK 格式錯誤！

Subnet Mask Input Text
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」新增文字 Subnet Mask 並確認 Alert 顯示 "MASK 格式錯誤！"
    Log    新增一筆不合法的 IP 資料
    Input New IP Data    IP_address=120.1.2.3    subnet_mask=hello mailgates
    Log    點擊新增並驗證是否出現[IP格是錯誤]警告框
    Click Add Button And Check Alert Message    alert_text=MASK 格式錯誤！

Description_Special characters
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」在 Description 新增 Special characters 並確認成功新增
    ...    Bug [設定說明] 欄位會重複 decode (description只顯示"~!@#$%^*()_+{}|:?")
    [Tags]    Bug
    Log    新增一筆資料
    Input New IP Data And Click Add Button    IP_address=127.1.1.123    subnet_mask=28    description=~!@#$%^*()_+{}|:?\
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在 Trust IP List 確認是否成功新增 (description只顯示"~!@#$%^*()_+{}|:?")
    Check Total Number In IP Allowlist    total_num=1
    Verify IP Data Display In Trust IP List    IPv=127.1.1.123/28    description=~!@#$%^*()_+{}|:?
    [Teardown]    Delete Trust IP    IPv=127.1.1.123/28    description=~!@#$%^*()_+{}|:?

Description Limit Text
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」在 description 測試可顯示字元上限
    Log    新增一筆資料
    Input New IP Data And Click Add Button    IP_address=127.1.1.123    subnet_mask=28    description=ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2560000
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在 Trust IP List 確認 [設定說明] 欄位顯示"ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd256" (不會顯示最後的2560000)
    Check Total Number In IP Allowlist    total_num=1
    Verify IP Data Display In Trust IP List    IPv=127.1.1.123/28    description=ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd256
    [Teardown]    Delete Trust IP    IPv=127.1.1.123/28    description=ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd256

Search IP Address and Description
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」檢查搜尋結果是否符合預期
    Log    新增四筆資料
    Input New IP Data And Click Add Button    IP_address=1.2.3.4    subnet_mask=255.255.255.0    description=信任 IP 說明設定
    Input New IP Data And Click Add Button    IP_address=127.2.2.123    subnet_mask=5    description=IP Address 123123
    Input New IP Data And Click Add Button    IP_address=127.1.1.123    subnet_mask=28    description=IPPPP 198.225
    Input New IP Data And Click Add Button    IP_address=198.225.1.1    description=測試測試 Test_789
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在阻擋名單中搜尋關鍵字
    Search Trust IP List Data    keyword=198.225
    Log    驗證含有關鍵字的資料是否出現
    Check Total Number In IP Allowlist    total_num=2
    Verify IP Data Display In Trust IP List    IPv=127.1.1.123/28    description=IPPPP 198.225
    Verify IP Data Display In Trust IP List    IPv=198.225.1.1/32    description=測試測試 Test_789
    [Teardown]    Run keywords    Search Trust IP List Data
    ...    AND    Delete Trust IP    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定    save=False
    ...    AND    Delete Trust IP    IPv=127.2.2.123/5    description=IP Address 123123    save=False
    ...    AND    Delete Trust IP    IPv=127.1.1.123/28    description=IPPPP 198.225    save=False
    ...    AND    Delete Trust IP    IPv=198.225.1.1/32    description=測試測試 Test_789

Add Same Data
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」確認新增重複資料時會出現提示 '相同的資料已存在'
    Log    新增一筆資料
    Input New IP Data And Click Add Button    IP_address=10.20.30.40    description=信任 IP 說明設定
    Log    新增一筆相同資料
    Input New IP Data    IP_address=10.20.30.40    description=信任 IP 說明設定
    Log    點擊新增並驗證是否出現[新增失敗]警告框
    Click Add Button And Check Alert Message    alert_text=信任 IP 說明設定    alert_text=新增失敗，相同的資料已存在 10.20.30.40/32=10.20.30.40/32

Edit
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」確認 編輯後，資料有更新
    Log    新增兩筆資料
    Input New IP Data And Click Add Button    IP_address=1.2.3.4    subnet_mask=255.255.255.0    description=信任 IP 說明設定
    Input New IP Data And Click Add Button    IP_address=127.2.2.123    subnet_mask=5    description=IP Address 123123
    Save All Changes
    Log    在 Trusted IP List 確認兩筆資料新增成功
    Check Total Number In IP Allowlist    total_num=2
    Verify IP Data Display In Trust IP List    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定
    Verify IP Data Display In Trust IP List    IPv=127.2.2.123/5    description=IP Address 123123
    Log    編輯 'IPv=1.2.3.4:255.255.255.0' 的資料
    Edit Trust IP    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定    new_IP_address=198.225.1.1    new_subnet_mask=    new_description=測試測試 Test_789
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    在 Trusted IP List 確認是否顯示正確資料
    Check Total Number In IP Allowlist    total_num=2
    Verify IP Data Display In Trust IP List    IPv=198.225.1.1/32    description=測試測試 Test_789
    Verify IP Data Display In Trust IP List    IPv=127.2.2.123/5    description=IP Address 123123
    [Teardown]    Run keywords    Delete Trust IP    IPv=198.225.1.1/32    description=測試測試 Test_789    save=False
    ...    AND    Delete Trust IP    IPv=127.2.2.123/5    description=IP Address 123123

Delete
    [Documentation]    Go to 「Email Security > Email Firewall > Trust IP List」確認成功刪除資料
    Log    新增兩筆資料
    Input New IP Data And Click Add Button    IP_address=1.2.3.4    subnet_mask=255.255.255.0    description=信任 IP 說明設定
    Input New IP Data And Click Add Button    IP_address=127.2.2.123    subnet_mask=5    description=IP Address 123123
    Save All Changes
    Log    在 Trusted IP List 確認兩筆資料新增成功
    Check Total Number In IP Allowlist    total_num=2
    Verify IP Data Display In Trust IP List    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定
    Verify IP Data Display In Trust IP List    IPv=127.2.2.123/5    description=IP Address 123123
    Log    刪除 'IPv=1.2.3.4:255.255.255.0' 的資料
    Delete Trust IP    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定
    Save All Changes
    Log    重新進入頁面
    Go To Trust IP List
    Log    確認 'IPv=1.2.3.4:255.255.255.0' 的資料已被刪除
    Check Total Number In IP Allowlist    total_num=1
    Verify IP Data Not Display In Trust IP List    IPv=1.2.3.4:255.255.255.0    description=信任 IP 說明設定
    [Teardown]    Delete Trust IP    IPv=127.2.2.123/5    description=IP Address 123123

*** Keywords ***
Go To Trust IP List
    [Documentation]    進入 "郵件安全 > 郵件防火牆 > 信任 IP 列表"
    Log    重載頁面
    Reload Page
    Log    進入 "郵件安全 > 郵件防火牆 > 信任 IP 列表"
    Click Top Menu And Click Left Main Menu Item And Submeun Item For Adm Mode    郵件安全    郵件防火牆    信任 IP 列表

Input New IP Data And Click Add Button
    [Arguments]    ${IP_address}=    ${subnet_mask}=    ${description}=
    [Documentation]    輸入新增 Trust IP 資料
    ...
    ...    ${IP_address}為指定新增 IP address
    ...
    ...    ${subnet_mask}為指定新增 subnet mask
    ...
    ...    ${description}為指定新增 description
    ...
    ...    點擊 [新增]
    ...
    ...    新增成功則點擊 [儲存所有變更]
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    輸入 IP 資料
    Input New IP Data    ${IP_address}    ${subnet_mask}    ${description}
    Log    點擊 [新增]
    Log    新增成功則點擊 [儲存所有變更]
    Click Element And Wait Until Element Show - FL    xpath=//input[@value='新增' or @value='Add']    xpath=//td[@name="ipv" and contains(text(),'${IP_address}')]

Input New IP Data
    [Arguments]    ${IP_address}=    ${subnet_mask}=    ${description}=
    [Documentation]    輸入新增 Trust IP 資料
    ...
    ...    ${IP_address}為指定新增 IP address
    ...
    ...    ${subnet_mask}為指定新增 subnet mask
    ...
    ...    ${description}為指定新增 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    輸入 IP address
    Input Text    xpath=//input[@name='ip' and not(@value)]    ${IP_address}
    Log    輸入 subnet mask
    Input Text    xpath=//input[@name='mask' and not(@value)]    ${subnet_mask}
    Log    輸入 description
    Input Text    xpath=//input[@name='descript' and not(@value)]    ${description}

Click Add Button
    [Arguments]    ${IP_address}=
    [Documentation]    點擊 [新增]
    ...    新增成功則點擊 [儲存所有變更]
    ...
    ...    ${IP_address}為指定新增 IP address
    ...
    ...    ${alert_text}為指定預期提示訊息
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊 [新增]
    Log    新增成功則點擊 [儲存所有變更]
    Click Element And Wait Until Element Show - FL    xpath=//input[@value='新增' or @value='Add']    xpath=//td[@name="ipv" and contains(text(),'${IP_address}')]

Click Add Button And Check Alert Message
    [Arguments]    ${IP_address}=    ${alert_text}=
    [Documentation]    點擊 [新增]
    ...    新增失敗則檢查提示
    ...
    ...    ${IP_address}為指定新增 IP address
    ...
    ...    ${alert_text}為指定預期提示訊息
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊 [新增]
    Log    檢查提示
    Click Element And Confirm Alert - FL    xpath=//input[@value='新增' or @value='Add']    ${alert_text}

Save All Changes
    [Documentation]    儲存所有更動
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊 [儲存所有更動]
    Click Element And Wait Until Element Show    xpath=//input[@value='儲存所有更動' or @value='Save All Changes']    xpath=//div[contains(text(),'設定已更新')]    name=rightFrame    top

Verify IP Data Display In Trust IP List
    [Arguments]    ${IPv}=    ${description}=
    [Documentation]    在新增資料後 驗證信任 IP 列表中總筆數是否正確，且是否正確顯示 新增的 IP 資料
    ...
    ...    ${IPv}為指定檢查 IPv
    ...
    ...    ${description}為指定檢查 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Run keyword If    '${description}' == ''    WebElement.Element Should Be Visible    xpath=//table[@id='ipList']//td[@name='ipv' and text()='${IPv}']/following-sibling::td[@name="descript"]
    ...    ELSE    WebElement.Element Should Be Visible    xpath=//table[@id='ipList']//td[@name='ipv' and text()='${IPv}']/following-sibling::td[@name="descript" and text()='${description}']

Check Total Number In IP Allowlist
    [Arguments]    ${total_num}=0
    [Documentation]    在新增資料後 驗證信任 IP 列表中總筆數是否正確
    ...
    ...    ${total_num}為信任 IP 列表中資料總筆數
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    計算 信任 IP 列表顯示幾筆資料
    ${rowsNumber}=    WebElement.Get Element Count    xpath=//table[@id="ipList"]//tbody//tr
    ${totalNumber}=    Convert To Number    ${total_num}
    WebElement.Should Be Equal    ${rowsNumber}    ${totalNumber}

Delete Trust IP
    [Arguments]    ${IPv}=    ${description}=    ${save}=True
    [Documentation]    刪除與給定資料相通的 Trust IP 資訊，可選是否儲存變更，預設為儲存
    ...
    ...    ${IPv}為指定刪除 IPv
    ...
    ...    ${description}為指定刪除 description
    ...
    ...    ${save}為刪除資料後是否儲存(預設為儲存)
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊該筆資料的刪除圖示
    Run keyword If    '${description}' == ''    Click Element And Wait Until Element Show - FL    xpath=//table[@id='ipList']//td[text()='${IPv}']/following-sibling::td[@name="descript"]/..//img[@onclick="itemRemove(this)"]    //div[@id="spic"]
    ...    ELSE    Click Element And Wait Until Element Show - FL    xpath=//table[@id='ipList']//td[text()='${IPv}']/following-sibling::td[text()='${description}']/..//img[@onclick="itemRemove(this)"]    //div[@id="spic"]
    Log    儲存所有變更
    Run Keyword If    '${save}' == 'True'    Save All Changes

Search Trust IP List Data
    [Arguments]    ${keyword}=
    [Documentation]    在搜尋欄位中輸入關鍵字，並點選搜尋按鈕
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    在搜尋欄位中輸入關鍵字
    Input Text    xpath=//input[@type='search']    ${keyword}
    Log    點選搜尋按鈕
    Click Element And Wait Until Element Reload    xpath=//img[@class='search']    xpath=//table[@id='ipList']//tbody

Edit Trust IP
    [Arguments]    ${IPv}=    ${description}=    ${new_IP_address}=${None}    ${new_subnet_mask}=${None}    ${new_description}=${None}
    [Documentation]    編輯指定資料的 Trust IP
    ...
    ...    ${IPv}為指定資料原 IPv
    ...
    ...    ${description}為指定資料原 description
    ...
    ...    ${new_IP_address}為指定資料新 IP address
    ...
    ...    ${new_subnet_mask}為指定資料新 subnet_mask
    ...
    ...    ${new_description}為指定資料新 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊該筆資料的編輯圖示
    Run keyword If    '${description}' == ''    Click Element And Wait Until Element Show - FL    xpath=//table[@id='ipList']//td[text()='${IPv}']/following-sibling::td[@name="descript"]/..//a[@onclick="itemEdit(this)"]    //div[@id="edit_block"]
    ...    ELSE    Click Element And Wait Until Element Show - FL    xpath=//table[@id='ipList']//td[text()='${IPv}']/following-sibling::td[text()='${description}']/..//a[@onclick="itemEdit(this)"]    //div[@id="edit_block"]
    Log    輸入新 IP address
    Run Keyword If    '${new_IP_address}' != '${None}'    Input Text    xpath=//div[@class="set-value"]/input[@name="ip"]    ${new_IP_address}
    Log    輸入新 subnet mask
    Run Keyword If    '${new_subnet_mask}' != '${None}'    Input Text    xpath=//div[@class="set-value"]/input[@name="mask"]    ${new_subnet_mask}
    Log    輸入新 description
    Run Keyword If    '${new_description}' != '${None}'    Input Text    xpath=//div[@class="set-value"]/input[@name="descript"]    ${new_description}
    Log    點擊【儲存】
    Click Element And Wait Until Element Hide    xpath=//button[contains(text(),'儲存')]    xpath=//div[@id="edit_block"]

Verify IP Data Not Display In Trust IP List
    [Arguments]    ${IPv}=    ${description}=
    [Documentation]    驗證信任 IP 列表中是否未顯示 指定 IP 資料
    ...
    ...    ${IPv}為指定檢查 IPv
    ...
    ...    ${description}為指定檢查 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    ${rowsNumber}=    WebElement.Get Element Count    xpath=//table[@id="ipList"]//tbody//tr
    FOR    ${row}    IN RANGE    ${rowsNumber}
        ${table}    Run Keyword and return status    Element Should Be Visible    xpath=//table[@id="ipList"]//tr[${row}+1]
        Exit For Loop If    ${table}==False
        Run keyword If    '${description}' == ''    WebElement.Element Should Not Be Visible    xpath=//table[@id='ipList']//tr[${row}+1]/td[@name='ipv' and text()='${IPv}']/following-sibling::td[@name="descript"]
        ...    ELSE    WebElement.Element Should Not Be Visible    xpath=//table[@id='ipList']//tr[${row}+1]/td[@name='ipv' and text()='${IPv}']/following-sibling::td[@name="descript" and text()='${description}']
    END
