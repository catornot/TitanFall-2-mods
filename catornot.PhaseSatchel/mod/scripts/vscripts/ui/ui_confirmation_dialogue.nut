global function conDialogue_Make

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
