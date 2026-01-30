<style>
<!--
.iewrap1{
position:relative;
height:100px;
}
.iewrap2{
position:absolute;
}
#SearchMenu, #ReportMenu, #MaintainMenu, #AdminMenu, #HelpMenu{
visibility:hide;
z-index:100;
}
.reg        {color:rgb(204,204,153); 
             text-decoration: none;
             font-weight: bold;
             font-family: Verdana;
             font-size: 10pt }

a.reg:Hover {color:rgb(255,255,204);
             font-weight:bold }

.menu        {color:rgb(204,204,153); 
             text-decoration: none;
             font-weight: bold;
             text-align: left;
             font-family: Verdana;
             font-size: 8pt }

.submenu     {color:rgb(204,204,153); 
             text-decoration: none;
             text-align: left;
             font-family: Verdana;
             font-size: 8pt }

.submenu:Hover {color:white; }

a.menu:Hover {color:rgb(255,255,204); }

.current    {color:white;
             font-weight:bold }

.exit       {color:rgb(0,51,153);
             text-decoration: none;
             font-weight: bold;
             font-family: Verdana;
             font-size: 10pt }


.exit:Hover {color:red;
             font-weight:bold }

A:link      {color:rgb(204,204,153);
             text-decoration:none }

A:visited   {color:rgb(204,204,153);
             text-decoration:none } 

A:active    {color:rgb(204,204,153);
             text-decoration:none }
-->
</style>
<TABLE BORDER="1" WIDTH="100%" HEIGHT="20%" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuBackColor%>">
  <TR>
  <TD WIDTH="90%" ALIGN="center" VALIGN="top"><FONT FACE="Tahoma" SIZE="2" COLOR="<%=strMenuTextColor%>">
  <B><%=TRIM(Session("UserName"))%> is currently logged in to the Navistar Repository System</B><BR>
  Use the navigation menu below to move around the repository.
  </FONT>
  </TD>
  <TD WIDTH="10%" VALIGN="top" ALIGN="right" ROWSPAN="2">
  <IMG SRC="../images/edwlogo.gif" WIDTH="102" HEIGHT="89" BORDER="0" ALT="edwlogo.gif (28431 bytes)" HSPACE="0" VSPACE="0">
  </TD>
  </TR>
  <TR>
  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="90%" ALIGN="center" VALIGN="top">
  <TABLE BORDER="1" WIDTH="100%" HEIGHT="100%" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuBackColor%>">
  <TR>
<!--Begin custom menu-->
<script language="JavaScript1.2">
/*
Drop down menu link
© Dynamic Drive (www.dynamicdrive.com)
For full source code, installation instructions,
100's more DHTML scripts, and Terms Of
Use, visit dynamicdrive.com
*/

//Contents for Search Menu
var mnuSearch=new Array()
mnuSearch[0]='<a CLASS="submenu" href=search_dbs.asp>Databases</a><br>'
mnuSearch[1]='<a CLASS="submenu" href=search_tbls.asp>Tables</a><br>'
mnuSearch[2]='<a CLASS="submenu" href=search_elem.asp>Elements</a><br>'
mnuSearch[3]='<a CLASS="submenu" href=search_elem_kywds.asp>Element Key Words</a><br>'
mnuSearch[4]='<a CLASS="submenu" href=search_stdabbr.asp>Standard Abbreviations</a>'

//Contents for Report submenu
var mnuReport=new Array()
mnuReport[0]='<a CLASS="submenu" href=rpt_main.asp>Relational Object Report</a><br>'
mnuReport[1]='<a CLASS="submenu" href=query_result.asp?RelObject=ClassWord>View Class Words</a><br>'
mnuReport[2]='<a CLASS="submenu" href=query_result.asp?RelObject=Server>Server Report</a><br>'
mnuReport[3]='<a CLASS="submenu" href=rpt_ddl.asp>Generate DDL</a>'

//Contents for Maintain submenu
var mnuMaintain=new Array()
mnuMaintain[0]='<a CLASS="submenu" href=add_db_nme.asp>Database</a><br>'
mnuMaintain[1]='<a CLASS="submenu" href=add_tbl_nme.asp>Table</a><br>'
mnuMaintain[2]='<a CLASS="submenu" href=add_elem_nme.asp>Element</a>'

//Contents for Admin submenu
var mnuAdmin=new Array()
mnuAdmin[0]='<a CLASS="submenu" href=add_server.asp>Servers</a><br>'
mnuAdmin[1]='<a CLASS="submenu" href=add_stdabbr.asp>Standard Abbreviations</a><br>'
mnuAdmin[2]='<a CLASS="submenu" href=add_user.asp>Users</a><br>'
mnuAdmin[3]='<a CLASS="submenu" href=copy_tbl.asp>Copy Table</a><br>'
mnuAdmin[4]='<a CLASS="submenu" href=status_move.asp>Status Move</a>'

//Contents for Help submenu
var mnuHelp=new Array()
mnuHelp[0]='<a CLASS="submenu" href=test.htm>Using the Repository</a><br>'
mnuHelp[1]='<a CLASS="submenu" href=test.htm>Generating Reports</a><br>'
mnuHelp[2]='<a CLASS="submenu" href=test.htm>Maintaining Objects</a><br>'
mnuHelp[3]='<a CLASS="submenu" href=test.htm>Administering Objects</a><br>'
mnuHelp[4]='<a CLASS="submenu" href=test.htm>Procedures</a><br>'
mnuHelp[5]='<a CLASS="submenu" href=test.htm>Support</a><br>'
mnuHelp[6]='<a CLASS="submenu" href=test.htm>Return to Main Page</a>'
</script>

<script language="JavaScript1.2">
//reusable/////////////////////////////
var zindex=100
function dropit2(whichone){
if (window.themenu&&themenu.id!=whichone.id)
themenu.style.visibility="hidden"
themenu=whichone
if (document.all){
themenu.style.left=document.body.scrollLeft+event.clientX-event.offsetX
themenu.style.top=document.body.scrollTop+event.clientY-event.offsetY+18
if (themenu.style.visibility=="hidden"){
themenu.style.visibility="visible"
themenu.style.zIndex=zindex++
}
else{
hidemenu()
}
}
}

function dropit(e,whichone){
if (window.themenu&&themenu.id!=eval(whichone).id)
themenu.visibility="hide"
themenu=eval(whichone)
if (themenu.visibility=="hide")
themenu.visibility="show"
else
themenu.visibility="hide"
themenu.zIndex++
themenu.left=e.pageX-e.layerX
themenu.top=e.pageY-e.layerY+19
return false
}

function hidemenu(whichone){
if (window.themenu)
themenu.style.visibility="hidden"
}

function hidemenu2(){
themenu.visibility="hide"
}

if (document.all)
{
document.body.onMouseOver=hidemenu
}
//reusable/////////////////////////////
</script>
<!----------Search Menu---------->
  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="10%" VALIGN="top"><P ALIGN="left">
  <ilayer height=35px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2 onMouseOver="dropit2(SearchMenu);event.cancelBubble=true;return false">
  <FONT face="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
    <a CLASS="menu" href=new_nav_menu.asp>Search</A></b></font>
  </span>
  </span>
  </layer>
  </ilayer>
  |</TD>
<!----------Search Menu---------->

<!----------Report Menu---------->
  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="10%" VALIGN="top"><P ALIGN="left">
  <ilayer height=35px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2 onMouseOver="dropit2(ReportMenu);event.cancelBubble=true;return false">
  <FONT face="Verdana" size="1" COLOR="<%=strMenuTextColor%>" onMouseOver="if(document.layers) return dropit(event, 'document.ReportMenu')">
    <a CLASS="menu" href=new_nav_menu.asp>Reports</A></b></font>
  </span>
  </span>
  </layer>
  </ilayer>
  |</TD>
<!----------Report Menu---------->

<%
   If Session("UAuth")="MNTN" Then %>
<!----------Maintain Menu---------->
  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="10%" VALIGN="top"><P ALIGN="left">
  <ilayer height=35px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2 onMouseOver="dropit2(MaintainMenu);event.cancelBubble=true;return false">
  <FONT face="Verdana" size="1" COLOR="<%=strMenuTextColor%>" onMouseOver="if(document.layers) return dropit(event, 'document.MaintainMenu')">
    <a CLASS="menu" href=new_nav_menu.asp>Maintain</A></b></font>
  </span>
  </span>
  </layer>
  </ilayer>
  |</TD>
<!----------Maintain Menu---------->

<%Else
   If Session("UAuth")="ADMN" Then %>
<!----------Maintain Menu---------->
  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="10%" VALIGN="top"><P ALIGN="left">
  <ilayer height=35px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2 onMouseOver="dropit2(MaintainMenu);event.cancelBubble=true;return false">
  <FONT face="Verdana" size="1" COLOR="<%=strMenuTextColor%>" onMouseOver="if(document.layers) return dropit(event, 'document.MaintainMenu')">
    <a CLASS="menu" href=new_nav_menu.asp>Maintain</A></b></font>
  </span>
  </span>
  </layer>
  </ilayer>
  |</TD>
<!----------Maintain Menu---------->

<!----------Admin Menu---------->
  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="10%" VALIGN="top"><P ALIGN="left">
  <ilayer height=35px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2 onMouseOver="dropit2(AdminMenu);event.cancelBubble=true;return false">
  <FONT face="Verdana" size="1" COLOR="<%=strMenuTextColor%>" onMouseOver="if(document.layers) return dropit(event, 'document.AdminMenu')">
    <a CLASS="menu" href=new_nav_menu.asp>Adminstration</A></font>
  </span>
  </span>
  </layer>
  </ilayer>
  |</TD>
<!----------Admin Menu---------->

<%Else%>
  <TD BGCOLOR="<%=strMenuBackColor%>" COLSPAN="2" ALIGN="center" VALIGN="top"></TD>&nbsp;
<%End If
End If
%>
<!----------Help Menu---------->
  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="10%" VALIGN="top"><P ALIGN="left">
  <ilayer height=35px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2 onMouseOver="dropit2(HelpMenu);event.cancelBubble=true;return false">
  <FONT face="Verdana" size="1" COLOR="<%=strMenuTextColor%>" onMouseOver="if(document.layers) return dropit(event, 'document.HelpMenu')">
    <a CLASS="menu" href=new_nav_menu.asp>Help</A></font>
  </span>
  </span>
  </layer>
  </ilayer>
  |</TD>
<!----------Help Menu---------->

  <TD BGCOLOR="<%=strMenuBackColor%>" WIDTH="10%" ALIGN="center" VALIGN="top"><P ALIGN="left">
  <A CLASS="exit" HREF="exit.asp" TARGET="_top" TITLE="Exit the Navistar Repository">Exit</A>
  </TD>
</TR>
</TABLE>
  <div id=SearchMenu style="position:absolute;left:0;top:0;layer-background-color:black;
      background-color:black;width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  SearchMenu.style.padding="0px"
  for (i=0;i<mnuSearch.length;i++)
  document.write(mnuSearch[i])
  </script>
  </div>
  <script language="JavaScript1.2">
  if (document.layers){
  document.SearchMenu.captureEvents(Event.MOUSEOUT)
  document.SearchMenu.onMouseOut=hidemenu
  }
  </script>

  <div id=ReportMenu style="position:absolute;left:0;top:0;layer-background-color:black;
      background-color:black;width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  ReportMenu.style.padding="0px"
  for (i=0;i<mnuReport.length;i++)
  document.write(mnuReport[i])
  </script>
  </div>
  <script language="JavaScript1.2">
  if (document.layers){
  document.ReportMenu.captureEvents(Event.MOUSEOUT)
  document.ReportMenu.onMouseOut=hidemenu
  }
  </script>


  <div id=MaintainMenu style="position:absolute;left:0;top:0;layer-background-color:black;
      background-color:black;width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  MaintainMenu.style.padding="0px"
  for (i=0;i<mnuMaintain.length;i++)
  document.write(mnuMaintain[i])
  </script>
  </div>
  <script language="JavaScript1.2">
  if (document.layers){
  document.MaintainMenu.captureEvents(Event.MOUSEOUT)
  document.MaintainMenu.onMouseOut=hidemenu
  }
  </script>  
  
  <div id=AdminMenu style="position:absolute;left:0;top:0;layer-background-color:black;
      background-color:black;width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  AdminMenu.style.padding="0px"
  for (i=0;i<mnuAdmin.length;i++)
  document.write(mnuAdmin[i])
  </script>
  </div>
  <script language="JavaScript1.2">
  if (document.layers){
  document.AdminMenu.captureEvents(Event.MOUSEOUT)
  document.AdminMenu.onMouseOut=hidemenu
  }
  </script>

  <div id=HelpMenu style="position:absolute;left:0;top:0;layer-background-color:black;
      background-color:black;width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  HelpMenu.style.padding="0px"
  for (i=0;i<mnuHelp.length;i++)
  document.write(mnuHelp[i])
  </script>
  </div>
  <script language="JavaScript1.2">
  if (document.all)
  {
	document.body.onclick=hidemenu;
	document.body.onscroll=hidemenu;
//	document.body.onmousemove=hidemenu;
  }
  if (document.layers){
  document.HelpMenu.captureEvents(Event.MOUSEMOVE)
  document.HelpMenu.onMouseMOVE=hidemenu
  }
  </script>
