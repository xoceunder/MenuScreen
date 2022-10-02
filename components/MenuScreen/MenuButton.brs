' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

' entry point of  MenuButton
' Note that we need to import this file in MenuScreen.xml using relative path.
sub Init()
    mBind(["mainGroup", "buttonLabel", "icon"])
    m.buttonLabel.font = createFont(m.global.GetApi.boldFont, m.global.GetApi.buttonsTextFontSize)
    m.buttonLabel.color = m.global.GetApi.buttonsTextColor
end sub

sub OnContentChanged()
    if m.top.itemContent <> invalid and m.top.width > 0 and m.top.height > 0
        m.mainGroup.translation = [m.top.width / 1, m.top.height / 2]
        m.buttonLabel.width = m.top.width
        m.icon.width = 170  'm.top.width
        m.icon.height = m.icon.width
        m.buttonLabel.text = m.top.itemContent.title
        showfocus()
    end if
end sub

sub showfocus()
    if m.top.itemContent <> invalid
        if m.top.focusPercent > 0.3
          m.icon.uri = m.top.itemContent.HDLISTITEMICONSELECTEDURL
          m.buttonLabel.color = m.global.GetApi.buttonsTextColor
        else
          m.icon.uri = m.top.itemContent.HDLISTITEMICONURL
          m.buttonLabel.color = m.global.GetApi.buttonsTextColor
        end if
    end if
end sub