<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/New_ElemNme.inc"-->
<!--#INCLUDE FILE="../include/Rpt_Helper.inc"-->
<%
Response.Buffer=True
Session.TimeOut = 60
Dim strCreator
Dim strCreateTS
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
Dim aryElementKeyWords
Dim iLoopCount
Dim sqlCheckExists
Dim strFrom
Dim aryDesc()

If Request.QueryString("From") = "" Then
    strFrom = Request.Form("From")
Else
    strFrom = Request.QueryString("From")
End IF

Set rs=Session("rs")
'-----------------------------Add a new element case
Select Case strFrom

Case "Add"
Dim aryElementBName
Dim iTermCount
Dim iTermCounter
Dim aryElementCName
Dim strErrMessage
Dim bShowErrMessage

'Assemble the business name from the querystring
strCreator = Session("USERID")
strCreateTS = CreateTS()
strLastModBy = Session("USERID")
strLastMod = CreateTS()
strElementBName = UCASE(Request.Form("ElementBName"))
aryElementBName = SPLIT(strElementBName,"*")
strElementBName= UCASE(JOIN(aryElementBName))
strElementDName = UCASE(Request.Form("ElementDName"))
strElementCName = UCASE(Request.Form("ElementCName"))
aryElementCName = SPLIT(strElementCName,"_")
strElementCName= JOIN(aryElementCName,"_")
strElementKeyWords = UCASE(Request.Form("ElementKeyWords"))
aryElementKeyWords = SPLIT(strElementKeyWords,"*")
iTermCount = UBOUND(aryElementCName)
strElementVersion = "1"
strElementStatus = "DVLP"
strLogLen = ""
strPhysLen = ""
strDecLen = ""
strHistory="Add"
strTemp = CheckDuplicateAlias(strElementCName)
'response.write strTemp & "== " & strElemcName
'response.end
If strTemp <> "False" Then
    strQString = "query_result.asp?RelObject=Element&Dupl=Yes&Criteria=" & strTemp
    Response.Redirect strQString
End If
'------------------this is a query case-----------------------------------
Case "Query"
Dim sqlQuery
Dim bCanDelete

bCanDelete=True
If Request.QueryString("Col1") = "" Then
  strElementDName = GetElementDName(UCASE(TRIM(Request.Form("Criteria"))))
  strElementStatus = "DVLP"
  strElementVersion = "1"
  sqlCheckExists= "SELECT elmt_dict_nme FROM irma05_element"
  sqlCheckExists=sqlCheckExists & " WHERE elmt_dict_nme= '" & strElementDName & "'"
  If rs.State=1 then
    rs.Close
  End If
  rs.Open sqlCheckExists
  If rs.BOF = -1 then%>
  <SCRIPT LANGUAGE="VBScript">
   Sub Window_OnLoad
     MsgBox "Your query returned zero records." & chr(10) & "Please check your spelling.",,"Error"
     location.Href = "add_elem_nme.asp?Option=Maintain"
   End Sub
   </SCRIPT>
<%
'    Response.Write("<BODY BGCOLOR=" & strPageBackColor & " link=" & strLinkColor & " alink=" & strALinkColor & " vlink=" & strVLinkColor & " align=Center>")
'    Response.Write("<FONT FACE=Verdana><Center><h2><b>ERROR!</B></h2><br>")
'    Response.Write("<CENTER><h3>" & Request.Form("Criteria") & " does not exist or is not found in the database.</H3></CENTER><br>")
'    Response.Write("<Center><h4><A Href=add_elem_nme.asp?Option=Maintain>Add another element</a></center>")
    Response.End
  End If
  rs.Close
Else
   strElementDName = UCASE(TRIM(Request.QueryString("Col1")))
   strElementStatus = UCASE(TRIM(Request.QueryString("Col3")))
   strElementVersion = UCASE(TRIM(Request.QueryString("Col4")))
End If

If strElementStatus <> "DVLP" then
   bShowMessage = True
   bCanDelete=False
   strElementStatus = "DVLP"
   strErrMessage = "You can only edit elements in development status.<BR>"
   strErrMessage = strErrMessage & "The element you selected was in production.<BR>"
   strErrMessage = strErrMessage & "A copy has been made in development status for you.<BR>"
End if   

'Check if element is can be deleted
If bCanDelete then
     sqlQuery = "SELECT tbl_nme"
     sqlQuery = sqlQuery & " FROM irma03_table_elmt"
     sqlQuery = sqlQuery & " WHERE elmt_dict_nme = '" & strElementDName & "'"
     sqlQuery = sqlQuery & " and elmt_stat_cd = '" & strElementStatus & "'"
     sqlQuery = sqlQuery & " and elmt_vrsn_no = '" & strElementVersion & "'"     

      If rs.State = 1 then
         rs.Close
      End If
      rs.open(sqlQuery)           'Open the record set
      If rs.BOF = -1 then
         bCanDelete = True
      Else
         bCanDelete = False
      End If
     rs.Close
End If
'Get the keywords and put them in an array
     sqlQuery = "SELECT key_word_nme"
     sqlQuery = sqlQuery & " FROM irma07_elmt_kwd"
     sqlQuery = sqlQuery & " WHERE elmt_dict_nme = '" & strElementDName & "'"
     sqlQuery = sqlQuery & " and elmt_stat_cd = '" & strElementStatus & "'"

'Response.write sqlquery
'response.end
        If rs.State = 1 then
           rs.Close
        End If
        rs.open(sqlQuery)           'Open the record set

iLoopCount = 0
ReDim aryElementKeywords(100)
If not rs.BOF = -1 then
   Do while rs.EOF <> true
      ReDim Preserve aryElementKeyWords(iLoopCount)
      aryElementKeyWords(iLoopCount) = rs.Fields(0)
      iLoopCount = iLoopCount + 1 
      rs.moveNext
   Loop
Else
   aryElementKeyWords(0) = "None Found"
End If
rs.Close

'get the element details
        sqlQuery = "SELECT a.elmt_dict_nme, a.elmt_busns_nme, a.elmt_col_nme,"
        sqlQuery = sqlQuery & " a.elmt_stat_cd, b.elmt_vrsn_no, a.elmt_creat_uid, a.creat_ts,"
        sqlQuery = sqlQuery & " a.elmt_lst_chng_uid, a.elmt_lst_chng_ts, b.elmt_data_typ_id,"
        sqlQuery = sqlQuery & " b.elmt_logcl_lng, b.elmt_phys_lng, b.elmt_dec_lng, c.text_80_desc, c.seq_no"
        sqlQuery = sqlQuery & " FROM irma05_element a, irma04_elmt_vrsn b, irma06_elmt_desc c"
        sqlQuery = sqlQuery & " WHERE b.elmt_dict_nme = '" & strElementDName & "'"
        sqlQuery = sqlQuery & " and b.elmt_stat_cd = '" & strElementStatus & "'"
        sqlQuery = sqlQuery & " and b.elmt_vrsn_no = '" & strElementVersion & "'"
        sqlQuery = sqlQuery & " and a.elmt_dict_nme = b.elmt_dict_nme"
        sqlQuery = sqlQuery & " and a.elmt_stat_cd = b.elmt_stat_cd"
        sqlQuery = sqlQuery & " and b.elmt_dict_nme = c.elmt_dict_nme"
        sqlQuery = sqlQuery & " and a.elmt_stat_cd = c.elmt_stat_cd"
        sqlQuery = sqlQuery & " ORDER BY c.seq_no"

        If rs.State = 1 then
           rs.Close
        End If
        rs.open(sqlQuery)
If rs.BOF=-1 then
   response.write "error<br>"
   response.write sqlquery
   response.end
End If
strElementDName = UCASE(TRIM(rs.fields(0)))
strElementBName = UCASE(TRIM(rs.Fields(1)))
strElementCName = UCASE(TRIM(rs.fields(2)))
aryElementCName = Split(strElementCName,"_")
iTermCount = UBOUND(aryElementCName)
strElementStatus = TRIM(rs.fields(3))
strElementVersion = rs.fields(4)
strCreator = UCASE(TRIM(rs.Fields(5)))
strCreateTS = rs.Fields(6) 
strLastModBy = UCASE(TRIM(rs.Fields(7)))
strLastMod = TRIM(rs.Fields(8))
strDataType = TRIM(rs.Fields(9))
If rs.Fields(10) = "0" then
   strLogLen = ""
Else
   strLogLen = rs.fields(10)
End if
If rs.Fields(11) <> "0" then
  strPhysLen = rs.Fields(11)
Else
   strPhysLen=""
End If
If rs.Fields(12) = "0" Then
   strDecLen=""
Else
   strDecLen = rs.Fields(12)
End if
strHistory="Query"  
End Select

%>
<!--Add elemenent details-->
<SCRIPT LANGUAGE="VbScript">

Sub Window_OnLoad()
'     Document.frmNewElement.Item(5).Focus
End Sub

FUNCTION CheckBusnsName(TERM)
	If IsNumeric(Left(TERM ,1)) Then
	   CheckBusnsName= False
     Else
        CheckBusnsName = True
	 End If
END FUNCTION

Sub cmdResubmit_OnClick()
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
ElseIf Not CheckBusnsName(strElementCName) Then
   msgBox "Column names cannot begin with a numeric"
Else  
  objCurForm.ElementCName.value = strElementCName
  objCurForm.From.Value="Add"
  objCurForm.Action="add_elem_dtls.asp"
  objCurForm.Submit
End If
End sub

<!--#INCLUDE FILE="../include/frbdnChars.inc"-->

Function Validate()
  Dim objCurForm 
  Dim strQString
  Dim strEvalDataType
  Dim aryElemName
  Dim strValidBName
  Dim strValidLogLen
  Dim strValidDecLen
  Dim strDesc

Set objCurForm = Document.Forms.Item(0)
strEvalDataType = ObjCurForm.DataType.Value

If strEvalDataType="" Then
        msgBox "Please select a data type.",,"Error"
        objCurForm.DataType.Focus
        Validate=False
        Exit Function
ElseIf objCurForm.Desc.value = "" Then
        msgBox "Please enter a description.",,"Error"
        objCurForm.Desc.Focus
        Validate=False
        Exit Function
End IF

Select Case strEvalDataType
       Case "BLOB"
       IF objCurForm.LogLen.Value = "" then
           msgBox "Please specify a length.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF ValidChar(objCurForm.LogLen.Value) <> "True" then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.LogLen.Value) then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value < 1 then
           msgBox "BLOB data types must be at least 1 character.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select           
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value > 999 then
           msgBox "BLOB data types must be at least 999 characters.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "BLOB data types do not require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "CHAR"
       strValidLen = ValidChar(objCurForm.LogLen.Value)
       strValidDec = ValidChar(objCurForm.DecLen.Value)
       IF objCurForm.LogLen.Value = "" then
           msgBox "Please specify a length.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF strValidLen <> "True" then
           msgBox "The length field contains a forbidden character.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.LogLen.Value) then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value < 1 then
           msgBox "CHAR data types must be at least 1 character.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value > 999 then
           msgBox "CHAR data types cannto be more than 999 characters.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "CHAR data types do not require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "DATE"
        If objCurForm.LogLen.Value <> "" then
           msgBox "You cannot specify a length for DATE data types.",,"Error"
           objCurForm.LogLen.Value = ""
           objCurForm.LogLen.Focus
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "DATE data types do not require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "DECIMAL"
       IF objCurForm.LogLen.Value = "" then
           msgBox "Please specify a length.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF ValidChar(objCurForm.LogLen.Value) <> "True" then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.LogLen.Value) then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value = "" then
           msgBox "DECIMAL data types require decimals.",,"Error"
           objCurForm.DecLen.Value = ""
           objCurForm.DecLen.Focus
           Validate=False
           Exit Function
       ElseIF ValidChar(objCurForm.DecLen.Value) <> "True" then
           msgBox "The decimal field must be numeric.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.DecLen.Value) then
           msgBox "The decimal field must be numeric.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
       ElseIf objCurForm.LogLen.Value < 1 then
           msgBox "DECIMAL data types must be at least 1 character.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value > 99 then
           msgBox "DECIMAL data types cannot be more than 99 characters.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value > 99 then
           msgBox "DECIMAL data types cannot have more than 99 decimal places.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value > objCurForm.LogLen.Value then
           msgBox "DECIMAL data types cannot have decimal places greater then the logical length.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
       End If  

       Case "FLOAT"
       IF objCurForm.LogLen.Value = "" then
           msgBox "Please specify a length.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF ValidChar(objCurForm.LogLen.Value) <> "True" then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.LogLen.Value) then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value < 1 then
           msgBox "FLOAT data types must be at least 1 character.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value > 99 then
           msgBox "FLOAT data types cannot be more than 99 characters.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value = "" then
           msgBox "FLOAT data types require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.DecLen.Value) then
           msgBox "The Decimal field must be numeric.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value > 99 then
           msgBox "FLOAT data types cannot have more than 99 decimal places.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value > objCurForm.LogLen.Value then
           msgBox "FLOAT data types cannot have decimal places greater then the logical length.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "GRAPHIC"
       IF objCurForm.LogLen.Value = "" then
           msgBox "Please specify a length.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF ValidChar(objCurForm.LogLen.Value) <> "True" then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.LogLen.Value) then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIf objCurForm.LogLen.Value < 1 then
           msgBox "GRAPHIC data types must be at least 2 characters.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value > 999 then
           msgBox "GRAPHIC data types cannot be more than 999 characters.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "GRAPHIC data types do not require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "INTEGER"
        If objCurForm.LogLen.Value <> "" then
           msgBox "You cannot specify a length for INTEGER data types.",,"Error"
           objCurForm.LogLen.Value = ""
           objCurForm.LogLen.Focus
           Validate=False
           Exit Function
       ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "INTEGER data types do not require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "LONGVAR"
        If objCurForm.LogLen.Value <> "" then
           msgBox "You cannot specify a length for LONGVAR data types.",,"Error"
           objCurForm.LogLen.Value = ""
           objCurForm.LogLen.Focus
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "LONGVAR data types do not require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "SMALLINT"
        If objCurForm.LogLen.Value <> "" then
           msgBox "You cannot specify a length for SMALLINT data types.",,"Error"
           objCurForm.LogLen.Value = ""
           objCurForm.LogLen.Focus
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "SMALLINT data types do not require decimals.",,"Error"
           objCurForm.DecLen.Focus
           objCurForm.DecLen.Select
           Validate=False
           Exit Function
        End If  

       Case "TIMESTAMP"
        If objCurForm.LogLen.Value <> "" then
           msgBox "You cannot specify a length for TIMESTAMP data types.",,"Error"
           objCurForm.LogLen.Value = ""
           objCurForm.LogLen.Focus
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "TIMESTAMP data types do not require decimals.",,"Error"
           objCurForm.DecLen.Value = ""
           objCurForm.DecLen.Focus
           Validate=False
           Exit Function
        End If  

       Case "VARCHAR"
        If objCurForm.LogLen.Value = "" then
           msgBox "Please specify a length for VARCHAR data types.",,"Error"
           objCurForm.LogLen.Focus
           Validate=False
           Exit Function
       ElseIF ValidChar(objCurForm.LogLen.Value) <> "True" then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
       ElseIF Not IsNumeric(objCurForm.LogLen.Value) then
           msgBox "The length field must be numeric.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value < 1 then
           msgBox "VARCHAR data types must be at least character.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.LogLen.Value > 9999 then
           msgBox "VARCHAR data types cannot be grater than 9,999 characters.",,"Error"
           objCurForm.LogLen.Focus
           objCurForm.LogLen.Select
           Validate=False
           Exit Function
        ElseIf objCurForm.DecLen.Value <> "" then
           msgBox "VARCHAR data types do not require decimals.",,"Error"
           objCurForm.DecLen.Value = ""
           objCurForm.DecLen.Focus
           Validate=False
           Exit Function
        End If  
End Select
   strDesc=REPLACE(objCurForm.Desc.Value," ","*")
   objCurForm.Desc.Value=""
   objCurForm.Desc.Value=strDesc
'   strDesc=REPLACE(objCurForm.Desc.Value,chr(13),chr(10))
'   objCurForm.Desc.Value=""
'   objCurForm.Desc.Value=strDesc
   strDesc=REPLACE(objCurForm.Desc.Value,chr(39),"-")
   objCurForm.Desc.Value=""
   objCurForm.Desc.Value=strDesc
   strDesc=REPLACE(objCurForm.Desc.Value,chr(34),"--")
   objCurForm.Desc.Value=""
   objCurForm.Desc.Value=strDesc
   Validate=True
End Function

Sub cmdSubmit_OnClick()
Dim objCurForm 

Set objCurForm = Document.Forms.Item(0)

If validate then
   objCurForm.Method="Post"
   objCurForm.From.Value="Step3"
   objCurForm.Action="verif_elem.asp"
   objCurForm.Submit
Else
   Exit Sub
End If
End Sub     

Sub cmdUpdate_OnClick
Dim objCurForm 

Set objCurForm = Document.Forms.Item(0)

If Validate then
   objCurForm.Method="Post"
   objCurForm.From.Value="Update"
   objCurForm.Action="verif_elem.asp"
   objCurForm.Submit
Else
   Exit Sub
End If
End Sub

Sub cmdCancel_OnClick
Dim objCurForm 
Set objCurForm = Document.Forms.Item(0)

If objCurForm.History.Value="Add" then
   objCurForm.Method="Post"
   objCurForm.Action="add_elem_nme.asp"
   objCurForm.Submit
Else
   history.back
End If
End Sub

Sub cmdDelete_OnClick
Dim objCurForm 
Dim iAnswer
Set objCurForm = Document.Forms.Item(0)
iAnswer=msgbox("Are you sure you want to delete this element?",4,"Confirm delete")
If iAnswer=6 then
   objCurForm.Method="Post"
   objCurForm.From.Value="Delete"
   objCurForm.Action="verif_elem.asp"
   objCurForm.Submit
End If
End Sub

</SCRIPT>
<BODY BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strBackColor%>" cellpadding="0" CELLSPACING="0">
  <TR>
    <TD WIDTH="100%" BGCOLOR="<%=strHeaderColor%>" height="40" align="middle"><FONT FACE="Verdana">
      <B> Specify Data - Element Details</B>
     </FONT>
<%If strFrom = "Query" then
     If bShowMessage then %>
     <BR><FONT FACE="Verdana" COLOR="<%=strErrTextColor%>">
    <%=strErrMessage%>
     </FONT>
<%End If
End If%>
    </TD>
  </TR>
</TABLE>
<!--Body Table -->

<TABLE BORDER="0" WIDTH="100%" BGCOLOR="<%=strBackColor%>" align="center">
 <FORM NAME="frmNewElement" METHOD="POST" ACTION="verif_elem.asp">
  <TR>
    <TD COLSPAN="4" "ALIGN="MIDDLE" STYLE="BORDER-BOTTOM RGB(255,255,255) SOLID THIN" WIDTH="100%">
    </TD>
  </TR>

<TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Status</FONT>
    </TD>

    <TD><%=strElementStatus%>
      <INPUT TYPE="HIDDEN" NAME="Status" VALUE="<%=strElementStatus%>">
      <INPUT TYPE="HIDDEN" NAME="Creator" VALUE="<%=strCreator%>"> 
      <INPUT TYPE="HIDDEN" NAME="CreateTS" VALUE="<%=strCreateTS%>"> 
      <INPUT TYPE="HIDDEN" NAME="From" VALUE="Step3"> 
      <INPUT TYPE="HIDDEN" NAME="History" VALUE="<%=strHistory%>">       
    </TD>

    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Version</B>
     </TD>
     
    <TD><%=strElementVersion%>
      <INPUT TYPE="HIDDEN" NAME="Version" VALUE="<%=strElementVersion%>">
    </TD>
</TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Business Name</B>
    </FONT>  
    </TD>

    <TD COLSPAN="3">
      <INPUT TYPE="TEXT" NAME="ElementBName1" SIZE="60" VALUE="<%=strElementBName%>" READONLY>
      <INPUT TYPE="HIDDEN" NAME="ElementBName" VALUE="<%=UCASE(JOIN(SPLIT(strElementBName),"*"))%>">
    </TD>
  </TR>

<TR>

    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Dictionary Name</B>
    </FONT>
    </TD>

    <TD COLSPAN="3">
      <INPUT TYPE="TEXT" NAME="ElementDName" SIZE="60" VALUE="<%=strElementDName%>" READONLY>
	</TD>
  </TR>

<%
Select Case strFrom
Case "Add"
    If Len(strElementCName) > 18 then
%>  
<TR>
      <TD ALIGN="Center" COLSPAN="4"><FONT COLOR="<%=strErrTextColor%>"><B>The column name is too long-
             Select the abbreviations remove
         </BR>
        </FONT>
      </TD>
  </TR>

<TR>
    <TD COLSPAN="4" ALIGN="center">
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
   <TD COLSPAN="4">
   <FONT FACE="Verdana" SIZE="2">
     <B>This element will be created on <%=strCreateTS%> by <%=strCreator%><BR>
        The keywords are&nbsp;
<%
  Response.Write "<INPUT TYPE=HIDDEN NAME=ElementKeyWords VALUE=" & strElementKeyWords & ">"
  For i = 0 to UBOUND(aryElementKeyWords)
     If InStr(aryElementKeyWords(i),"$") then
         strTemp = JOIN(SPLIT(aryElementKeyWords(i),"$"))
         If i = UBOUND(aryElementKeyWords) then
            Response.Write "and " & strTemp & "."
         Else
            Response.Write strTemp & ","
         End If
      Else
         If i = UBOUND(aryElementKeyWords) then
            Response.Write "and " & aryElementKeyWords(i) & "."
         Else 
            Response.Write aryElementKeyWords(i) & ", "
         End If
      End If 
   Next%>
    </B>
   </FONT>
   <INPUT TYPE="HIDDEN" NAME="ModifiedBy" VALUE="<%Session("UserID")%>">
   </TD>
</TR>

 <TR>
	<TD ALIGN="center" COLSPAN="4">
  	   <INPUT TYPE="HIDDEN" NAME="ElementCName" VALUE="<%=strElementCName%>">  
  	   <INPUT TYPE="HIDDEN" NAME="NumTerms" VALUE="<%=iTermCount%>">  
       <INPUT TYPE="BUTTON" VALUE="ReSubmit" NAME="cmdReSubmit">
     </TD>
   </TR>
</FORM>
</TABLE>
</BODY>
<%
   Else
%>  

<TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Column Name</B>
   </TD>

    <TD COLSPAN="3">
       <INPUT TYPE="TEXT" NAME="ElementCName" SIZE="30" VALUE="<%=strElementCName%>" READONLY>
    </TD>
</TR>
<TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Data Type</B></FONT>
    </TD>

    <TD>
      <SELECT NAME="DataType" SIZE="1">
      <OPTION SELECTED>--Select a data type--</OPTION>
      <OPTION VALUE="BLOB">Blob</OPTION>
      <OPTION VALUE="CHAR">Character</OPTION>
      <OPTION VALUE="DATE">Date</OPTION>
      <OPTION VALUE="DECIMAL">Decimal</OPTION>
      <OPTION VALUE="FLOAT">Float</OPTION>
      <OPTION VALUE="GRAPHIC">Graphic</OPTION>
      <OPTION VALUE="INTEGER">Integer</OPTION>
      <OPTION VALUE="LONGVAR">Long Variable</OPTION>
      <OPTION VALUE="SMALLINT">Small Integer</OPTION>
      <OPTION VALUE="TIMESTAMP">Timestamp </OPTION>
      <OPTION VALUE="VARCHAR">Variable Character </OPTION>
      </SELECT>
    </TD>
</TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Length</B></FONT>
    </TD>

    <TD><INPUT NAME="LogLen" SIZE="8" VALUE="<%=strLogLen%>" maxlength="8">
    </TD>
<!--
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Physical Length</B></FONT>
    </TD>

    <TD><INPUT NAME="PhysLen" SIZE="5" VALUE="<%=strPhysLen%>">
    </TD>
-->
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Decimal Places</B></FONT>
    </TD>

    <TD>
     <INPUT NAME="DecLen" SIZE="3" VALUE="<%=strDecLen%>" maxlength="3">
    </TD>
</TR>

  <TR>
    <TD COLSPAN="4"><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Description</B></FONT>
    </TD>
  </TR>

  <TR>
    <TD COLSPAN="4"><TEXTAREA ROWS="7" NAME="Desc" COLS="80" WRAP="hard"></TEXTAREA>
    </TD>
  </TR>
<TR>
   <TD COLSPAN="4">
   <FONT FACE="Verdana" SIZE="2">
     <B>This element will be created on <%=strCreateTS%> by <%=strCreator%><BR>
        The keywords are&nbsp;
   <INPUT TYPE="HIDDEN" NAME="ElementKeyWords" VALUE="<%=strElementKeyWords%>">  
<%
   For i = 0 to UBOUND(aryElementKeyWords)
     If InStr(aryElementKeyWords(i),"$") then
         strTemp = JOIN(SPLIT(aryElementKeyWords(i),"$"))
         If i = UBOUND(aryElementKeyWords) then
            Response.Write "and " & strTemp & "."
         Else
            Response.Write strTemp & ","
         End If
      Else
         If i = UBOUND(aryElementKeyWords) then
            Response.Write "and " & aryElementKeyWords(i) & "."
         Else 
            Response.Write aryElementKeyWords(i) & ", "
         End If
      End If 
   Next%>
    </B>
   </FONT>
   <INPUT TYPE="HIDDEN" NAME="LastModBy" VALUE="<%=strLastModBy%>">
   </TD>
</TR>

 <TR>
	<TD ALIGN="center" COLSPAN="4">
	   <INPUT TYPE="Button" VALUE="Submit" NAME="cmdSubmit">&nbsp;&nbsp;&nbsp;&nbsp;
	   <INPUT TYPE="reset" VALUE="Cancel" NAME="cmdCancel">
	</TD>
   </TR>
</FORM>
</TABLE>
</BODY>
<%End If

Case"Query"
%>

<TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Column Name</B>
     </TD>
     <TD COLSPAN="3">
          <INPUT TYPE="TEXT" NAME="ElementCName" SIZE="30" VALUE="<%=strElementCName%>" READONLY>
      </TD>
</TR>

<TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Data Type</B></FONT>
    </TD>

    <TD><SELECT NAME="DataType" SIZE="1">
      <OPTION SELECTED VALUE="<%=strDataType%>" SELECTED><%=strDataType%></OPTION>
      <OPTION VALUE="BLOB">Blob</OPTION>
      <OPTION VALUE="CHAR">Character</OPTION>
      <OPTION VALUE="DATE">Date</OPTION>
      <OPTION VALUE="DECIMAL">Decimal</OPTION>
      <OPTION VALUE="FLOAT">Float</OPTION>
      <OPTION VALUE="GRAPHIC">Graphic</OPTION>
      <OPTION VALUE="INTEGER">Integer</OPTION>
      <OPTION VALUE="LONGVAR">Long Variable</OPTION>
      <OPTION VALUE="SMALLINT">Small Integer</OPTION>
      <OPTION VALUE="TIMESTAMP">Timestamp </OPTION>
      <OPTION VALUE="VARCHAR">Variable Character </OPTION>
    </SELECT>
    </TD>
</TR>


  <TR>
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Length</B></FONT>
    </TD>

    <TD><INPUT NAME="LogLen" SIZE="8" VALUE="<%=strLogLen%>" maxlength="8">
    </TD>
<!--
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Physical Length</B></FONT>
    </TD>

    <TD><INPUT NAME="txtPhysLen" SIZE="5" VALUE="<%=strPhysLen%>">
    </TD>
-->
    <TD><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Decimal Places</B></FONT>
    </TD>

    <TD>
     <INPUT NAME="DecLen" SIZE="3" VALUE="<%=strDecLen%>" maxlength="3">
    </TD>
</TR>

  <TR>
    <TD COLSPAN="4"><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Description</B></FONT>
    </TD>
  </TR>

<TR>
   <TD COLSPAN="4">
<%
iLoopCount = 0
    Do While rs.EOF <> True
        ReDim PRESERVE aryDesc(iLoopCount)
        aryDesc(iLoopCount) = RTRIM(rs.Fields(13))
        iLoopCount = iLoopCount + 1
        rs.MoveNext
  Loop
  rs.Close
%>
   <TEXTAREA ROWS="8" NAME="Desc" COLS="80" WRAP="hard"><%
       For iLoopCount = 0 to UBOUND(aryDesc)
           Response.Write aryDesc(iLoopCount) & chr(10)
       Next
       %></TEXTAREA>
         </TD>
</TR>
<TR>
   <TD COLSPAN="4">
   <FONT FACE="Verdana" SIZE="2">
     <B>This element was created on <%=strCreateTS%> by <%=strCreator%><BR>
        and was last modified on <%=strLastMod%> by <%=strLastModBy%>.<BR>
        The keywords are&nbsp;
<%For i = 0 to UBOUND(aryElementKeyWords)
     If InStr(aryElementKeyWords(i),"$") then
         strTemp = JOIN(SPLIT(aryElementKeyWords(i),"$"))
         If i = UBOUND(aryElementKeyWords) then
            Response.Write "and " & strTemp & "."
         Else
            Response.Write strTemp & ","
         End If
      Else
         If i = UBOUND(aryElementKeyWords) then
             response.Write "and " & aryElementKeyWords(i) & "."
         Else
            response.Write aryElementKeyWords(i) & ", "
         End If
      End If 
   Next%>
   </FONT>
   <INPUT TYPE="HIDDEN" NAME="LastModBy" VALUE="<%=strLastModBy%>">
   </TD>
</TR>

 <TR>
	<TD ALIGN="center" COLSPAN="4">
	   <INPUT TYPE="Button" VALUE="Update" NAME="cmdUpdate">&nbsp;&nbsp;&nbsp;&nbsp;
<% If bCanDelete then %>
	   <INPUT TYPE="Button" VALUE="Delete" NAME="cmdDelete">&nbsp;&nbsp;&nbsp;&nbsp;
<%End If %>
	   <INPUT TYPE="Button" VALUE="Cancel" NAME="cmdCancel">
	</TD>
   </TR>
</FORM>
</TABLE>
</BODY>
<%End Select%>