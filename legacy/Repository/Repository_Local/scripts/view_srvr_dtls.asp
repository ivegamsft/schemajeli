<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<% 
Session.Timeout=60
response.buffer = true
Dim sqlD
Dim sqlS
Dim iRecCount

Set rs = session("rs")
If rs.State=1 then
   rs.close
End If
SQLD = "SELECT seq_no, text_80_desc FROM irma02_table_desc"
SQLD = SQLD & " WHERE tbl_nme='" & Request.QueryString("Col0") & "' "
SQLD = SQLD & " and tbl_stat_cd='" & Request.QueryString("Col1") & "' order by seq_no "

rs.open(SQLD)
%>
<html>
<head>
<title>Display Server Details
</title>
</head>
<body MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<!--Header table -->
<table border="0" width="100%" align="center" bgcolor="<%=strHeaderColor%>">
  <tr>
    <td height="20" align="center"><font face="Verdana" size="3">
    <a NAME="TOP"></a><b>Table details for&nbsp;<%=Request.QueryString("Col0")%></b>
    </font>
	</td>
  </tr>    
</table>
<!--Body Table -->
<table border="0" width="100%" align="center" bgcolor="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr>
<td nowrap BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>Description:</b><br></font>
</tr>
<tr>
<td nowrap BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana"><div ALIGN="left">
<%
Do While Not rs.EOF%>
<%=rs.Fields(1).Value%><br>
<% rs.movenext
Loop
rs.Close %>
</div>
</font>
</td>
</tr>
<!-- DISPLAY UPDATE STATISTICS -------------------------------------->
<%
SQLS = "SELECT tbl_creat_uid, creat_ts, tbl_lst_chng_uid, tbl_lst_chng_ts FROM irma01_table"
SQLS = SQLS & " WHERE tbl_nme='" & Request.QueryString("Col0") & "' "
SQLS = SQLS & " and tbl_stat_cd='" & Request.QueryString("Col1") & "' "
If rs.State=1 then
   rs.close
End If
rs.open(SQLS)
%>
<tr>
<td nowrap BGCOLOR="<%=strHeaderColor%>" align="center"><font SIZE="3" FACE="Verdana"><b>Table Update Statistics</b></font></td>
</tr>
<tr>
<td nowrap BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">Created by <%=rs.Fields(0).Value%></font></td>
</tr>
<tr>
<td nowrap BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">Last Updated by <%=rs.Fields(2).Value%> at <%=rs.Fields(3).Value%></font></td>
</tr>
<%rs.Close%>
</table>
<!-- DISPLAY TABLE ELEMENTS ---------------------------->
<table border="0" width="100%" align="center" bgcolor="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr bgcolor="<%=strHeaderColor%>">
<td height="30" colspan="5" BGCOLOR="<%=strHeaderColor%>" align="center">
<%
SQL = "SELECT elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no, prim_key_no, seq_no "
SQL = SQL & " FROM irma03_table_elmt "
SQL = SQL & " WHERE tbl_nme='" & Request.QueryString("Col0") & "'"
SQL = SQL & " AND tbl_stat_cd='" & Request.QueryString("Col1") & "'"
SQL = SQL & " ORDER by seq_no "
If rs.state=1 then
   rs.close
End If
rs.open(SQL)
If NOT rs.BOF = -1 then
  Do Until rs.EOF = TRUE
     iRecCount = iRecCount + 1
     rs.MoveNext
  Loop
  rs.MoveFirst
Else
  iRecCount=0
End If
%>
<font SIZE="3" FACE="Verdana"><b>Elements&nbsp;[<%=iRecCount%>]</b></font></td></tr> 
<%If iRecCount > 0 then %>
<tr>
<td></td>
<td nowrap><font SIZE="3" FACE="Verdana"><b>Element Name</b></font></td>
<td nowrap><font SIZE="3" FACE="Verdana"><b>Status</b></font></td>
<td nowrap><font SIZE="3" FACE="Verdana"><b>Primary Key</b></font></td>
<td nowrap><font SIZE="3" FACE="Verdana"><b>Version</b></font></td>
</tr>
<%Do While Not rs.EOF%>
<tr>
   <td nowrap BGCOLOR="<%=strPageBackColor%>">
   <a Href="view_elem_dtls.asp?Col1=<%=TRIM(rs.Fields(0).Value)%>&amp;Col3=<%=TRIM(rs.Fields(1).value)%>&amp;Col4=<%=TRIM(rs.Fields(2).value)%>">
   <img SRC="../images/report80_trans.gif" BORDER="0" WIDTH="26" HEIGHT="26"></a>
   </td>
   <td nowrap BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(0).Value%>
   </font>
   </td>
   <td nowrap BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(1).Value%>
   </font>
   </td>
   <td nowrap BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(3).Value%>
   </font>
   </td>
   <td nowrap BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(2).Value%>
   </font>
   </td>
   </tr>
   <%rs.movenext %>
<%Loop%> 
<tr BGCOLOR="<%=strHeaderColor%>">
<td colspan="5" align="center"><font SIZE="3" FACE="Verdana"><a HREF="#TOP"><b>Back to Top</b></a></font></td>
</tr>
<%
rs.close 
End If
%>
</table>
</body>
</html>
   