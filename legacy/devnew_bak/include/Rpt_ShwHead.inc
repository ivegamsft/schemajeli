<SCRIPT LANGUAGE="VBSCRIPT">
Sub SelectReport()
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)
    If objCurForm.Report.Value <> "" then
       objCurForm.RelObjReport.Value = objCurForm.Report.Value
       Select Case objCurForm.Report.Value
          Case "Server"
             objCurForm.RelObjStatus.Value = ""
             objCurForm.RelObjServer.Value = ""
             objCurForm.RelObjReportType.Value = ""
             objCurForm.RelObjName.Value = ""             
             objCurForm.Step.Value = "2"
          Case "Database"
             objCurForm.RelObjStatus.Value = ""
             objCurForm.RelObjServer.Value = ""
             objCurForm.RelObjReportType.Value = ""
             objCurForm.RelObjName.Value = ""             
             objCurForm.Step.Value = "2"
          Case "Table"
             objCurForm.RelObjStatus.Value = ""
             objCurForm.RelObjServer.Value = ""
             objCurForm.RelObjReportType.Value = ""
             objCurForm.RelObjName.Value = ""             
             objCurForm.Step.Value = "3"
          Case "Element"
             objCurForm.RelObjStatus.Value = ""
             objCurForm.RelObjServer.Value = ""
             objCurForm.RelObjReportType.Value = ""
             objCurForm.RelObjName.Value = ""             
             objCurForm.Step.Value = "3"
          End Select
       objCurForm.Submit
    End If
End Sub

Sub SelectServer()
   Dim objCurForm
   Dim qString
   Set objCurForm = Document.Forms.Item(0)
    If objCurForm.Server.Value <> "" then
       Select Case objCurForm.Report.Value
       Case "Server"
         objCurForm.RelObjServer.Value = objCurForm.Server.Value
         objCurForm.RelObjStatus.Value = ""
         objCurForm.RelObjReportType.Value = ""
         objCurForm.RelObjName.Value = ""             
         objCurForm.Step.Value = "5"
       Case "Database"
         objCurForm.RelObjServer.Value = objCurForm.Server.Value
         objCurForm.RelObjStatus.Value = ""
         objCurForm.RelObjReportType.Value = ""
         objCurForm.RelObjName.Value = ""             
         objCurForm.Step.Value = "3"
       End Select
    objCurForm.Submit
    End If
End Sub
     
Sub SelectStatus()
   Dim objCurForm
   Dim qString
   Set objCurForm = Document.Forms.Item(0)
    If objCurForm.Status.Value <> "" then
       objCurForm.RelObjStatus.Value = objCurForm.Status.Value
       objCurForm.RelObjReportType.Value = ""
       objCurForm.RelObjName.Value = ""             
       objCurForm.Step.Value = "4"
       objCurForm.Submit
    End If
End Sub

Sub SelectType()
   Dim objCurForm
   Dim qString
   Set objCurForm = Document.Forms.Item(0)
    If objCurForm.Type.Value <> "" then
       objCurForm.RelObjReportType.Value = objCurForm.Type.Value
       objCurForm.RelObjName.Value = ""             
       objCurForm.Step.Value = "5"
       objCurForm.Submit
    End If
End Sub


<!--#INCLUDE FILE="../include/Valid_DbNme.inc"-->
<!--#INCLUDE FILE="../include/Valid_TblNme.inc"-->
<!--#INCLUDE FILE="../include/Valid_ElemNme.inc"-->

Sub cmdGenReport_OnClick()
  Dim objCurForm
  Dim strValidChar
  Set objCurForm = Document.Forms.Item(0)

  If IsObject(objCurForm.Name) Then
     If objCurForm.Name.Value = "" Then
        MsgBox "Please enter an object name.",,"Error"
        objCurForm.Name.Focus
        Exit Sub
  Else
  Select Case objCurForm.Report.Value
  Case "Server"
     msgbox "Because of the complexity of some reports " & chr(13) _
            & "they may take up to 5 minutes to generate." & chr(13) _
            & "Please be patient.",64,"Information"
     objCurForm.Action="rpt_result.asp"
     objCurForm.RelObjName.Value = objCurForm.Server.Value
     objCurForm.Submit
  Case "Database"
     msgbox "Some reports may take up to 5 minutes to generate." & chr(13) _
            & "Please be patient.",64,"Information"
     objCurForm.Action="rpt_result.asp"
     objCurForm.RelObjName.Value = objCurForm.Name.Value
     objCurForm.Submit
  Case "Table"
     strValidChar = ValidTblChars(objCurForm.Name.value)
     If strValidChar <> "True" then
        msgBox "invalid char"
     Else
     msgbox "Some reports may take up to 5 minutes to generate." & chr(13) _
            & "Please be patient.",64,"Information"
     objCurForm.Action="rpt_result.asp"
     objCurForm.RelObjName.Value = objCurForm.Name.Value
     objCurForm.Submit
     End If

  Case "Element"
     strValidChar = ValidElemChars(objCurForm.Name.value)
  If objCurForm.Name.Value= "" then
      msgBox "Please enter a name.",,"Error"
      objCurForm.Name.Focus
      Exit Sub
'  ElseIf strValidChar <> "True" Then
'      msgBox "The name field contains the forbidden character " & chr(34) & strValidChar & chr(34) & "." & chr(10) & "Please correct",,"Error"
'      objCurForm.Name.Focus
'      objCurForm.Name.Select
'      Exit Sub
   Else
     msgbox "Some reports may take up to 5 minutes to generate." & chr(13) _
            & "Please be patient.",64,"Information"
     objCurForm.Action="rpt_result.asp"
     objCurForm.RelObjName.Value = objCurForm.Name.Value
     objCurForm.Submit
   End If
   End Select
   End If
End If
End Sub     

</SCRIPT>

<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->
<!--Header table -->
<TABLE BORDER="0" WIDTH="70%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
<TR>
<TD WIDTH="100%" HEIGHT="40" ALIGN="center"><FONT FACE="Verdana" SIZE="3">
<B>Relational Object Report-</B>enter data<BR>
</TD>
</TR>    
</TABLE>
<!--Body Table -->
<TABLE BORDER="0" WIDTH="70%" ALIGN="center" BGCOLOR="<%=strBackColor%>">
<FORM NAME="frmObjectReport" METHOD="POST" ACTION="" >
<INPUT TYPE="hidden" NAME="UserId" VALUE="<%=Session("USERID")%>">
<INPUT TYPE="hidden" NAME="RelObjReport" VALUE="<%=strRelObjReport%>">
<INPUT TYPE="hidden" NAME="RelObjReportType" VALUE="<%=strRelObjReportType%>">
<INPUT TYPE="hidden" NAME="RelObjStatus" VALUE="<%=strRelObjStatus%>">
<INPUT TYPE="hidden" NAME="RelObjServer" VALUE="<%=strRelObjServer%>">
<INPUT TYPE="hidden" NAME="RelObjName" VALUE="<%=strRelObjName%>">
<INPUT TYPE="hidden" NAME="Step" VALUE="<%=strStep%>">
<!--
<b>Report=<%=strRelObjReport%><br>
   type=<%=strRelObjReportType%><br>
   status=<%=strRelObjStatus%><br>
   server=<%=strRelObjServer%><br>
   name=<%=strRelObjName%><br>
   step=<%=strStep%><br>
</b>
-->