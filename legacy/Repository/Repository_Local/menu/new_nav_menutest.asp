<HTML>
<HEAD>
<STYLE>
BODY       { 
              font-family:Verdana;
              font-size: small;
              color:#2F2F9F;
              font-weight: bold;}

.warning    {
              font-family:Arial;
              font-size: x-small;
              color:red;}
              
A:link      {
             font-family:Verdana;
             font-size: small;
             color:blue;
             text-decoration:none;
             font-weight: bold; }

A:visited   {color:blue;
             font-size: small;
             font-family:Verdana;
             text-decoration:none;
             font-weight: bold; }


A:active    {color:blue;
             font-size: small;
             font-family:Verdana;
             text-decoration:none;
             font-weight: bold; }


A:hover     {color:red;
             font-size: small;
             font-family:Verdana;
             text-decoration:none;
             font-weight: bold; }

</STYLE>
<TITLE>MainPage
</TITLE>
<%
'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<!--#INCLUDE FILE="../include/colors.inc"-->
</HEAD>
<BODY BGCOLOR="#00a000" marginwidth = "0" marginheight = "0" leftmargin="0" topmargin="0">
<TABLE BORDER="1" WIDTH="100%" HEIGHT="75" CELLSPACING="0" CELLPADDING="0" BGCOLOR="#0000c0">
  <TR>
  <TD WIDTH="90%" HEIGHT="90%" ALIGN="middle" VALIGN="bottom"><FONT FACE="Tahoma" SIZE="2" COLOR="#00e0c0">
  <B>
            <%=TRIM(Session("UserName"))%> is currently logged in to the Navistar Repository System</B><BR>
  Use the navigation menu below to move around the repository.
  </FONT>
  </TD>
  <TD WIDTH="10%" VALIGN="bottom" ALIGN="right" ROWSPAN="2">
  <A HREF="http://wwwnio.navistar.com/edw" TARGET="_blank">
  <IMG alt="Enterprise Data Warehouse" border=0 height=89 hspace  =0 name=logo src="../images/edwlogo.gif" width=102 > 
  </A>
  </TD>
  </TR>
  <TR>
  <TD WIDTH="90%" HEIGHT="5%" BGCOLOR="#00e0c0" ALIGN="middle" VALIGN="center">
  <TABLE BORDER="0" WIDTH="100%" HEIGHT="100%" CELLSPACING="0" CELLPADDING="0" BGCOLOR="#00e0c0" id=TABLE1>
  <TR>
  <TD WIDTH="100%" BGCOLOR="#00e0c0" ALIGN="middle" VALIGN="bottom">
  <script ID="NavBar" language="JavaScript" src="..\navmenu\NavBar.js" TYPE="text/javascript"></script>
  <script ID="Menu" language="JavaScript" src="..\navmenu\Menu.js" TYPE="text/javascript"></script>
  <script ID="Display" language="JavaScript" src="..\navmenu\displayMenu.js" TYPE="text/javascript"></script>
  <script ID="Validate" language="JavaScript" src="..\navmenu\Validation.js" TYPE="text/javascript"></script>
 
  </TD>
  </TR>
</TABLE>
</TD>
</TR>
</TABLE>
</BODY>
</HTML>