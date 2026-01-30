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
<HTML>
<HEAD>
<TITLE>Display Element Details
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<!--Header table -->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <TR>
    <TD HEIGHT="20" ALIGN="center"><FONT FACE="Verdana" SIZE="2">
    <A NAME="TOP"></A><B>Data element details for <%=Request.QueryString("Col1")%></B>
    </FONT>
	</TD>
  </TR>    
</TABLE>
<!--Body Table -->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Business Name</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strBackColor%>"><FONT SIZE="2" FACE="Verdana" COLOR="<%=strTextHLTColor%>"><B><%=TRIM(rs.Fields(3).Value)%></B></FONT>
</TD>
</TR> 
<TR>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Column Name</B></FONT></TD> 
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(4).Value)%></FONT></TD>
</TR>
<TR>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Status</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(0).Value)%></FONT></TD>
</TR>
<TR>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Creator</B></FONT></TD>
<TD NOWRAP COLSPAN="2" BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(1).Value)%></FONT></TD>
</TR>
<!--
<TR>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Create Date</B></FONT></TD>
<TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(2).Value)%></FONT></TD>
</TR>
-->
<TR> 
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Version</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(5).Value)%></FONT></TD>
</TR>
<TR>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Data Type</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(6).Value)%></FONT></TD>
</TR> 
<TR>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Logical Length</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(7).Value)%></FONT></TD>
</TR>
<TR> 
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Physical Length</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(8).Value)%></FONT></TD>
</TR>
<TR> 
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Decimal Length</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana"><%=TRIM(rs.Fields(9).Value)%></FONT></TD>
</TR>
<TR> 
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Null Code</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana">N/A</FONT></TD>
</TR>
<%rs.close

SQLD = "SELECT seq_no, text_80_desc FROM irma06_elmt_desc WHERE elmt_dict_nme='" & Request.QueryString("Col1") & "' and elmt_stat_cd='" & Request.QueryString("Col3") & "' order by seq_no "
If rs.State = 1 then
   rs.Close
End IF
rs.open(SQLD)%>

<TR>
<TD NOWRAP VALIGN="top"><FONT SIZE="2" FACE="Verdana"><B>Description</B></FONT></TD>
<TD COLSPAN="2" NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana">
<%
Do While Not rs.EOF%>
<%=REPLACE(RTRIM(rs.Fields(1).Value)," ","&nbsp;")%><BR>
<% rs.movenext
Loop
rs.Close %>
</FONT>
</TD>
</TR>
</TABLE>
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" cellspacing="0">
<TR BGCOLOR="<%=strHeaderColor%>">
<TD HEIGHT="30" COLSPAN="3" ALIGN="Center">
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
<FONT SIZE="2" FACE="Verdana"><B>Tables Where Element is Used&nbsp;[<%=iRecCount%>]</B></FONT></TD>
</TR>
<%If iRecCount > 0 then %>
<TR>
<TD></TD>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Table Name</B></FONT></TD>
<TD NOWRAP><FONT SIZE="2" FACE="Verdana"><B>Status</B></FONT></TD>
</TR>
<%Do While Not rs.EOF%>
<TR>
<TD NOWRAP BGCOLOR="<%=strPageBackColor%>">
   <A HREF="view_tbl_dtls.asp?Col0=<%=TRIM(rs.Fields(0).Value)%>&Col1=<%=TRIM(rs.Fields(1).value)%>">
   <IMG SRC="../images/report80_trans.gif" BORDER="0"></A></TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana">  
   <%=rs.Fields(0).Value%>
   </FONT>
   </TD>
   <TD NOWRAP BGCOLOR="<%=strPageBackColor%>"><FONT SIZE="2" FACE="Verdana">  
   <%=rs.Fields(1).Value%>
   </FONT>
   </TD>
   </TR>
   <%rs.movenext %>
<%Loop%> 
<TR BGCOLOR="<%=strHeaderColor%>">
<TD COLSPAN="3" ALIGN="center"><FONT SIZE="2" FACE="Verdana"><A HREF="#TOP"><B>Back to Top</B></A></TD>
</TR>
<% rs.close
End If
%>
</TABLE>
</BODY>
</HTML>
  