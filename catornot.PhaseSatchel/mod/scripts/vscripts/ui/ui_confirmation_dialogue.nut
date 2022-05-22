global function conDialogue_Make
global function conDialogue_Make2

void function conDialogue_Make() // script_ui conDialogue_Make()
{
    DialogData dialogData
    dialogData.header = "#DIALOG_MAIL_INIQUITY_CONFIRMATION" 
    dialogData.image = $"rui/menu/common/inbox_icon_new"
    dialogData.message = "#ASK_INIQUTY"
    dialogData.darkenBackground = true
    // dialogData.showSpinner = true // funny thing but overlaps with .image
    dialogData.noChoiceWithNavigateBack = true
    AddDialogButton( dialogData, "", Reopen )
    AddDialogButton( dialogData, "Yes", Said_Yes )
    AddDialogButton( dialogData, "No", Said_No )
    OpenDialog( dialogData )
}

void function Reopen()
{
    conDialogue_Make()
}

void function Said_Yes()
{
    ClientCommand( "inquity_dialogue_yes_88" )
}

void function Said_No()
{
    ClientCommand( "inquity_dialogue_no_88" )
}

void function conDialogue_Make2() // script_ui conDialogue_Make()
{
    DialogData dialogData
    dialogData.header = "#DIALOG_MAIL_INIQUITY_CONFIRMATION" 
    dialogData.image = $"rui/menu/common/inbox_icon_new"
    dialogData.message = "#ASK_INIQUTY2"
    dialogData.darkenBackground = true
    dialogData.noChoiceWithNavigateBack = true
    AddDialogButton( dialogData, "", Reopen2 )
    AddDialogButton( dialogData, "Yes", Said_Yes2 )
    AddDialogButton( dialogData, "No", Said_No2 )
    OpenDialog( dialogData )
}

void function Reopen2()
{
    conDialogue_Make2()
}

void function Said_Yes2()
{
    ClientCommand( "inquity_dialogue_yes_882" )
}

void function Said_No2()
{
    ClientCommand( "inquity_dialogue_no_882" )
}
