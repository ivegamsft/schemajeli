<style>
<!--
.iewrap1{
position:absolute;
height:300px;
}
.iewrap2{
position:absolute;
}

#SearchMenu, #ReportMenu, #MaintainMenu, #AdminMenu, #HelpMenu{
}
.menu       {
             cursor:hand;
             color:white; 
             text-decoration: none;
             font-weight: bold;
             text-align: left;
             font-family: Verdana;
             font-size: 8pt }

.menuon {
             cursor:hand;
             color:black; }

.submenu    {
             position:absolute;
             visibility:hidden;
             left:0;
             top:0;
             background-color:rgb(51,102,255);
             width:150;
             border:1px solid black;
             padding:0px;
             text-align:left;
             text-indent:0;}
             

.submenuitem    {
             color:white;
             text-decoration: none;
             text-align: left;
             font-family: Verdana;
             font-size: 8pt }

.submenuitem:hover    {
             color:black;}



.exit       {color:white;
             text-decoration: none;
             font-weight: bold;
             font-family: Verdana;
             font-size: 10pt }

.exit:Hover {color:red;
             font-weight:bold }
-->
</style>
<TABLE BORDER="0" WIDTH="100%" HEIGHT="75" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuHeaderColor%>">
  <TR>
  <TD WIDTH="90%" ALIGN="center" VALIGN="top"><FONT FACE="Tahoma" SIZE="2" COLOR="<%=strMenuTextColor%>">
  <B><%=TRIM(Session("UserName"))%> is currently logged in to the Navistar Repository System</B><BR>
  Use the navigation menu below to move around the repository.
  </FONT>
  </TD>
  <TD WIDTH="10%" ROWSPAN="2" VALIGN="bottom">
  <A HREF="http://wwwnio.navistar.com/edw" TARGET="_blank">
  <IMG SRC="../images/edwlogo.gif"  HEIGHT="85" WIDTH="100" ALT="edwlogo.gif (28431 bytes)" BORDER="0" ALIGN="absbottom"></A>
  </TD>
  </TR>
  <TR>
  <TD VALIGN="bottom" BGCOLOR="<%=strMenuHeaderColor%>" WIDTH="90%">
  <TABLE BORDER="0" WIDTH="100%" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuBackColor%>">
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
mnuSearch[0]='<a CLASS="submenuitem" href=search_dbs.asp>Databases</a><br>'
mnuSearch[1]='<a CLASS="submenuitem" href=search_tbls.asp>Tables</a><br>'
mnuSearch[2]='<a CLASS="submenuitem" href=search_elem.asp>Elements</a><br>'
mnuSearch[3]='<a CLASS="submenuitem" href=search_elem_kywds.asp>Element Key Words</a><br>'
mnuSearch[4]='<a CLASS="submenuitem" href=search_stdabbr.asp>Standard Abbreviations</a>'

//Contents for Report submenuitem
var mnuReport=new Array()
mnuReport[0]='<a CLASS="submenuitem" href=rpt_main.asp>Relational Object Report</a><br>'
mnuReport[1]='<a CLASS="submenuitem" href=query_result.asp?RelObject=ClassWord>View Class Words</a><br>'
mnuReport[2]='<a CLASS="submenuitem" href=query_result.asp?RelObject=Server>Server Report</a><br>'
mnuReport[3]='<a CLASS="submenuitem" href=rpt_ddl.asp>Generate DDL</a>'

//Contents for Maintain submenuitem
var mnuMaintain=new Array()
mnuMaintain[0]='<a CLASS="submenuitem" href=add_db_nme.asp>Database</a><br>'
mnuMaintain[1]='<a CLASS="submenuitem" href=add_tbl_nme.asp>Table</a><br>'
mnuMaintain[2]='<a CLASS="submenuitem" href=add_elem_nme.asp>Element</a>'

//Contents for Admin submenuitem
var mnuAdmin=new Array()
mnuAdmin[0]='<a CLASS="submenuitem" href=add_server.asp>Servers</a><br>'
mnuAdmin[1]='<a CLASS="submenuitem" href=add_stdabbr.asp>Standard Abbreviations</a><br>'
mnuAdmin[2]='<a CLASS="submenuitem" href=add_user.asp>Users</a><br>'
mnuAdmin[3]='<a CLASS="submenuitem" href=copy_tbl.asp>Copy Table</a><br>'
mnuAdmin[4]='<a CLASS="submenuitem" href=status_move.asp>Status Move</a>'

//Contents for Help submenuitem
var mnuHelp=new Array()
mnuHelp[0]='<a CLASS="submenuitem" href=test.htm>Using the Repository</a><br>'
mnuHelp[1]='<a CLASS="submenuitem" href=test.htm>Generating Reports</a><br>'
mnuHelp[2]='<a CLASS="submenuitem" href=test.htm>Maintaining Objects</a><br>'
mnuHelp[3]='<a CLASS="submenuitem" href=test.htm>Administering Objects</a><br>'
mnuHelp[4]='<a CLASS="submenuitem" href=test.htm>Procedures</a><br>'
mnuHelp[5]='<a CLASS="submenuitem" href=test.htm>Support</a><br>'
mnuHelp[6]='<a CLASS="submenuitem" href=test.htm>Return to Main Page</a>'
</script>

<script language="JavaScript1.2">
//reusable/////////////////////////////
var zindex=100
function showmenu(whichone){
//if (window.themenu&&themenu.id!=whichone.id)
//themenu.style.visibility="hidden"
themenu=whichone
//if (document.all){
themenu.style.left=document.body.scrollLeft+event.clientX-event.offsetX
themenu.style.top=document.body.scrollTop+event.clientY-event.offsetY+18
//if (themenu.style.visibility=="hidden"){
themenu.style.visibility="visible"
themenu.style.zIndex=zindex++
//}
//else{
//hidemenu()
}
//}
//}

//function dropit(e,whichone){
//if (window.themenu&&themenu.id!=eval(whichone).id)
//themenu.visibility="hidden"
//themenu=eval(whichone)
//if (themenu.visibility=="hide")
//themenu.visibility="show"
//else
//themenu.visibility="hide"
//themenu.zIndex++
//themenu.left=e.pageX-e.layerX
//themenu.top=e.pageY-e.layerY+19
//return false
//}

function hidemenu(whichone){
if (window.themenu)
//return
themenu.style.visibility="hidden"
event.cancelBubble = true
}

function rollover()  {
   if (window.event.srcelement.classname =="menu") {
       window.event.srcelement.classname == "menuon";
   }
}
rollover.onmouseover = rollover;

function rolloff()  {
  if (window.event.srcelement.classname == "menuon")  {
      window.event.srcelement.classname = "menu";
   }
}
 
rollover.onmouseout = rolloff; 
//function hidemenu2(){
//themenu.visibility="hide"
//}

if (document.all)
{
document.body.onMouseOver=hidemenu
}
//reusable/////////////////////////////
</script>
<!----------Search Menu---------->
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <div id="submenu">
  </div>
  <span class="menu">
  <a CLASS="menu" href=new_nav_menu.asp>|Search</A></b></font>
  </SPAN>
  <script language="JavaScript1.2">
  if (document.all)
  for (i=0;i<mnuSearch.length;i++)
  document.write(mnuSearch[i])
  </script>
  &nbsp;</TD>
<!----------Search Menu---------->
<!-- onMouseOut="dhidemenu(SearchMenu);event.cancelBubble=true;return false"-->
<!----------Report Menu---------->
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <ilayer height=35px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2>
  <a CLASS="menu" href=new_nav_menu.asp onMouseOver="dropit2(ReportMenu);event.cancelBubble=true;return false" onMouseOut="if(document.layers) return dropit(event, 'document.ReportMenu')">|Reports</A></b></font>
  </span>
  </span>
  </layer>
  </ilayer>
  &nbsp;</TD>
<!----------Report Menu---------->

<%
   If Session("UAuth")="MNTN" Then %>
<!----------Maintain Menu---------->
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <ilayer height=50px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2>
  <a CLASS="menu" href=new_nav_menu.asp onMouseOver="dropit2(MaintainMenu);event.cancelBubble=true;return false" onMouseOut="if(document.layers) return dropit(event, 'document.MaintainMenu')">|Maintain</A></b></font>
  </span>
  </span>
  </layer>
  </ilayer>
  &nbsp;</TD>
<!----------Maintain Menu---------->

<%Else
   If Session("UAuth")="ADMN" Then %>
<!----------Maintain Menu---------->
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <ilayer height=50px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2>
  <a CLASS="menu" href=new_nav_menu.asp onMouseOver="dropit2(MaintainMenu);event.cancelBubble=true;return false" onMouseOut="if(document.layers) return dropit(event, 'document.MaintainMenu')">|Maintain</A></b></font>
  </span>
  </span>
  </layer>
  </ilayer>
  &nbsp;</TD>
<!----------Maintain Menu---------->

<!----------Admin Menu---------->
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <ilayer height=50px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2>
  <a CLASS="menu" href=new_nav_menu.asp onMouseOver="dropit2(AdminMenu);event.cancelBubble=true;return false" onMouseOut="if(document.layers) return dropit(event, 'document.AdminMenu')">|Adminstration</A></font>
  </span>
  </span>
  </layer>
  </ilayer>
  &nbsp;</TD>
<!----------Admin Menu---------->

<%Else%>
  <TD COLSPAN="2"></TD>&nbsp;
<%End If
End If
%>
<!----------Help Menu---------->
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <ilayer height=50px>
  <layer visibility=show>
  <span class=iewrap1>
  <span class=iewrap2>
  <a CLASS="menu" href=new_nav_menu.asp onMouseOver="dropit2(HelpMenu);event.cancelBubble=true;return false" onMouseOut="if(document.layers) return dropit(event, 'document.HelpMenu')">|Help</A></font>
  </span>
  </span>
  </layer>
  </ilayer>
  &nbsp;</TD>
<!----------Help Menu---------->

  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <A CLASS="exit" HREF="exit.asp" TARGET="_top" TITLE="Exit the Navistar Repository">|Exit</A>
  </TD>
</TR>
</TABLE>
</TD>
</TR>
</TABLE>


  <div id=ReportMenu style="position:absolute;left:0;top:0;layer-background-color:rgb(51,102,255);
      background-color:rgb(51,102,255);width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  ReportMenu.style.padding="0px"
  for (i=0;i<mnuReport.length;i++)
  document.write(mnuReport[i])
  </script>
  </div>

  <div id=MaintainMenu style="position:absolute;left:0;top:0;layer-background-color:rgb(51,102,255);
      background-color:rgb(51,102,255);width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  MaintainMenu.style.padding="0px"
  for (i=0;i<mnuMaintain.length;i++)
  document.write(mnuMaintain[i])
  </script>
  </div>
  
  <div id=AdminMenu style="position:absolute;left:0;top:0;layer-background-color:rgb(51,102,255);
      background-color:rgb(51,102,255);width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="JavaScript1.2">
  if (document.all)
  AdminMenu.style.padding="0px"
  for (i=0;i<mnuAdmin.length;i++)
  document.write(mnuAdmin[i])
  </script>
  </div>

  <div id=HelpMenu style="position:absolute;left:0;top:0;layer-background-color:rgb(51,102,255);
      background-color:rgb(51,102,255);width:150;visibility:hidden;border:0px solid black;padding:0px;
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
//	document.body.onmouseout=hidemenu;
  }
//  if (document.layers){
 // document.HelpMenu.captureEvents(Event.MOUSEMOVE)
  //document.HelpMenu.onMouseMOVE=hidemenu
  //}
  </script>
