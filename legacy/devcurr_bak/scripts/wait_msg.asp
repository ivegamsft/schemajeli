<%
Response.buffer = True
Session.Timeout=60
Dim strQString
strQString = Request.Form("QString")
%>

<!--#INCLUDE FILE="../include/colors.inc"-->
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Parent.Location.HREF="<%=strQString%>"
End Sub
</SCRIPT>
<HTML>
<HEAD>
<TITLE>Please Wait</TITLE>
</HEAD>
<BODY LANGUAGE="VBSCRIPT" BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<TABLE BORDER="0" WIDTH="80%" CELLSPACING="0" CELLPADDING="0" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
<TR>
<TD ALIGN="center">
<H3><FONT FACE="Verdana">Please wait while your query is being processed...</H3></FONT>
</TD>
</TR>
<TR>
<TD ALIGN="center" HEIGHT="10">
<IMG SRC="../images/wait.gif" BORDER="0" ALIGN="absmiddle">
If this window does not disappear in a few minutes, <A HREF="<%=strQString%>"> click here.</A>
</TD>
</TR>
</TABLE>
</BODY>
</HTML>