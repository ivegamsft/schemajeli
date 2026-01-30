
	var CurNavBarMenu = "";
	var IsMenuDropDown = true;
	var HTMLStr;
	var x = 0;
	var y = 0;
	var x2 = 0;
	var y2 = 0;
	var NavBarMinWidth;
	var NavBarMenu;
	var NavBarBGColor;
	var NavBarLoaded = false;
	var DoubleQuote = String.fromCharCode(34);
	var aDefNavBarColor = new Array(3);
	var newLineChar = String.fromCharCode(10);
	var NavBarFont;
	var TotalMenu = 0;
	var arrMenuInfo = new Array(30);

	document.write("<SPAN ID='StartMenu' STYLE='display:none;'></SPAN>");

	HTMLStr = 
		"<DIV ID='idNavBar' STYLE='width:100%;text-align:center;>" +
		"<DIV ID='idMenu' STYLE='position:relative;height:20;width:100%'>" +
		"<DIV ID='idNavBarMenuPane' STYLE='position:absolute;top:-6;left:0;height:20;width:100%; text-align:center' NOWRAP><!--Menus--></DIV>" +
		"</DIV>" +
		"</DIV>" +
		"<SCRIPT TYPE='text/javascript'>" + 
		"   var NavBarMenu = StartMenu;" + 
		"</SCRIPT>" + 
		"<DIV WIDTH=100%>";

	window.onresize  = resizeNavBar;
	



function drawNavBar()
{
	HTMLStr += "</DIV>";
	document.write(HTMLStr);
	NavBarLoaded = true;

	idNavBar.style.backgroundColor     = NavBarBGColor;

	idNavBarMenuPane.style.backgroundColor = aDefNavBarColor[0];
	resizeNavBar();
}

function resizeNavBar()
{
	if (NavBar_Supported == false) return;

	w = Math.max(NavBarMinWidth, document.body.clientWidth) - NavBarMinWidth;

}

function setNavBarBGColor(color)
{	
	NavBarBGColor = color;
	if (NavBarLoaded == true)
		idNavBar.style.backgroundColor = NavBarBGColor;
}	




function setDefaultNavBarMenuColor(bgColor, fontColor, mouseoverColor)
{	
	if (bgColor   != "")	  aDefNavBarColor[0] = bgColor;
	if (fontColor != "")	  aDefNavBarColor[1] = fontColor;
	if (mouseoverColor != "") aDefNavBarColor[2] = mouseoverColor;
}

function setNavBarMenuColor(MenuIDStr, bgColor, fontColor, mouseoverColor)
{	
	if (NavBarLoaded == false) return;

	// Reset previous NavBar Menu color if any
	if (CurNavBarMenu != "")
	{
		PrevID = CurNavBarMenu.substring(4);
		CurNavBarMenu = "";
		setNavBarMenuColor(PrevID, aDefNavBarColor[0], aDefNavBarColor[1], aDefNavBarColor[2]);
	}

	var	id = "AM_" + "NavBar_" + MenuIDStr;
	var thisMenu = document.all(id);
	if (thisMenu != null)
	{
		CurNavBarMenu = "NavBar_" + MenuIDStr;
		aCurNavBarColor[0] = bgColor;
		aCurNavBarColor[1] = fontColor;
		aCurNavBarColor[2] = mouseoverColor;

		// Change menu color
		if (bgColor != "")
			thisMenu.style.backgroundColor = bgColor;
		if (fontColor != "")
			thisMenu.style.color = fontColor;

		// Change subMenu color
		id = "NavBar_" + MenuIDStr;
		thisMenu = document.all(id);
		if (thisMenu != null)
		{
			if (bgColor != "")
				thisMenu.style.backgroundColor = bgColor;
			
			if (fontColor != "")
			{
				i = 0;
				id = "AS_" + "NavBar_" + MenuIDStr;
				thisMenu = document.all.item(id,i);
				while (thisMenu != null)
				{
					thisMenu.style.color = fontColor;
					i += 1;
					thisMenu = document.all.item(id,i);
				}
			}
		}
	}
}


function setSubMenuWidth(MenuIDStr, WidthType, WidthUnit)
{
	var fFound = false;
	
	for (i = 0; i < TotalMenu; i++)
		if (arrMenuInfo[i].IDStr == MenuIDStr)
		{
			fFound = true;
			break;
		}

	if (!fFound)
	{
		arrMenuInfo[i] = new menuInfo(MenuIDStr);
		TotalMenu += 1;
	}

	if (!fFound && WidthType.toUpperCase().indexOf("DEFAULT") != -1)
	{
		arrMenuInfo[i].type = "A";
		arrMenuInfo[i].unit = 160;
	}
	else
	{
		arrMenuInfo[i].type = (WidthType.toUpperCase().indexOf("ABSOLUTE") != -1)? "A" : "R";
		arrMenuInfo[i].unit = WidthUnit;
	}
}

// This function creates a menuInfo object instance.
function menuInfo(MenuIDStr)
{
	this.IDStr = MenuIDStr;
	this.type  = "";
	this.unit  = 0;
	this.width = 0;
	this.count = 0;
}

function updateSubMenuWidth(MenuIDStr)
{
	for (i = 0; i < TotalMenu; i++)
		if (arrMenuInfo[i].IDStr == MenuIDStr)
		{
			if (arrMenuInfo[i].width < MenuIDStr.length) 
				arrMenuInfo[i].width = MenuIDStr.length;
			arrMenuInfo[i].count = arrMenuInfo[i].count + 1;
			break;
		}
}

function addNavBarMenu(MenuIDStr, MenuDisplayStr, MenuHelpStr, MenuURLStr)
{ 	
	if (addNavBarMenu.arguments.length > 4)
		TargetStr = addNavBarMenu.arguments[4];
	else
		TargetStr = "_top";
	tempID = "NavBar_" + MenuIDStr;
	addMenu(tempID, MenuDisplayStr, MenuHelpStr, MenuURLStr, TargetStr, true); 
}


function addMenu(MenuIDStr, MenuDisplayStr, MenuHelpStr, MenuURLStr, TargetStr, bNavBarMenu)
{
	cFont   = NavBarFont;
	cColor0 = aDefNavBarColor[0];
	cColor1 = aDefNavBarColor[1];
	cColor2 = aDefNavBarColor[2];
	tagStr  = "<!--Menus-->";

	MenuStr = newLineChar;
	
	MenuStr += "<A TARGET='" + TargetStr + "' TITLE='" + MenuHelpStr + "'" +
			   "   ID='AM_" + MenuIDStr + "'" +
			   "   STYLE='text-decoration:none;cursor:hand;font:" + cFont + ";background-color:" + cColor0 + ";color:" + cColor1 + ";'";
	if (MenuURLStr != "")
	{
		MenuStr += " HREF='" + formatURL(MenuURLStr, ("NavBar_" + MenuDisplayStr)) + "'";
	}
	else
		MenuStr += " HREF='' onclick='window.event.returnValue=false;'";
	MenuStr += 	" onmouseout="  + DoubleQuote + "mouseMenu('out' ,'" + MenuIDStr + "'); hideMenu();" + DoubleQuote + 
				" onmouseover=" + DoubleQuote + "mouseMenu('over','" + MenuIDStr + "'); doMenu('"+ MenuIDStr + "');" + DoubleQuote + ">" +
				"&nbsp;" + MenuDisplayStr + "&nbsp;</a>";
	MenuStr += "<SPAN STYLE='font:" + cFont + ";color:" + cColor1 + "'>&nbsp;|</SPAN>" + tagStr;
	
	HTMLStr = HTMLStr.replace(tagStr, MenuStr);	
	setSubMenuWidth(MenuIDStr,"default",0);
}

function addNavBarSubMenu(MenuIDStr, SubMenuStr, SubMenuURLStr)
{	
	if (addNavBarSubMenu.arguments.length > 3)
		TargetStr = addNavBarSubMenu.arguments[3];
	else
		TargetStr = "_top";
	tempID = "NavBar_" + MenuIDStr;
	addSubMenu(tempID,SubMenuStr,SubMenuURLStr,TargetStr,true); 
}


function addSubMenu(MenuIDStr, SubMenuStr, SubMenuURLStr, TargetStr, bNavBarMenu)
{
	cFont   = NavBarFont;
	cColor0 = aDefNavBarColor[0];
	cColor1 = aDefNavBarColor[1];
	cColor2 = aDefNavBarColor[2];
	
	var MenuPos = MenuIDStr.toUpperCase().indexOf("MENU");
	if (MenuPos == -1) { MenuPos = MenuIDStr.length; }
	InstrumentStr = MenuIDStr.substring(0 , MenuPos) + "|" + SubMenuStr;;
	URLStr        = formatURL(SubMenuURLStr, InstrumentStr);

	var LookUpTag  = "<!--" + MenuIDStr + "-->";
	var sPos = HTMLStr.indexOf(LookUpTag);
	if (sPos <= 0)
	{
		HTMLStr += newLineChar + newLineChar +
				"<SPAN ID='" + MenuIDStr + "'" +
				" STYLE='display:none;position:absolute;width:160;background-color:" + cColor0 + ";padding-top:0;padding-left:0;padding-bottom:20;z-index:9;'" +
				" onmouseout='hideMenu();'>";
		if (Frame_Supported == false || bNavBarMenu == false)
			HTMLStr += "<HR  STYLE='position:absolute;left:0;top:0;color:" + cColor1 + "' SIZE=1>";
		HTMLStr += "<DIV STYLE='position:relative;left:0;top:8;'>";
	}

	TempStr = newLineChar +
				"<A ID='AS_" + MenuIDStr + "'" +
				"   STYLE='text-decoration:none;cursor:hand;font:" + cFont + ";color:" + cColor1 + "'" +
				"   HREF='" + URLStr + "' TARGET='" + TargetStr + "'" +
				" onmouseout="  + DoubleQuote + "mouseMenu('out' ,'" + MenuIDStr + "');" + DoubleQuote + 
				" onmouseover=" + DoubleQuote + "mouseMenu('over','" + MenuIDStr + "');" + DoubleQuote + ">" +
				"&nbsp;" + SubMenuStr + "</A><BR>" + LookUpTag;
	if (sPos <= 0)
		HTMLStr += TempStr + "</DIV></SPAN>";
	else
		HTMLStr = HTMLStr.replace(LookUpTag, TempStr);	

	updateSubMenuWidth(MenuIDStr);	
}

function addNavBarSubMenuLine(MenuIDStr)
{	
	tempID = "NavBar_" + MenuIDStr;
	addSubMenuLine(tempID,true);
}



function addSubMenuLine(MenuIDStr, bNavBarMenu)
{
	var LookUpTag = "<!--" + MenuIDStr + "-->";
	var sPos = HTMLStr.indexOf(LookUpTag);
	if (sPos > 0)
	{
		cColor  = aDefNavBarColor[1];
		TempStr = newLineChar + "<HR STYLE='color:" + cColor + "' SIZE=1>" + LookUpTag;
		HTMLStr = HTMLStr.replace(LookUpTag, TempStr);
	}
}

function mouseMenu(id, MenuIDStr) 
{
	IsMouseout = (id.toUpperCase().indexOf("OUT") != -1);

	if (IsMouseout)
	{
		color = aDefNavBarColor[1];
		if (MenuIDStr == CurNavBarMenu && aCurNavBarColor[1] != "") 
			color = aCurNavBarColor[1];
	}
	else
	{
		color = aDefNavBarColor[2];
		if (MenuIDStr == CurNavBarMenu && aCurNavBarColor[2] != "") 
			color = aCurNavBarColor[2];
	}
	window.event.srcElement.style.color = color;
}

function doMenu(MenuIDStr) 
{
	var thisMenu = document.all(MenuIDStr);
	if (NavBarMenu == null || thisMenu == null || thisMenu == NavBarMenu) 
	{
		window.event.cancelBubble = true;
		return false;
	}
	// Reset dropdown menu
	window.event.cancelBubble = true;
	NavBarMenu.style.display = "none";
	showElement("SELECT");
	showElement("OBJECT");
	NavBarMenu = thisMenu;

	// Set dropdown menu display position
	x  = window.event.srcElement.offsetLeft +
	 	 window.event.srcElement.offsetParent.offsetLeft;
	
	x2 = x + window.event.srcElement.offsetWidth;
	// Set the sub menus' top position ----------------------------------------
	y  = idMenu.offsetHeight+1; //Drop Down's Top -----------------%%%%%%%%%%%%
	thisMenu.style.top  = y;
	thisMenu.style.left = x;
	thisMenu.style.clip = "rect(0 0 0 0)";
	thisMenu.style.display = "block";

	// delay 2 millsecond to allow the value of NavBarMenu.offsetHeight be set
	window.setTimeout("showMenu()", 2);
	return true;
}

function showMenu() 
{
	if (NavBarMenu != null) 
	{ 
		IsMenuDropDown = (Frame_Supported)? false : true;
		if (IsMenuDropDown == false)
		{
			y = (y - NavBarMenu.offsetHeight - idMenu.offsetHeight);
			if (y < 0) y = 0;
			NavBarMenu.style.top = y;
		}
		y2 = y + NavBarMenu.offsetHeight;

		NavBarMenu.style.clip = "rect(auto auto auto auto)";
		hideElement("SELECT");
		hideElement("OBJECT");
	}
}

function hideMenu()
{
	if (NavBarMenu != null && NavBarMenu != StartMenu) 
	{
		// Don't hide the menu if the mouse move between the menu and submenus
		cY = event.clientY + document.body.scrollTop;
		if ( (event.clientX >= (x+5) && event.clientX <= x2) &&
			 ((IsMenuDropDown == true  && cY > (y-10) && cY <= y2)      ||
			  (IsMenuDropDown == false && cY >= y     && cY <= (y2+10)) ))
		{
			window.event.cancelBubble = true;
			return; 
		}

		NavBarMenu.style.display = "none";
		NavBarMenu = StartMenu;
		window.event.cancelBubble = true;

		showElement("SELECT");
		showElement("OBJECT");
	}
}

function hideElement(elmID)
{
	for (i = 0; i < document.all.tags(elmID).length; i++)
	{
		obj = document.all.tags(elmID)[i];
		if (! obj || ! obj.offsetParent)
			continue;

		// Find the element's offsetTop and offsetLeft relative to the BODY tag.
		objLeft   = obj.offsetLeft;
		objTop    = obj.offsetTop;
		objParent = obj.offsetParent;
		while (objParent.tagName.toUpperCase() != "BODY")
		{
			objLeft  += objParent.offsetLeft;
			objTop   += objParent.offsetTop;
			objParent = objParent.offsetParent;
		}
		// Adjust the element's offsetTop relative to the dropdown menu
		objTop = objTop - y;

		if (x > (objLeft + obj.offsetWidth) || objLeft > (x + NavBarMenu.offsetWidth))
			;
		else if (objTop > NavBarMenu.offsetHeight)
			;
		else
			obj.style.visibility = "hidden";
	}
}

function showElement(elmID)
{
	for (i = 0; i < document.all.tags(elmID).length; i++)
	{
		obj = document.all.tags(elmID)[i];
		if (! obj || ! obj.offsetParent)
			continue;
		obj.style.visibility = "";
	}
}

function formatURL(URLStr, InstrumentStr)
{
	var tempStr = URLStr;

	if (InstrumentStr && URLStr != "" )
	{
		var ParamPos1 = URLStr.indexOf("?");
		var ParamPos2 = URLStr.lastIndexOf("?");
		var ParamPos3 = URLStr.toLowerCase().indexOf("target=");
		var ParamPos4 = URLStr.indexOf("#");
		var Bookmark  = "";
		var URL = URLStr;
		if (ParamPos4 >= 0)
		{
		 	URL = URLStr.substr(0, ParamPos4);
			Bookmark = URLStr.substr(ParamPos4);
		}
		
		if (ParamPos1 == -1)
			tempStr = "?MSCOMTB=";
		else if (ParamPos1 == ParamPos2 && ParamPos3 == -1)	
			tempStr = "&MSCOMTB=";
		else if (ParamPos1 == ParamPos2 && ParamPos3 != -1)	
			tempStr = "?MSCOMTB=";
		else if (ParamPos1 < ParamPos2)
			tempStr = "&MSCOMTB=";

		tempStr = URL + tempStr + InstrumentStr.replace(" ","%20") + Bookmark;
	}
	return tempStr;
}
