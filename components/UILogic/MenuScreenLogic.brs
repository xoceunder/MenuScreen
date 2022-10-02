' ********** Copyright 2021 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainScene.xml using relative path.

sub ShowMenuScreen()
    m.MenuScreen = CreateObject("roSGNode", "MenuScreen")
	m.MenuScreen.observeField("itemSelected", "OnMenuSelection")
    ShowScreen(m.MenuScreen) ' show MenuScreen
end sub

sub OnMenuSelection(event)
  itemSelected = event.getData()
  Dbg("Menu item:", itemSelected)
  if itemSelected <> invalid
    if itemSelected = 0
    else if itemSelected = 1
    else if itemSelected = 2
    else if itemSelected = 3
    end if
  end if
end sub