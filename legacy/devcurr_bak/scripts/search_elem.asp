<%
Response.buffer = True
Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.frmSearchElements.Criteria.Focus
     Document.frmSearchElements.Criteria.Select
End Sub
<!--#INCLUDE FILE="../include/Valid_ElemNme.inc"-->
Sub cmdSubmit_OnClick()
   Dim objCurForm
   Dim strValidChar
   
   Set objCurForm = Document.Forms.Item(0)
   strValidChar = ValidElemChars(objCurForm.Criteria.value)
   If objCurForm.Criteria.Value= "" then
      msgBox "Please enter some criteria.",,"Error"
      objCurForm.Criteria.Focus
     Exit Sub
   ElseIf strValidChar <> "True" Then
      msgBox "The search criteria field contains the forbidden character " & chr(34) & strValidChar & chr(34) & "." & chr(10) & "Please correct",,"Error"
      objCurForm.Criteria.Focus
      objCurForm.Criteria.Select
      Exit Sub
   ElseIf objCurForm.Criteria.Value = "%"  Then
      msgBox "You cannot use the % alone.  Use the % as a wildcard",,"Error"
      objCurForm.Criteria.Focus
      objCurForm.Criteria.Select
      Exit Sub
   Else
      objCurForm.Action="query_result.asp?RelObject=Table&Criteria=" & objCurForm.Criteria.Value
      objCurForm.Submit
   End If
End Sub     
</script>
<body bgcolor="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<table border="0" width="90%" align="center" bgcolor="<%=strHeaderColor%>">
  <tr>
    <td width="100%" height="40" align="center"><font face="Verdana" size="3">
    <b>Search Elements</b><br>
    Enter the first "n" characters of the abbreviated business name
    (the element dictionary name) you are looking for.  For example, to search for the element PART 25 NUMBER, 
    the business name is PART 25 NUMBER, the dictionary name is PART-25-NO and the column name is PART_25_NO.<br>
    You can enter: &quot;PART-25-NO&quot;,&quot;PART&quot; or &quot;%ART&quot; or &quot;PA%t&quot;.</font>
	</td>
  </tr>    
</Table>

<!--Body Table -->
<table border="0" width="90%" align="center" bgcolor="<%=strBackColor%>">
<FORM NAME="frmSearchElements" METHOD="GET" ACTION="query_result.asp" >
	<tr>
       <td colspan="2" align="center">
       <INPUT type="hidden" name="RelObject" Value="Element">
       <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">       
       <INPUT type="hidden" name="Operator" Value="LIKE">
       <input type="text" name="Criteria" size="25">
       </td>
	</tr>
      <tr>
        <td width="50%" align="right"><input type="Button" value="Submit" name="cmdSubmit">
        </td>
        <td width="50%" align="left"><input type="RESET" value="Reset" name="cmdReset">
        </td>
      </tr>
  </FORM>
</table>
