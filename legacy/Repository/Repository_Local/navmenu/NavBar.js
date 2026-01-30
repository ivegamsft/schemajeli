
var strNavBar;
var x = 0;
var y = 0;
var x2 = 0;
var y2 = 0;
var blnLoaded = false;
var NavBarMinWidth;
var NavBarMenu;
var NavBarBGColor;
var DoubleQuote = String.fromCharCode(34);
var varNavBarColor = new Array(3);
var newLineChar = String.fromCharCode(10);
var NavBarFont;
var TotalMenu = 0;
var varMenuInfo = new Array(30);

document.write("<SPAN ID='StartMenu' STYLE='display:none;'></SPAN>");
strNavBar = 
	"<DIV ID='idNavBar' STYLE='background-color:transparent;width:100%;text-align:left; font:verdana';>" +
	"<DIV ID='idMenu' STYLE='position:relative;height:20;width:100%'>" +
	"<DIV ID='idNavBarMenuPane' STYLE='position:absolute;top:6;left:0;height:20;width:100%; text-align:left' NOWRAP><!--Menus--></DIV>" +
	"</DIV></DIV><SCRIPT TYPE='text/javascript'> var NavBarMenu = StartMenu;</SCRIPT> <DIV WIDTH=100%>";

window.onresize  = resizeNavBar;
	
function showNavBar() {
	strNavBar += "</DIV>";
	document.write(strNavBar);
	blnLoaded = true;
	idNavBar.style.backgroundColor     = NavBarBGColor;
	idNavBarMenuPane.style.backgroundColor = varNavBarColor[0];
	resizeNavBar();
}

function resizeNavBar() {
	w = Math.max(NavBarMinWidth, document.body.clientWidth) - NavBarMinWidth;
}

function setNavBarBGColor(color) {	
	NavBarBGColor = color;
	if (blnLoaded) {
		idNavBar.style.backgroundColor = NavBarBGColor;
	}
}	

function setDefaultNavBarMenuColor(bgColor, fontColor, mouseoverColor) {	
	if (bgColor   != "")	  varNavBarColor[0] = bgColor;
	if (fontColor != "")	  varNavBarColor[1] = fontColor;
	if (mouseoverColor != "") varNavBarColor[2] = mouseoverColor;
}

function setNavBarMenuColor(MenuID, bgColor, fontColor, mouseoverColor) {	
	if (!blnLoaded) return;

	var	id = "MainMenu" + MenuID;
	var thisMenu = document.all(id);
	if (thisMenu != null) {
		if (bgColor != "") {
			thisMenu.style.backgroundColor = bgColor;
		}
		if (fontColor != "") {
			thisMenu.style.color = fontColor;
		}

		id = "NavBar" + MenuID;
		thisMenu = document.all(id);
		if (thisMenu != null) {
			if (bgColor != "") {
				thisMenu.style.backgroundColor = bgColor;
			}
			if (fontColor != "") {
				i = 0;
				id = "SubMenu" + MenuID;
				thisMenu = document.all.item(id,i);
				while (thisMenu != null) {
					thisMenu.style.color = fontColor;
					i += 1;
					thisMenu = document.all.item(id,i);
				}
			}
		}
	}
}


function setSubMenuWidth(MenuID, WidthType, WidthUnit) {
	var blnExists = false;
	for (i = 0; i < TotalMenu; i++) {
		if (varMenuInfo[i].IDAttribute == MenuID) {
			blnExists = true;
			break;
		}
	}
	
	if (!blnExists) {
		varMenuInfo[i] = new newMenu(MenuID);
		TotalMenu += 1;
	}

	if (!blnExists && WidthType.toUpperCase().indexOf("DEFAULT") != -1) {
		varMenuInfo[i].type = "A";
		varMenuInfo[i].unit = 160;
	}
	else {
		varMenuInfo[i].type = (WidthType.toUpperCase().indexOf("ABSOLUTE") != -1)? "A" : "R";
		varMenuInfo[i].unit = WidthUnit;
	}
}

function newMenu(MenuID)  {
	this.IDAttribute = MenuID;
	this.type  = "";
	this.unit  = 0;
	this.width = 0;
	this.count = 0;
}

function updateSubMenuWidth(MenuID) {
	for (i = 0; i < TotalMenu; i++) {
		if (varMenuInfo[i].IDAttribute == MenuID) {
			if (varMenuInfo[i].width < MenuID.length) {
				varMenuInfo[i].width = MenuID.length;
			}
			varMenuInfo[i].count = varMenuInfo[i].count + 1;
			break;
		}
	}
}

function addNavBarMenu(MenuID, MenuDisplayStr, MenuHelpStr, MenuURLStr) { 	
	if (addNavBarMenu.arguments.length > 4) {
		TargetStr = addNavBarMenu.arguments[4];
	}
	else {
		TargetStr = "_top";
	}
	
	tempID = "NavBar" + MenuID;
	addMenu(tempID, MenuDisplayStr, MenuHelpStr, MenuURLStr, TargetStr, true); 
}


function addMenu(MenuID, MenuDisplayStr, MenuHelpStr, MenuURLStr, TargetStr, bNavBarMenu) {
	cFont   = NavBarFont;
	cColor0 = varNavBarColor[0];
	cColor1 = varNavBarColor[1];
	cColor2 = varNavBarColor[2];
	tagStr  = "<!--Menus-->";

	MenuStr = newLineChar;
	
	MenuStr += "<A TARGET='" + TargetStr + "' TITLE='" + MenuHelpStr + "'" +
			   "   ID='MainMenu" + MenuID + "'" +
			   "   STYLE='text-decoration:none;cursor:hand;font:" + cFont + ";background-color:" + cColor0 + ";color:" + cColor1 + ";'";
	if (MenuURLStr != "") {
		MenuStr += " HREF='" + MenuURLStr + "'";
	}
	else {
		MenuStr += " HREF='' onclick='window.event.returnValue=false;'";
	}
	MenuStr += 	" onmouseout="  + DoubleQuote + "mouseMenu('out' ,'" + MenuID + "'); hideMenu();" + DoubleQuote + 
				" onmouseover=" + DoubleQuote + "mouseMenu('over','" + MenuID + "'); doMenu('"+ MenuID + "');" + DoubleQuote + ">" +
				"&nbsp;" + MenuDisplayStr + "&nbsp;</a>";
	MenuStr += "<SPAN STYLE='font:" + cFont + ";color:" + cColor1 + "'>&nbsp;|</SPAN>" + tagStr;
	
	strNavBar = strNavBar.replace(tagStr, MenuStr);	
	setSubMenuWidth(MenuID,"default",0);
}

function addNavBarSubMenu(MenuID, SubMenuStr, SubMenuURLStr) {	
	if (addNavBarSubMenu.arguments.length > 3) {
		TargetStr = addNavBarSubMenu.arguments[3];
	}
	else {
		TargetStr = "_top";
	}
	tempID = "NavBar" + MenuID;
	addSubMenu(tempID,SubMenuStr,SubMenuURLStr,TargetStr,true); 
}


function addSubMenu(MenuID, SubMenuStr, SubMenuURLStr, TargetStr, bNavBarMenu) {
	cFont   = NavBarFont;
	cColor0 = varNavBarColor[0];
	cColor1 = varNavBarColor[1];
	cColor2 = varNavBarColor[2];
	
	URLStr = SubMenuURLStr;

	var LookUpTag  = "<!--" + MenuID + "-->";
	var intIndex = strNavBar.indexOf(LookUpTag);
	if (intIndex <= 0) {
		strNavBar += newLineChar + newLineChar +
				"<SPAN ID='" + MenuID + "'" +
				" STYLE='display:none;position:absolute;text-align:left;width:160;background-color:" + cColor0 + ";padding-top:0;padding-left:0;padding-bottom:0;z-index:9;'" +
				" onmouseout='hideMenu();'>";

		strNavBar += "<HR  STYLE='position:absolute;left:0;top:0;color:text-align:left;" + cColor1 + "' SIZE=1>";
		strNavBar += "<DIV STYLE='position:relative;left:0;top:0;text-align:left;'>";
	}

	TempStr = newLineChar +
				"<A ID='SubMenu" + MenuID + "'" +
				"   STYLE='text-decoration:none;text-align:left;cursor:hand;font:" + cFont + ";color:" + cColor1 + "'" +
				"   HREF='" + URLStr + "' TARGET='" + TargetStr + "'" +
				" onmouseout="  + DoubleQuote + "mouseMenu('out' ,'" + MenuID + "');" + DoubleQuote + 
				" onmouseover=" + DoubleQuote + "mouseMenu('over','" + MenuID + "');" + DoubleQuote + ">" +
				"&nbsp;" + SubMenuStr + "</A><BR>" + LookUpTag;
	if (intIndex <= 0) {
		strNavBar += TempStr + "</DIV></SPAN>";
	}
	else {
		strNavBar = strNavBar.replace(LookUpTag, TempStr);	
	}

	updateSubMenuWidth(MenuID);	
}

function addNavBarSubMenuLine(MenuID) {	
	tempID = "NavBar" + MenuID;
	addSubMenuLine(tempID,true);
}



function addSubMenuLine(MenuID, bNavBarMenu) {
	var LookUpTag = "<!--" + MenuID + "-->";
	var intIndex = strNavBar.indexOf(LookUpTag);
	if (intIndex > 0) {
		cColor  = varNavBarColor[1];
		TempStr = newLineChar + "<HR STYLE='color:" + cColor + "' SIZE=1>" + LookUpTag;
		strNavBar = strNavBar.replace(LookUpTag, TempStr);
	}
}

function mouseMenu(id, MenuID) {
	var elStyle = window.event.srcElement.style
	if (id.toUpperCase().indexOf("OUT") != -1) {
		elStyle.color = varNavBarColor[1];
	}
	else {
		elStyle.color = varNavBarColor[2];
	}
}

function doMenu(MenuID)  {
	var thisMenu = document.all(MenuID);
	if (NavBarMenu == null || thisMenu == null || thisMenu == NavBarMenu) {
		window.event.cancelBubble = true;
		return false;
	}

	window.event.cancelBubble = true;
	NavBarMenu.style.display = "none";
	showElement("SELECT");
	showElement("OBJECT");
	NavBarMenu = thisMenu;

	var el = window.event.srcElement;
	x  = el.offsetLeft + el.offsetParent.offsetLeft;
	x2 = x + el.offsetWidth;
	y  = idMenu.offsetHeight+69; //Drop Down's Top -----------------%%%%%%%%%%%%
    thisMenu.style.top  = y;
	thisMenu.style.left = x;
	thisMenu.style.clip = "rect(0 0 0 0)";
	thisMenu.style.display = "block";

	window.setTimeout("showMenu()", 2);
	return true;
}

function showMenu()  {
	if (NavBarMenu != null) { 
		y2 = y + NavBarMenu.offsetHeight;
		NavBarMenu.style.clip = "rect(auto auto auto auto)";
		hideElement("SELECT");
		hideElement("OBJECT");
	}
}

function hideMenu() {
	if (NavBarMenu != null && NavBarMenu != StartMenu) {
		cY = event.clientY + document.body.scrollTop;
		if ((event.clientX >= (x+5) && event.clientX <= x2) && ((cY > (y-10) && cY <= y2))) {
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

function hideElement(elID) {
	for (i = 0; i < document.all.tags(elID).length; i++) {
		el = document.all.tags(elID)[i];
		if (! el || ! el.offsetParent)
			continue;

		elLeftOffSet   = el.offsetLeft;
		elTopOffSet    = el.offsetTop;
		elParent = el.offsetParent;
		while (elParent.tagName.toUpperCase() != "BODY") {
			elLeftOffSet  += elParent.offsetLeft;
			elTopOffSet   += elParent.offsetTop;
			elParent = elParent.offsetParent;
		}

		elTopOffSet = elTopOffSet - y;

		if ((x > (elLeftOffSet + el.offsetWidth) || elLeftOffSet > (x + NavBarMenu.offsetWidth)) || (elTopOffSet > NavBarMenu.offsetHeight)) {
			;
		}
		else {
			el.style.visibility = "hidden";
		}
	}
}

function showElement(elID) {
	for (i = 0; i < document.all.tags(elID).length; i++) {
		el = document.all.tags(elID)[i];
		if (! el || ! el.offsetParent)
			continue;
		el.style.visibility = "";
	}
}

function OpenHelp(helpFile)
{
  window.status = " ";
  if (helpFile == "HowTo")
      helpFile = "../help/hlp_howTo.htm"
  else
  if (helpFile == "Admin")
      helpFile = "../help/hlp_admin.htm"
  else
    if (helpFile == "Codes")
      helpFile = "../help/hlp_codes.htm"
  else
    if (helpFile == "Maintain")
      helpFile = "../help/hlp_maintain.htm"
  else
    if (helpFile == "Procs")
      helpFile = "../help/hlp_procs.htm" 
  else
    if (helpFile == "Reports")
      helpFile = "../help/hlp_reports.htm"
  else
    if (helpFile == "Support")
      helpFile = "../help/hlp_support.htm"
  else
    if (helpFile == "Search")
      helpFile = "../help/hlp_search.htm";

  open(helpFile, "Help", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no");
//  objNewWindow.cancelbubble = true;
//  objNewWindow.returnValue = false;
//  window.status = "Help window open";
return false;
}