<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%'<!--#INCLUDE FILE="../include/security.inc"-->
Response.buffer=True
'Response.Write(Request.QueryString("From"))
'Response.end
Dim strCreator
Dim strCreateDate
Dim strLastMod
Dim strLastModBy
Dim strElementBName
Dim strElementDName
Dim strElementCName
Dim strElementVersion
Dim strElementStatus
Dim strDataType
Dim strLogLen
Dim strPhysLen
Dim strDecLen
Dim strFrom

strFrom = Request.QueryString("From")
Select Case strFrom

Case "Add"
Dim aryElementBName
Dim iTermCount
Dim iTermCounter
Dim aryColName()
Dim aryElentCName()

'Assemble the business name from the querystring
strCreator = Session("USERID")
strCreateDate = CreateTS()
strLastModBy = Session("USERID")
strLastMod = CreateTS()
strElementBName = UCASE(Request.QueryString("ElementBName"))
aryElementBName = SPLIT(strElementBName,"*")
strElementBName= UCASE(JOIN(aryElementBName))
strElementDName = UCASE(Request.QueryString("ElementDName"))
strElementCName = UCASE(Request.QueryString("ElementCName"))
aryElementCName = SPLIT(strElementCName,"_")
strElementCName= UCASE(JOIN(aryElementCName,"_"))
iTermCount = UBOUND(aryElementCName)
strElementVersion = "1"
strElementStatus = "DVLP"
strLogLen = ""
strPhysLen = ""
strDecLen = ""


Case "Query"
Dim sqlQuery

strElementDName = UCASE(TRIM(Request.QueryString("Col1")))
strElementVersion = UCASE(TRIM(Request.QueryString("Col4")))
strElementStatus = UCASE(TRIM(Request.QueryString("Col3")))

        sqlQuery = "SELECT a.elmt_dict_nme, a.elmt_busns_nme, a.elmt_col_nme,"
        sqlQuery = sqlQuery & " a.elmt_stat_cd, b.elmt_vrsn_no, a.elmt_creat_uid, a.create_ts"
        sqlQuery = sqlQuery & " a.elmt_lst_chng_uid, a.elmt_lst_chng_ts, b.elmt_data_typ_id,"
        sqlQuery = sqlQuery & " b.elmt_logcl_lng, b.elmt_phys_lng, b.elmt_dec_lng, c.text_80_desc, c.seq_no"
        sqlQuery = sqlQuery & " FROM irma05_element a, irma04_elmt_vrsn b, irma06_elmt_desc c"
        sqlQuery = sqlQuery & " WHERE a.elmt_dict_nme = '" & strElementDName & "'"
        sqlQuery = sqlQuery & " and a.elmt_stat_cd = '" & strElementStatus & "'"
        sqlQuery = sqlQuery & " and b.elmt_vrsn_no = '" & strElementVersion & "'"
        sqlQuery = sqlQuery & " and a.elmt_dict_nme = b.elmt_dict_nme"
        sqlQuery = sqlQuery & " and a.elmt_stat_cd = b.elmt_stat_cd"
        sqlQuery = sqlQuery & " and b.elmt_dict_nme = c.elmt_dict_nme"
        sqlQuery = sqlQuery & " and a.elmt_stat_cd = c.elmt_stat_cd"
        sqlQuery = sqlQuery & " ORDER BY c.seq_no"
'Response.write sqlquery
'response.end
        Set rs = Session("rs")
        'rs.Close                   'Debugging
        rs.open(sqlQuery)           'Open the record set

strCreator = UCASE(TRIM(rs.Fields(5)))
strLastModBy = UCASE(TRIM(rs.Fields(7)))
strCreateDate = rs.Fields(6) 
strLastMod = rs.Fields(8)
strElementBName = UCASE(TRIM(rs.Fields(1)))
strElementDName = UCASE(TRIM(rs.fields(0)))
strElementCName = UCASE(TRIM(rs.fields(2)))
aryElementCName = Split(strElementCName,"_")
iTermCount = UBOUND(aryElementCName)
strElementVersion = rs.fields(4)
strElementStatus = rs.fields(3)
strDataType = rs.Fields(9)
strLogLen = rs.fields(10)
strPhysLen = rs.fields(11)
strDecLen = rs.fields(12)

End Select
'response.end
%>

<SCRIPT LANGUAGE="VbScript">
Sub Window_OnLoad()
'     Document.frmNewElement.Item(0).Focus
End Sub

Sub Resubmit()
  Dim objCurForm 
  Dim aryElementCName()
  Dim Terms
  Dim aryTerms
  Set objCurForm = Document.Forms.item(0)
ReDim aryElementCName(objCurForm.NumTerms.Value)
Terms = 0
  For i=0 to objCurForm.NumTerms.Value

    If Not objCurForm.ChkTerm(i).Checked then
        ReDim Preserve aryElementCName(Terms) 
        aryElementCName(Terms) = ObjCurForm.TERM(i).Value
        Terms = Terms + 1
   End If
  Next 
  strElementCName = JOIN(aryElementCName,"_")
If Len(strElementCName) > 18 then
   msgBox "The column name cannot be > 18 characters",, "Error"
Else
  objCurForm.ElementCName.value = strElementCName
  objCurForm.Action="add_elem_Dtls.asp"
  objCurForm.Submit
End If
End sub

FUNCTION ValidChar(NAME)
DIM aryForbiddenChars(32)
DIM iCount

	aryForbiddenChars(0)= "!"
	aryForbiddenChars(1)= "@"
	aryForbiddenChars(2)= "#"
	aryForbiddenChars(3)= "$"
	aryForbiddenChars(4)= "%"
	aryForbiddenChars(5)= "^"
	aryForbiddenChars(6)= "&"
	aryForbiddenChars(7)= "*"
	aryForbiddenChars(8)= "("
	aryForbiddenChars(9)= ")"
	aryForbiddenChars(10)= "["
	aryForbiddenChars(11)= "{"
	aryForbiddenChars(12)= "]"
	aryForbiddenChars(13)= "}"
	aryForbiddenChars(14)= chr(34)
	aryForbiddenChars(15)= "'"
	aryForbiddenChars(16)= ";"
	aryForbiddenChars(17)= ":"
	aryForbiddenChars(18)= "\"
	aryForbiddenChars(19)= "|"
	aryForbiddenChars(20)= ","
	aryForbiddenChars(21)= ","
	aryForbiddenChars(22)= "."
	aryForbiddenChars(23)= ">"
	aryForbiddenChars(24)= "/"
	aryForbiddenChars(25)= "?"
	aryForbiddenChars(26)= "`"
	aryForbiddenChars(27)= "~"
	aryForbiddenChars(28)= "-"
	aryForbiddenChars(29)= "_"
	aryForbiddenChars(30)= "="
	aryForbiddenChars(31)= "+"
    aryForbiddenChars(32)= chr(32) & chr(32)

For iCOUNT = 0 to UBOUND(aryForbiddenChars)
    If InStr(NAME,aryForbiddenChars(iCOUNT)) THEN
        ValidChar=aryForbiddenChars(iCOUNT)
		Exit For
	else
	    ValidChar="True"
	End if
Next
END FUNCTION

Sub DimColName()
msgbox "Hello"
End Sub

Sub cmdSubmit_OnClick()
  Dim objCurForm 
  Dim strQString
  Dim strElemName 
  Dim aryElemName
  Dim strValidBName
  Dim strValidChar
  Set objCurForm = Document.Forms.Item(0)

If objCurForm.Criteria.Value= "" then
       msgBox "Please enter a business name.",,"Error"
       objCurForm.Criteria.Focus
       Exit Sub
 ElseIf objCurForm.Classword.SelectedIndex = 0 Then
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
End If
    strElemName = UCASE(TRIM(objCurForm.Criteria.Value))
    aryElemName = SPLIT(strElemName)
If aryElemName(UBOUND(aryElemName)) = TRIM(objCurForm.Classword.Value) Then
    strElemName = JOIN(aryElemName)
Else
    strElemName = JOIN(aryElemName) & " " & TRIM(objCurForm.Classword.Value)
End If

If objCurForm.DNormNo.Value <> "" then
   strElemName = strElemName & " " & TRIM(objCurForm.DNormNo.Value)
End If

  strElemName = UCASE(strElemName)
  strValidBName = CheckBusnsName(strElemName)
  strValidChar = ValidChar(strElemName)

  If not strValidBName then
         msgBox "Business names cannot begin with a numeric or a space.",,"Error"
         objCurForm.Criteria.Focus
         objCurForm.Criteria.Select
         exit Sub
  ElseIf strValidChar <> "True" Then
         msgBox "Business name contains the forbidden character " & chr(34) & strValidChar & chr(34) & "." & chr(10) & "Please correct",,"Error"
         objCurForm.Criteria.Focus
         objCurForm.Criteria.Select
       exit Sub
  Else      
      msgBox "ok to submit." & strElemName,,"ok"
      'objCurForm.Submit
  End If
End Sub     
</SCRIPT>
<BODY BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE BORDER="1" WIDTH="90%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" CELLSPACING="0">
  <TR>
    <TD WIDTH="100%" BGCOLOR="<%=strHeaderColor%>" height="40" align="middle"><FONT FACE="Verdana">
      <B>Design Element - Details</B><BR>
	 Specify Data
     </FONT>
    </TD>
  </TR>
</TABLE>
<!--Body Table -->

<TABLE BORDER="1" WIDTH="90%" BGCOLOR="<%=strBackColor%>" align="center">
  <TR>
    <TD COLSPAN="4" "ALIGN="MIDDLE" STYLE="BORDER-BOTTOM: RGB(255,255,255) SOLID THIN" WIDTH="100%">
    </TD>
  </TR>

 <FORM NAME="frmNewElement" METHOD="GET" ACTION="verif_elem.asp">
  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Created:</B>
      </FONT>
     </TD>

      <TD>
     <INPUT TYPE="Text" NAME="CreateDate" SIZE="20" VALUE="<%=strCreateDate%>" READONLY>
     </TD>

    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Last Modified:</B>
      </FONT>
     </TD>

      <TD>
     <INPUT TYPE="Text" NAME="LastModDate" SIZE="20" VALUE="<%=strLastMod%>" READONLY>
     </TD>
</TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Created by:</B>
      </FONT>
     </TD>

      <TD>
     <INPUT TYPE="Text" NAME="Creator" SIZE="9" VALUE="<%=strCreator%>" READONLY>
     </TD>

    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Last Modified by:</B>
      </FONT>
     </TD>

      <TD>
     <INPUT TYPE="Text" NAME="LastModBy" SIZE="8" VALUE="<%=strLastModBy%>" READONLY>
     </TD>
</TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Business Name:</B>
    </FONT>  
    </TD>
    <TD COLSPAN="3">
      <INPUT TYPE="TEXT" NAME="ElementBName" SIZE="80" VALUE="<%=strElementBName%>" READONLY>
    </TD>
  </TR>

   <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Dictionary Name:</B>
      </FONT>
    </TD>
    <TD COLSPAN="3">
      <INPUT TYPE="TEXT" NAME="ElementDName" SIZE="80" VALUE="<%=strElementDName%>" READONLY>
	</TD>
  </TR>

<%
If strFrom = "Add" Then
    If Len(strElementCName) > 18 then
%>  
<TR>
<FORM NAME="Resubmit" METHOD="GET" ACTION="add_elem_Dtls.asp">
      <TD ALIGN="Center" COLSPAN="3"><FONT COLOR="<%=strErrTextColor%>"><B>The column name is too long-
             Select the abbreviations remove
         </BR>
        </FONT>
      </TD>
  </TR>

<TR>
    <TD COLSPAN="3" ALIGN="center">
<%
      ReDim aryColNames(iTermCount)
      Dim chkBox
      For iTermCounter = 0 to iTermCount 
      chkBox = Request.Form("chkTerm" & iTermCounter)
           aryColNames(iTermCounter)= aryElementCName(iTermCounter)
          If chkBox = "ON" Then
          %>  <INPUT TYPE="TEXT" NAME="TERM" SIZE="8" VALUE="<%=aryElementCName(iTermCounter)%>" READONLY>
              <INPUT TYPE="checkbox" NAME="CHKTERM" VALUE="ON" CHECKED>
           <%Else
           %>  
        <INPUT TYPE="TEXT" NAME="TERM" SIZE="8" VALUE="<%=aryElementCName(iTermCounter)%>" READONLY>
        <INPUT TYPE="checkbox" NAME="CHKTERM" VALUE="OFF">
<%      End If
Next 
%>
 <TR>
	<TD ALIGN="center" COLSPAN="2">
	   <INPUT TYPE="hidden" NAME="numTerms" VALUE="<%=iTermCount%>">  
       <INPUT TYPE="hidden" NAME="From" VALUE="Add">
<!--   <INPUT TYPE="hidden" NAME="ElementCName" VALUE="">  
   <INPUT TYPE="HIDDEN" NAME="ElementBName" VALUE="<%=strElementBName%>">
   <INPUT TYPE="HIDDEN" NAME="ElementDName" VALUE="<%=strElementDName%>">
-->   <INPUT TYPE="Button" VALUE="ReSubmit" NAME="cmdReSubmit" OnClick="Resubmit()">
     </TD>
   </TR>
</FORM>
</TABLE>
</BODY>
          <%End IF%>
<TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Column Name:</B>
     </TD>
     <TD Colspan="3">
          <INPUT TYPE="TEXT" NAME="<%=strElementCName%>" SIZE="30" VALUE="<%=strElementCName%>" READONLY>
      </TD>
 </TR>
 
  <TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Data Type:</B></FONT>
    </TD>

    <TD WIDTH="512"><SELECT NAME="cboDataType" SIZE="1">
      <OPTION VALUE="Bool">Boolean </OPTION>
      <OPTION VALUE="Char">Character </OPTION>
      <OPTION VALUE="Curr">Currency </OPTION>
      <OPTION VALUE="Date">Date </OPTION>
      <OPTION VALUE="Date_Time">Date/Time </OPTION>
      <OPTION VALUE="Dec">Decimal </OPTION>
      <OPTION VALUE="Long">Long </OPTION>
      <OPTION VALUE="Int">Integer </OPTION>
      <OPTION VALUE="Short">Short </OPTION>
      <OPTION VALUE="Text">Text </OPTION>
      <OPTION VALUE="TimeStamp">Timestamp </OPTION>
      <OPTION VALUE="VarChar">Variable Character </OPTION>
<%If strFrom = "Query" Then%>
      <OPTION SELECTED VALUE="<%=strDataType%>" SELECTED><%=strDataType%></OPTION>
<%End If%>
    </SELECT></TD>

    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Decimal Length</B></FONT>
    </TD>

    <TD><INPUT NAME="txtDecLen" SIZE="5" VALUE="<%=strDecLen%>">
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Version:</B></FONT>
    </TD>

    <TD><INPUT NAME="txtVersion" SIZE="2" VALUE="<%=strElementVersion%>">
    </TD>

    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Status:</B></FONT>
    </TD>

    <TD><INPUT NAME="txtStatus" SIZE="5" VALUE="<%=strElementStatus%>" READONLY>
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Logical Length</B></FONT>
    </TD>

    <TD><INPUT NAME="txtLogLen" SIZE="5" VALUE="<%=strLogLen%>">
    </TD>

    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Physical Length</B></FONT>
    </TD>

    <TD><INPUT NAME="txtPhysLen" SIZE="5" VALUE="<%=strPhysLen%>">
    </TD>
  </TR>
<%If strFrom = "Query" then %>
  <TR>
    <TD VALIGN="top"><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Description</B></FONT>
    </TD>

    <TD COLSPAN="3"><TEXTAREA ROWS="7" NAME="txtDesc" COLS="80">
<%   Do While rs.EOF <> True 'Loop get all the matching rows
        If RS.Fields(12) = "" Then
            Response.Write chr(13)
            RS.MoveNext
        Else
            Response.Write rs.Fields(12)
            response.write chr(13)
        End If
     rs.MoveNext
  Loop
RS.Close
    End IF
End If%>
  <TR>
    <TD VALIGN="top"><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Description</B></FONT>
    </TD>
    <TD COLSPAN="3"><TEXTAREA ROWS="7" NAME="txtDesc" COLS="80">
    </TEXTAREA>
    </TD>
  </TR>
 
 <TR>
	<TD ALIGN="center" COLSPAN="4">
	   <INPUT TYPE="Button" VALUE="Submit" NAME="cmdSubmit">&nbsp;&nbsp;&nbsp;&nbsp;
	   <INPUT TYPE="reset" VALUE="Reset" NAME="cmdReset">
	</TD>
   </TR>
</FORM>
</TABLE>
</BODY>
