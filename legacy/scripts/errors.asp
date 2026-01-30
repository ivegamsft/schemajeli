<!--#INCLUDE FILE="../include/colors.inc"-->
<html>
<head>
<title>Navistar Repository System - Error</title>
</head>
<body bgcolor="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<table border="0" width="75%" align="center" bgcolor="<%=strHeaderColor%>">
  <tr>
    <td width="100%" height="40" align="center">
    <font face="Verdana" size="3" color="<%=strErrTextColor%>">
     <h2>An Error has occurred!</font></h2>
    </td>
  </tr>

  <tr>
    <td height="20" align="center">
    <font face="Verdana" size="3">
<%If Session("Error") <> "" then %>
      <b>Error:&nbsp;<%=Session("Error")%></b>
<%Else%>
     An error has occurred.
<%End If%>
    </font>
    </td>
  </tr>
  <tr>
    <td align="center"><font face="Verdana" size="3">
         Please contact <cite><a href="mailto:rephlpteam@USAEXCH01.navistar.com">The
    Navistar Repository System Help Team</a></cite></td>
  </tr>
  <tr>
    <td height="30" BGCOLOR="<%=strBackColor%>"align="center"><font face="Verdana" size="3">
    <font face="Verdana" size="3"><a Href="http://wwwnio.navistar.com/edw/dataaccess/default.htm">Exit</A>
    </td>
  </tr>
</table>
</body>
</html>
<%
session.abandon
%>
