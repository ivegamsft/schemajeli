


ShowWebPage();

function ShowWebPage()
{
	if (NavBar.readyState != "complete" ||
	    Menu.readyState != "complete"
	    )
	{
		window.setTimeout("ShowWebPage();",100);
		return;
	}

	showNavBar();
}

