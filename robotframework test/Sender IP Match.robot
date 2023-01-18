*** Settings ***
Suite Setup       Open Browser To MG Login Page
Suite Teardown    Close All Open Browsers
Test Setup        Run Keywords    Login MG With System Admin And Go To Administrator Mode    Go To Sender IP Match
Test Teardown     Run Keywords    Close Other Windows    MG Logout Directly
Resource          ${CURDIR}/../../Global Settings.txt

*** Variables ***
${None}           ${EMPTY}

*** Test Cases ***
Hint Content Display
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認提示訊息是否出現
    Log    確認提示訊息是否出現
    Mouse Over On Hint And Verify Content Display    寄件人 IP 對應列表    寄件人 IP 對應列表    寄件人 IP 對應列表

System_Add Sender IP List_CIDR
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」新增 CIDR 並確認成功新增
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司 Description_357
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司 Description_357
    [Teardown]    Delete All Sender IP

System_Add Sender IP List_MASK
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」新增 MASK 並確認是否成功
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=resa@open.com    IP_address=172.1.1.5/24    description=Sender5566 ABC
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=resa@open.com    IP_address=172.1.1.5/24    description=Sender5566 ABC
    [Teardown]    Delete All Sender IP

System_Add Sender IP List_SINGLE
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」新增 SINGLE 並確認是否成功
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@aaa.aa    IP_address=1.1.1.1/32    description=寄件人 IP 對應列表說明設定Note
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP Match List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=*@aaa.aa    IP_address=1.1.1.1/32    description=寄件人 IP 對應列表說明設定Note
    [Teardown]    Delete All Sender IP

System_Note_Limit Text
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」在 Note 測試可顯示字元上限
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2560000
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP Match List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Log    在 Sender IP Match List 確認 [設定說明] 欄位顯示"ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd256" (不會顯示最後的2560000)
    Verify IP Data Display In Sender IP List    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd256
    [Teardown]    Delete All Sender IP

System_Note_Special characters
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」在 Note 新增 Special characters 並確認是否成功
    ...
    ...    Bug 新增後 [說明] 只顯示 "~!@"
    [Tags]    Bug
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=~!@#$%^&*()_+{}|:"<>?\
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP Match List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=~!@#$%^&*()_+{}|:"<>?\
    [Teardown]    Delete All Sender IP

System_Search
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」檢查搜尋結果是否符合預期
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    新增五筆資料
    Input New IP Data And Click Add Button    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kkk@kkk.kk    IP_address=2.2.2.2    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Input New IP Data And Click Add Button    sender=*@aaa.aa    IP_address=2.2.3.6    description=ABC欸逼西
    Input New IP Data And Click Add Button    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在名單中搜尋關鍵字
    Search Sender IP List Data    keyword=36
    Log    驗證含有關鍵字的資料是否出現
    Count Data Total Number In List    total_num=3
    Verify IP Data Display In Sender IP List    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Verify IP Data Display In Sender IP List    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Verify IP Data Display In Sender IP List    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    [Teardown]    Delete All Sender IP

System_Edit
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認 編輯後，資料有更新
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=
    Log    編輯 'sender=*@example.com' 的資料
    Edit Sender IP    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=    new_sender=kenny@opfind.com    new_IP_address=127.2.2.5/22    new_description=網擎資訊軟體股份有限公司
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP List 確認是否顯示正確資料
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    [Teardown]    Delete All Sender IP

System_Delete_One Data
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功刪除一筆資料
    ...
    ...    Bug 61475 刪除 Alert 訊息應與「IP 允許/阻擋名單」一致
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    新增兩筆資料
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=3.3.6.6:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    Log    刪除一筆指定資料
    Delete One Sender IP    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    Log    重新進入頁面
    Go To Sender IP Match
    Log    確認被刪除資料不存在清單中
    Count Data Total Number In List    total_num=1
    Verify IP Data Not Display In Sender IP List    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    [Teardown]    Delete All Sender IP

System_Delete_Multiple Data
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功刪除多筆資料
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    新增五筆資料
    Input New IP Data And Click Add Button    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kkk@kkk.kk    IP_address=2.2.2.2    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Input New IP Data And Click Add Button    sender=*@aaa.aa    IP_address=2.2.3.6    description=ABC欸逼西
    Input New IP Data And Click Add Button    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    Log    重新進入頁面
    Go To Sender IP Match
    Log    勾選欲刪除的資料
    Select Sender Data    sender=kkk@kkk.kk    IP_address=2.2.2.2/32    description=網擎資訊軟體股份有限公司
    Select Sender Data    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Select Sender Data    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    Log    點擊[刪除]鍵
    Click The Delete Button
    Log    重新進入頁面
    Go To Sender IP Match
    Log    確認被刪除資料不存在清單中
    Count Data Total Number In List    total_num=2
    Verify IP Data Not Display In Sender IP List    sender=kkk@kkk.kk    IP_address=2.2.2.2/32    description=網擎資訊軟體股份有限公司
    Verify IP Data Not Display In Sender IP List    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Verify IP Data Not Display In Sender IP List    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    [Teardown]    Delete All Sender IP

System_Delete_All Data
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功刪除全部資料
    Log    新增三筆資料
    Input New IP Data And Click Add Button    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kkk@kkk.kk    IP_address=2.2.2.2    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Log    刪除所有資料
    Delete All Sender IP
    Log    重新進入頁面
    Go To Sender IP Match
    Log    確認清單中不存在資料
    Count Data Total Number In List    total_num=0
    Verify List Is Empty

System_Import
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功匯入檔案
    Log    匯入資料並確認匯入成功訊息
    Import The File To List And Check Success Message    SIP policy_sample.txt
    Sleep    3
    Log    驗證資料是否匯入成功
    Count Data Total Number In List    total_num=3
    Verify IP Data Display In Sender IP List    sender=*@abc.aa    IP_address=2.2.3.6/32    description=ABC欸逼西
    Verify IP Data Display In Sender IP List    sender=mail2000@openfind.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司
    Verify IP Data Display In Sender IP List    sender=goo@momo.bb    IP_address=1.1.1.1/25    description=567836_[hihi]
    [Teardown]    Delete All Sender IP

System_Export
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功匯出檔案
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    新增任意三筆資料
    Input New IP Data And Click Add Button    sender=*@abc.aa    IP_address=2.2.3.6    description=ABC欸逼西
    Input New IP Data And Click Add Button    sender=mail2000@openfind.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=goo@momo.bb    IP_address=1.1.1.1/25    description=567836_[hihi]
    Log    重新進入頁面
    Go To Sender IP Match
    Log    匯出檔案
    Click Export To Download File    sip_policy.txt
    Log    重新整理頁面
    Reload Page
    Log    驗證資料匯出成功
    Verify List Export To The File Row Data Is Correct    0    *@abc.aa\t2.2.3.6/32\tABC欸逼西    sip_policy.txt
    Verify List Export To The File Row Data Is Correct    1    mail2000@openfind.com\t1.2.3.4:255.255.255.0\t網擎資訊軟體股份有限公司    sip_policy.txt
    Verify List Export To The File Row Data Is Correct    2    goo@momo.bb\t1.1.1.1/25\t567836_[hihi]    sip_policy.txt
    [Teardown]    Run Keywords    Delete All Sender IP    Close Other Windows    MG Logout Directly    Empty Downloads Folder

Domain_Add Sender IP List_CIDR
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」新增 CIDR 並確認成功新增
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司 Description_357
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司 Description_357
    [Teardown]    Delete All Sender IP

Domain_Add Sender IP List_MASK
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」新增 MASK 並確認是否成功
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=resa@open.com    IP_address=172.1.1.5/24    description=Sender5566 ABC
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=resa@open.com    IP_address=172.1.1.5/24    description=Sender5566 ABC
    [Teardown]    Delete All Sender IP

Domain_Add Sender IP List_SINGLE
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」新增 SINGLE 並確認是否成功
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@aaa.aa    IP_address=1.1.1.1/32    description=寄件人 IP 對應列表說明設定Note
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP Match List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=*@aaa.aa    IP_address=1.1.1.1/32    description=寄件人 IP 對應列表說明設定Note
    [Teardown]    Delete All Sender IP

Domain_Note_Limit Text
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」在 Note 測試可顯示字元上限
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd2560000
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP Match List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Log    在 Sender IP Match List 確認 [設定說明] 欄位顯示"ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd256" (不會顯示最後的2560000)
    Verify IP Data Display In Sender IP List    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd256
    [Teardown]    Delete All Sender IP

Domain_Note_Special characters
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」在 Note 新增 Special characters 並確認是否成功
    ...
    ...    Bug 新增後 [說明] 只顯示 "~!@"
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=~!@#$%^&*()_+{}|:"<>?\
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP Match List 確認是否成功新增
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=~!@#$%^&*()_+{}|:"<>?\
    [Teardown]    Delete All Sender IP

Domain_Search
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」檢查搜尋結果是否符合預期
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增五筆資料
    Input New IP Data And Click Add Button    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kkk@kkk.kk    IP_address=2.2.2.2    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Input New IP Data And Click Add Button    sender=*@aaa.aa    IP_address=2.2.3.6    description=ABC欸逼西
    Input New IP Data And Click Add Button    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在名單中搜尋關鍵字
    Search Sender IP List Data    keyword=36
    Log    驗證含有關鍵字的資料是否出現
    Count Data Total Number In List    total_num=3
    Verify IP Data Display In Sender IP List    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Verify IP Data Display In Sender IP List    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Verify IP Data Display In Sender IP List    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    [Teardown]    Delete All Sender IP

Domain_Edit
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認 編輯後，資料有更新
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增一筆資料
    Input New IP Data And Click Add Button    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=
    Log    編輯 'sender=*@example.com' 的資料
    Edit Sender IP    sender=*@example.com    IP_address=1.2.3.4:255.255.255.0    description=    new_sender=kenny@opfind.com    new_IP_address=127.2.2.5/22    new_description=網擎資訊軟體股份有限公司
    Log    重新進入頁面
    Go To Sender IP Match
    Log    在 Sender IP List 確認是否顯示正確資料
    Count Data Total Number In List    total_num=1
    Verify IP Data Display In Sender IP List    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    [Teardown]    Delete All Sender IP

Domain_Delete_One Data
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功刪除一筆資料
    ...
    ...    Bug 61475 刪除 Alert 訊息應與「IP 允許/阻擋名單」一致
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增兩筆資料
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=3.3.6.6:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    Log    刪除一筆指定資料
    Delete One Sender IP    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    Log    重新進入頁面
    Go To Sender IP Match
    Log    確認被刪除資料不存在清單中
    Count Data Total Number In List    total_num=1
    Verify IP Data Not Display In Sender IP List    sender=kenny@opfind.com    IP_address=127.2.2.5/22    description=網擎資訊軟體股份有限公司
    [Teardown]    Delete All Sender IP

Domain_Delete_Multiple Data
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功刪除多筆資料
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增五筆資料
    Input New IP Data And Click Add Button    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kkk@kkk.kk    IP_address=2.2.2.2    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Input New IP Data And Click Add Button    sender=*@aaa.aa    IP_address=2.2.3.6    description=ABC欸逼西
    Input New IP Data And Click Add Button    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    Log    重新進入頁面
    Go To Sender IP Match
    Log    勾選欲刪除的資料
    Select Sender Data    sender=kkk@kkk.kk    IP_address=2.2.2.2/32    description=網擎資訊軟體股份有限公司
    Select Sender Data    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Select Sender Data    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    Log    點擊[刪除]鍵
    Click The Delete Button
    Log    重新進入頁面
    Go To Sender IP Match
    Log    確認被刪除資料不存在清單中
    Count Data Total Number In List    total_num=2
    Verify IP Data Not Display In Sender IP List    sender=kkk@kkk.kk    IP_address=2.2.2.2/32    description=網擎資訊軟體股份有限公司
    Verify IP Data Not Display In Sender IP List    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Verify IP Data Not Display In Sender IP List    sender=mail2000@openfine.com    IP_address=1.1.1.3/32    description=567836_hihi
    [Teardown]    Delete All Sender IP

Domain_Delete_All Data
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功刪除全部資料
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增三筆資料
    Input New IP Data And Click Add Button    sender=abc36@mart.com    IP_address=1.2.3.4:255.255.255.0    description=範本 EXAMPLE
    Input New IP Data And Click Add Button    sender=kkk@kkk.kk    IP_address=2.2.2.2    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=resa@example.com    IP_address=127.11.22.36/10    description=說明:說明:說明:
    Log    刪除所有資料
    Delete All Sender IP
    Log    重新進入頁面
    Go To Sender IP Match
    Log    確認清單中不存在資料
    Count Data Total Number In List    total_num=0
    Verify List Is Empty

Domain_Import
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功匯入檔案
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    匯入資料並確認匯入成功訊息
    Import The File To List And Check Success Message    SIP policy_sample.txt
    Sleep    3
    Log    驗證資料是否匯入成功
    Count Data Total Number In List    total_num=3
    Verify IP Data Display In Sender IP List    sender=*@abc.aa    IP_address=2.2.3.6/32    description=ABC欸逼西
    Verify IP Data Display In Sender IP List    sender=mail2000@openfind.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司
    Verify IP Data Display In Sender IP List    sender=goo@momo.bb    IP_address=1.1.1.1/25    description=567836_[hihi]
    [Teardown]    Delete All Sender IP

Domain_Export
    [Documentation]    Go to 「Email Security > Email Firewall > Sender IP Match」確認能否成功匯出檔案
    ...
    ...    Bug 61571 寄件人 IP 新增的說明欄位變成亂碼
    [Tags]    Bug
    Log    切換到網域
    Select Domain_Adminstrator Mode UI    ${M2K_Domain}
    Log    新增任意三筆資料
    Input New IP Data And Click Add Button    sender=*@abc.aa    IP_address=2.2.3.6    description=ABC欸逼西
    Input New IP Data And Click Add Button    sender=mail2000@openfind.com    IP_address=1.2.3.4:255.255.255.0    description=網擎資訊軟體股份有限公司
    Input New IP Data And Click Add Button    sender=goo@momo.bb    IP_address=1.1.1.1/25    description=567836_[hihi]
    Log    重新進入頁面
    Go To Sender IP Match
    Log    匯出檔案
    Click Export To Download File    sip_policy.txt
    Log    重新整理頁面
    Reload Page
    Log    驗證資料匯出成功
    Verify List Export To The File Row Data Is Correct    0    *@abc.aa\t2.2.3.6/32\tABC欸逼西    sip_policy.txt
    Verify List Export To The File Row Data Is Correct    1    mail2000@openfind.com\t1.2.3.4:255.255.255.0\t網擎資訊軟體股份有限公司    sip_policy.txt
    Verify List Export To The File Row Data Is Correct    2    goo@momo.bb\t1.1.1.1/25\t567836_[hihi]    sip_policy.txt
    [Teardown]    Run Keywords    Delete All Sender IP    Close Other Windows    MG Logout Directly    Empty Downloads Folder

*** Keywords ***
Go To Sender IP Match
    [Documentation]    進入 "郵件安全 > 郵件防火牆 > 寄件人 IP 對應列表"
    Log    重載頁面
    Reload Page
    Log    進入 "郵件安全 > 郵件防火牆 > 寄件人 IP 對應列表"
    Click Top Menu And Click Left Main Menu Item And Submeun Item For Adm Mode    郵件安全    郵件防火牆    寄件人 IP 對應列表

Input New IP Data And Click Add Button
    [Arguments]    ${sender}=    ${IP_address}=    ${description}=
    [Documentation]    輸入新增 Trust IP 資料
    ...
    ...    ${sender}為指定新增 sender
    ...
    ...    ${IP_address}為指定新增 IP address
    ...
    ...    ${description}為指定新增 description
    ...
    ...    點擊 [新增]
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    輸入 IP 資料
    Input New IP Data    ${sender}    ${IP_address}    ${description}
    Log    點擊 [新增]
    Click Element And Wait Until Element Show - FL    xpath=//input[@id='rule_add']    xpath=//div[contains(text(),'儲存成功')]    name=rightFrame    top

Input New IP Data
    [Arguments]    ${sender}=    ${IP_address}=    ${description}=
    [Documentation]    輸入新增 sender IP 資料
    ...
    ...    ${sender}為指定新增 sender
    ...
    ...    ${IP_address}為指定新增 IP address
    ...
    ...    ${description}為指定新增 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    輸入 sender
    Input Text    xpath=//input[@id='sender_input']    ${sender}
    Log    輸入 IP address
    Input Text    xpath=//input[@id='ip_input']    ${IP_address}
    Log    輸入 description
    Input Text    xpath=//input[@id='desc_input']    ${description}

Click Add Button And Check Alert Message
    [Arguments]    ${alert_text}=
    [Documentation]    點擊 [新增]
    ...
    ...    新增失敗則檢查提示
    ...
    ...    ${alert_text}為指定預期提示訊息
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊 [新增]
    Log    檢查提示
    Click Element And Confirm Alert - FL    xpath=//input[@id='rule_add']    ${alert_text}

Verify IP Data Display In Sender IP List
    [Arguments]    ${sender}=    ${IP_address}=    ${description}=
    [Documentation]    在新增資料後，是否正確顯示新增的 IP 資料
    ...
    ...    ${sender}為指定檢查 sender
    ...
    ...    ${IP_address}為指定檢查 IP address
    ...
    ...    ${description}為指定檢查 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Run keyword If    '${description}' == ''    WebElement.Element Should Be Visible    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and not(text())][1]
    ...    ELSE    WebElement.Element Should Be Visible    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and normalize-space()='${description}']

Verify IP Data Not Display In Sender IP List
    [Arguments]    ${sender}=    ${IP_address}=    ${description}=
    [Documentation]    驗證 IP 列表中是否未顯示 指定 IP 資料
    ...
    ...    ${sender}為指定檢查 sender
    ...
    ...    ${IP_address}為指定檢查 IP address
    ...
    ...    ${description}為指定檢查 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    ${rowsNumber}=    WebElement.Get Element Count    xpath=//table[@id="sender_ip_list"]//tbody//tr
    FOR    ${row}    IN RANGE    ${rowsNumber}
        ${table}    Run Keyword and return status    Element Should Be Visible    xpath=//table[@id="sender_ip_list"]//tr[${row}+1]
        Exit For Loop If    ${table}==False
        Run keyword If    '${description}' == ''    WebElement.Element Should Not Be Visible    xpath=//table[@id='sender_ip_list']//tr[${row}+1]/td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and not(text())][1]
        ...    ELSE    WebElement.Element Should Not Be Visible    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and text()='${description}']
    END

Delete One Sender IP
    [Arguments]    ${sender}=    ${IP_address}=    ${description}=
    [Documentation]    刪除與給定資料相通的 Sender IP 資訊
    ...
    ...    ${sender}為指定檢查 sender
    ...
    ...    ${IP_address}為指定檢查 IP address
    ...
    ...    ${description}為指定檢查 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊該筆資料的刪除圖示
    Run keyword If    '${description}' == ''    Click Element And Confirm Alert - FL    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and not(text())][1]/following-sibling::td//a[@class="a_delete"]    確認刪除?
    ...    ELSE    Click Element And Confirm Alert - FL    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and text()='${description}']/following-sibling::td//a[@class="a_delete"]    確認刪除?

Delete All Sender IP
    [Documentation]    刪除名單所有 IP 資料
    Log    重新進入 Sender IP Match 頁面
    Go To Sender IP Match
    Log    勾選所有資料
    WebElement.Click Element    xpath=//label[@for="allbox"]
    Log    點選 [刪除] 鍵，並顯示出 Alert 再點選確定，確認表單為空
    Click Element And Confirm Alert And Wait Until Element Show - FL    xpath=//button[@class="dt-button delete"]    確認刪除?    xpath=//table[@id='sender_ip_list']//tbody//td[@class='dataTables_empty']

Search Sender IP List Data
    [Arguments]    ${keyword}=
    [Documentation]    在搜尋欄位中輸入關鍵字，並點選搜尋按鈕
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    在搜尋欄位中輸入關鍵字
    Input Text    xpath=//input[@type='search']    ${keyword}
    Log    點選搜尋按鈕
    Click Element And Wait Until Element Reload    xpath=//img[@class='search']    xpath=//table[@id='sender_ip_list']//tbody

Edit Sender IP
    [Arguments]    ${sender}=    ${IP_address}=    ${description}=    ${new_sender}=${None}    ${new_IP_address}=${None}    ${new_description}=${None}
    [Documentation]    編輯指定資料的 Sender
    ...
    ...    ${sender}為指定資料舊 sender
    ...
    ...    ${IP_address}為指定資料舊 IP address
    ...
    ...    ${description}為指定資料舊 description
    ...
    ...    ${new_sender}為指定資料新 sender
    ...
    ...    ${new_IP_address}為指定資料新 IP address
    ...
    ...    ${new_description}為指定資料新 description
    Log    進入 Frame "rightFrame"
    Enter Frame    name=rightFrame
    Log    點擊該筆資料的編輯圖示
    Run keyword If    '${description}' == ''    Click Element And Wait Until Element Show - FL    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and not(text())][1]/following-sibling::td//a[@class="a_edit"]    xpath=//span[@id="ui-id-1"]
    ...    ELSE    Click Element And Wait Until Element Show - FL    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and text()='${description}']/following-sibling::td//a[@class="a_edit"]    xpath=//span[@id="ui-id-1"]
    Log    輸入新 sender
    Run Keyword If    '${new_sender}' != '${None}'    Input Text    xpath=//input[@id='sender_n']    ${new_sender}
    Log    輸入新 IP address
    Run Keyword If    '${new_IP_address}' != '${None}'    Input Text    xpath=//input[@id='allow_ip_n']    ${new_IP_address}
    Log    輸入新 description
    Run Keyword If    '${new_description}' != '${None}'    Input Text    xpath=//input[@id='desc_n']    ${new_description}
    Log    點擊【儲存】
    Click Element And Wait Until Element Hide    xpath=//button[contains(text(),'儲存設定')]    xpath=//span[@id="ui-id-1"]

Select Sender Data
    [Arguments]    ${sender}=    ${IP_address}=    ${description}=
    [Documentation]    勾選指定資料的 Sender
    ...
    ...    ${sender}為指定 sender
    ...
    ...    ${IP_address}為指定 IP address
    ...
    ...    ${description}為指定 description
    Log    勾選指定資料的 Sender
    Run keyword If    '${description}' == ''    Click Element    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and not(text())][1]/..//label
    ...    ELSE    Click Element    xpath=//table[@id='sender_ip_list']//td[@class=" dt-left" and text()='${sender}']/following-sibling::td[@class=" dt-left" and text()='${IP_address}']/following-sibling::td[@class=" dt-left" and text()='${description}']/..//label

Click The Delete Button
    [Documentation]    點擊[刪除]鍵
    Log    點擊[刪除]鍵
    Click Element And Confirm Alert - FL    xpath=//button[@class="dt-button delete"]    確認刪除?
