<%
Response.buffer = True
Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<HTML>
<HEAD>
<TITLE>Search elements
</TITLE>
</HEAD>
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
</SCRIPT>
<BODY BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<TABLE BORDER="0" WIDTH="90%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <TR>
  <TD WIDTH="100%" HEIGHT="40" ALIGN="center"><FONT FACE="Verdana" SIZE="3">
    <B>Search Elements</B><BR>
    Enter the first "n" characters of the abbreviated business name
    (the element dictionary name) you are looking for.  For example, to search for the element PART 25 NUMBER, 
    the business name is PART 25 NUMBER, the dictionary name is PART-25-NO and the column name is PART_25_NO.<BR>
    You can enter: &quot;PART-25-NO&quot;,&quot;PART&quot; or &quot;%ART&quot; or &quot;PA%t&quot;.</FONT>
  </TD>
  </TR>    
</TABLE>

<!--Body Table -->
<TABLE BORDER="0" WIDTH="90%" ALIGN="center" BGCOLOR="<%=strBackColor%>">
<FORM NAME="frmSearchElements" METHOD="GET" ACTION="query_result.asp" >
  <TR>
  <TD COLSPAN="2" ALIGN="center">
   <INPUT TYPE="hidden" NAME="RelObject" VALUE="Element">
   <INPUT TYPE="hidden" NAME="UserId" VALUE="<%=Session("USERID")%>">       
   <INPUT TYPE="hidden" NAME="Operator" VALUE="LIKE">
   <INPUT TYPE="text" NAME="Criteria" SIZE="25">
  </TD>
  </TR>
  <TR>
  <TD WIDTH="50%" ALIGN="right"><INPUT TYPE="Button" VALUE="Submit" NAME="cmdSubmit">
  </TD>
  <TD WIDTH="50%" ALIGN="left"><INPUT TYPE="RESET" VALUE="Reset" NAME="cmdReset">
  </TD>
  </TR>
</FORM>
</TABLE>
</BODY>
</HTML>