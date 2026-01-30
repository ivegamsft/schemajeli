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
<HTML>
<BODY BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <TR>
    <TD HEIGHT="20" ALIGN="center"><FONT FACE="Verdana" SIZE="3">
    <A NAME="TOP"></A><B>Database details for&nbsp;<%=strDbName%></B>
    </FONT>
	</TD>
  </TR>    
</TABLE>
<!--Body Table -->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR>
<TD width="30%"></TD>
<TD width="30%"></TD>
<TD width="30%"></TD>
</tr>

<TR>
<TD NOWRAP BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>In server</B></FONT></TD>
<TD NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana"><%=strServer%></FONT></TD>
</TR>

<TR>
<TD NOWRAP BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>RDBMS</B></FONT></TD>
<TD NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana"><%=strRDBMS%></FONT></TD>
</TR>

<TR>
<TD NOWRAP BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>RDBMS version</B></FONT></TD>
<TD NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana"><%=strRDBMSVer%></FONT></TD>
</TR>

<TR>
<TD NOWRAP BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Status</B></FONT></TD>
<TD NOWRAP colspan="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana"><%=strDbStatus%></FONT></TD>
</TR>

<TR>
<TD NOWRAP COLSPAN="3" BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Description</B></FONT></TD>
</TR>

<TR>
<TD NOWRAP COLSPAN="3" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana"><%=strDbDesc%></FONT></TD>
</TR>

<!-- DISPLAY UPDATE STATISTICS -->
<TR>
<TD NOWRAP COLSPAN="3" BGCOLOR="<%=strHeaderColor%>" align="center"><FONT SIZE="3" FACE="Verdana"><B>Database Update Statistics</B></FONT></TD>
</TR>
<TR>
<TD NOWRAP COLSPAN="3" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">Created by <%=strCreateUID%></FONT></TD>
</TR>
<TR>
<TD NOWRAP COLSPAN="3" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">Last Updated by <%=strLstChngUID%> at <%=strLstChngTS%></FONT></TD>
</TR>
</TABLE>
<!-- DISPLAY TABLES -->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR BGCOLOR="<%=strHeaderColor%>">
<TD HEIGHT="30" COLSPAN="3" BGCOLOR="<%=strHeaderColor%>" align="center">
<FONT SIZE="3" FACE="Verdana"><B>Tables&nbsp;[<%=iRecCount%>]</B></FONT></TD></TR>
<%If iRecCount > 0 then %>
<TR>
<TD>&nbsp;</TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B>Table Name</B></FONT></TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B>Status</B></FONT></TD>
</TR>
<%For i = 0 to UBOUND(aryTables)%>
<TR>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>">
   <A HREF="view_tbl_dtls.asp?Col0=<%=TRIM(aryTables(i,0))%>&Col1=<%=TRIM(aryTables(i,1))%>">
   <IMG SRC="../images/report80_trans.gif" BORDER="0"></A>
   </TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">  
   <%=aryTables(i,0)%>
   </FONT>
   </TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">  
   <%=aryTables(i,1)%>
   </FONT>
   </TD>
<%Next %>
</TR>
<TR BGCOLOR="<%=strHeaderColor%>">
<TD COLSPAN="3" ALIGN="center"><FONT SIZE="3" FACE="Verdana"><A HREF="#TOP"><B>Back to Top</B></A></FONT></TD>
</TR>
<%
Else
%>
<TR>
<TD>&nbsp;</TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B>None Found</B></FONT></TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B></B></FONT></TD>
</TR>
<%
End If
%>
</TABLE>
</BODY>
</HTML>
   