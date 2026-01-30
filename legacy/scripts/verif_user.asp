<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Dim strEvent
Dim strHeaderMsg
Dim strViewMsg
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
strLstChngUId = Session("UserID")
strLstChngUid = strCreateUid
strLstChngTs = CreateTS()
strCreateTS = CreateTS()

sqlQuery = "Select * from irma15_user"
sqlQuery = sqlQuery & " Where UID = '" & strUserId & "'"
sqlQuery = sqlQuery & " AND user_auth_cd = '" & strUserAuth & "'"
If rs.State=1 then
   rs.close
End If
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
   strHeaderMsg = "<Center>User already exists"
   strAddNewMsg = "<a Href=add_user.asp>Create another user</A>"
   rs.Close   
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
If rs.State=1 then
   rs.close
End If
rs.open(sqlQuery)           'Open the record set
If InStr(1,strUserLName,"!") Then
   strUserLName = Replace(strUserLname,"!","'")
End If
strHeaderMsg = "User name " & strUserFName & " " & strUserLName & _
               " with login id " & strUserId & " " & "and " & _
               strUserAuth & " was created on " & strCreateTS & _ 
               " By " & strCreateUId & "." & chr(13)
strAddNewMsg = "<a Href=add_user.asp>Create another user</A>"
End If

Case "Update"
Dim strOldId
Set rs = Session("rs")
strOldId = UCASE(TRIM(Request.QueryString("OldId")))
strUserId = UCASE(TRIM(Request.QueryString("UserId")))
strUserAuth = UCASE(TRIM(Request.QueryString("UserAuth")))
strUserFName = UCASE(TRIM(Request.QueryString("UserFName")))
strUserLName = UCASE(TRIM(Request.QueryString("UserLName")))
strLstChngUId = Session("UserID")
strLstChngTS = CreateTS()

sqlQuery = "UPDATE irma15_user SET"
sqlQuery = sqlQuery & " uid = '" & strUserId & "',"
sqlQuery = sqlQuery & " empl_1st_nme  = '" & strUserFName & "',"
sqlQuery = sqlQuery & " empl_lst_nme  = '" & strUserLName & "',"
sqlQuery = sqlQuery & " lst_chng_ts = '" & strlstChngTs & "',"
sqlQuery = sqlQuery & " lst_chng_uid = '" & strlstChngUId & "'"
sqlQuery = sqlQuery & " WHERE uid = '" & strOldId & "'"
sqlQuery = sqlQuery & " AND user_auth_cd = '" & strUserAuth & "'"
If rs.State=1 then
   rs.close
End If
rs.open(sqlQuery)           'Open the record set
If InStr(1,strUserLName,"!") Then
   strUserLName = Replace(strUserLname,"!","'")
End If
strHeaderMsg = "User name " & strUserFName & " " & strUserLName & _
               " with login id " & strUserId & " " & "and authority " & _
               strUserAuth & " was updated " & strLstChngTS & _ 
               " By " & strLstChngUId & "." & chr(13)
strAddNewMsg = "<a Href=add_user.asp>Back to users</A>"

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
If rs.State=1 then
   rs.close
End If
rs.open(sqlQuery)           'Open the record set
If InStr(1,strUserLName,"!") Then
   strUserLName = Replace(strUserLname,"!","'")
End If
strHeaderMsg = "User name " & strUserFName & " " & strUserLName & _
               " with login id " & strUserId & " " & "and authority " & _
               strUserAuth & " was deleted at " & strLstChngTS & _ 
               " By " & strLstChngUId & "." & chr(13)
strAddNewMsg = "<a Href=add_user.asp>Back to users</A>"

End Select
%>
<HTML>
<HEAD>
<TITLE>Display User Details
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->
<!--Header table -->
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
