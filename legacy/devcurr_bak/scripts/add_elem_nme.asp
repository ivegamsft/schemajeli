<% Response.Buffer = true 
session.timeout = 60%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Dim strFrom
Dim strHeaderMessage
Dim strCriteria
Dim iTermLen
Dim strClassword
Dim strDNormNo
Dim strErrTerm
Dim strOption

strFrom=Request.Form("From")
strOption = Request.QueryString("Option")
'response.write strFrom
'response.end

Select Case strFrom

Case "Error"
strCriteria = Session("Criteria")
strCriteria = JOIN(SPLIT(strCriteria,"*"))
strClassword = Session("Classword")
If Session("Dnorm") = "True" Then
    iTermLen = Len(TRIM(strCriteria)) - Len(TRIM(strClassword)) - 1
Else
    iTermLen = Len(TRIM(strCriteria)) - Len(TRIM(strClassword))
End If
strCriteria = TRIM(Left(strCriteria,iTermLen))
sqlQuery = "SELECT std_abbr_srce_nme, std_abbr_nme" 
sqlQuery = sqlQuery & " FROM irma10_std_abbr" 
sqlQuery = sqlQuery & " WHERE clas_word_i = 'Y'"
sqlQuery = sqlQuery & " ORDER BY std_abbr_srce_nme"
Set rs=Session("rs")
If rs.state = 1 then
   rs.Close
End If
rs.open(sqlQuery)           'Open the record set
strDNormNo = Session("DNormNo")
strErrTerm = Session("ErrTerm")
strErrTerm = JOIN(SPLIT(strErrTerm,"*"))
strHeaderMessage = "<FONT size=2 COLOR=" & strErrTextColor & ">There was an error generating the names for your element.<br>"
strHeaderMessage = strHeaderMessage & "Valid abbreviations for the terms indicated with &quot;??&quot; were not found.<br>"
strHeaderMessage = strHeaderMessage & "Check your spelling or if you need a new abbreviation, contact "
strHeaderMessage = strHeaderMessage & "<A HREF=mailto:rephlpteam@USAEXCH01.navistar.com>The object management team.</A></FONT>"

Case ""
strCriteria = ""
strClassword = ""
strDNormNo = ""
Select Case strOption
  Case ""
  strHeaderMessage = "Specify data</b> - Add element<br>Element business name"
  sqlQuery = "SELECT std_abbr_srce_nme, std_abbr_nme" 
  sqlQuery = sqlQuery & " FROM irma10_std_abbr" 
  sqlQuery = sqlQuery & " WHERE clas_word_i = 'Y'"
  sqlQuery = sqlQuery & " ORDER BY std_abbr_srce_nme"
  Set rs=Session("rs")
  If rs.state = 1 then
     rs.Close
  End If
  rs.open(sqlQuery)           'Open the record set
  
  Case "Maintain"
  strHeaderMessage = "Specify data</b> - Maintain element<br>Enter the business name, column name or the dictionary name for the element to maintain.<BR>"
  End Select
End Select
%>
<!--Add element name step1-->
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.Forms.Item(0).Criteria.Focus
End Sub

FUNCTION CheckBusnsName(TERM)
	If IsNumeric(Left(TERM ,1)) Then
	   CheckBusnsName= False
     Else  
       CheckBusnsName = True
	 End If
END FUNCTION

<!--#INCLUDE FILE="../include/frbdnChars.inc"-->

Sub cmdAdd_OnClick()
  Dim objCurForm 
  Dim strQString
  Dim strElemName 
  Dim strValidBName
  Dim strValidChar
  Dim iTermCount
  Set objCurForm = Document.Forms.Item(0)

If objCurForm.Criteria.Value= "" then
       msgBox "Please enter a business name.",,"Error"
       objCurForm.Criteria.Focus
       Exit Sub
ElseIf LEN(objCurForm.Criteria.Value) < 3 then
       msgbox "Business names must consist of at least one term and a class word",,"Error"
       objCurForm.Criteria.Focus
       Exit Sub
ElseIf objCurForm.Classword.SelectedIndex = 0 OR objCurForm.Classword.Value = "" Then
        msgBox "Please Select a class word.",,"Error"
        objCurForm.Classword.Focus
        Exit Sub
ElseIf objCurForm.DNormNo.Value <> "" then
        If Not IsNumeric(objCurForm.DNormNo.Value) Then
           msgBox "The denomalization number must be numeric.",,"Error"
           objCurForm.DNormNo.Focus
           objCurForm.DNormNo.Select
           Exit Sub
        ElseIF objCurForm.DNormNo.Value > 100 then
           msgBox "The denomalization number cannot be > 100.",,"Error"
           objCurForm.DNormNo.Focus
           objCurForm.DNormNo.Select
        Exit Sub
        End If
ElseIf UCASE(TRIM(objCurForm.Criteria.Value)) = UCASE(TRIM(objCurForm.Classword.Value)) then
       msgbox "Business names must consist of at least one term and a class word",,"Error"
       objCurForm.Criteria.Focus
       objCurForm.Criteria.Select
       Exit Sub
End If
    strElemName = UCASE(TRIM(objCurForm.Criteria.Value))
    aryElemName = SPLIT(strElemName)
If aryElemName(UBOUND(aryElemName)) = TRIM(objCurForm.Classword.Value) Then
    strElemName = UCASE(JOIN(aryElemName))
Else
    strElemName = UCASE(JOIN(aryElemName)) & " " & TRIM(objCurForm.Classword.Value)
End If

If objCurForm.DNormNo.Value <> "" then
   strElemName = strElemName & " " & TRIM(objCurForm.DNormNo.Value)
End If

  strElemName = UCASE(strElemName)
  strValidBName = CheckBusnsName(strElemName)
  strValidChar = ValidChar(strElemName)

  If Not strValidBName then
         msgBox "Business names cannot begin with a numeric.",,"Error"
         objCurForm.Criteria.Focus
         objCurForm.Criteria.Select
         exit Sub
  ElseIf strValidChar <> "True" Then
         msgBox "Business name contains the forbidden character " & chr(34) & strValidChar & chr(34) & "." & chr(10) & "Please correct",,"Error"
         objCurForm.Criteria.Focus
         objCurForm.Criteria.Select
       exit Sub
  Else      
      msgBox "A suggessted list of names will be generated for " & strElemName & Chr(10) & "This may take some time.",,"Please wait"
      objCurForm.From.Value = "New"
'      objCurForm.Action="wait_msg.asp?verif_elem.asp"
      objCurForm.Submit
  End If
End Sub     

Sub cmdMaintain_OnClick()
  Dim objCurForm 
  Dim strQString
  Dim strElemName 
  Dim strValidBName
  Dim strValidChar
  Dim iTermCount
  Set objCurForm = Document.Forms.Item(0)

If objCurForm.Criteria.Value= "" then
   msgBox "Please an element business name, dictionay name or column name.",,"Error"
   objCurForm.Criteria.Focus
   Exit Sub
Else      
   objCurForm.From.Value = "Query"
'   msgBox "ok to submit." & strElemName,,"ok"
   objCurForm.Submit
   End If
End Sub     


</SCRIPT>

<BODY BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE BORDER="0" WIDTH="90%" ALIGN="center" BGCOLOR="<%=strBackColor%>">
  <TR>
  <TD WIDTH="100%" BGCOLOR="<%=strHeaderColor%>" height="40" align="middle"><FONT FACE="Verdana">
   <B><%=strHeaderMessage%></B><BR>
  </FONT>
  </TD>
  </TR>
</TABLE>
<%Select Case strOption
  Case ""%>
<!--Body Table -->
<TABLE BORDER="0" BGCOLOR="<%=strBackColor%>" width="90%" align="center" cellpadding="0" cellSpacing="0">
  <FORM NAME="frmNewElement" METHOD="POST" ACTION="verif_elem.asp">
  <TR>
  <TD ALIGN="center" STYLE="BORDER-BOTTOM: rgb(255,255,255) solid thin">
  </TD>
  </TR>

  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
   <B>Business Name</B>
  </TD>
    
  <TD><FONT FACE="Verdana" SIZE="2">
   <B><A HREF="query_result.asp?RelObject=ClassWord" TITLE="View class words">Class Word</A></B>
  </FONT>
  </TD>
    
  <TD><FONT FACE="Verdana" SIZE="2">
    <B>D-Norm <BR>Number</B>
   </FONT>
   </TD>
   </TR>

  <TR>
  </TD>
  <TD><INPUT NAME="From" TYPE="Hidden" VALUE="Add">
      <INPUT TYPE="hidden" NAME="UserId" VALUE="<%=Session("USERID")%>">
      <INPUT TYPE="Text" NAME="Criteria" SIZE="50" VALUE="<%=strCriteria%>">
   </TD>                

  <TD><SELECT NAME="ClassWord" SIZE="1">
      <OPTION SELECTED VALUE="Classword">Select a Class Word</OPTION>
<%    If Not rs.EOF Then rs.MoveFirst
         Do While Not rs.EOF
           If strClassWord <> TRIM(rs.Fields(0)) Then%>
      <OPTION VALUE="<%=TRIM(rs.Fields(0))%>"><%=TRIM(rs.Fields(0))%></OPTION>
      <%      rs.MoveNext
           Else%>
      <OPTION SELECTED VALUE="<%=strClassword%>"><%=strClassword%>
           <%   rs.MoveNext
           End IF
      Loop
      rs.Close%>
      </SELECT>                
  </TD>
  
  <TD ALIGN="Center"><INPUT TYPE="Text" NAME="DNormNo" SIZE="2" MAXLENGTH="3" VALUE="<%=strDNormNo%>">
  </TD>                
  </TR>

  <TR>
  <TD HEIGHT="30">
  </TD>
  </TR>

  <TR>
  <TD COLSPAN="3" ALIGN="center"><INPUT TYPE="Button" VALUE=" Add " NAME="cmdAdd">&nbsp;&nbsp;&nbsp;&nbsp;
                           	     <INPUT TYPE="reset" VALUE="Reset" NAME="cmdReset">
  </TD>
  </TR>
<%Case "Maintain" %>
<!--Body Table for edit element-->
<TABLE BORDER="0" BGCOLOR="<%=strBackColor%>" width="90%" align="center" cellpadding="0" cellSpacing="0">
<FORM NAME="frmEditElement" METHOD="POST" ACTION="add_elem_dtls.asp">
  <TR>
  <TD HEIGHT="20">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="3" ALIGN="center">
  <INPUT NAME="From" TYPE="Hidden" VALUE="Edit">
  <INPUT TYPE="hidden" NAME="UserId" VALUE="<%=Session("USERID")%>">
  <INPUT TYPE="hidden" NAME="Qstring" VALUE="verif_elem.asp">
  <INPUT TYPE="Text" NAME="Criteria" SIZE="50" VALUE="<%=strEditCriteria%>">
  </TD>                
  </TR>
  <TR>
  <TD WIDTH="30%">&nbsp;</TD>
  <TD ALIGN="Left"><FONT FACE="Verdana" SIZE="2">
  For example:
  <LI>Business Name = order number
  <LI>Column Name = ord_no
  <LI>Dictionary Name = ord-no
  </TD>
  <TD WIDTH="30%">&nbsp;</TD>
  </TR>
  <TR>
  <TD HEIGHT="20">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="3" ALIGN="center">
  <INPUT TYPE="Button" VALUE="Maintain" NAME="cmdMaintain">&nbsp;&nbsp;&nbsp;&nbsp;
  <INPUT TYPE="reset" VALUE=" Reset " NAME="cmdReset">
  </TD>
  </TR>
<%End Select %>
</FORM>
</TABLE>

