<%
Response.buffer = True
Session.Timeout=60
Dim strQString
strQString = Request.Form("QString")
'response.write strqstring
'response.end
%>

<!--#INCLUDE FILE="../include/colors.inc"-->
<html>
<head>
<title>Please Wait</title>
</head>
<body LANGUAGE="VBSCRIPT" BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<table BORDER="0" WIDTH="80%" CELLSPACING="0" CELLPADDING="0" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
<tr>
<td ALIGN="center">
<h3><font FACE="Verdana">Please wait while your query is being processed...</h3></font>
</td>
</tr>
<tr>
<td ALIGN="center" HEIGHT="10">
<img SRC="../images/wait.gif" BORDER="0" ALIGN="absmiddle" WIDTH="322" HEIGHT="179">
If this window does not disappear in a few minutes, <a HREF="<%=strQString%>"> click here.</a>
</td>
</tr>
</table>
<script LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Parent.Location.HREF="<%=strQString%>"
End Sub
</script>
</body>
</html>