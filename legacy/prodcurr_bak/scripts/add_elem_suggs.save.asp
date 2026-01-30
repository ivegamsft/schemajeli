<%
 Response.Buffer = TRUE
 Session.Timeout=60
 Server.ScriptTimeOut = 1800
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/rpt_helper.inc"-->

<SCRIPT LANGUAGE="VBScript"><!--
 Sub cmdCancel_OnClick
   history.back
 End Sub
 //--></SCRIPT>
 
<%aryElements = Session("aryElemDictNames")%>

<!--<%for i=0 to ubound(aryElements)
     response.write aryElements(i,0)
     response.write aryElements(i,1)
 	 response.write aryElements(i,2)%>
  <BR>
<%Next%> -->

 <FORM ACTION="add_elem_dtls.asp" METHOD="POST" NAME="add_elem_dtls" >
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
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Status</B></FONT>
</TD>
</TR>

<% For i = 0 to UBOUND(aryElements) %> 
  <% aryCurElementDetails = GetElementDetails(aryElements(i,0),aryElements(i,1),aryElements(i,2))%>
  <TR>
  <% if aryCurElementDetails(0) <> "Error" then %>
  <TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(1) %></FONT>
  </TD>
  <TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(5) %></FONT>
  </TD>
  <TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(7) %></FONT>
  </TD>
  <TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(3) %></FONT>
  </TD>
  </TR>
<%end if %>
<!-- <TR>
<TD colspan="2" BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Description</B><BR></FONT>
</TR>
-->
<%Next%> 
<TD><INPUT TYPE="submit" VALUE="Add Anyway" >
&nbsp;&nbsp <INPUT TYPE="button" VALUE="Cancel" NAME="cmdCancel"></TD>

</table>
</body>
