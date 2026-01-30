<%
 Response.Buffer = TRUE
 Session.Timeout=60
 Server.ScriptTimeOut = 1800
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/rpt_helper.inc"-->


<%aryElements = Session("aryElemDictNames")%>
<%for i=0 to ubound(aryElements)
    response.write aryElements(i)%>
   <BR>
<%next%> 
 
 <BODY BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
 <TABLE CELLSPACING="0" BORDER="0" WIDTH="100%" ALIGN="center">
 <A NAME="top"></A>
 <TR BGCOLOR="<%=strHeaderColor%>">
 <TD HEIGHT="20" ALIGN="center" COLSPAN=1 <FONT FACE="Verdana" COLOR="<%=strTextColor%>">
 <B>Suggested Element Names </B>
</TABLE>
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Element Name</B></FONT>
</TD>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Data Type</B></FONT>
</TD>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Length</B></FONT>
</TD>
</TR>

<% For i = 0 to UBOUND(aryElements) %> 
<% aryCurElementDetails = GetElementDetails(aryElements(i),"DVLP","1") %>
<TR>
<TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(0) %></FONT>
</TD>
<TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(5) %></FONT>
</TD>
<TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(7) %></FONT>
</TD>
</TR>
<!-- <TR>
<TD colspan="2" BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Description</B><BR></FONT>
</TR>
-->
<%Next%> 
     
<!--     'strElemBName = aryCurElementDetails(0)
     strElemDName = aryCurElementDetails(1)
	 response.write strElemDName
     'strElemCName = aryCurElementDetails(2)
     
	  response.write  strElemDataType
     'strElemLLen = aryCurElementDetails(6)
     strElemPLen = aryCurElementDetails(7)
	 response.write  strElemPLen
     'strElemDLen = aryCurElementDetails(8)
     strElemDesc = aryCurElementDetails(13)
	  response.write strElemDesc 
-->

<!--<SCRIPT LANGUAGE=VBSCRIPT>
' Sub Window_OnLoad()
'    Document.Add.Submit
' End Sub
</SCRIPT>
<FORM NAME="Add" METHOD="POST" ACTION="add_elem_dtls.asp">
<INPUT TYPE="HIDDEN" NAME="From" VALUE="Add">
</FORM>
-->
</table>
</body>
