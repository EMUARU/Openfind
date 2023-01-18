*** Settings ***
Suite Setup       Open Browser To MG Login Page
Suite Teardown    Close All Open Browsers
Test Setup        Run Keywords    Login MG With System Admin And Go To Administrator Mode    Go To DKIM Verification
Test Teardown     Run Keywords    Close Other Windows    MG Logout Directly
Resource          ${CURDIR}/../../Global Settings.txt

*** Variables ***
&{authentication_result_name}    無 DKIM 簽章=nosig    DKIM 驗證成功=success    DKIM 驗證失敗=fail

*** Test Cases ***
Hint Content Display
    [Documentation]    將滑鼠移到提示圖標，確認提示框是否出現
    Log    將滑鼠移到提示圖示
    Mouse Over On Hint And Verify Content Display    DKIM 驗證    DKIM 驗證    DKIM 驗證

System_Disable Status
    [Documentation]    檢查驗證能否停用
    Log    將 DKIM 驗證 設為停用
    Switch DKIM Verification Status To Enable Or Disable    status=Disable
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 驗證 為停用
    Verify DKIM Verification Status    status=Disable
    [Teardown]    Switch DKIM Verification Status To Enable Or Disable    status=Enable

System_No DKIM Signature_Accept
    [Documentation]    檢查 無 DKIM 簽章 能否接受信件
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=無 DKIM 簽章    action=接收信件    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 '無 DKIM 簽章' 為 '接受信件'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=無 DKIM 簽章    action=接收信件

System_No DKIM Signature_Reject
    [Documentation]    檢查 無 DKIM 簽章 能否拒絕信件
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=無 DKIM 簽章    action=拒絕信件    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 '無 DKIM 簽章' 為 '拒絕信件'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=無 DKIM 簽章    action=拒絕信件

System_No DKIM Signature_Mark as SPAM
    [Documentation]    檢查 無 DKIM 簽章 能否標記為垃圾信
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=無 DKIM 簽章    action=標記為垃圾信    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 '無 DKIM 簽章' 為 '標記為垃圾信'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=無 DKIM 簽章    action=標記為垃圾信

System_DKIM Verification Successful_Accept
    [Documentation]    檢查 DKIM 驗證成功 能否接受信件
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證成功    action=接收信件    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證成功' 為 '接受信件'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證成功    action=接收信件

System_DKIM Verification Successful_Reject
    [Documentation]    檢查 DKIM 驗證成功 能否拒絕信件
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證成功    action=拒絕信件    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證成功' 為 '拒絕信件'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證成功    action=拒絕信件

System_DKIM Verification Successful_Mark as SPAM
    [Documentation]    檢查 DKIM 驗證成功 能否標記為垃圾信
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證成功    action=標記為垃圾信    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證成功' 為 '標記為垃圾信'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證成功    action=標記為垃圾信

System_DKIM Verification Failed_Accept
    [Documentation]    檢查 DKIM 驗證失敗 能否接受信件
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證失敗    action=接收信件    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證失敗' 為 '接受信件'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證失敗    action=接收信件

System_DKIM Verification Failed_Reject
    [Documentation]    檢查 DKIM 驗證失敗 能否拒絕信件
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證失敗    action=拒絕信件    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證失敗' 為 '拒絕信件'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證失敗    action=拒絕信件

System_DKIM Verification Failed_Mark as SPAM
    [Documentation]    檢查 DKIM 驗證失敗 能否標記為垃圾信
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證失敗    action=標記為垃圾信    mode=system
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證失敗' 為 '標記為垃圾信'
    Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證失敗    action=標記為垃圾信

Domain_Use System Default Status Hint Content Display
    [Documentation]    將滑鼠移到提示圖標，確認提示框是否出現
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將滑鼠移到提示圖示
    Domain_Mouse Over On Hint And Verify Content Display    DKIM 驗證:    啟用狀態:    DKIM 驗證

Domain_Enabled Status Hint Content Display
    [Documentation]    將滑鼠移到提示圖標，確認提示框是否出現
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將滑鼠移到提示圖示
    Domain_Mouse Over On Hint And Verify Content Display    DKIM 驗證:    啟用狀態:    注意

Domain_Use System Default Status
    [Documentation]    檢查驗證能否使用系統預設值
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    在網域將 DKIM 驗證 設為使用系統預設值
    Switch DKIM Verification Status To Enable Or Disable Or System Default    status=System Default
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 驗證 為使用系統預設值

Domain_Diable Status
    [Documentation]    檢查驗證能否停用
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    在網域將 DKIM 驗證 設為停用
    Switch DKIM Verification Status To Enable Or Disable Or System Default    status=Disable
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 驗證 為停用

Domain_No DKIM Signature_Accept
    [Documentation]    檢查 無 DKIM 簽章 能否接受信件
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=無 DKIM 簽章    action=接收信件    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 '無 DKIM 簽章' 為 '接受信件'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=無 DKIM 簽章    action=接收信件

Domain_No DKIM Signature_Reject
    [Documentation]    檢查 無 DKIM 簽章 能否拒絕信件
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=無 DKIM 簽章    action=拒絕信件    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 '無 DKIM 簽章' 為 '拒絕信件'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=無 DKIM 簽章    action=拒絕信件

Domain_No DKIM Signature_Mark as SPAM
    [Documentation]    檢查 無 DKIM 簽章 能否標記為垃圾信
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=無 DKIM 簽章    action=標記為垃圾信    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 '無 DKIM 簽章' 為 '標記為垃圾信'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=無 DKIM 簽章    action=標記為垃圾信

Domain_DKIM Verification Successful_Accept
    [Documentation]    檢查 DKIM 驗證成功 能否接受信件
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證成功    action=接收信件    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證成功' 為 '接受信件'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證成功    action=接收信件

Domain_DKIM Verification Successful_Reject
    [Documentation]    檢查 DKIM 驗證成功 能否拒絕信件
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證成功    action=拒絕信件    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證成功' 為 '拒絕信件'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證成功    action=拒絕信件

Domain_DKIM Verification Successful_Mark as SPAM
    [Documentation]    檢查 DKIM 驗證成功 能否標記為垃圾信
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證成功    action=標記為垃圾信    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證成功' 為 '標記為垃圾信'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證成功    action=標記為垃圾信

Domain_DKIM Verification Failed_Accept
    [Documentation]    檢查 DKIM 驗證失敗 能否接受信件
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證失敗    action=接收信件    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證失敗' 為 '接受信件'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證失敗    action=接收信件

Domain_DKIM Verification Failed_Reject
    [Documentation]    檢查 DKIM 驗證失敗 能否拒絕信件
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證失敗    action=拒絕信件    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證失敗' 為 '拒絕信件'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證失敗    action=拒絕信件

Domain_DKIM Verification Failed_Mark as SPAM
    [Documentation]    檢查 DKIM 驗證失敗 能否標記為垃圾信
    Log    在系統將 DKIM 驗證 設為啟用
    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    將 DKIM 驗證 設為啟用 並 設置驗證結果的執行動作
    Switch Authentication result Actions    authentication_result=DKIM 驗證失敗    action=標記為垃圾信    mode=domain
    Log    重新進入頁面
    Go To DKIM Verification
    Log    驗證 DKIM 狀態 為 啟用 且 'DKIM 驗證失敗' 為 '標記為垃圾信'
    Domain_Verify DKIM Verification Status And Authentication result Actions    authentication_result=DKIM 驗證失敗    action=標記為垃圾信

*** Keywords ***
Go To DKIM Verification
    [Documentation]    進入「郵件安全 > 郵件防火牆 > 網域相關認證 > DKIM 驗證」
    Log    重新整理頁面
    Reload Page
    Log    點擊 郵件安全 > 郵件防火牆 > 網域相關認證 > DKIM 驗證
    Click Top Menu And Click Left Main Menu Item And Submeun Item For Adm Mode    郵件安全    網域相關認證    DKIM 驗證

Domain_Mouse Over On Hint And Verify Content Display
    [Arguments]    ${function}    ${text}    ${content}
    [Documentation]    將滑鼠移到提示的圖示上
    ...    ${function}: 功能頁面名稱
    ...
    ...
    ...    ${text}: Hint 的標題；${content}: Hint 內容(驗證一段敘述即可)
    Enter Frame    id=rightFrame
    mouse over    xpath=//div[@class='title' and contains(text(),'${function}')]/parent::*/parent::*//*[contains(text(),'${text}')]/../..//span[contains(@class,'info')]//img[contains(@alt,'${content}')]

Switch DKIM Verification Status To Enable Or Disable
    [Arguments]    ${status}=
    [Documentation]    在「郵件安全 > 郵件防火牆 > 網域相關認證 > DKIM 驗證」啟用或停用 DKIM 驗證
    ...
    ...    ${status}為 "Enable" 或 "Disable"
    Log    取得當前啟用狀態
    ${current_status} =    Get Text    xpath=//label[@name="dkim_enabled"]//div[@class="text"]
    Log    若當前狀態與預期不符則更改狀態
    Run keyword If    '${status}' == 'Enable' and '${current_status}' == '停用'    Click Element And Wait Until Element Reload    xpath=//label[@name="dkim_enabled"]    xpath=//label[@name="dkim_enabled"]//div[@class="text"]
    Run keyword If    '${status}' == 'Disable' and '${current_status}' == '啟用'    Click Element And Wait Until Element Reload    xpath=//label[@name="dkim_enabled"]    xpath=//label[@name="dkim_enabled"]//div[@class="text"]
    Log    儲存變更
    Run Keyword And Ignore Error    Click Element And Wait Until Element Show - FL    xpath=//input[@id="verify_submit"]    xpath=//div[contains(text(),'設定 成功')]    id=rightFrame    top

Switch DKIM Verification Status To Enable Or Disable Or System Default
    [Arguments]    ${status}=
    [Documentation]    在網域時選擇啟用狀態
    ...
    ...    ${status}為給定啟用狀態，可以是 'System Default' 或 'Enable' 或 'Disable'
    Run keyword If    '${status}' == 'System Default'    Click Element    xpath=//label[@for="dkim_apply_sys"]
    Run keyword If    '${status}' == 'Enable'    Click Element    xpath=//label[@for="dkim_enabled"]
    Run keyword If    '${status}' == 'Disable'    Click Element    xpath=//label[@for="dkim_disabled"]
    Log    儲存變更
    Click Element And Wait Until Element Show - FL    xpath=//input[@value="儲存設定"]    xpath=//div[contains(text(),'設定成功')]    id=rightFrame    top

Verify DKIM Verification Status
    [Arguments]    ${status}=
    [Documentation]    在「郵件安全 > 郵件防火牆 > 網域相關認證 > DKIM 驗證」 檢查 DKIM 驗證 為啟用或停用
    ...
    ...    ${status}為 "Enable" 或 "Disable"
    Log    取得當前啟用狀態
    ${current_status} =    Get Text    xpath=//label[@name="dkim_enabled"]//div[@class="text"]
    Log    確認當前狀態與預期是否相符
    Run keyword If    '${status}' == 'Enable'    Should Be Equal    '${current_status}'    '啟用'
    Run keyword If    '${status}' == 'Disable'    Should Be Equal    '${current_status}'    '停用'

Switch Authentication result Actions
    [Arguments]    ${authentication_result}    ${action}    ${mode}
    [Documentation]    在「郵件安全 > 郵件防火牆 > 網域相關認證 > DKIM 驗證」 切換驗證結果的執行動作
    ...
    ...    ${authentication_result}為指定驗證結果 可為 '無 DKIM 簽章' 或 'DKIM 驗證成功' 或 'DKIM 驗證失敗'
    ...
    ...    ${action}為指定驗證結果的執行動作 可為 '接收信件' 或 '拒絕信件' 或 '標記為垃圾信'
    ...
    ...    ${mode}可為 'system' 或 'domain'
    Log    取得當前 DKIM 驗證啟用狀態
    Run keyword If    '${mode}' == 'system'    Run Keyword And Ignore Error    Switch DKIM Verification Status To Enable Or Disable    status=Enable
    Run keyword If    '${mode}' == 'domain'    Run Keyword And Ignore Error    Switch DKIM Verification Status To Enable Or Disable Or System Default    status=Enable
    Enter Frame    id=rightFrame
    Log    選擇指定驗證結果的執行動作
    ${authentication_result}    get from dictionary    ${authentication_result_name}    ${authentication_result}
    Click Element And Wait Until Element Show    xpath=//select[@name="${authentication_result}"]    xpath=//option[contains(text(),"${action}")]
    Select From List by Label    xpath=//select[@name="${authentication_result}"]    ${action}
    Run Keyword And Ignore Error    Click Element And Wait Until Element Show - FL    xpath=//div[@class="submitBtns"]/input[@value="儲存設定" and not(@disabled)]    xpath=//div[contains(text(),'設定 成功')]    id=rightFrame    top

Verify DKIM Verification Status And Authentication result Actions
    [Arguments]    ${authentication_result}    ${action}
    [Documentation]    在「郵件安全 > 郵件防火牆 > 網域相關認證 > DKIM 驗證」 檢查驗證結果的執行動作
    ...
    ...    ${authentication_result}為指定驗證結果 可為 '無 DKIM 簽章' 或 'DKIM 驗證成功' 或 'DKIM 驗證失敗'
    ...
    ...    ${action}為指定驗證結果的執行動作 可為 '接收信件' 或 '拒絕信件' 或 '標記為垃圾信'
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    驗證 DKIM 驗證 為啟用
    Verify DKIM Verification Status    status=Enable
    Log    驗證指定驗證結果的執行動作
    ${authentication_result}    get from dictionary    ${authentication_result_name}    ${authentication_result}
    Element Should Be Visible    xpath=//select[@name="${authentication_result}"]/Option[contains(text(),'${action}')][@selected]

Domain_Verify DKIM Verification Status And Authentication result Actions
    [Arguments]    ${authentication_result}    ${action}
    [Documentation]    在網域「郵件安全 > 郵件防火牆 > 網域相關認證 > DKIM 驗證」 檢查驗證結果的執行動作
    ...
    ...    ${authentication_result}為指定驗證結果 可為 '無 DKIM 簽章' 或 'DKIM 驗證成功' 或 'DKIM 驗證失敗'
    ...
    ...    ${action}為指定驗證結果的執行動作 可為 '接收信件' 或 '拒絕信件' 或 '標記為垃圾信'
    Log    進入 Frame "rightFrame"
    Enter Frame    id=rightFrame
    Log    驗證 DKIM 驗證 為啟用
    Log    驗證指定驗證結果的執行動作
    ${authentication_result}    get from dictionary    ${authentication_result_name}    ${authentication_result}
    Element Should Be Visible    xpath=//select[@name="${authentication_result}"]/Option[contains(text(),'${action}')][@selected]
