<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/naming.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<%'<!--#INCLUDE FILE="../include/security.inc"-->
Dim strEvent
strEvent = Request.QueryString("Event")
'response.write strevent
'   Response.End
Select Case strEvent

Case "Add"
Set rs = Session("rs")
strUserId = UCASE(TRIM(Request.QueryString("UserId")))
strUserAuth = UCASE(TRIM(Request.QueryString("UserAuth")))
strUserFName = UCASE(TRIM(Request.QueryString("UserFName")))
strUserLName = UCASE(TRIM(Request.QueryString("UserLName")))
strCreateUId = Session("UserID")
strLstChngUId = UCASE(TRIM(Request.QueryString("LstChngUId")))
If strLstChngUid = "" Then
   strLstChngUid = strCreateUid
End If
strLstChngTS = UCASE(TRIM(Request.QueryString("LstChngTS")))
If strLstChngTS = "" Then
   strLstChngTs = TimeStamp()
End If
strCreateTS = UCASE(TRIM(Request.QueryString("CreateTs")))

sqlQuery = "Select * from irma15_user"
sqlQuery = sqlQuery & " Where UID = '" & strUserId & "'"
sqlQuery = sqlQuery & " AND user_auth_cd = '" & strUserAuth & "'"
'rs.Close                   'Debugging
'response.Write sqlQuery
'response.end
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
   Response.Write("<Center><H2>User already exists</H2>")
   Response.Write("<BR>")
   Response.Write("<a Href=" & "add_user.asp" & ">Create another user</A></CENTER>")
   rs.Close   
   Response.End
Else
rs.Close
sqlQuery = "INSERT INTO irma15_user Values ("
sqlQuery = sqlQuery & "'" & strUserId & "' ,"
sqlQuery = sqlQuery & "'" & strUserAuth & "' ,"
sqlQuery = sqlQuery & "'" & strUserFName & "' ,"
sqlQuery = sqlQuery & "'" & strUserLName & "' ,"
sqlQuery = sqlQuery & "'" & strCreateUId & "' ,"
sqlQuery = sqlQuery & "'" & strLstChngUId & "' ,"
sqlQuery = sqlQuery & "'" & strLstChngTS & "' ,"
sqlQuery = sqlQuery & "'" & strCreateTS & "')"

'rs.Close                   'Debugging
'response.Write sqlQuery
'response.end
rs.open(sqlQuery)           'Open the record set
Response.Write ("<Center><H2>User name " & strUserFName & " " & strUserLName & _
               " with login id " & strUserId & " " & "and " & _
               strUserAuth & " was be created on " & strCreateTS & _ 
               " By " & strCreateUId & "." & chr(13))
Response.Write ("</H2><br>")
Response.Write ("<a Href=" & "add_user.asp" & "><H2>Create another user</H2></A></CENTER>")
End If

Case "Update"
Dim strOldId
Set rs = Session("rs")
strOldId = UCASE(TRIM(Request.QueryString("OldId")))
strUserId = UCASE(TRIM(Request.QueryString("UserId")))
strUserAuth = UCASE(TRIM(Request.QueryString("UserAuth")))
strUserFName = UCASE(TRIM(Request.QueryString("UserFName")))
strUserLName = UCASE(TRIM(Request.QueryString("UserLName")))
strLstChngUId = UCASE(TRIM(Request.QueryString("LstChngUId")))
strLstChngTS = timestamp()

sqlQuery = "UPDATE irma15_user SET"
sqlQuery = sqlQuery & " uid = '" & strUserId & "',"
sqlQuery = sqlQuery & " empl_1st_nme  = '" & strUserFName & "',"
sqlQuery = sqlQuery & " empl_lst_nme  = '" & strUserLName & "',"
sqlQuery = sqlQuery & " lst_chng_ts = '" & strlstChngTs & "',"
sqlQuery = sqlQuery & " lst_chng_uid = '" & strlstChngUId & "'"
sqlQuery = sqlQuery & " WHERE uid = '" & strOldId & "'"
sqlQuery = sqlQuery & " AND user_auth_cd = '" & strUserAuth & "'"
'rs.Close                   'Debugging
'response.Write sqlQuery
'response.end
rs.open(sqlQuery)           'Open the record set
Response.Write ("<CENTER><H2>User name " & strUserFName & " " & strUserLName & _
               " with login id " & strUserId & " " & "and authority " & _
               strUserAuth & " was updated " & strCreateTS & _ 
               " By " & strCreateUId & "." & chr(13))
Response.Write ("</H2><br>")
Response.Write ("<a Href=" & "add_user.asp" & "><H2>Back to users</H2></A></CENTER>")

Case "Delete"
Set rs = Session("rs")
strUserId = UCASE(TRIM(Request.QueryString("UserId")))
strUserAuth = UCASE(TRIM(Request.QueryString("UserAuth")))
strUserFName = UCASE(TRIM(Request.QueryString("UserFName")))
strUserLName = UCASE(TRIM(Request.QueryString("UserLName")))
strCreateUId = UCASE(TRIM(Request.QueryString("CreateUId")))

sqlQuery = "DELETE FROM irma15_user"
sqlQuery = sqlQuery & " WHERE uid = '" & strUserId & "'"
sqlQuery = sqlQuery & " AND user_auth_cd = '" & strUserAuth & "'"
'rs.Close                   'Debugging
'response.Write sqlQuery
'response.end
rs.open(sqlQuery)           'Open the record set
Response.Write ("<Center><H2>User name " & strUserFName & " " & strUserLName & _
               " with login id " & strUserId & " " & "and authority " & _
               strUserAuth & " was deleted at " & strCreateTS & _ 
               " By " & strCreateUId & "." & chr(13))
Response.Write ("</H2><br>")
Response.Write ("<a Href=" & "add_user.asp" & "><H2>Back to users</H2></A></center>")

End Select
%>