*** Settings ***
Suite Setup       Open Browser To MG Login Page
Suite Teardown    Close All Open Browsers
Test Setup        Run Keywords    Login MG With System Admin And Go To Administrator Mode    Go To RBL Protection
Test Teardown     Run Keywords    Close Other Windows    MG Logout Directly
Resource          ${CURDIR}/../../Global Settings.txt

*** Variables ***
${None}           ${EMPTY}

*** Test Cases ***
Domain Blocklist Hint Content Display
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認 Domain Blocklist 提示訊息是否出現
    Log    確認提示訊息是否出現
    Mouse Over On Hint And Verify Content Display    RBL 防護    網域阻擋列表    網域阻擋列表

System_Add Block Domain Name And Switch Status To Enable
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功新增，且狀態為 "啟用"
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    切換狀態為【啟用】
    Switch One Domain Status To Enable Or Disable    block_domain=*open.com    status=Enable
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否成功新增
    Search Block Domain List Data    keyword=*open.com
    Count Data Total Number In List    total_num=1
    Verify Domain Data Display In Block Domain List    block_domain=*open.com
    Log    在 Domain Blocklist 確認狀態是否為 "啟用"
    Verify One Block Domain Status    block_domain=*open.com    status=Enable
    [Teardown]    Delete Block Domain    block_domain=*open.com

System_Add Block Domain Name And Switch Status To Disable
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功新增，且狀態為 "停用"
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    切換狀態為【啟用】
    Switch One Domain Status To Enable Or Disable    block_domain=*open.com    status=Disable
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否成功新增
    Search Block Domain List Data    keyword=*open.com
    Count Data Total Number In List    total_num=1
    Verify Domain Data Display In Block Domain List    block_domain=*open.com
    Log    在 Domain Blocklist 確認狀態是否為 "啟用"
    Verify One Block Domain Status    block_domain=*open.com    status=Disable
    [Teardown]    Delete Block Domain    block_domain=*open.com

System_Edit
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功修改阻擋網域
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    將網域修改成*open789.com
    Edit Block Domain    block_domain=*open.com    new_block_domain=*open789.com
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否顯示正確資料
    Search Block Domain List Data    keyword=*open789.com
    Count Data Total Number In List    total_num=1
    Verify Domain Data Display In Block Domain List    block_domain=*open789.com
    [Teardown]    Delete Block Domain    block_domain=*open789.com

System_Delete
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功刪除阻擋網域
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    刪除一筆資料
    Search Block Domain List Data    keyword=*open.com
    Delete Block Domain    block_domain=*open.com
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否刪除資料
    Search Block Domain List Data    keyword=*open.com
    Count Data Total Number In List    total_num=0

System_Search
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功查詢阻擋網域
    Log    新增三筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Input New Domain Data And Click Add Button    block_domain=*open789.com
    Input New Domain Data And Click Add Button    block_domain=*abcdd.*
    Search Block Domain List Data    keyword=open
    Log    檢查是否查詢出現預期資料
    Count Data Total Number In List    total_num=2
    Verify Domain Data Display In Block Domain List    block_domain=*open.com
    Verify Domain Data Display In Block Domain List    block_domain=*open789.com
    [Teardown]    Run keywords    Search Block Domain List Data    keyword=
    ...    AND    Delete Block Domain    block_domain=*open.com
    ...    AND    Delete Block Domain    block_domain=*open789.com
    ...    AND    Delete Block Domain    block_domain=*abcdd.*

Domain_Add Block Domain Name And Switch Status To Enable
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功新增，且狀態為 "啟用"
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    切換成啟用狀態
    Switch Status In Domain    status=Enable
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    切換狀態為【啟用】
    Switch One Domain Status To Enable Or Disable    block_domain=*open.com    status=Enable
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify Domain Data Display In Block Domain List    block_domain=*open.com
    Log    在 Domain Blocklist 確認狀態是否為 "啟用"
    Verify One Block Domain Status    block_domain=*open.com    status=Enable
    [Teardown]    Run keywords    Delete Block Domain    block_domain=*open.com
    ...    AND    Switch Status In Domain    status=System Default

Domain_Add Block Domain Name And Switch Status To Disable
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功新增，且狀態為 "停用"
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    切換成啟用狀態
    Switch Status In Domain    status=Enable
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    切換狀態為【啟用】
    Switch One Domain Status To Enable Or Disable    block_domain=*open.com    status=Disable
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify Domain Data Display In Block Domain List    block_domain=*open.com
    Log    在 Domain Blocklist 確認狀態是否為 "啟用"
    Verify One Block Domain Status    block_domain=*open.com    status=Disable
    [Teardown]    Run keywords    Delete Block Domain    block_domain=*open.com
    ...    AND    Switch Status In Domain    status=System Default

Domain_Edit
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功修改阻擋網域
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    切換成啟用狀態
    Switch Status In Domain    status=Enable
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    將網域修改成*open789.com
    Edit Block Domain    block_domain=*open.com    new_block_domain=*open789.com
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否顯示正確資料
    Count Data Total Number In List    total_num=1
    Verify Domain Data Display In Block Domain List    block_domain=*open789.com
    [Teardown]    Run keywords    Delete Block Domain    block_domain=*open789.com
    ...    AND    Switch Status In Domain    status=System Default

Domain_Delete
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功刪除阻擋網域
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    切換成啟用狀態
    Switch Status In Domain    status=Enable
    Log    新增一筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Log    刪除一筆資料
    Delete Block Domain    block_domain=*open.com
    Log    重新進入頁面
    Go To RBL Protection
    Log    在 Domain Blocklist 確認是否刪除資料
    Count Data Total Number In List    total_num=0
    [Teardown]    Switch Status In Domain    status=System Default

Domain_Search
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認是否能成功查詢阻擋網域
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    切換成啟用狀態
    Switch Status In Domain    status=Enable
    Log    新增三筆資料
    Input New Domain Data And Click Add Button    block_domain=*open.com
    Input New Domain Data And Click Add Button    block_domain=*open789.com
    Input New Domain Data And Click Add Button    block_domain=*abcdd.*
    Search Block Domain List Data    keyword=open
    Log    檢查是否查詢出現預期資料
    Count Data Total Number In List    total_num=2
    Verify Domain Data Display In Block Domain List    block_domain=*open.com
    Verify Domain Data Display In Block Domain List    block_domain=*open789.com
    [Teardown]    Run keywords    Search Block Domain List Data    keyword=
    ...    AND    Delete Block Domain    block_domain=*open.com
    ...    AND    Delete Block Domain    block_domain=*open789.com
    ...    AND    Delete Block Domain    block_domain=*abcdd.*
    ...    AND    Switch Status In Domain    status=System Default

IP Allowlist Hint Content Display
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認 IP Allowlist 提示訊息是否出現
    Log    確認提示訊息是否出現
    Scroll Page To Bottom
    Mouse Over On Hint And Verify Content Display    RBL 防護    IP 允許名單    來源 IP 位址

Check RBL Protection Default Site
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認 [RBL Protection] 區塊是否顯示指定 6 個 default site
    Log    確認 [RBL Protection] 區塊是否顯示指定 6 個 default site
    Verify RBL Protection Default Site    site=cbl.abuseat.org
    Verify RBL Protection Default Site    site=sbl-xbl.spamhaus.org
    Verify RBL Protection Default Site    site=bl.spamcop.net
    Verify RBL Protection Default Site    site=cblless.anti-spam.org.cn
    Verify RBL Protection Default Site    site=dnsbl.njabl.org
    Verify RBL Protection Default Site    site=dnsbl-3.uceprotect.net

Select RBL Protestion Site And Actions Choice Classified as Spam
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認 [RBL Protection] 區塊是否能勾選指定的 default site，勾選 "分類為垃圾信"，並成功輸入 IP 允許清單
    Log    在 [RBL Protection] 區塊勾選以下三個選項
    勾選 sbl-xbl.spamhaus.org、cblless.anti-spam.org.cn、dnsbl-3.uceprotect.net(其他不勾選)
    Log    勾選 "分類為垃圾信"
    Choice RBL Action    action=Classified as Spam
    Log    在 IP 允許清單填入內容
    Set IP Allowlist And Save Change    allowlist=172.11.222.33/24 # 內部網域\n172.16.56.78:255.255.255.0 # 註解Note
    Log    重新進入頁面
    Go To RBL Protection
    Log    確認 [RBL Protection] 區塊是否顯示勾選符合預期
    確認 [RBL Protection] 區塊是否顯示勾選 sbl-xbl.spamhaus.org、cblless.anti-spam.org.cn、dnsbl-3.uceprotect.net(其他不勾選)
    Log    確認 [Action] 區塊是否勾選 Classified as Spam
    確認 [Action] 區塊是否勾選 Classified as Spam
    Log    確認 IP 允許清單是否符合預期
    Verify IP Allowlist    allowlist=172.11.222.33/24 # 內部網域\n172.16.56.78:255.255.255.0 # 註解Note
    [Teardown]    Set IP Allowlist And Save Change    allowlist=\n

Select RBL Protestion Site And Actions Choice Reject
    [Documentation]    Go to 「Email Security > Email Firewall > RBL Protection」確認 [RBL Protection] 區塊是否能勾選指定的 default site，勾選 "拒絕連線"，並成功輸入 IP 允許清單
    Log    在 [RBL Protection] 區塊勾選以下二個選項
    勾選 bl.spamcop.net、dnsbl-3.uceprotect.net(其他不勾選)
    Log    勾選 "拒絕連線"
    Choice RBL Action    action=Reject
    Log    在 IP 允許清單填入內容
    Set IP Allowlist And Save Change    allowlist=172.20.1.1:255.255.255.255 # 測試網域123456\n172.20.22.33/32 # (Note)_!@=%^*+
    Log    重新進入頁面
    Go To RBL Protection
    Log    確認 [RBL Protection] 區塊是否顯示勾選符合預期
    確認 [RBL Protection] 區塊是否顯示勾選 bl.spamcop.net、dnsbl-3.uceprotect.net(其他不勾選)
    Log    確認 [Action] 區塊是否勾選 Reject
    確認 [Action] 區塊是否勾選 Reject
    Log    確認 IP 允許清單是否符合預期
    Verify IP Allowlist    allowlist=172.20.1.1:255.255.255.255 # 測試網域123456\n172.20.22.33/32 # (Note)_!@=%^*+
    [Teardown]    Set IP Allowlist And Save Change    allowlist=\n

*** Keywords ***
Go To RBL Protection
    [Documentation]    進入 "郵件安全 > 郵件防火牆 > RBL 防護"
    Log    重載頁面
    Reload Page
    Log    進入 "郵件安全 > 郵件防火牆 > RBL 防護"
    Click Top Menu And Click Left Main Menu Item And Submeun Item For Adm Mode    郵件安全    郵件防火牆    RBL 防護

Input New Domain Data And Click Add Button
    [Arguments]    ${block_domain}=
    [Documentation]    輸入新增 Block Domain 資料
    ...
    ...    ${block_domain}為指定新增 block domain
    ...
    ...    點擊 [新增]
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    輸入 domain 資料
    Log    在 [Block Domain Name] 輸入資料並點擊 【新增】並確認新增成功提示訊息
    Input Text    xpath=//input[@id='rblhit_addnew_pattern']    ${block_domain}
    Click Element And Confirm Alert - FL    xpath=//input[@id='rblhit_addnew_btn']    新增成功

Switch One Domain Status To Enable Or Disable
    [Arguments]    ${block_domain}=    ${status}=
    [Documentation]    在「郵件安全 > 郵件防火牆 > RBL 防護」啟用或停用指定資料的 Block Domain
    ...
    ...    ${block_domain}為指定變更 block domain
    ...
    ...    ${status}為 "Enable" 或 "Disable"
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    取得網域當前啟用狀態
    Search Block Domain List Data    keyword=${block_domain}
    ${enable} =    Get Element Attribute    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${block_domain}']/..//label[@name="rbl-enable"]    attribute=value
    Log    若當前狀態與預期不符則更改狀態
    Run keyword If    '${status}' == 'Enable' and ${enable} == 0    Click Element    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${block_domain}']/..//label[@name="rbl-enable"]
    Run keyword If    '${status}' == 'Disable' and ${enable} == 1    Click Element    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${block_domain}']/..//label[@name="rbl-enable"]

Verify Domain Data Display In Block Domain List
    [Arguments]    ${block_domain}=
    [Documentation]    驗證Block Domain List中是否正確顯示 新增的 Domain 資料
    ...
    ...    ${block_domain}為指定檢查 block domain
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    驗證Block Domain List中是否正確顯示 新增的 Domain 資料
    WebElement.Element Should Be Visible    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${block_domain}']

Verify One Block Domain Status
    [Arguments]    ${block_domain}=    ${status}=
    [Documentation]    檢查指定 Block Domain 狀態
    ...
    ...    ${block_domain}為指定檢查 block domain
    ...
    ...    ${status}為預期狀態，可以是"Enable" 或 "Disable"
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    取得網域當前啟用狀態
    ${enable} =    Get Element Attribute    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${block_domain}']/..//label[@name="rbl-enable"]    attribute=value
    Log    確認當前狀態與預期是否相符
    Run keyword If    '${status}' == 'Enable'    Should Be Equal    ${enable}    1
    Run keyword If    '${status}' == 'Disable'    Should Be Equal    ${enable}    0

Delete Block Domain
    [Arguments]    ${block_domain}=
    [Documentation]    刪除指定 Block Domain
    ...
    ...    ${block_domain}為指定刪除 block domain
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    刪除該筆資料
    Search Block Domain List Data    keyword=${block_domain}
    Click Element    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${block_domain}']/..//img[@src="/mg/images/ic_delete_cross.png"]

Edit Block Domain
    [Arguments]    ${block_domain}=    ${new_block_domain}=${None}
    [Documentation]    編輯指定資料的 domain
    ...
    ...    ${block_domain}為指定資料舊 block_domain
    ...
    ...    ${new_block_domain}為指定資料新 block_domain
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    點擊該筆資料的編輯圖示
    Search Block Domain List Data    keyword=${block_domain}
    Click Element And Wait Until Element Show - FL    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${block_domain}']/..//img[@src="/mg/images/ic_pen.png"]    xpath=//input[@id="rblhit_textfield"]
    Log    輸入新資料並儲存設定並確認編輯成功訊息
    Input Text And Submit And Confirm Alert And Wait Until Element Show    xpath=//input[@id="rblhit_textfield"]    ${new_block_domain}    xpath=//button[contains(text(),'儲存設定')]    設定完成    xpath=//table[@id='rblhit-list']//td[@class=" block-domain" and text()='${new_block_domain}']

Search Block Domain List Data
    [Arguments]    ${keyword}=
    [Documentation]    在搜尋欄位中輸入關鍵字，並點選搜尋按鈕
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    在搜尋欄位中輸入關鍵字
    Input Text    xpath=//input[@type='search']    ${keyword}
    Log    點選搜尋按鈕
    Click Element And Wait Until Element Reload    xpath=//img[@class='search']    xpath=//table[@id='rblhit-list']//tbody

Switch Status In Domain
    [Arguments]    ${status}=
    [Documentation]    在網域時選擇啟用狀態
    ...
    ...    ${status}為給定啟用狀態，可以是 'System Default' 或 'Enable' 或 'Disable'
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Run keyword If    '${status}' == 'System Default'    Click Element    xpath=//label[@for="rbl_default"]
    Run keyword If    '${status}' == 'Enable'    Click Element    xpath=//label[@for="rbl_enabled"]
    Run keyword If    '${status}' == 'Disable'    Click Element    xpath=//label[@for="rbl_disabled"]
    Click Element And Wait Until Element Show - FL    xpath=//input[@value="儲存設定"]    xpath=//div[contains(text(),'設定成功')]    id=rightFrame    top

Verify RBL Protection Default Site
    [Arguments]    ${site}=
    [Documentation]    確認 [RBL Protection] 區塊是否顯示指定 default site
    ...
    ...    ${site}為預期顯示指定 default site
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    確認 [RBL Protection] 區塊是否顯示指定 default site
    Element Should Be Visible    xpath=//form[@name="rbl"]//label[contains(text(),'${site}')]

Choice RBL Action
    [Arguments]    ${action}=
    [Documentation]    選擇 RBL 行為
    ...
    ...    ${action}為給定 RBL 行為，可以是 'Classified as Spam' 或 'Reject'
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    勾選"分類為垃圾信" 或 "拒絕連線"
    Run keyword If    '${action}' == 'Classified as Spam'    Click Element    xpath=//label[@for="rbl_action_spam"]
    Run keyword If    '${action}' == 'Reject'    Click Element    xpath=//label[@for="rbl_action_reject"]

Set IP Allowlist And Save Change
    [Arguments]    ${allowlist}=
    [Documentation]    設置 IP 允許清單並儲存變更
    ...
    ...    ${allowlist}為給定 IP 允許清單
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    填入 IP 允許清單並點擊 "儲存設定"
    Input Text And Submit And Wait Until Element Show    xpath=//textarea[@id="rbl_wlist"]    ${allowlist}    xpath=//input[@id="rbl_submit"]    xpath=//div[contains(text(),'設定 「RBL Setting」 成功')]    id=rightFrame    top

Verify IP Allowlist
    [Arguments]    ${allowlist}=
    [Documentation]    檢查 IP 允許清單
    ...
    ...    ${allowlist}為給定 IP 允許清單
    ${current_allowlist} =    Get Element Attribute    xpath=//textarea[@id="rbl_wlist"]    value
    Log    比對檔案內容與預期是否相符
    ${line_current_allowlist} =    Get Line    ${current_allowlist}    0
    ${line_allowlist} =    Get Line    ${allowlist}    0
    Should Be Equal    ${line_current_allowlist}    ${line_allowlist}
    ${line_current_allowlist} =    Get Line    ${current_allowlist}    1
    ${line_allowlist} =    Get Line    ${allowlist}    1
    Should Be Equal    ${line_current_allowlist}    ${line_allowlist}

勾選 sbl-xbl.spamhaus.org、cblless.anti-spam.org.cn、dnsbl-3.uceprotect.net(其他不勾選)
    Log    勾選 sbl-xbl.spamhaus.org、cblless.anti-spam.org.cn、dnsbl-3.uceprotect.net(其他不勾選)

確認 [RBL Protection] 區塊是否顯示勾選 sbl-xbl.spamhaus.org、cblless.anti-spam.org.cn、dnsbl-3.uceprotect.net(其他不勾選)
    Log    確認 [RBL Protection] 區塊是否顯示勾選符合預期

確認 [Action] 區塊是否勾選 Classified as Spam
    Log    確認 [Action] 區塊是否勾選 Classified as Spam

勾選 bl.spamcop.net、dnsbl-3.uceprotect.net(其他不勾選)
    Log    勾選 bl.spamcop.net、dnsbl-3.uceprotect.net(其他不勾選)

確認 [RBL Protection] 區塊是否顯示勾選 bl.spamcop.net、dnsbl-3.uceprotect.net(其他不勾選)
    Log    確認 [RBL Protection] 區塊是否顯示勾選 bl.spamcop.net、dnsbl-3.uceprotect.net(其他不勾選)

確認 [Action] 區塊是否勾選 Reject
    Log    確認 [Action] 區塊是否勾選 Reject
