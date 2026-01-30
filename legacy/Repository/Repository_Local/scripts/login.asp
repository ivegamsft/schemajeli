<%
'LOGIN.ASP
%>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.frmLogin.UserId.Focus
     Document.frmLogin.UserId.Select
End Sub

Sub cmdLogin_OnClick()
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)

   If objCurForm.Item(0).Value="" then
      msgBox "Please enter a user id.",,"Error"
      Document.frmLogin.UserId.Focus
   Else
      objCurForm.Submit
  End If
End Sub     
</SCRIPT>
<HTML>
<HEAD>
<TITLE>Navistar Repository System-Login</TITLE>
<BASE TARGET="_top">
</HEAD>
<BODY>
<TABLE BORDER="0" WIDTH="100%" CELLSPACING="0" CELLPADDING="1" BGCOLOR="#CCCC99" BACKGROUND="../images/watermrk.jpg">
  <TR>
  <TD ROWSPAN="2" WIDTH="10%">&nbsp;
  </TD>
  <TD WIDTH="80%" ALIGN="Center"><FONT FACE="Verdana" COLOR="#000000" SIZE="5">
    <B>Navistar Repository System</B><BR>
    </FONT>
  </TD>  
  <TD ROWSPAN="2" WIDTH="10%">
    <IMG SRC="../images/edwlogo.gif" WIDTH="102" HEIGHT="89" BORDER="0" ALT="edwlogo.gif (28431 bytes)">
  </TD>
  </TR>
</TABLE>
  <BR>
  <BR>
<TABLE BORDER="0" WIDTH="50%" CELLSPACING="0" CELLPADDING="1" BGCOLOR="#EEEECC" ALIGN="Center">
<FORM NAME="frmLogin" METHOD="POST" ACTION="loginchk.asp">
  <TR>
  <TD COLSPAN="4" BGCOLOR="#CCCC99" ALIGN="CENTER"><CENTER><FONT FACE="Verdana">
   <B>Enter your login id to begin your session</B></FONT>
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4" HEIGHT="10">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="2">
  </TD>
  <TD NOWRAP ALIGN="right"><FONT FACE="Verdana"><B>Login ID:</B></FONT>
  </TD>
  <TD><INPUT TYPE="TEXT" NAME="UserID" SIZE="15" VALUE="<%=Request.QueryString("USERID")%>">
  </TD>
  <TD COLSPAN="2">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4">
  </TD>
  </TR>
<%If Request.QueryString("ShowPassword") = "True" Then %>
  <SCRIPT LANGUAGE="VBScript">
  Sub Window_OnLoad()
     Document.frmLogin.Password.Focus
  End Sub

  Sub cmdAdminLogin_OnClick()
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)

   If objCurForm.Password.Value="" then
      msgBox "Please enter a password.",,"Error"
      objCurForm.Password.Focus
   Else
      objCurForm.Action = "login_admin.asp"
      objCurForm.Submit
  End If
 End Sub     

Sub cmdAdminCancel_OnClick
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)
   objCurForm.Action = "login.asp"
   objCurForm.Submit
End Sub
  </SCRIPT>
  <TR>
  <TD COLSPAN="2">
  </TD>
  <TD NOWRAP ALIGN="right"><FONT FACE="Verdana"><B>Password:</B></FONT>
  </TD>
  <TD><INPUT TYPE="PASSWORD" NAME="Password" SIZE="15">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4" HEIGHT="10">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4" ALIGN="center">
    <INPUT TYPE="BUTTON" VALUE="Administrative Login" NAME="cmdAdminLogin" DEFAULT>
    <INPUT TYPE="RESET" VALUE="        Reset        " NAME="cmdAdminCancel">
  </TD>
  </TR>
<%Else %>
  <TR>
  <TD COLSPAN="4" HEIGHT="10">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4" ALIGN="center">
    <INPUT TYPE="BUTTON" VALUE="Login" NAME="cmdLogin">
    <INPUT TYPE="RESET" VALUE="Reset" NAME="cmdReset">
  </TD>
  </TR>
<%End If%>
</FORM>
</TABLE>
</BODY>
</HTML>