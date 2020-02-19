*** Settings ***

Resource        robot/Cumulus/resources/NPSP.robot
Library         cumulusci.robotframework.PageObjects
...             robot/Cumulus/resources/ContactPageObject.py
...             robot/Cumulus/resources/LevelsPageObject.py
...             robot/Cumulus/resources/NPSPSettingsPageObject.py
Suite Setup     Open Test Browser
Suite Teardown  Delete Records and Close Browser


*** Variables ***
&{contact_fields}           Email=test@example.com
${min_amount}  0.10
${max_amount}  0.90
${minamount_to_edit}  0.01
${maxamount_to_edit}  0.99
${contact_smallestvalue}  0.75
*** Test Cases ***

Create and edit level to verify fields
    [Documentation]                      Create a level and verify the fields on the created level details page
    ...                                  Edit the level details and update the fields. Verify the updated fields
    ...                                  are persisted on the details page.
    [tags]                               W-038641                 feature:Levels


    Go To Page                                          Home                      Level__c
    Enter Level Values
    ...                                                 Level Name=AutomationLevel
    ...                                                 Minimum Amount=${min_amount}
    ...                                                 Maximum Amount=${max_amount}
    Enter Level Dd Values
    ...                                                 Target=Contact
    ...                                                 Source Field=Smallest Gift
    ...                                                 Level Field=Level
    ...                                                 Previous Level Field=Previous Level
    Click Button                                        Save
    Current Page Should be                              Details    Level__c
    ${level_id} =                                       Save Current Record ID For Deletion  Level__c
    Set Global Variable                                 ${level_id}
    Go To Page                                          Details
        ...                                             Level__c
        ...                                             object_id=${level_id}

    Wait Until Loading Is Complete
    Navigate To And Validate Field Value                Minimum Amount (>\=)    contains    ${min_amount}
    Navigate To And Validate Field Value                Maximum Amount (<)      contains    ${max_amount}
    Go to edit level page                               ${level_id}
    Enter Level Values
    ...                                                 Minimum Amount=${minamount_to_edit}
    ...                                                 Maximum Amount=${maxamount_to_edit}
    Enter Level Dd Values
    ...                                                 Source Field=Smallest Gift

    Click Button                                        Save
    Go To Page                                          Details
    ...                                                 Level__c
    ...                                                 object_id=${level_id}

    Wait Until Loading Is Complete

    Navigate To And Validate Field Value    Maximum Amount (<)     contains       ${maxamount_to_edit}
    Navigate To And Validate Field Value    Source Field           contains       npo02__SmallestAmount__c


2 Validate Level Assignment in Batch Job
    [Documentation]                      Create a contact, edit the smallgift field value to apply a valid
    ...                                  level by running the batch process

    [tags]                                  W-038641                 feature:Level
    # --------------------------------
    # Modify the SmallestGift field to allow the level to be applied
    # --------------------------------
    Setupdata                               contact                   contact_data=${contact_fields}
    Set Global Variable                     ${data}
    Salesforce Update                       Contact                   ${data}[contact][Id]  npo02__SmallestAmount__c=${contact_smallestvalue}
    Go To Page                              Details
    ...                                     Contact
    ...                                     object_id=${data}[contact][Id]

    Navigate To And Validate Field Value    Smallest Gift             contains    $${contact_smallestvalue}
    # --------------------------------
    # Open NPSP Settings and run the Levels batch job
    # --------------------------------
    Open NPSP Settings                      Bulk Data Processes         Level Assignment Batch
    Click Settings Button                   idPanelLvlAssignBatch       Run Batch
    Wait For Batch To Process               LVL_LevelAssign_BATCH       Completed
    # --------------------------------
    # Return to the Contact to validate the updated Level field
    # --------------------------------
    Go To Page                              Details
    ...                                     Contact
    ...                                     object_id=${data}[contact][Id]
    Navigate To And Validate Field Value    Level    contains          AutomationLevel

3. Delete a Level
    [Documentation]                      Delete the Level from the levels listing page
    [tags]                                  W-038641                 feature:Level

    Go To Page                              Details
    ...                                     Level__c
    ...                                     object_id=${level_id}
    Click Show More Actions Button          Delete
    Click Modal Button                      Delete
    Go To Page                              Details
    ...                                     Contact
    ...                                     object_id=${data}[contact][Id]
    Navigate To And Validate Field Value    Level      does not contain    AutomationLevel    section=Donation Totals
