<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<% 
Session.Timeout=60
response.buffer = true
Dim sqlQuery
Dim iRecCount
Dim strDbName
Dim strDbStatus
Dim strRDBMS
Dim strRDBMSVer
Dim strDbBName
Dim strServer
Dim strDbDesc
Dim strCreateUID
Dim strCreateTS
Dim strLastChngUID
Dim strLastChngTS
Dim bHasTables
Dim aryTables()
Set rs = session("rs")

strDbName = UCASE(Request.QueryString("DbName"))
strDbStatus = UCASE(Request.QueryString("Status"))
strServer = UCASE(Request.QueryString("Server"))
sqlQuery = "SELECT * FROM irma01_table WHERE db_nme = '" & strdbName & "'"
If rs.State=1 then
   rs.close
End If
rs.open(sqlQuery)
    If rs.BOF = -1 then
       sqlQuery = "SELECT a.db_busns_nme, a.db_nme, a.db_stat_cd, a.rdbms_nme, a.rdbms_vrsn_no, "
       sqlQuery = sqlQuery & " a.text_160_desc, a.creat_uid, a.lst_chng_uid, a.lst_chng_ts, a.creat_ts, "
       sqlQuery = sqlQuery & " b.srvr_nme "
       sqlQuery = sqlQuery & " FROM irma11_db a, irma13_db_srvr b "
       sqlQuery = sqlQuery & " WHERE a.db_nme='" & strDbName & "' "
       sqlQuery = sqlQuery & " AND a.db_stat_cd='" & strDbStatus & "'"
       sqlQuery = sqlQuery & " AND b.srvr_nme='" & strServer & "'"
       sqlQuery = sqlQuery & " AND a.db_nme=b.db_nme "
       sqlQuery = sqlQuery & " AND a.db_stat_cd=b.db_stat_cd "
       bHasTables = False
   Else
       sqlQuery = "SELECT a.db_busns_nme, a.db_nme, a.db_stat_cd, a.rdbms_nme, a.rdbms_vrsn_no, "
       sqlQuery = sqlQuery & " a.text_160_desc, a.creat_uid, a.lst_chng_uid, a.lst_chng_ts, a.creat_ts, "
       sqlQuery = sqlQuery & " b.srvr_nme, c.tbl_nme, c.tbl_stat_cd "
       sqlQuery = sqlQuery & " FROM irma11_db a, irma13_db_srvr b, irma01_table c "
       sqlQuery = sqlQuery & " WHERE a.db_nme='" & strDbName & "' "
       sqlQuery = sqlQuery & " AND a.db_stat_cd='" & strDbStatus & "'"
       sqlQuery = sqlQuery & " AND b.srvr_nme='" & strServer & "'"
       sqlQuery = sqlQuery & " AND a.db_nme=b.db_nme "
       sqlQuery = sqlQuery & " AND a.db_stat_cd=b.db_stat_cd "
       sqlQuery = sqlQuery & " AND a.db_nme=c.db_nme "
       sqlQuery = sqlQuery & " AND a.db_stat_cd=c.db_stat_cd "
       sqlQuery = sqlQuery & " ORDER BY c.tbl_nme, c.tbl_stat_cd "
       bHasTables = true
   End If
rs.Close
'response.write sqlquery
If rs.State=1 then
   rs.close
End If
rs.open(sqlQuery)

strDbBName = TRIM(rs.Fields(0))
strRDBMS = UCASE(TRIM(rs.Fields(3)))
strRDBMSVer = TRIM(rs.Fields(4))
strDbDesc = REPLACE(rs.Fields(5)," ","&nbsp;")
strCreateUID = UCASE(TRIM(rs.Fields(6)))
strLastChngUID = UCASE(TRIM(rs.Fields(7)))
strLastChngTS = rs.Fields(8)
strCreateTS = rs.Fields(9)
strServer = UCASE(TRIM(rs.Fields(10)))
iRecCount=0
If bHasTables then
   Do Until rs.EOF = TRUE
      iRecCount = iRecCount +1
      rs.MoveNext
   Loop
   rs.MoveFirst
   ReDim aryTables(iRecCount -1,1)
   iLoopCount = 0
   Do Until rs.EOF = True
      aryTables(iLoopCount,0) = rs.Fields(11)
      aryTables(iLoopCount,1) = rs.Fields(12)
      iLoopCount = iLoopCount + 1
      rs.MoveNext
   Loop
Else
   iRecCount = 0
   ReDim aryTables(0,1)
   aryTables(0,0) = "NONE FOUND"
   aryTables(0,1) = ""
End If
rs.Close



%>
<!--DISPLAY DATABASE DESCRIPTION -->
<html>
<head>
<title>Display Database Details
</title>
</head>
<body MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<!--Header table -->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <tr>
    <td HEIGHT="20" ALIGN="center"><font FACE="Verdana" SIZE="3">
    <a NAME="TOP"></a><b>Database details for&nbsp;<%=strDbName%></b>
    </font>
	</td>
  </tr>    
</table>
<!--Body Table -->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr>
<td width="30%"></td>
<td width="30%"></td>
<td width="30%"></td>
</tr>

<tr>
<td NOWRAP BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>In server</b></font></td>
<td NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana"><%=strServer%></font></td>
</tr>

<tr>
<td NOWRAP BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>RDBMS</b></font></td>
<td NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana"><%=strRDBMS%></font></td>
</tr>

<tr>
<td NOWRAP BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>RDBMS version</b></font></td>
<td NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana"><%=strRDBMSVer%></font></td>
</tr>

<tr>
<td NOWRAP BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>Status</b></font></td>
<td NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana"><%=strDbStatus%></font></td>
</tr>

<tr>
<td NOWRAP COLSPAN="3" BGCOLOR="<%=strBackColor%>"><font SIZE="3" FACE="Verdana"><b>Description</b></font></td>
</tr>

<tr>
<td NOWRAP COLSPAN="3" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana"><%=strDbDesc%></font></td>
</tr>

<!-- DISPLAY UPDATE STATISTICS -->
<tr>
<td NOWRAP COLSPAN="3" BGCOLOR="<%=strHeaderColor%>" align="center"><font SIZE="3" FACE="Verdana"><b>Database Update Statistics</b></font></td>
</tr>
<tr>
<td NOWRAP COLSPAN="3" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">Created by <%=strCreateUID%></font></td>
</tr>
<tr>
<td NOWRAP COLSPAN="3" BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">Last Updated by <%=strLstChngUID%> at <%=strLstChngTS%></font></td>
</tr>
</table>
<!-- DISPLAY TABLES -->
<table BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<tr BGCOLOR="<%=strHeaderColor%>">
<td HEIGHT="30" COLSPAN="3" BGCOLOR="<%=strHeaderColor%>" align="center">
<font SIZE="3" FACE="Verdana"><b>Tables&nbsp;[<%=iRecCount%>]</b></font></td></tr>
<%If iRecCount > 0 then %>
<tr>
<td>&nbsp;</td>
<td NOWRAP><font SIZE="3" FACE="Verdana"><b>Table Name</b></font></td>
<td NOWRAP><font SIZE="3" FACE="Verdana"><b>Status</b></font></td>
</tr>
<%For i = 0 to UBOUND(aryTables)%>
<tr>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>">
   <a HREF="view_tbl_dtls.asp?Col0=<%=TRIM(aryTables(i,0))%>&amp;Col1=<%=TRIM(aryTables(i,1))%>">
   <img SRC="../images/report80_trans.gif" BORDER="0" WIDTH="26" HEIGHT="26"></a>
   </td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=aryTables(i,0)%>
   </font>
   </td>
   <td NOWRAP BGCOLOR="<%=strPageBackColor%>"><font SIZE="3" FACE="Verdana">  
   <%=aryTables(i,1)%>
   </font>
   </td>
<%Next %>
</tr>
<tr BGCOLOR="<%=strHeaderColor%>">
<td COLSPAN="3" ALIGN="center"><font SIZE="3" FACE="Verdana"><a HREF="#TOP"><b>Back to Top</b></a></font></td>
</tr>
<%
Else
%>
<tr>
<td>&nbsp;</td>
<td NOWRAP><font SIZE="3" FACE="Verdana"><b>None Found</b></font></td>
<td NOWRAP><font SIZE="3" FACE="Verdana"><b></b></font></td>
</tr>
<%
End If
%>
</table>
</body>
</html>
   