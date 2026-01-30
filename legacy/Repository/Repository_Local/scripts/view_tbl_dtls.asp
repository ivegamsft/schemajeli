<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<% 
Session.Timeout=60
response.buffer = true
Dim sqlD
Dim sqlS
Dim iRecCount
Dim strTblDbName
Dim strDbStatus
Dim bHasDb
Set rs = session("rs")
bHasDb=False
If rs.State=1 then
   rs.close
End If
SQLD = "SELECT a.db_nme, a.db_stat_cd, c.srvr_nme "
SQLD = SQLD & " FROM irma01_table a, irma11_db b, irma13_db_srvr c "
SQLD = SQLD & " WHERE a.tbl_nme='" & Request.QueryString("Col0") & "' "
SQLD = SQLD & " and a.tbl_stat_cd='" & Request.QueryString("Col1") & "'"
SQLD = SQLD & " and a.db_nme= b.db_nme "
SQLD = SQLD & " and a.db_stat_cd = b.db_stat_cd "
SQLD = SQLD & " and b.db_nme = c.db_nme "
SQLD = SQLD & " and b.db_stat_cd = c.db_stat_cd "
rs.open(SQLD)
If rs.BOF <> -1 then
   If IsNULL(rs.Fields(0)) or IsEmpty(rs.Fields(0)) or rs.Fields(0) = "" then
      bHasDb = False
      strDbName = "N/A"
   Else
      bHasDb=True
      strDbName = UCASE(TRIM(rs.Fields(0)))
      strDbStatus = UCASE(TRIM(rs.Fields(1)))
      strServer = UCASE(TRIM(rs.Fields(2)))
End If
rs.Close
Else
  bHasDb = False
  strDbName = "N/A"
End If
SQLD = "SELECT a.seq_no, a.text_80_desc "
SQLD = SQLD & " FROM irma02_table_desc a, irma01_table b "
SQLD = SQLD & " WHERE a.tbl_nme='" & Request.QueryString("Col0") & "' "
SQLD = SQLD & " and a.tbl_stat_cd='" & Request.QueryString("Col1") & "'"
SQLD = SQLD & " and a.tbl_nme = b.tbl_nme "
SQLD = SQLD & " and a.tbl_stat_cd = b.tbl_stat_cd "
SQLD = SQLD & " ORDER By seq_no "
If rs.State=1 then
   rs.close
End If
rs.open(SQLD)
%>
<html>
<head>
<title>Display Table Details
</title>
</head>
<body MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<!--Header table -->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>" cellpadding="0" cellspacing="0">
  <tr>
    <td HEIGHT="20" ALIGN="center"><font FACE="Verdana" SIZE="3">
    <a NAME="TOP"></a><b>Table details for&nbsp;<%=Request.QueryString("Col0")%>&nbsp;in database
<%If bHasDb = False then %>
      <%=strDbName%></b>
<%Else%>
       <a HREF="view_db_dtls.asp?DbName=<%=strDbName%>&amp;Status=<%=strDbStatus%>&amp;Server=<%=strServer%>"><%=strDbName%></a>
<%End If%>
    </font>
	</td>
  </tr>    
</table>
<!--Body Table -->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr>
<td BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>Status</b></font>
</td>
<td BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana"><%=Request.QueryString("Col1")%></font>
</td>
</tr>
<tr>
<td colspan="2" BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>Description</b><br></font>
</tr>
<tr>
<td colspan="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">
<%
Do While Not rs.EOF%>
<%=REPLACE(rs.Fields(1).Value," ","&nbsp;")%><br>
<% rs.MoveNext
Loop
rs.Close %>
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
<td colspan="2" BGCOLOR="<%=strHeaderColor%>" align="center"><font SIZE="3" FACE="Verdana"><b>Table Update Statistics</b></font></td>
</tr>
<tr>
<td colspan="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">Created by <%=rs.Fields(0).Value%></font></td>
</tr>
<tr>
<td colspan="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">Last Updated by <%=rs.Fields(2).Value%> at <%=rs.Fields(3).Value%></font></td>
</tr>
<%rs.Close%>
</table>
<!-- DISPLAY TABLE ELEMENTS ---------------------------->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr BGCOLOR="<%=strHeaderColor%>">
<td HEIGHT="30" COLSPAN="5" BGCOLOR="<%=strHeaderColor%>" align="center">
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
<td NOWRAP><font SIZE="3" FACE="Verdana"><b>Element Name</b></font></td>
<td NOWRAP><font SIZE="3" FACE="Verdana"><b>Status</b></font></td>
<td NOWRAP><font SIZE="3" FACE="Verdana"><b>Primary Key</b></font></td>
<td NOWRAP><font SIZE="3" FACE="Verdana"><b>Version</b></font></td>
</tr>
<%Do While Not rs.EOF%>
<tr>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>">
   <a HREF="view_elem_dtls.asp?Col1=<%=TRIM(rs.Fields(0).Value)%>&amp;Col3=<%=TRIM(rs.Fields(1).value)%>&amp;Col4=<%=TRIM(rs.Fields(2).value)%>">
   <img SRC="../images/report80_trans.gif" BORDER="0" WIDTH="26" HEIGHT="26"></a>
   </td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(0).Value%>
   </font>
   </td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(1).Value%>
   </font>
   </td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(3).Value%>
   </font>
   </td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=rs.Fields(2).Value%>
   </font>
   </td>
   </tr>
   <%rs.movenext %>
<%Loop%> 
<tr BGCOLOR="<%=strHeaderColor%>">
<td COLSPAN="5" ALIGN="center"><font SIZE="3" FACE="Verdana"><a HREF="#TOP"><b>Back to Top</b></a></font></td>
</tr>
<%
rs.close 
End If%>
</table>
</body>
</html>
   