<%
Response.buffer = True
Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--Search databases-->
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.frmSearchDatabases.Criteria.Focus
     Document.frmSearchDatabases.Criteria.Select
End Sub

<!--#INCLUDE FILE="../include/Valid_DbNme.inc"-->

Sub cmdSubmit_OnClick()
   Dim objCurForm
   Dim strValidChar

   Set objCurForm = Document.Forms.Item(0)
   strValidChar = ValidDbChars(objCurForm.Criteria.value)
   If objCurForm.Criteria.Value= "" then
      msgBox "Please enter some criteria.",,"Error"
      objCurForm.Criteria.Focus
  ElseIf strValidChar <> "True" Then
      msgBox "The search criteria field contains the forbidden character " & chr(34) & strValidChar & chr(34) & "." & chr(10) & "Please correct",,"Error"
      objCurForm.Criteria.Focus
      objCurForm.Criteria.Select
      Exit Sub
   Else
     objCurForm.Submit
  End If
End Sub     
</script>
<body bgcolor="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<table border="0" width="75%" align="center" bgcolor="<%=strHeaderColor%>">
  <tr>
    <td width="100%" height="40" align="center"><font face="Verdana" size="3">
    <b>Search Databases</b><br>
    Enter the first "n" characters in the database name you are looking for.<br>
	For example, if you are looking for database "CCBPZD12" you can enter "CCB".</font>
	</td>
  </tr>    
</Table>

<!--Body Table -->
<table border="0" width="75%" align="center" bgcolor="<%=strBackColor%>">
<FORM NAME="frmSearchDatabases" METHOD="GET" ACTION="query_result.asp" >
	<tr>
       <td colspan="2" align="center">
       <INPUT type="hidden" name="RelObject" Value="Database">
       <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">       
       <INPUT type="hidden" name="Operator" Value="LIKE">
       <input type="text" name="Criteria" size="25">
       </td>
	</tr>
      <tr>
        <td width="50%" align="right"><input type="Button" value="Submit" name="cmdSubmit" action="query_result.asp?RelObject=Table&Criteria=<%response.write(request.form("Criteria"))%>">
        </td>
        <td width="50%" align="left"><input type="RESET" value="Reset" name="cmdReset">
        </td>
      </tr>
  </FORM>
</table>
