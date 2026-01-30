<% Response.Buffer = true %>
<%
Dim DConn
Dim cmdDC
Dim rsDC
Dim Item
Dim strRelObject
Dim strObjName
Dim sqlQuery
Dim iFieldCount, iLoopVar
Dim BackColor
Dim TextColor
Dim HeaderCount
Dim Header(5)
Dim iRows
' Retrieve QueryString Variables and convert them to a usable form
strRelObject = Request.QueryString("RelObject")

Select Case strRelObject
	Case "Servers"
		strCriteria = Request.Form("ObjName")
		sqlQuery = "SELECT tblSrvr_Db_Tbl.db_Nme, tblSrvr_Db_Tbl.tbl_Nme" 
		sqlQuery = sqlQuery & " FROM tblSrvr_Db_Tbl" 
 		sqlQuery = sqlQuery & " WHERE tblSrvr_Db_Tbl.srvr_nme ='" & strCriteria & "'"
		HeaderCount = 2
		Header(0)="Database Name"
		Header(1)="Table Name"
	Case "Databases"
		strCriteria = Request.Form("ObjName")
		sqlQuery = "SELECT tblSrvrs_Dbs.srvr_nme, tblSrvrs_Dbs.db_nme"
        sqlQuery = sqlQuery & " FROM tblSrvrs_Dbs INNER JOIN tblAll_Srvrs ON tblSrvrs_Dbs.srvr_nme = tblAll_Srvrs.srvr_nme"
		sqlQuery = sqlQuery & " WHERE tblSrvrs_Dbs.srvr_Plat = '" & strCriteria & "'"
        HeaderCount = 2
		Header(0) = "Server Name"
		Header(1) = "Database Name"
	Case "Tables"
        strCriteria = Request.Form("ObjName")
		sqlQuery = "SELECT yzdbdat_irma01_table.tbl_nme, yzdbdat_irma01_table.tbl_stat_cd, yzdbdat_irma03_table_elmt.elmt_dict_nme" 
		sqlQuery = sqlQuery & " FROM yzdbdat_irma03_table_elmt INNER JOIN (tblSrvr_Db_Tbl INNER JOIN yzdbdat_irma01_table ON tblSrvr_Db_Tbl.tbl_Nme = yzdbdat_irma01_table.tbl_nme) " 
		sqlQuery = sqlQuery & " ON (yzdbdat_irma03_table_elmt.tbl_stat_cd = yzdbdat_irma01_table.tbl_stat_cd) AND (yzdbdat_irma03_table_elmt.tbl_nme = yzdbdat_irma01_table.tbl_nme)"
 		sqlQuery = sqlQuery & " WHERE tblSrvr_Db_Tbl.db_Nme ='" & strCriteria & "'"
		HeaderCount = 3
		Header(0)="Table Name"
		Header(1)="Status"
		Header(2)="Element Name"

	Case "Elements"
		strCriteria = Request.Form("ObjName")
		sqlQuery = "SELECT tblSrvr_Db_Tbl.db_Nme, tblSrvr_Db_Tbl.tbl_Nme" 
		sqlQuery = sqlQuery & " FROM tblSrvr_Db_Tbl" 
 		sqlQuery = sqlQuery & " WHERE tblSrvr_Db_Tbl.srvr_nme ='" & strCriteria & "'"
		HeaderCount = 2
		Header(0)="Database Name"
		Header(1)="Table Name"
End Select
'Response.Write(strCriteria) 'for debugging sql
'Response.Write(sqlQuery) 'for debugging sql
'Response.Write(Request.Form("ObjName"))
'Response.End

' Create and establish data connection
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
%>
<TABLE>
<table border="0" width="100%" align="center">
  <tr>
     <td bgcolor="#4889A2" width="100%" height="40"><center><font face="Verdana" color="ffffff">
	 <B>Browsing <%= strCriteria %></B><BR></font></center></b>
     </td>
  </tr>
</table>

<TABLE>
<!--Check for proper headers-->
<table border="0" width="100%" align="center">
	<THEAD bgcolor="#C0C0C0">
		<% For iLoopvar = 0 to HeaderCount -1 %>
		<TH><%= Header(iLoopVar) %></TH>
        <% Next %>
	</THEAD>
<%
' Loop through recordset and display results
If Not rsDC.EOF Then rsDC.MoveFirst

' Get the number of fields and subtract one so our loops start at 0
iFieldCount = rsDC.Fields.Count - 1
BackColor="#C0C0C0"
TextColor="#000000"
iRows=0
' Continue till we get to the end, and while in each <TR> loop through fields
Do While Not rsDC.EOF
	If BackColor="#ffffff" Then 
		   BackColor="#C0C0C0"
		   TextColor="#000000"
	    Else
		   BackColor="#ffffff"
		   TextColor="#000000"
		End If%>
   <TR bgcolor="<%= BackColor %>"> 
	    <% For iLoopVar = 0 to iFieldCount%>
		<TD width="50%" border="0"><FONT FACE="Verdana" color="<%=TextColor %>"><%= rsDC.Fields(iLoopVar)%></td>
<%       Next 
         rsDC.MoveNext
		 iRows = iRows + 1
         If iRows = 5 OR rsDC.EOF Then
            Response.Flush
        end if 
%>
</FONT>
</tr>
<%
Loop
If BackColor="#ffffff" Then 
		   BackColor="#C0C0C0"
		   TextColor="#000000"
	    Else
		   BackColor="#ffffff"
		   TextColor="#000000"
		End If
%>

<TR ALIGN="center" bgcolor="<%= BackColor %>">
   <TD Colspan="<%=HeaderCount%>"><FONT FACE="Verdana" color="<%=TextColor %>"><b>End of Report - <%=iRows%> Total</b>
     </FONT>
   </TD>
</TR>
</TABLE>

<%
' Close Data Access Objects and free DB variables
	rsDC.Close
	Set rsDC =  Nothing
	' can't do a "cmdDC.Close" !
	Set cmdDC = Nothing
	DConn.Close
	Set DConn = Nothing
%>