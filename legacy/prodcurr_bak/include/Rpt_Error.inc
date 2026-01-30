<SCRIPT LANGUAGE="VBScript">
Sub Window_OnLoad
Dim iAnswer
iAnswer = MsgBox("Your query returned zero records." & chr(10) & "Please check your spelling.",,"Error")
If iAnswer > 0 Then
   submit()
End If
End Sub
   
Sub Submit()
  Document.Forms.Item(0).submit
End Sub
Sub Cancel()
  location.Href = "rpt_main.asp"
End Sub
</SCRIPT>
<HTML>
<HEAD>
<TITLE>Session timeout</TITLE>
</HEAD>
<BODY BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE ALIGN="center">
<TR>
<TD HEIGHT="70">
</TD>
</TR>
<TR>
<FORM NAME="Error" METHOD="POST" ACTION="rpt_main.asp">
<TD ALIGN="CENTER"><FONT FACE="Verdana" SIZE="2" COLOR="<%=strErrTextColor%>"><H3><B>
     Your query returned no records<BR>
     Please check your spelling and try again</B></H3><BR>
     <INPUT TYPE="BUTTON" NAME="cmdSubmit" VALUE="Try again" OnClick="Submit">
     <INPUT TYPE="BUTTON" NAME="cmdCancel" VALUE="Cancel" OnClick="Cancel">
     <INPUT TYPE="HIDDEN" NAME="RelObjReport" VALUE ="<%=strRelObjReport%>">
     <INPUT TYPE="HIDDEN" NAME="RelObjStatus" VALUE ="<%=strRelObjStatus%>">
     <INPUT TYPE="HIDDEN" NAME="RelObjName" VALUE ="<%=strRelObjName%>">     
     <INPUT TYPE="HIDDEN" NAME="RelObjReportType" VALUE ="<%=strRelObjReportType%>">
     <INPUT TYPE="HIDDEN" NAME="RelObjServer" VALUE ="<%=strRelObjServer%>">
     <INPUT TYPE="HIDDEN" NAME="Step" VALUE ="5">
</TR>
</FORM>
</TABLE>
</BODY>
</HTML>
