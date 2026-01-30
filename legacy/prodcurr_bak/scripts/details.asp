<% response.buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<%Dim DConn
Dim cmdDC
Dim rsDC
Dim Item
Dim strRelObject
Dim strObjName
Dim sqlQuery
Dim iFieldCount
Dim iLoopVar
Dim strDescSrce
Dim iLabelCount
Dim aryLabel(15)
Dim iRows
Dim iDataSrc      '1=access 2=informix(session variable)
Dim strUAuth

' Retrieve QueryString Variables and convert them to a usable form
strRelObject = Request.QueryString("RelObject")
'********aryLabel holds the Label information 

If strUAuth="Edit" then
    aryHeader(0)="Detail&nbsp;&nbsp;"
	aryHeader(1)="Edit&nbsp;&nbsp;"
else
   aryHeader(0)="Detail&nbsp;&nbsp;"
   aryHeader(1)=""
end if
Select Case strRelObject
	Case "Servers"
		iDataSrc = 1
		strCriteria = Request.QueryString("Name")
		sqlQuery = "SELECT tblSrvr_Db_Tbl.db_Nme, tblSrvr_Db_Tbl.tbl_Nme" 
		sqlQuery = sqlQuery & " FROM tblSrvr_Db_Tbl" 
 		sqlQuery = sqlQuery & " WHERE tblSrvr_Db_Tbl.srvr_nme ='" & strCriteria & "'"
		iHeaderCount = 4
		aryHeader(2)="Database Name"
		aryHeader(3)="Table Name"
		DescSrce=""
	Case "Databases"
		iDataSrc = 1
		strCriteria = Request.QueryString("Name")
		sqlQuery = "SELECT tblSrvrs_Dbs.srvr_nme, tblSrvrs_Dbs.db_nme"
        sqlQuery = sqlQuery & " FROM tblSrvrs_Dbs INNER JOIN tblAll_Srvrs ON tblSrvrs_Dbs.srvr_nme = tblAll_Srvrs.srvr_nme"
		sqlQuery = sqlQuery & " WHERE tblSrvrs_Dbs.srvr_Plat = '" & strCriteria & "'"
        iHeaderCount = 4
		aryHeader(2) = "Server Name"
		aryHeader(3) = "Database Name"
		DescSrce=""
	Case "Tables"
		iDataSrc = 2
        strCriteria = Request.QueryString("Name")
		sqlQuery = "SELECT tbl_stat_cd, tbl_creat_uid, creat_ts, tbl_lst_chng_uid, tbl_lst_chng_ts"
 		sqlQuery = sqlQuery & " FROM irma01_table"
		sqlQuery = sqlQuery & " WHERE tbl_nme='" & Request.QueryString("Name") & "' " 
		sqlQuery = sqlQuery & " AND tbl_stat_cd='" & Request.QueryString("Status") & "' "
		iLabelCount = 5
		aryLabel(0)="Status Code"
		aryLabel(1)="Creatd By:"
		aryLabel(2)="Create Date:"
        aryLabel(3)="Last Modified By:"       
        aryLabel(4)="Last Modified Date:"
		DescSrce="irma02_table_desc"
	Case "Elements"
		iDataSrc = 2
		strCriteria = Request.QueryString("Name")
		sqlQuery = "SELECT a.elmt_busns_nme, elmt_col_nme, a.elmt_stat_cd, a.creat_user_id, a.creat_ts,"
		sqlQuery = sqlQuery & " b.elmt_vrsn_no, b.elmt_data_typ_id,"
 		sqlQuery = sqlQuery & " elmt_logcl_lng, elmt_phys_lng, elmt_dec_lng" 
        sqlQuery = sqlQuery & " FROM irma05_element a, irma04_elmt_vrsn b"
        sqlQuery = sqlQuery & " WHERE a.elmt_dict_nme='" & Request.QueryString("Name") & "'"
        sqlQuery = sqlQuery & " AND a.elmt_stat_cd='" & Request.QueryString("Status") & "'"
        sqlQuery = sqlQuery & " AND b.elmt_vrsn_no='" & Request.QueryString("Version") & "'"
        sqlQuery = sqlQuery & " AND a.elmt_dict_nme = b.elmt_dict_nme"
        sqlQuery = sqlQuery & " AND a.elmt_stat_cd = b.elmt_stat_cd"
		iLabelCount = 9
		aryLabel(0)="Business Name:"
		aryLabel(1)="Column Name:"
		aryLabel(2)="Status Code:"
		aryLabel(3)="Created By:"
        aryLabel(4)="Create Date:"
		aryLabel(5)="Version Number:"
		aryLabel(6)="Data Type:"
		aryLabel(7)="Logical Length:"		
		aryLabel(8)="Physical Length:"
		aryLabel(9)="Decimal Length:"
		DescSrce="irma06_elmt_desc"
   Case "Abbreviation"
		iDataSrc = 2
		strCriteria = Request.QueryString("Name")
		sqlQuery = "SELECT std_abbr_nme, std_abbr_srce_nme" 
		sqlQuery = sqlQuery & " FROM irma10_stda_bbr" 
 		'sqlQuery = sqlQuery & " WHERE tblSrvr_Db_Tbl.srvr_nme ='" & strCriteria & "'"
		iHeaderCount = 4
		aryHeader(2)="Abbreviation"
		aryHeader(3)="Full word or phrase"
		DescSrce="irma10_std_abbr"
End Select
'Response.Write(strCriteria) 'for debugging sql
'Response.Write(sqlQuery) 'for debugging sql
'Response.Write(Request.Form("ObjName"))
'Response.End

' Create and establish data connection
'check for connection type
select case iDataSrc
    Case 1
       Set DConn = Server.CreateObject("ADODB.Connection")
       DConn.ConnectionTimeout = 15
       DConn.CommandTimeout = 30
       'Access connection code
       DConn.Open "DBQ=" & Server.MapPath("../navservers.mdb") & ";Driver={Microsoft Access Driver (*.mdb)};DriverId=25;MaxBufferSize=8192;Threads=20;"
       Set cmdDC = Server.CreateObject("ADODB.Command")
       cmdDC.ActiveConnection = DConn
       cmdDC.CommandText = sqlQuery
       cmdDC.CommandType = 1
       ' Create recordset and retrieve values using command object
       Set rsDC = Server.CreateObject("ADODB.Recordset")
       ' Opening record set with a forward-only cursor (the 0) and in read-only mode (the 1)
       rsDC.Open cmdDC, , 0, 1
   Case 2
        Session.TimeOut = 1
        Server.ScriptTimeout = 1800
        Session("TimeOutChk") = "Y" 
        Set rsDC = Server.CreateObject("ADODB.Recordset")
		Set rsDC = Session("rs")
        STime = Time
        rsDC.open(SQLQuery)
        ETime = Time
	end select
%>
<!--This is the description page-->
<TABLE>
<table border="0" width="100%" align="center">
  <tr>
     <td bgcolor="#4889A2" width="100%" height="40"><center><font face="Verdana" color="ffffff">
	 <B>Details for <%= strCriteria %></B><BR></font></center></b>
     </td>
  </tr>
</table>

<table border="0" width="50%" cellpadding="0" cellspacing="0">
<!--Get and display stuff-->

<% SQLD = "SELECT seq_no, text_80_desc FROM irma06_elmt_desc WHERE elmt_dict_nme='" & Request.QueryString("Col1") & "' and elmt_stat_cd='" & Request.QueryString("Col3") & "' order by seq_no " %>

<%    rs.open(SQLD) %>


<br>
<br>
<b><font size=2><font face="arial">  Description:</b> 

<% Do While Not rs.EOF%>

<table border="0" width="100%" cellpadding="0" cellspacing="0">
     <td nowrap align="left">
      <font size=2><font face="arial">  
      <%=rs.Fields(1).Value %>
     </td>
      <% rs.movenext %>

<%Loop%> 

</table>
<P><b>Table Details For: <%=Request.QueryString("Col0")%></b></P>             

<! DISPLAY TABLE DESCRIPTION -------------------------------

<% SQLD = "SELECT seq_no, text_80_desc FROM irma02_table_desc" %> 
<% SQLD = SQLD & " WHERE tbl_nme='" & Request.QueryString("Col0") & "' " %> 
<% SQLD = SQLD & " and tbl_stat_cd='" & Request.QueryString("Col1") & "' order by seq_no " %>
<!<%=SQLD%>


<% SQLT = "SELECT tbl_nme, tbl_stat_cd from irma03_table_elmt"%>
<% SQLT = SQLT & " WHERE elmt_dict_nme='" & Request.QueryString("Col1") & "'"%>
<!<% SQLT = SQLT & " and elmt_stat_cd='" & Request.QueryString("Col3") & "'"%>
<!<% SQLT = SQLT & " and elmt_vrsn_no='" & Request.QueryString("Col4") & "'" %>
<% SQLT = SQLT & " order by tbl_nme" %>

<%    rs.open(SQLT) %>
<br>
<% Do While Not rs.EOF%>

<table border="0" cellpadding="0" cellspacing="0">
     <tr>
       <td nowrap align="left">
         <font size=2><font face="arial">  
         <%=rs.Fields(0).Value%>&nbsp 
       </td>
       <td nowrap align="left">
         <%=rs.Fields(1).Value%>
       </td>
      <% rs.movenext %>
     </tr>
<%Loop%> 

</table>

<%
' Close Data Access Objects and free DB variables
   'extra clean up for access data source
	If iDataSrc = 1 then
		Set cmdDC = Nothing
        DConn.Close
		Set DConn = Nothing
	End if

    rsDC.Close
    Session("TimeOutChk") = "N"
    Session.timeout = 20
    Server.scripttimeout = 90
%>