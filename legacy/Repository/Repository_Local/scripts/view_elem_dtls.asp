<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Session.Timeout=60
response.buffer = true
Dim iRecCount
SQL = "SELECT DISTINCT a.elmt_stat_cd, a.creat_user_id, a.creat_ts, a.elmt_busns_nme,"
SQL = SQL & " elmt_col_nme, b.elmt_vrsn_no, b.elmt_data_typ_id,"
SQL = SQL & " elmt_logcl_lng, elmt_phys_lng, elmt_dec_lng"
SQL = SQL & " FROM irma05_element a, irma04_elmt_vrsn b"
SQL = SQL & " WHERE a.elmt_dict_nme='" & Request.QueryString("Col1") & "'"
SQL = SQL & " and a.elmt_stat_cd='" & Request.QueryString("Col3") & "'"
SQL = SQL & " and b.elmt_vrsn_no='" & Request.QueryString("Col4") & "'"
SQL = SQL & " and a.elmt_dict_nme = b.elmt_dict_nme"
SQL = SQL & " and a.elmt_stat_cd = b.elmt_stat_cd"

Set rs = session("rs")
If rs.State = 1 Then
   rs.Close
End If
rs.open(SQL)
%>
<html>
<head>
<title>Display Element Details
</title>
</head>
<body MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<!--Header table -->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <tr>
    <td HEIGHT="20" ALIGN="center"><font FACE="Verdana" SIZE="2">
    <a NAME="TOP"></a><b>Data element details for <%=Request.QueryString("Col1")%></b>
    </font>
	</td>
  </tr>    
</table>
<!--Body Table -->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Business Name</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strBackColor%>"><font SIZE="2" FACE="Verdana" COLOR="<%=strTextHLTColor%>"><b><%=TRIM(rs.Fields(3).Value)%></b></font>
</td>
</tr> 
<tr>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Column Name</b></font></td> 
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(4).Value)%></font></td>
</tr>
<tr>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Status</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(0).Value)%></font></td>
</tr>
<tr>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Creator</b></font></td>
<td NOWRAP COLSPAN="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(1).Value)%></font></td>
</tr>
<!--<TR><TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Create Date</B></FONT></TD><TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(2).Value)%></FONT></TD></TR>-->
<tr> 
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Version</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(5).Value)%></font></td>
</tr>
<tr>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Data Type</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(6).Value)%></font></td>
</tr> 
<tr>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Logical Length</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(7).Value)%></font></td>
</tr>
<tr> 
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Physical Length</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(8).Value)%></font></td>
</tr>
<tr> 
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Decimal Length</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(9).Value)%></font></td>
</tr>
<tr> 
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Null Code</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana">N/A</font></td>
</tr>
<%rs.close

SQLD = "SELECT seq_no, text_80_desc FROM irma06_elmt_desc WHERE elmt_dict_nme='" & Request.QueryString("Col1") & "' and elmt_stat_cd='" & Request.QueryString("Col3") & "' order by seq_no "
If rs.State = 1 then
   rs.Close
End IF
rs.open(SQLD)%>

<tr>
<td NOWRAP VALIGN="top"><font SIZE="2" FACE="Verdana"><b>Description</b></font></td>
<td COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana">
<%
Do While Not rs.EOF%>
<%=REPLACE(RTRIM(rs.Fields(1).Value)," ","&nbsp;")%><br>
<% rs.movenext
Loop
rs.Close %>
</font>
</td>
</tr>
</table>
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr BGCOLOR="<%=strHeaderColor%>">
<td HEIGHT="30" COLSPAN="3" ALIGN="Center">
<%
SQLT = "SELECT tbl_nme, tbl_stat_cd from irma03_table_elmt"
SQLT = SQLT & " WHERE elmt_dict_nme='" & Request.QueryString("Col1") & "'"
SQLT = SQLT & " and elmt_stat_cd='" & Request.QueryString("Col3") & "'"
SQLT = SQLT & " and elmt_vrsn_no='" & Request.QueryString("Col4") & "'"
SQLT = SQLT & " order by tbl_nme, tbl_stat_cd "

If rs.State = 1 then
   rs.Close
End IF
rs.open(SQLT)
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
<font SIZE="2" FACE="Verdana"><b>Tables Where Element is Used&nbsp;[<%=iRecCount%>]</b></font></td>
</tr>
<%If iRecCount > 0 then %>
<tr>
<td></td>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Table Name</b></font></td>
<td NOWRAP><font SIZE="2" FACE="Verdana"><b>Status</b></font></td>
</tr>
<%Do While Not rs.EOF%>
<tr>
<td NOWRAP BGCOLOR="<%=strPageBackColor%>">
   <a HREF="view_tbl_dtls.asp?Col0=<%=TRIM(rs.Fields(0).Value)%>&amp;Col1=<%=TRIM(rs.Fields(1).value)%>">
   <img SRC="../images/report80_trans.gif" BORDER="0" WIDTH="26" HEIGHT="26"></a></td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana">  
   <%=rs.Fields(0).Value%>
   </font>
   </td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="2" FACE="Verdana">  
   <%=rs.Fields(1).Value%>
   </font>
   </td>
   </tr>
   <%rs.movenext %>
<%Loop%> 
<tr BGCOLOR="<%=strHeaderColor%>">
<td COLSPAN="3" ALIGN="center"><font SIZE="2" FACE="Verdana"><a HREF="#TOP"><b>Back to Top</b></a></td>
</tr>
<% rs.close
End If
%>
</table>
</body>
</html>
  