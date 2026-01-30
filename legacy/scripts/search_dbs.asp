<%
Response.buffer = True
Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<HTML>
<HEAD>
<TITLE>Search for Databases
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

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
</SCRIPT>
<!--Header table -->
<TABLE BORDER="0" WIDTH="90%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <TR>
  <TD WIDTH="100%" HEIGHT="40" ALIGN="center"><FONT FACE="Verdana" SIZE="3">
    <B>Search Databases</B><BR>
    Enter the first "n" characters in the database name you are looking for.<BR>
	For example, if you are looking for database "CCBPZD12" you can enter "CCB".</FONT>
  </TD>
  </TR>    
</TABLE>

<!--Body Table -->
<TABLE BORDER="0" WIDTH="90%" ALIGN="center" BGCOLOR="<%=strBackColor%>">
<FORM NAME="frmSearchDatabases" METHOD="GET" ACTION="query_result.asp" >
  <TR>
  <TD COLSPAN="2" ALIGN="center">
    <INPUT TYPE="hidden" NAME="RelObject" VALUE="Database">
    <INPUT TYPE="hidden" NAME="UserId" VALUE="<%=Session("USERID")%>">       
    <INPUT TYPE="hidden" NAME="Operator" VALUE="LIKE">
    <INPUT TYPE="text" NAME="Criteria" SIZE="25">
  </TD>
  </TR>
  <TR>
  <TD WIDTH="50%" ALIGN="right"><INPUT TYPE="Button" VALUE="Submit" NAME="cmdSubmit" ACTION="query_result.asp?RelObject=Table&Criteria=<%response.write(request.form("CRITERIA"))%>">
  </TD>
  <TD WIDTH="50%" ALIGN="left"><INPUT TYPE="RESET" VALUE="Reset" NAME="cmdReset">
  </TD>
  </TR>
</FORM>
</TABLE>
</BODY>
</HTML>
