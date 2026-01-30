<%
 Response.Buffer = TRUE
 Session.Timeout=60
 Server.ScriptTimeOut = 1800
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/rpt_helper.inc"-->

<script language="JavaScript1.2">
<!--
var head="display:''"
function ExpandCollapse(header){
   var head=header.style
   if (head.display=="none")
      head.display=""
   else
      head.display="none"
}
//-->
</script>

<SCRIPT LANGUAGE="VBScript"><!--
 Sub cmdCancel_OnClick
   history.back
 End Sub
 //--></SCRIPT>
 
<%aryElements = Session("aryElemDictNames")%>

 <FORM ACTION="add_elem_dtls.asp" METHOD="POST" NAME="add_elem_dtls" >
 <BODY BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
 <TABLE CELLSPACING="0" BORDER="0" WIDTH="100%" ALIGN="center">
 <A NAME="top"></A>
 <TR BGCOLOR="<%=strHeaderColor%>">
 <TD HEIGHT="20" ALIGN="center" COLSPAN=1> <FONT FACE="Verdana" COLOR="<%=strTextColor%>">
 <B>Suggested Element Names </B></font>
</TABLE>
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><B>Element Name</B></FONT>
</TD>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><B>Data Type</B></FONT>
</TD>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><B>Length</B></FONT>
</TD>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><B>Status</B></FONT>
</TD>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><B>Version</B></FONT>
</TD>
</TR>

<% if aryElements(0,0) = "Not Found" then 
      response.redirect "add_elem_dtls.asp" 
   end if
%>	  

<% For i = 0 to UBOUND(aryElements) %> 
<% aryCurElementDetails = GetElementDetails(aryElements(i,0),aryElements(i,1),aryElements(i,2))%>
<TR>

<TD wrap=no BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(1) %></FONT>
</TD>
<TD wrap=no BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(5) %></FONT>
</TD>
<TD wrap=no BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(7) %></FONT>
</TD>
<% Select Case aryCurElementDetails(3)
          Case "PRDT"
            strQTextColor=strProdColor
          Case "DVLP"
            strQTextColor=strDvlpColor
          Case "APRV"
            strQTextColor=strAprvColor
          Case "ITST"
             strQTextColor=strItstColor  
          Case Else
              strQTextColor=strQTextColor
   End Select  %>
<TD wrap=no BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" COLOR="<%=strQTextColor%>" FACE="Verdana"><% =aryCurElementDetails(3) %></FONT>
</TD>
<TD wrap=no BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(4) %></FONT>
</TD>

</TR>

<!------------ COLLAPSABLE DESCRIPTION -->
<TR>
<TD  valign=top colspan=5 BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana">

<h5 TITLE="Click here to show or hide element Business, Column names and Description" style="cursor:hand" onClick="ExpandCollapse(document.all[this.sourceIndex+1])">Click here to show/hide Element Details...</h5>
<span style="display:none" style=&{head};>
<table>
<tr>
<td colspan=2><FONT SIZE="2" FACE="Verdana"><b>Element Business Name:</font></td>
<td colspan=2></b><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(0)%></font><br></td>
</tr>
<tr>
<td colspan=2><FONT SIZE="2" FACE="Verdana"><b>Element Column Name:</b></font></td>
<td colspan=2><FONT SIZE="2" FACE="Verdana"><% =aryCurElementDetails(2)%></font></td>
</tr>
<tr>
<td colspan=1><FONT SIZE="2" FACE="Verdana"> <b>Element Description:</b></font></td>
<tr>
<td colspan=4><FONT SIZE="2" FACE="Verdana"></b><br><% =aryCurElementDetails(13) %></font></td>
</tr>
</tr>
</table>
</span>
</td>
</TR>
<%Next%>
<tr>
<TD><INPUT TYPE="submit" VALUE="Add Anyway" >
&nbsp;&nbsp <INPUT TYPE="button" VALUE="Cancel" NAME="cmdCancel"></TD>
</tr>
</table>
</body>
