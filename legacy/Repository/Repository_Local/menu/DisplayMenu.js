


ShowPage();
function ShowPage()
{
	if (NavBar.readyState != "complete" ||
	    Menu.readyState != "complete"
	    )
	{
		window.setTimeout("ShowPage();",100);
		return;
	}

	drawNavBar();
}

