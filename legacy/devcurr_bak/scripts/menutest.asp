<HTML>
<HEAD>
<TITLE>MainPage
</TITLE>
</HEAD>
<BODY>
<style>
.menu       {
             cursor:hand;
             color:black; 
             text-decoration: none;
             font-weight: bold;
             text-align: left;
             font-family: Verdana;
             font-size: 8pt }

.menu:hover {
             cursor:hand;
             color:blue; }

.menuitem       {
             cursor:hand;
             color:blue; 
             text-decoration: none;
             font-weight: bold;
             text-align: left;
             font-family: Verdana;
             font-size: 8pt }

.menuitem:hover {
             cursor:hand;
             color:black; }

.submenu    {
             cursor:hand;
             position:absolute;
             visibility:hidden;
             left:0;
             top:0;
             background-color:rgb(51,102,255);
             width:150;
             border:1px solid black;
             padding:0px;
             text-align:left;
             text-indent:0;
             color:black;
             text-decoration: none;
             text-align: left;
             font-family: Verdana;
             font-size: 8pt; }

.submenu:hover    {
             color:yellow;}



.exit       {color:red;
             text-decoration: none;
             font-weight: bold;
             font-family: Verdana;
             font-size: 10pt; }

.exit:Hover {color:yellow;
             font-weight:bold; }
</style>
<script LANGUAGE="VBScript">
Dim arySearchmenu(4)
Dim aryReportMenu(3)
Dim aryMaintainMenu(2)
Dim aryAdminMenu(4)
Dim aryHelpMenu(6)

arySearchmenu(0)="<a href=search_dbs.asp>Databases</a><br>"
arySearchmenu(1)="<a href=search_tbls.asp>Tables</a><br>"
arySearchmenu(2)="<a href=search_elem.asp>Elements</a><br>"
arySearchmenu(3)="<a CLASS=submenuitem href=search_elem_kywds.asp>Element Key Words</a><br>"
arySearchmenu(4)="<a CLASS=submenuitem href=search_stdabbr.asp>Standard Abbreviations</a>"

aryReportMenu(0)="<a CLASS=submenuitem href=rpt_main.asp>Relational Object Report</a><br>"
aryReportMenu(1)="<a CLASS=submenuitem href=query_result.asp?RelObject=ClassWord>View Class Words</a><br>"
aryReportMenu(2)="<a CLASS=submenuitem href=query_result.asp?RelObject=Server>Server Report</a><br>"
aryReportMenu(3)="<a CLASS=submenuitem href=rpt_ddl.asp>Generate DDL</a>"

aryMaintainMenu(0)="<a CLASS=submenuitem href=add_db_nme.asp>Database</a><br>"
aryMaintainMenu(1)="<a CLASS=submenuitem href=add_tbl_nme.asp>Table</a><br>"
aryMaintainMenu(2)="<a CLASS=submenuitem href=add_elem_nme.asp>Element</a>"

aryAdminMenu(0)="<a CLASS=submenuitem href=add_server.asp>Servers</a><br>"
aryAdminMenu(1)="<a CLASS=submenuitem href=add_stdabbr.asp>Standard Abbreviations</a><br>"
aryAdminMenu(2)="<a CLASS=submenuitem href=add_user.asp>Users</a><br>"
aryAdminMenu(3)="<a CLASS=submenuitem href=copy_tbl.asp>Copy Table</a><br>"
aryAdminMenu(4)="<a CLASS=submenuitem href=status_move.asp>Status Move</a>"

aryHelpMenu(0)="<a CLASS=submenuitem href=test.htm>Using the Repository</a><br>"
aryHelpMenu(1)="<a CLASS=submenuitem href=test.htm>Generating Reports</a><br>"
aryHelpMenu(2)="<a CLASS=submenuitem href=test.htm>Maintaining Objects</a><br>"
aryHelpMenu(3)="<a CLASS=submenuitem href=test.htm>Administering Objects</a><br>"
aryHelpMenu(4)="<a CLASS=submenuitem href=test.htm>Procedures</a><br>"
aryHelpMenu(5)="<a CLASS=submenuitem href=test.htm>Support</a><br>"
aryHelpMenu(6)="<a CLASS=submenuitem href=test.htm>Return to Main Page</a>"
</script>
<TABLE BORDER="0" WIDTH="100%" HEIGHT="75" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuHeaderColor%>">
  <TR>
<script LANGUAGE="VBScript">
Sub ShowSubMenu(menu)
    writemenu
    menu.style.left=(document.body.scrollLeft) + (window.event.clientX) - (window.event.offsetX)
    menu.style.top=((document.body.scrollTop) + (window.event.clientY) - (window.event.offsetY) + 18)
    If menu.style.visibility="hidden" Then
       menu.style.visibility="visible"
       menu.style.zIndex=zindex + 1
    Else
       hidemenu(menu)
    End If
End Sub

Sub hidemenu(menu)
    menu.style.visibility="hidden"
    window.event.cancelBubble = true
end Sub
</script>
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <span class="menu" onmouseover="showsubmenu(SearchMenu)">
  <a CLASS="menuitem" href=new_nav_menu.asp>|Search</A></b></font>
  </SPAN>
  &nbsp;</TD>
  <TD WIDTH="10%" BGCOLOR="<%=strMenuBackColor%>"><P ALIGN="left">
  <A CLASS="exit" HREF="exit.asp" TARGET="_top" TITLE="Exit the Navistar Repository">|Exit</A>
  </TD>
</TR>
</TABLE>

  <div id="SearchMenu" style="position:absolute;left:0;top:0;layer-background-color:black;
      background-color:black;width:150;visibility:hidden;border:0px solid black;padding:0px;
      text-align:left; overflow:clip; text-indent:0">
  <script language="vbscript">
  Sub writeMenu
  For i=0 to UBOUND(arySearchMenu)
     document.write(arySearchMenu(i))
  Next
  end sub
  </script>
  </DIV>
</BODY>
</HTML>

