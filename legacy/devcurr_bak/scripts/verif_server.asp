<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Session.Timeout = 60
Dim strEvent
strEvent = Request.QueryString("Event")

Select Case strEvent
Case "Add"
Set rs = Session("rs")
strServerName = UCASE(TRIM(Request.QueryString("ServerName")))
strServerOs = UCASE(TRIM(Request.QueryString("ServerOs")))
strServerOSVer = UCASE(TRIM(Request.QueryString("ServerOSVer")))
strServerLoc = UCASE(TRIM(Request.QueryString("ServerLoc")))
strServerDesc = JOIN(SPLIT(Request.QueryString("ServerDesc"),"*"))
strCreateUId = Session("UserID")
strLstChngUId = Session("UserId")
strLstChngTs = CreateTS()
strCreateTS = CreateTS()

sqlQuery = "SELECT * FROM irma12_srvr"
sqlQuery = sqlQuery & " WHERE srvr_nme = '" & strServerName & "'"
If rs.state = 1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
   strServerName = rs.Fields(0)
   rs.Close   
   response.redirect("add_server.asp?From=GetServer&ServerName=" & strServername)
Else
rs.Close
sqlQuery = "INSERT INTO irma12_srvr Values ("
sqlQuery = sqlQuery & "'" & strServerName & "' ,"
sqlQuery = sqlQuery & "'" & strServerOs & "' ,"
sqlQuery = sqlQuery & "'" & strServerOsVer & "' ,"
sqlQuery = sqlQuery & "'" & strServerLoc & "' ,"
sqlQuery = sqlQuery & "'" & strServerDesc & "' ,"
sqlQuery = sqlQuery & "'" & strCreateUId & "' ,"
sqlQuery = sqlQuery & "'" & strLstChngUId & "' ,"
sqlQuery = sqlQuery & "'" & strLstChngTS & "' ,"
sqlQuery = sqlQuery & "'" & strCreateTS & "')"
If rs.state =1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
strHeaderMsg = "Server " & strServerName & "<br>" & _
               " with the operating system " & strServerOS & " Version " & strServerOsVer & "<br>" & _
               " located at " & strServerLoc & "<br>" & _
               " was created on " & strCreateTS & "<br>" & _ 
               " By " & strCreateUId & "."
strAddNewMsg = "<a Href=" & "add_server.asp" & ">Add another server</A>"
End If

Case "Update"
Dim strOldSeverName
Set rs = Session("rs")
strOldServerName = UCASE(TRIM(Request.QueryString("OldServerName")))
strServerName = UCASE(TRIM(Request.QueryString("ServerName")))
strServerOs = UCASE(TRIM(Request.QueryString("ServerOs")))
strServerOSVer = UCASE(TRIM(Request.QueryString("ServerOSVer")))
strServerLoc = UCASE(TRIM(Request.QueryString("ServerLoc")))
strServerDesc = JOIN(SPLIT(Request.QueryString("ServerDesc"),"*"))
strLstChngUId = Session("UserID")
strLstChngTs = CreateTS()

sqlQuery = "UPDATE irma12_srvr SET "
sqlQuery = sqlQuery & " srvr_nme = '" & strServerName & "',"
sqlQuery = sqlQuery & " srvr_os_nme = '" & strServerOs & "',"
sqlQuery = sqlQuery & " srvr_os_vrsn_no = '" & strServerOsVer & "',"
sqlQuery = sqlQuery & " cmpny_loc_abbr = '" & strServerLoc & "',"
sqlQuery = sqlQuery & " text_160_desc = '" & strServerDesc & "',"
sqlQuery = sqlQuery & " lst_chng_uid = '" & strLstChngUId & "',"
sqlQuery = sqlQuery & " lst_chng_ts = '" & strLstChngTS & "'"
sqlQuery = sqlQuery & " WHERE srvr_nme = '" & strOldServerName & "'"
If rs.state = 1 then
    rs.Close
End If
rs.open(sqlQuery)           'Open the record set
strHeaderMsg = "Server " & strServerName & "<br>" & _
               " with the operating system " & strServerOS & " Version " & strServerOsVer & "<br>" & _
               " located at " & strServerLoc & "<br>" & _
               " was updated on " & strCreateTS & "<br>" & _ 
               " By " & strLstChngUId & "."
strAddNewMsg = "<a Href=" & "add_server.asp" & ">Edit another server</A>"

Case "Delete"
Set rs = Session("rs")

strServerName = UCASE(TRIM(Request.QueryString("ServerName")))
strLstChngUId = Session("UserID")
strLstChngTs = CreateTS()

sqlQuery = "DELETE FROM irma12_srvr "
sqlQuery = sqlQuery & " WHERE srvr_nme = '" & strServerName & "'"
If rs.state = 1 then
    rs.Close
End If
rs.open(sqlQuery)           'Open the record set
strHeaderMsg = "Server " & strServerName & "<br>" & _
               " with the operating system " & strServerOS & " Version " & strServerOsVer & "<br>" & _
               " located at " & strServerLoc & "<br>" & _
               " was deleted on " & strCreateTS & "<br>" & _ 
               " By " & strLstChngUId & "."
strAddNewMsg = "<a Href=" & "add_server.asp" & ">Delete another server</A>"

Case "Edit"
Set rs = Session("rs")
strServerName = UCASE(TRIM(Request.QueryString("ServerName")))

sqlQuery = "SELECT * FROM irma12_srvr "
sqlQuery = sqlQuery & " WHERE srvr_nme = '" & strServerName & "'"
If rs.state = 1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
   strServerName = rs.Fields(0)
   rs.Close   
   response.redirect("add_server.asp?From=GetServer&ServerName=" & strServerName)
Else
strHeaderMsg = "The server name you entered " & strServerName & "<br>" & _
               " Does not exist.  Please check your spelling."
strAddNewMsg = "<a Href=" & "add_server.asp" & ">Add another server</A>"
End If

End Select
%>
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
