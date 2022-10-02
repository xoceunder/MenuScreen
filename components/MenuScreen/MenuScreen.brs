' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

' entry point of  MenuScreen
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
  'Dbg("MenuScreen Init")
  m.buttons = m.top.findNode("buttons")
  m.top.observeField("focusedChild","onFocusedChildChange")
end sub

sub onFocusedChildChange()
  if m.top.hasFocus()
    buildButtons()
    m.buttons.setFocus(true)
    m.top.visible = true
  end if
end sub

sub buildButtons()
  'Dbg("buildButtons")
  if m.buttons.content = invalid
    buttons = []
    buttons.Push({id: "1", title: "Events", HDLISTITEMICONURL: "pkg:/images/menu/icon-home2.png", HDLISTITEMICONSELECTEDURL: "pkg:/images/menu/icon-home.png"})
    buttons.Push({id: "2", title: "Movies", HDLISTITEMICONURL: "pkg:/images/menu/movie2.png", HDLISTITEMICONSELECTEDURL: "pkg:/images/menu/movie.png"})
    buttons.Push({id: "3", title: "Series", HDLISTITEMICONURL: "pkg:/images/menu/icon-account2.png", HDLISTITEMICONSELECTEDURL: "pkg:/images/menu/icon-account.png"})
    buttons.Push({id: "4", title: "Account", HDLISTITEMICONURL: "pkg:/images/menu/icon-pp2.png", HDLISTITEMICONSELECTEDURL: "pkg:/images/menu/icon-pp.png"})
    buttons.Push({id: "5", title: "Settings", HDLISTITEMICONURL: "pkg:/images/menu/settings2.png", HDLISTITEMICONSELECTEDURL: "pkg:/images/menu/settings.png"})
    buttons.Push({id: "6", title: "Privacy policy", HDLISTITEMICONURL: "pkg:/images/menu/icon-pp2.png", HDLISTITEMICONSELECTEDURL: "pkg:/images/menu/icon-pp.png"})
	buttons.Push({id: "7", title: "AboutUs", HDLISTITEMICONURL: "pkg:/images/menu/icon-pp2.png", HDLISTITEMICONSELECTEDURL: "pkg:/images/menu/icon-pp.png"})
    m.buttons.numColumns = buttons.count()
    m.buttons.content = List2ContentNode(buttons)
  end if
End sub

