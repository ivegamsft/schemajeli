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
</script>
<html>
<head>
<TITLE>Navistar Repository System-Login</TITLE>
<base target="_top">
</HEAD>
<TABLE BORDER="0" WIDTH="100%" CELLSPACING="0" CELLPADDING="1" bgcolor="#CCCC99" BACKGROUND="../images/watermrk.jpg">
   <TR>
      <TD ROWSPAN="2" width="10%">&nbsp;
      </TD>
        <TD width="80%" align="Center"><FONT FACE="Verdana" COLOR="#000000" Size="5">
        <B>Navistar Repository System</B><BR>
          </FONT>
      </TD>  
      <TD ROWSPAN="2" width="10%">
         <IMG SRC="../images/edwlogo.gif" WIDTH="102" HEIGHT="89" BORDER="0" ALT="edwlogo.gif (28431 bytes)">
      </TD>
    </TR>
</table>
<BR>
<BR>
<TABLE BORDER="0" WIDTH="50%" CELLSPACING="0" CELLPADDING="1" bgcolor="#EEEECC" align="Center">
<FORM NAME="frmLogin" METHOD="POST" ACTION="loginchk.asp">
    <tr>
      <td colspan="4" bgcolor="#CCCC99" ALIGN="CENTER"><center><font face="Verdana">
      <b>Enter your login id to begin your session</b></font>
      </td>
	</tr>
    
    <tr>
      <td colspan="4" height="10">
      </TD>
    </TR>
    
    <tr>
      <td Colspan="2">
      </td>
      <td nowrap align="right"><font face="Verdana"><b>Login ID:</b></font>
      </td>
      <td><input type="TEXT" name="UserID" size="15" value="<%=Request.QueryString("UserId")%>">
      </td>
      <td colspan="2">
      </td>
    </tr>
    <tr>
      <td colspan="4">
      </td>
      </TR>
<%If Request.QueryString("ShowPassword") = "True" Then %>
  <Script LANGUAGE="VBScript">
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
      <td Colspan="2">
      </td>
      <td nowrap align="right"><font face="Verdana"><b>Password:</b></font>
      </td>
      <td><input type="PASSWORD" name="Password" size="15">
      </td>
      </TR>
      <TR>
      <td colspan="4">
      </td>
    </tr>
    <tr>
      <td colspan="4" height="10">
      </TD>
    </TR>

    <tr>
      <td colspan="4" align="center">
          <input TYPE="BUTTON" VALUE="Administrative Login" NAME="cmdAdminLogin">
          <input type="RESET" value="        Cancel        " name="cmdAdminCancel">
      </td>
    </tr>
<%Else %>
    <tr>
      <td colspan="4" height="10">
      </TD>
    </TR>

    <tr>
      <td colspan="4" align="center">
          <input TYPE="BUTTON" VALUE="Login" NAME="cmdLogin">
          <input type="RESET" value="Cancel" name="cmdCancel">
      </td>
    </tr>
<%End If%>
</form>
</table>
</html>