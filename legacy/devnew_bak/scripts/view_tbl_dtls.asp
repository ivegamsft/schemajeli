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
<HTML>
<HEAD>
<TITLE>Display Table Details
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<!--Header table -->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>" cellpadding="0" cellspacing="0">
  <TR>
    <TD HEIGHT="20" ALIGN="center"><FONT FACE="Verdana" SIZE="3">
    <A NAME="TOP"></A><B>Table details for&nbsp;<%=Request.QueryString("Col0")%>&nbsp;in database
<%If bHasDb = False then %>
      <%=strDbName%></B>
<%Else%>
       <A HREF="view_db_dtls.asp?DbName=<%=strDbName%>&Status=<%=strDbStatus%>&Server=<%=strServer%>"><%=strDbName%></A>
<%End If%>
    </FONT>
	</TD>
  </TR>    
</TABLE>
<!--Body Table -->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR>
<TD BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Status</B></FONT>
</TD>
<TD BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana"><%=Request.QueryString("Col1")%></FONT>
</TD>
</TR>
<TR>
<TD colspan="2" BGCOLOR="<%=strBackColor%>"><FONT SIZE="3" FACE="Verdana"><B>Description</B><BR></FONT>
</TR>
<TR>
<TD colspan="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">
<%
Do While Not rs.EOF%>
<%=REPLACE(rs.Fields(1).Value," ","&nbsp;")%><BR>
<% rs.MoveNext
Loop
rs.Close %>
</FONT>
</TD>
</TR>
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
<TR>
<TD colspan="2" BGCOLOR="<%=strHeaderColor%>" align="center"><FONT SIZE="3" FACE="Verdana"><B>Table Update Statistics</B></FONT></TD>
</TR>
<TR>
<TD colspan="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">Created by <%=rs.Fields(0).Value%></FONT></TD>
</TR>
<TR>
<TD colspan="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">Last Updated by <%=rs.Fields(2).Value%> at <%=rs.Fields(3).Value%></FONT></TD>
</TR>
<%rs.Close%>
</TABLE>
<!-- DISPLAY TABLE ELEMENTS ---------------------------->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR BGCOLOR="<%=strHeaderColor%>">
<TD HEIGHT="30" COLSPAN="5" BGCOLOR="<%=strHeaderColor%>" align="center">
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
<FONT SIZE="3" FACE="Verdana"><B>Elements&nbsp;[<%=iRecCount%>]</B></FONT></TD></TR> 
<%If iRecCount > 0 then %>
<TR>
<TD></TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B>Element Name</B></FONT></TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B>Status</B></FONT></TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B>Primary Key</B></FONT></TD>
<TD NOWRAP><FONT SIZE="3" FACE="Verdana"><B>Version</B></FONT></TD>
</TR>
<%Do While Not rs.EOF%>
<TR>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>">
   <A HREF="view_elem_dtls.asp?Col1=<%=TRIM(rs.Fields(0).Value)%>&Col3=<%=TRIM(rs.Fields(1).value)%>&Col4=<%=TRIM(rs.Fields(2).value)%>">
   <IMG SRC="../images/report80_trans.gif" BORDER="0"></A>
   </TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">  
   <%=rs.Fields(0).Value%>
   </FONT>
   </TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">  
   <%=rs.Fields(1).Value%>
   </FONT>
   </TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">  
   <%=rs.Fields(3).Value%>
   </FONT>
   </TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="3" FACE="Verdana">  
   <%=rs.Fields(2).Value%>
   </FONT>
   </TD>
   </TR>
   <%rs.movenext %>
<%Loop%> 
<TR BGCOLOR="<%=strHeaderColor%>">
<TD COLSPAN="5" ALIGN="center"><FONT SIZE="3" FACE="Verdana"><A HREF="#TOP"><B>Back to Top</B></A></FONT></TD>
</TR>
<%
rs.close 
End If%>
</TABLE>
</BODY>
</HTML>
   