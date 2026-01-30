<TABLE BORDER="0" WIDTH="100%" HEIGHT="75" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuHeaderColor%>">
  <TR>
  <TD WIDTH="90%" ALIGN="center" VALIGN="top"><FONT FACE="verdana" Size="2" COLOR="#FFFFFF"><B><%=TRIM(Session("UserName"))%> is currently logged in to the Navistar Repository System</B><BR>
  Use the navigation menu below to move around the repository.</FONT>
  </TD>
  <TD WIDTH="10%" VALIGN="bottom" ALIGN="right" ROWSPAN="2"  BGCOLOR="#000000">
  <IMG SRC="../images/edwlogo.gif" WIDTH="102" HEIGHT="89" BORDER="0" ALT="edwlogo.gif (28431 bytes)" HSPACE="0" VSPACE="0" ALIGN="absbottom">
  </TD>
  </TR>
  <TR>
  <TD WIDTH="90%" valign="middle"><FONT FACE="Verdana" SIZE="1"><b>
   <script ID="NavBar" language="JavaScript" src='..\navmenu\NavBar.js'></script>
   <script ID="Menu" language="JavaScript" src='..\navmenu\\Menu.js'></script>
   <script ID="Display" language="JavaScript" src='..\navmenu\DisplayMenu.js'></script>
   </B></FONT>
  </TD>
</TR>
<TR>
<TD COLSPAN="2" HEIGHT="10" BGCOLOR="<%=strPageBackColor%>">
</TD>
</TR>
</TABLE>
