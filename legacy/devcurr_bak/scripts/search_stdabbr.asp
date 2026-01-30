<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.frmSearchStdAbbr.Criteria.Focus
     Document.frmSearchStdAbbr.Criteria.Select
End Sub

<!--#INCLUDE FILE="../include/frbdnChars.inc"-->

Sub cmdSubmit_OnClick()
   Dim objCurForm
   Dim strValidChar
   Set objCurForm = Document.Forms.Item(0)
   strValidChar = ValidChar(objCurForm.Criteria.value)
   If objCurForm.Criteria.Value= "" then
      msgBox "Please enter some criteria.",,"Error"
      objCurForm.Criteria.Focus
      Exit Sub
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
<table border="0" width="90%" align="center" bgcolor="<%=arypagecolors(7)%>">
  <tr>
    <td colspan="2" height="40" align="center"><font face="Verdana">
    <b>Search Standard Abbreviations</b><br>
	Enter a word or an abbreviation<br>
	</font>
	</td>
 </tr>    

    
    </td>
  </tr>    
</Table>

<!--Body Table -->
<table border="0" width="90%" align="center" bgcolor="<%=strBackColor%>">
  <tr>
    <td align="center" colspan="3" style="border-bottom: thin solid rgb(255,255,255)">
    </td>
  </tr>
  
  <tr>
  </tr>
  <FORM NAME="frmSearchStdAbbr" METHOD="GET" ACTION="query_result.asp">
  <tr>
     <td align="center" colspan="4">
     <INPUT type="hidden" name="RelObject" Value="Abbreviation">
     <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">
     <INPUT type="text" name="Criteria" size="30">
     </td>
   </tr>   

      <tr>
        <td width="50%" align="right"><input type="button" value="Submit" name="cmdSubmit">
        </td>
        <td width="50%" align="left"><input type="reset" value="Reset" name="cmdReset">
        </td>
      </tr>
    </table>
</form>
</body>

