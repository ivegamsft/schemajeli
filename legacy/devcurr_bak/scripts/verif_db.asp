<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Session.Timeout = 60
Dim sqlQuery
Dim sqlCheckExists
Dim strAddNewMsg
Dim strHeaderMsg
Dim strViewMsg
Dim bError
Dim strQString
Dim strDbBName
Dim strDBName
Dim strDbStatus
Dim strDbDesc
Dim strLastChngUID
Dim strLastChngTS
Dim strCreateTS
Dim strCreateUID
Dim strServerName
Dim strRDBMS
Dim strRDBMSVer
Dim strFrom
Dim strEvent
Dim con
Dim rs

Set con=Session("Con")
Set rs=Session("rs")
strEvent = Request.Form("Event")
bError = False
'------------------------------------------Case start adding to db
Select Case strEvent

Case "Add"
Dim sqlAddDb
Dim sqlAddDbServer
strDbBName = UCASE(Request.Form("DbBName"))
strDbName = UCASE(Request.Form("DbName"))
strDbStatus = UCASE(Request.Form("DbStatus"))
strDbDesc = Request.Form("DbDesc")
strLastChngUID = UCASE(Session("UserId"))
strLastChngTS = CreateTS()
strCreateUID = UCASE(Session("UserId"))
strCreateTS = CreateTS()
strServerName =  UCASE(Request.Form("Server"))
strRDBMS =  UCASE(Request.Form("RDBMS"))
strRDBMSVer =  Request.Form("RDBMSVer")
sqlCheckExists = "SELECT * from irma13_db_srvr "
sqlCheckExists = sqlCheckExists & " WHERE  db_nme = '" & strDbName & "'"
sqlCheckExists = sqlCheckExists & " AND db_stat_cd = '" & strDbStatus & "'"
'sqlCheckExists = sqlCheckExists & " AND srvr_nme = '" & strServerName & "'"
If rs.State = 1 then
   rs.Close
End If
rs.Open(sqlCheckExists)
If NOT rs.BOF = -1 then
    strQString = "query_result.asp?RelObject=Database&Criteria=" & strDbName
    Response.Redirect strQString
End If

sqlAddDB = "INSERT INTO irma11_db VALUES ("
sqlAddDB = sqlAddDB & "'" & strDbName & "', "
sqlAddDB = sqlAddDB & "'" & strDbStatus & "', "
sqlAddDB = sqlAddDB & "'" & strRDBMS & "', "
sqlAddDB = sqlAddDB & "'" & strRDBMSVer & "', "
sqlAddDB = sqlAddDB & "'" & strDbDesc & "', "
sqlAddDB = sqlAddDB & "'" & strCreateUID & "', "
sqlAddDB = sqlAddDB & "'" & strLastChngUID & "', "
sqlAddDB = sqlAddDB & "'" & strLastChngTS & "', "
sqlAddDB = sqlAddDB & "'" & strCreateTS & "', "
sqlAddDB = sqlAddDB & "'" & strDbBName & "') "

sqlAddDbServer = "INSERT INTO irma13_db_srvr VALUES ("
sqlAddDbServer = sqlAddDbServer & "'" & strServerName & "', "
sqlAddDbServer = sqlAddDbServer & "'" & strDbName & "', "
sqlAddDbServer = sqlAddDbServer & "'" & strDbStatus & "', "
sqlAddDbServer = sqlAddDbServer & "'" & strCreateUID & "', "
sqlAddDbServer = sqlAddDbServer & "'" & strLastChngUID & "', "
sqlAddDbServer = sqlAddDbServer & "'" & strLastChngTS & "', "
sqlAddDbServer = sqlAddDbServer & "'" & strCreateTS & "') "

'Response.write sqladddb & "<br>-----" & sqladddbserver
'response.end
'  con.Rollbacktrans
con.BeginTrans
  con.Execute sqlAddDB,1,1
  con.Execute sqlAddDBServer,1,1
con.CommitTrans
strHeaderMsg = strDbName & " was sucessfully added.<br>"
strAddNewMsg = "<A HREF=add_db_nme.asp>Add another</A>"
strViewMsg = "<A HREF=add_db_nme.asp?From=Query&DbName=" & strDbName & "&Status=" & strDbStatus & "&Server=" & strServerName & ">View the database you just addeed</A>"
'---------------------------------Update from an existing database
Case "Update"
Dim sqlUpdateDb
Dim sqlUpdateDbServer
Dim strOldDbName
Dim strOldDbBName
Dim strOldServerName

strDbBName = UCASE(Request.Form("DbBName"))
strDbName = UCASE(Request.Form("DbName"))
strOldDbName = UCASE(Request.Form("OldDbName"))
strDbStatus = UCASE(Request.Form("DbStatus"))
strDbDesc = Request.Form("DbDesc")
strLastChngUID = UCASE(TRIM(Session("UserId")))
strLastChngTS = CreateTS
strOldServerName = UCASE(Request.Form("OldServerName"))
strServerName =  UCASE(Request.Form("Server"))
strRDBMS =  UCASE(Request.Form("RDBMS"))
strRDBMSVer =  Request.Form("RDBMSVer")
'Check to see if the database exists
sqlCheckExists = "SELECT * from irma13_db_srvr "
sqlCheckExists = sqlCheckExists & " WHERE db_nme = '" & strOldDbName & "'"
sqlCheckExists = sqlCheckExists & " AND db_stat_cd = '" & strDbStatus & "'"
sqlCheckExists = sqlCheckExists & " AND srvr_nme = '" & strOldServerName & "'"
If rs.State = 1 then
   rs.Close
End If
rs.Open sqlCheckExists
If rs.BOF = -1 then
    bError = True
    strHeaderMsg = strOldDbName & " was not found.<br>Please check your spelling.<br>"
    strAddNewMsg = "<A HREF=add_db_nme.asp>Add another</A>"
    strViewMsg = ""
End IF
rs.Close
If Not bError then
sqlUpdateDb = "UPDATE irma11_db SET "
sqlUpdateDb = sqlUpdateDb & "db_nme= '" & strDbName & "', "
sqlUpdateDb = sqlUpdateDb & "rdbms_nme= '" & strRDBMS & "', "
sqlUpdateDb = sqlUpdateDb & "rdbms_vrsn_no= '" & strRDBMSVer & "', "
sqlUpdateDb = sqlUpdateDb & "text_160_desc= '" & strDbDesc & "', "
sqlUpdateDb = sqlUpdateDb & "lst_chng_uid= '" & strLastChngUID & "', "
sqlUpdateDb = sqlUpdateDb & "lst_chng_ts= '" & strLastChngTS & "', "
sqlUpdateDb = sqlUpdateDb & "db_busns_nme= '" & strDbBName & "' "
sqlUpdateDb = sqlUpdateDb & "WHERE db_nme= '" & strOldDbName & "' "
sqlUpdateDb = sqlUpdateDb & "AND db_stat_cd= '" & strDbStatus & "' "

'con.RollBackTrans
'response.end
con.BeginTrans
   con.Execute sqlUpdateDb,1,1
   If con.Errors.Count <> 0 Then
      con.RollBackTrans
   Else
      con.CommitTrans
   End If

'response.write sqlUpdateDb & "<br>-------"
'response.write sqlUpdateDbServer & "<br>-------"
'Response.End
    strHeaderMsg = strDbName & " was sucessfully updated."
    strAddNewMsg = "<A HREF=add_db_nme.asp>Add another</A>"
strViewMsg = "<A HREF=add_db_nme.asp?From=Query&DbName=" & strDbName & "&Status=" & strDbStatus & "&Server=" & strServerName & ">View the database you just updated</A>"
End IF
'-----------------------------------Case to delete Db
Case "Delete"
Dim sqlDeleteDb
Dim sqlDeleteDbDesc
Dim sqlDeleteDbVer

strDbName = UCASE(TRIM(Request.Form("DbName")))
strDbStatus = UCASE(TRIM(Request.Form("DbStatus")))

sqlCheckExists= "SELECT db_nme FROM irma11_db "
sqlCheckExists=sqlCheckExists & " WHERE  db_nme = '" & strDbName & "'"
sqlCheckExists=sqlCheckExists & " AND db_stat_cd = '" & strDbStatus & "'"
'response.write sqlCheckexists
'response.end
If rs.State=1 then
   rs.Close
End If
rs.Open sqlCheckExists
If rs.BOF = -1 then
    bError = True
    strHeaderMsg = strDbName & " was not found.<br>Please check your spelling.<br>"
    strAddNewMsg = "<A HREF=add_db_nme.asp>Add another</A>"
    strViewMsg = ""
End If
rs.Close

sqlDeleteDb = "DELETE FROM irma11_Db "
sqlDeleteDb = sqlDeleteDb & " WHERE db_nme= '" & strDbName & "' "
sqlDeleteDb = sqlDeleteDb & " AND db_stat_cd= '" & strDbStatus & "' "

sqlDeleteDbServer = "DELETE FROM irma13_db_srvr "
sqlDeleteDbServer = sqlDeleteDbserver & " WHERE  db_nme= '" & strDbName & "' "
sqlDeleteDbServer = sqlDeleteDbServer & " AND db_stat_cd= '" & strDbStatus & "' "

'con.rollbacktrans
con.BeginTrans
    con.Execute sqlDeleteDb
    con.Execute sqlDeleteDbServer
con.CommitTrans
strHeaderMsg = strDbName & " was sucessfully deleted."
strAddNewMsg = "<A HREF=add_db_nme.asp>Add another</A>"
strViewMsg = ""

Case "Edit"
Set rs = Session("rs")
strDbName = UCASE(TRIM(Request.Form("DbName")))
strDbStatus = UCASE(TRIM(Request.Form("DbStatus")))

sqlQuery = "SELECT db_nme, db_stat_cd FROM irma11_db "
sqlQuery = sqlQuery & " WHERE  db_nme = '" & strDbName & "'"
sqlQuery = sqlQuery & " AND db_stat_cd = '" & strDbStatus & "'"
'Response.write sqlquery
'response.end
If rs.state = 1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
   response.redirect("query_result.asp?RelObject=Database&Criteria=" & strDbName)
Else
   response.redirect("add_db_nme.asp?From=&Error=True")
End If
rs.Close
End Select
%>

<!--Header Table-->
<HTML>
<body bgcolor="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<table border="0" width="80%" align="center" bgcolor="<%=strHeaderColor%>">
  <tr>
    <td width="100%" height="20" align="center">
<%If bError then%>
    <font face="Verdana" size="3" COLOR="<%=strErrTextColor%>"><Center><h3><%=strHeaderMsg%></H3></FONT>
<%Else%>
   <font face="Verdana" size="3"><Center><h3><%=strHeaderMsg%></H3></FONT>
<%End IF%>
	</td>
  </tr>    
</Table>
<!--Body Table -->
<table border="0" width="80%" align="center" bgcolor="<%=strBackColor%>">
<tr>
   <td align="center">
    <font face="Verdana" size="3"><%=strAddNewMsg%></a></FONT>
    </TD>
 </tr>
 <tr>
   <td align="center">
   <font face="Verdana" size="3"><%=strViewMsg%></font>
 </TR>
</table>
</BODY>
</HTML>
