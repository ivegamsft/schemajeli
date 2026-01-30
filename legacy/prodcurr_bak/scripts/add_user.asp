<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<%

Dim strCreateUId
Dim strCreateTS
Dim strLastChngUId
Dim strLastChngTS
Dim strUserId
Dim strUserLName
Dim strUserFName
Dim strFrom
Dim sqlQuery
Dim strUserAuth

strFrom = Request.QueryString("From")

Select Case strFrom
Case ""
strCreateUId = Session("USERID")
strCreateTS = CreateTS()
strLastChngUId = Session("USERID")
strLastChngTS = CreateTS()
strUserId = ""
strUserLName = ""
strUserFName =""
Set rs = Session("rs")
sqlQuery = "Select * from irma15_user"
sqlQuery = sqlQuery & " ORDER BY uid "
If rs.State = 1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set

Case "GetUser"
Dim strUser
Dim aryUser
strUser = Request.QueryString("Users")

aryUser = SPLIT(strUser,"-")
Set rs = Session("rs")
sqlQuery = "Select * from irma15_user"
sqlQuery = sqlQuery & " WHERE uid = '" & aryUser(0) & "'"
sqlQuery = sqlQuery & " AND user_auth_Cd = '" & aryUser(1) & "'"
If rs.State=1 then
   rs.close
End If
rs.open(sqlQuery)           'Open the record set
strCreateUId = TRIM(rs.Fields(4))
strCreateTS = TRIM(rs.Fields(7))
strLastChngUId = TRIM(rs.Fields(5))
strLastChngTS = TRIM(rs.Fields(6))
strUserId = TRIM(rs.Fields(0))
strUserLName = TRIM(rs.Fields(3))
strUserFName = TRIM(rs.Fields(2))
strUserAuth = TRIM(rs.fields(1))
If InStr(1,strUserLName,"!") Then
   strUserLName = Replace(strUserLName,"!","'")
End If
End Select
%>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.frmAddUser.UserId.Focus
End Sub

Sub cmdCreate_OnClick()
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)

   If objCurForm.UserId.Value="" then
         msgBox "Please enter user's logon id.",,"Error"
        objCurForm.UserId.Focus
   ElseIf objCurForm.UserAuth.SelectedIndex = 0 Then
        msgBox "Please select the user's authority.",,"Error"
        objCurForm.UserAuth.Focus
        Exit Sub
   ElseIf objCurForm.UserFName.Value="" then
        msgBox "Please enter the user's first name.",,"Error"
        objCurForm.FName.Focus
   ElseIf objCurForm.UserLName.Value="" then
        msgBox "Please enter the user's last name.",,"Error"
        objCurForm.LName.Focus
   Else
      If InStr(1,objCurForm.UserLName.Value,"'") Then
         objCurForm.UserLName.Value = Replace(objCurForm.UserLName.Value,"'","!")
      End If
      objCurForm.Submit
  End If
End Sub  

Sub cmdUpdate_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Event.Value = "Update"
   objCurForm.Submit
End Sub

Sub cmdDelete_OnClick
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Event.Value = "Delete"
   objCurForm.Submit
End Sub

Sub cmdEdit_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
If objCurForm.Users.Value = "" Then
   msgbox "Select a user to edit",,"Error"
   objCurForm.Users.Focus
   objCurForm.Users.SelectedIndex = 0
Else
   objCurForm.From.Value = "GetUser"
   objCurForm.Action = "add_user.asp"
   objCurForm.Submit
End If
End Sub     

Sub cmdCancel_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Action = "add_user.asp"
   objCurForm.From.Value = ""
   objCurForm.Submit
End Sub
</SCRIPT>
<!--Header table -->
<BODY BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE BORDER="0" WIDTH="50%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
 <TR>
    <TD ALIGN="center">
    <FONT FACE="Verdana"><B>Specify Data - User</B>
    </FONT>
    </TD>
</TR>
</TABLE>
<!--Body Table -->
<TABLE BGCOLOR="<%=strBackColor%>" border="0"  width="50%" align="center">
<FORM METHOD="GET" NAME="frmAddUser" Action="verif_user.asp">
    <INPUT TYPE="Hidden" NAME="OldId" VALUE="<%=strUserId%>">
    <INPUT TYPE="Hidden" NAME="From" VALUE="AddUser">
    <INPUT TYPE="Hidden" NAME="Event" VALUE="Add">
  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
    <B>Created By</B>
    </TD></FONT>
    <TD>
    <INPUT TYPE="Text" NAME="CreateUId" SIZE="10" VALUE="<%=strCreateUId%>" READONLY>
    </TD>
</TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
    <B>Create Date:</B></FONT>
    </TD>
    <TD>
    <INPUT TYPE="Text" NAME="CreateTS" SIZE="20" VALUE="<%=strCreateTS%>" READONLY>
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Last Modified by:</B>
    </FONT>
    </TD>
    <TD>
    <INPUT TYPE="Text" NAME="LastChngUId" SIZE="10" VALUE="<%=strLastChngUId%>" READONLY>
    </TD>
</TR>

<TR>
     <TD><FONT FACE="Verdana" SIZE="2">
	 <B>Last Modified:</B>
     </FONT>
     </TD>
     <TD>
     <INPUT TYPE="Text" NAME="LastChngTS" SIZE="20" VALUE="<%=strLastChngTS%>" READONLY>
     </TD>
</TR>

<TR>
    <TD><FONT FACE="Verdana" SIZE="2">
    <B>User Id:</B></FONT>
    </TD>
    <TD>
    <INPUT TYPE="text" NAME="UserId" VALUE="<%=strUserId%>" SIZE="20">
    </TD>
  </TR>

  <TR>
   <TD><FONT FACE="Verdana" SIZE="2"><B>Authority</B>
    </TD></FONT>
<% If strFrom = "GetUser" Then %>
    <TD>
    <INPUT TYPE="text" NAME="UserAuth" VALUE="<%=strUserAuth%>" SIZE="20" READONLY>
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2"><B>First Name</B>
    </TD></FONT>
    <TD><INPUT TYPE="text" NAME="UserFName" VALUE="<%=strUserFName%>" SIZE="20">
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2"><B>Last Name</B>
    </TD></FONT>
    <TD><INPUT TYPE="text" NAME="UserLName" VALUE="<%=strUserLName%>" SIZE="20">
    </TD>
  </TR>
  <TR>
    <TD COLSPAN="2" ALIGN="center">
    <INPUT TYPE="button" VALUE="Update" NAME="cmdUpdate">&nbsp;
    <INPUT TYPE="button" VALUE="Delete" NAME="cmdDelete">&nbsp;
    <INPUT TYPE="reset" VALUE="Cancel" NAME="cmdCancel">&nbsp;
    </TD>
  </TR>  
<%Else %>
    <TD><SELECT NAME="UserAuth" SIZE="1">
                <OPTION SELECTED VALUE>Select a user authority</OPTION>
                <OPTION VALUE="USER">USER</OPTION>
                <OPTION VALUE="MNTN">MAINTAIN</OPTION>
                <OPTION VALUE="ADMN">ADMINISTER</OPTION>
                </SELECT>                
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2"><B>First Name</B>
    </TD></FONT>
    <TD><INPUT TYPE="text" NAME="UserFName" VALUE="<%=strUserFName%>" SIZE="20">
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2"><b>Last Name</b>
    </TD></FONT>
    <TD><INPUT TYPE="text" NAME="UserLName" VALUE="<%=strUserLName%>" SIZE="20">
    </TD>
  </TR>

<TR valign="top">
    <TD><FONT FACE="Verdana" SIZE="2"><B>Existing users</B>
    </TD></FONT>
    <TD><SELECT NAME="Users" SIZE="4">
     
   <%
   Do While rs.EOF <> True 'Loop get all the matching rows
        If RS.Fields(0) = "" Then
            RS.MoveNext
        Else
   %>
     <OPTION Value="<%=TRIM(rs.Fields(0)) & "-" & TRIM(rs.Fields(1))%>"><%=TRIM(rs.Fields(0))%></OPTION>
   <%
        End If
     rs.MoveNext
  Loop
%>
                </SELECT>                
  </TD>
  </TR>

  <TR>
    <TD COLSPAN="2" ALIGN="center">
    <INPUT TYPE="button" VALUE="Create" NAME="cmdCreate">&nbsp;
    <INPUT TYPE="Button" VALUE="  Edit  " NAME="cmdEdit">&nbsp;
    <INPUT TYPE="reset" VALUE="Reset " NAME="cmdReset">&nbsp;
    </TD>
  </TR>  
<%End IF
RS.Close
%>
</FORM>
</TABLE>
</BODY>