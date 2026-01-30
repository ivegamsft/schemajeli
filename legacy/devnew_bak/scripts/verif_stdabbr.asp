<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Session.Timeout = 60
Dim strEvent
strEvent = Request.QueryString("Event")
'response.write strevent
'   Response.End
Select Case strEvent

Case "Add"
Set rs = Session("rs")
strStdAbbr = UCASE(TRIM(Request.QueryString("StdAbbr")))
strStdAbbrSrc = UCASE(TRIM(Request.QueryString("StdAbbrSrc")))
strClassWord = UCASE(TRIM(Request.QueryString("ClassWord")))
strCreateUId = Session("UserID")
strLstChngUId = UCASE(TRIM(Request.QueryString("LstChngUId")))
strLstChngUid = strCreateUid
strLstChngTs = CreateTS()
strCreateTS = CreateTS()

sqlQuery = "SELECT * FROM irma10_std_abbr"
sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & strStdAbbrSrc & "'"
If rs.state = 1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
   strStdAbbrSrc = rs.Fields(0)
   rs.Close   
   response.redirect("add_stdAbbr.asp?From=GetAbbr&StdAbbr=" & strStdAbbrSrc)
Else
rs.Close
sqlQuery = "INSERT INTO irma10_std_abbr Values ("
sqlQuery = sqlQuery & "'" & strStdAbbrSrc & "' ,"
sqlQuery = sqlQuery & "'" & strStdAbbr & "' ,"
sqlQuery = sqlQuery & "'" & strClassword & "' ,"
sqlQuery = sqlQuery & "'' ,"
sqlQuery = sqlQuery & "'" & strCreateUId & "' ,"
sqlQuery = sqlQuery & "'" & strLstChngUId & "' ,"
sqlQuery = sqlQuery & "'" & strLstChngTS & "' ,"
sqlQuery = sqlQuery & "'" & strCreateTS & "')"
If rs.state =1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
strHeaderMsg = "Standard abbreviation source name " & strStdAbbrSrc & "<br>" & _
               " with the abbreviation " & strStdAbbr & "<br>" & _
               " and class word flag as " & strClassWord & "<br>" & _
               " was created on " & strCreateTS & "<br>" & _ 
               " By " & strCreateUId
strAddNewMsg = "<a Href=" & "add_stdabbr.asp" & ">Add another standard abbreviation</A>"
End If

Case "Update"
Dim strOldId
Set rs = Session("rs")
strOldStdAbbrSrc = UCASE(TRIM(Request.QueryString("OldStdAbbrSrc")))
strStdAbbrSrc = UCASE(TRIM(Request.QueryString("StdAbbrSrc")))
strStdAbbr = UCASE(TRIM(Request.QueryString("StdAbbr")))
strClassWord = UCASE(TRIM(Request.QueryString("ClassWord")))
strLstChngUId =Session("UserID")
strLstChngTS = CreateTS()

sqlQuery = "UPDATE irma10_std_abbr SET "
sqlQuery = sqlQuery & " std_abbr_srce_nme = '" & strStdAbbrSrc & "',"
sqlQuery = sqlQuery & " std_abbr_nme = '" & strStdAbbr & "',"
sqlQuery = sqlQuery & " clas_word_i = '" & strClassword & "',"
sqlQuery = sqlQuery & " err_i = '',"
sqlQuery = sqlQuery & " lst_chng_user_id = '" & strLstChngUId & "',"
sqlQuery = sqlQuery & " lst_chng_ts = '" & strLstChngTS & "'"
sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & strOldStdAbbrSrc & "'"
If rs.state = 1 then
    rs.Close
End If
rs.open(sqlQuery)           'Open the record set
strHeaderMsg = "The standard abbreviation source name " & strStdAbbrSrc & "<br>" & _
               " with the abbreviation " & strStdAbbr & "<br>" & _
               " and class word flag as " & strClassWord & "<br>" & _
               " was updated on " & strLstChngTS & "<br>" & _ 
               " By " & strLstChngUId & "."
strAddNewMsg = "<a Href=" & "add_stdabbr.asp" & ">Add another standard abbreviation</A>"

Case "Delete"
Set rs = Session("rs")
strLstChngUId = Session("UserID")
strLstChngTs = CreateTS()
strStdAbbr = UCASE(TRIM(Request.QueryString("StdAbbr")))
strStdAbbrSrc = UCASE(TRIM(Request.QueryString("StdAbbrSrc")))

sqlQuery = "DELETE FROM irma10_std_abbr "
sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & strStdAbbrSrc & "'"
If rs.state = 1 then
    rs.Close
End If
rs.open(sqlQuery)           'Open the record set
strHeaderMsg = "The standard abbreviation source name " & strStdAbbrSrc & "<br>" & _
               " with the abbreviation " & strStdAbbr & "<br>" & _
               " was deleted on " & strLstChngTS & "<br>" & _ 
               " By " & strLstChngUId & "."
strAddNewMsg = "<a Href=" & "add_stdabbr.asp" & ">Edit another standard abbreviation</A>"

Case "Edit"
Set rs = Session("rs")
strStdAbbrSrc = UCASE(TRIM(Request.QueryString("StdAbbrSrc")))

sqlQuery = "SELECT * FROM irma10_std_abbr "
sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & strStdAbbrSrc & "'"
If rs.state = 1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
   strStdAbbrSrc = rs.Fields(0)
   rs.Close   
   response.redirect("add_stdAbbr.asp?From=GetAbbr&StdAbbr=" & strStdAbbrSrc)
Else
bError = True
strHeaderMsg = "The standard abbreviation source name " & strStdAbbrSrc & "<br>" & _
               " Does not exist.  Please check your spelling."
strAddNewMsg = "<a Href=" & "add_stdabbr.asp" & ">Edit another standard abbreviation</A>"
End If

End Select
%>
<HTML>
<HEAD>
<TITLE>Display Statndard Abbreviation
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
