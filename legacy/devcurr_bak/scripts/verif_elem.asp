<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/New_ElemNme.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Dim sqlQuery
Dim sqlCheckExists
Dim strQString
Dim aryOrgTerms
Dim aryStdAbbrs
Dim strElemBName
Dim strElemDName
Dim aryElemDName()
Dim aryElemDesc
Dim iArrayCount
Dim strElemCName
Dim strStdAbbrs
Dim strTemp
Dim aryTerms
Dim iNotFound
Dim aryKeyWords()
Dim strKeyWords
Dim iKeyWordIndex
Dim strFrom
Dim strHeaderMsg
Dim strViewMsg
Dim strAddNewMsg
Dim bError
Dim con
Dim rs

Set con=Session("Con")
Set rs=Session("rs")
strFrom = Request.Form("From")

'------------------------------------------Case start adding to db
Select Case strFrom
Case "New"
Dim bDNorm
Dim strClassWord
Dim strDNormNo

strCriteria = UCASE(TRIM(Request.Form("Criteria"))) 
strClassWord = UCASE(TRIM(Request.Form("Classword")))
strDNormNo = UCASE(TRIM(Request.Form("DNormNo")))

strElemBName = strCriteria
aryElemBName = SPLIT(strElemBName)

If aryElemBName(UBOUND(aryElemBName)) =  strClassWord Then
    strElemBName = UCASE(JOIN(aryElemBName))
Else
    strElemBName=UCASE(strElemBName & " " & strClassWord)
End If

If strDNormNo = "" then
   strElemBName=UCASE(TRIM(strElemBName))
Else
   strElemBName=UCASE(strElemBName & " " & strDNormNo)
   bDNorm = True
End If

'Check for existing element
strTemp = CheckExisting(strElemBName)
If strTemp <> "False" Then
    strQString = "query_result.asp?RelObject=Element&Dupl=Yes&Criteria=" & strTemp
    Response.Redirect strQString
End If
'If bName does not exist, parse and get abbrs
aryTermsRet = SPLIT(strElemBName)
aryOrgTerms=GetStdAbbr(aryTermsRet)
aryStdAbbrs = FindPhrases(aryTermsRet)
iKeywordIndex = 0
ReDim aryKeyWords(100)
For i = 0 to UBOUND(aryStdAbbrs)
    aryKeywords(iKeyWordIndex) = aryStdAbbrs(i,1)
    iKeywordIndex = iKeywordIndex + 1
    aryKeywords(iKeyWordIndex) = aryStdAbbrs(i,0)
    iKeywordIndex = iKeywordIndex + 1    
next

For i = 0 to UBOUND(aryStdAbbrs)
    If aryStdAbbrs(i,2) <> "" Then     'If there are phrases returned, there will be nulls in the array
       ReDim PRESERVE aryElemDName(iArrayCount)
       aryElemDName(iArrayCount) = aryStdAbbrs(i,2)
       aryKeywords(iKeyWordIndex) = aryStdAbbrs(i,2)
       iKeywordIndex = iKeywordIndex + 1
       aryKeywords(iKeyWordIndex) = JOIN(SPLIT(aryStdAbbrs(i,4)),"$")   'split the phrase keyword with $
       iKeywordIndex = iKeywordIndex + 1
       iArrayCount = iArrayCount + 1
    End If
Next
strKeyWords = aryKeyWords(0)
For i = 0 to UBOUND(aryKeyWords)
If aryKeyWords(i) <> "" then
   If InStr(strKeyWords,aryKeyWords(i)) = 0 then
    strKeyWords  = strKeyWords & "*" & aryKeyWords(i)
  End IF
End If
Next
strElemBName = ""
For i = 0 to UBOUND(aryOrgTerms)
    strElemBName = strElemBName & "*" & aryOrgTerms(i,0)
Next
strElemDName = UCASE(JOIN(aryElemDName,"-"))
'Check dName for duplicate alias
strElemCName = UCASE(JOIN(aryElemDName,"_"))
strTemp = CheckDuplicateAlias(strElemDName)
'response.write strTemp & "== " & strElemcName
'response.end
If strTemp <> "False" Then
    strQString = "query_result.asp?RelObject=Element&Dupl=Yes&Criteria=" & strTemp
    Response.Redirect strQString
End If
iNotFound = InStr(strElemDName,"??")
Session("Criteria") = strElemBName
Session("ClassWord") = strClassWord
Session("DNormNo") = strDNormNo
Session("DNorm") = bDNorm
If iNotFound > 0 Then
   strTemp=JOIN(aryElemDName,"*")
   Session("ErrTerm") = strTemp
%>
      <SCRIPT LANGUAGE=VBSCRIPT>
       Sub Window_OnLoad()
           Document.Error.Submit
       End Sub
       </SCRIPT>
       <FORM NAME="Error" METHOD="POST" ACTION="add_elem_nme.asp">
       <INPUT TYPE="HIDDEN" NAME="From" VALUE="Error">
       </FORM>
<%
Else
arySuggDictNames = GetSuggested(strCriteria & " " & strClassWord)
Session("aryElemDictNames") = arySuggDictNames
strElemBName=UCASE(JOIN(aryTermsRet,"*"))
%>
'<!--this was commented from old way if going straight to element details
'<SCRIPT LANGUAGE=VBSCRIPT>
'Sub Window_OnLoad()
'  Document.Add.Submit
'End Sub
'</SCRIPT>
'<FORM NAME="Add" METHOD="POST" ACTION="add_elem_dtls.asp">
'<INPUT TYPE=HIDDEN NAME=ELEMENTBNAME VALUE="<%=strElemBName%>">
'<INPUT TYPE=HIDDEN NAME=ELEMENTDNAME VALUE="<%= strElemDName%>">
'<INPUT TYPE=HIDDEN NAME=ELEMENTCNAME VALUE="<%=strElemCName%>">
'<INPUT TYPE=HIDDEN NAME=ELEMENTKEYWORDS VALUE="<%=strKeyWords%>">
'<INPUT TYPE="HIDDEN" NAME="From" VALUE="Add">
'</FORM>
-->
<%
Session("strElemBName") = strElemBName
Session("strElemDName") = strElemDName
Session("strElemCName") = strElemCName
Session("strKeyWords") = strKeyWords
Session("strDNormNo") = strDNormNo
strQString = "add_elem_suggs.asp"
Response.Redirect strQString
End If
'--------------------------Case add to post to irma01 database final step
Case "Step3"
Dim sqlAddElement
Dim sqlAddElementDesc
Dim sqlAddElementVer
Dim sqlAddElementKeywords
Dim aryTempKeyWords
strElemDName = UCASE(TRIM(Request.Form("ElementDName")))
strElemStat = UCASE(TRIM(Request.Form("Status")))
strElemBName = UCASE(TRIM(Request.Form("ElementBName")))
aryElemBName = SPLIT(strElemBName,"*")
strElemBName = UCASE(JOIN(aryElemBName))
strElemCName = UCASE(TRIM(Request.Form("ElementCName")))
strCreator = UCASE(TRIM(Request.Form("Creator")))
strLastModBy = strCreator
strLastModTS = CreateTS()
strElemVer = UCASE(TRIM(Request.Form("Version")))
strDataType = UCASE(TRIM(Request.Form("DataType")))

If UCASE(TRIM(Request.Form("PhysLen"))) <> "" then
   strElemPLen = UCASE(TRIM(Request.Form("PhysLen")))
Else
   strElemPLen = "0"
End IF
If UCASE(TRIM(Request.Form("LogLen"))) <> "" then
   strElemLLen = UCASE(TRIM(Request.Form("LogLen")))
Else
   strElemLLen = "0"
End IF
If UCASE(TRIM(Request.Form("DecLen"))) <> "" then
   strElemDLen = UCASE(TRIM(Request.Form("DecLen")))
Else
   strElemDLen = "0"
End IF

'If InStr(Request.Form("Desc"),Chr(10)) then
'    aryElemDesc = SPLIT(Request.Form("Desc"),"+")
'Else
    aryElemDesc = SPLIT(Request.Form("Desc"),chr(10))
'End If
strCreateTS = CreateTS()

aryTempKeyWords = SPLIT(Request.Form("ElementKeyWords"),"*")

sqlCheckExists= "SELECT elmt_dict_nme FROM irma05_element"
sqlCheckExists=sqlCheckExists & " WHERE elmt_dict_nme= '" & strElemDName & "'"
If rs.State=1 then
   rs.Close
End If

rs.Open sqlCheckExists
If rs.BOF <> -1 then
   Response.Redirect "query_result.asp?RelObject=Element&Dupl=Yes&Criteria=" & strElemDName
End If
rs.Close

sqlAddElement = "INSERT INTO irma05_element VALUES ("
sqlAddElement = sqlAddElement & "'" & strElemDName & "', "
sqlAddElement = sqlAddElement & "'" & strElemStat & "', "
sqlAddElement = sqlAddElement & "'" & strElemBName & "', "
sqlAddElement = sqlAddElement & "'" & strElemCName & "', "
sqlAddElement = sqlAddElement & "'" & strCreator & "', "
sqlAddElement = sqlAddElement & "'" & strLastModBy & "', "
sqlAddElement = sqlAddElement & "'" & strLastModTS & "', "
sqlAddElement = sqlAddElement & "'N', "
sqlAddElement = sqlAddElement & "'" & strCreator & "', "
sqlAddElement = sqlAddElement & "'" & strLastModBy & "', "
sqlAddElement = sqlAddElement & "'" & strLastModTS & "', "
sqlAddElement = sqlAddElement & "'" & strCreateTS & "') "

sqlAddElementVer = "INSERT INTO irma04_elmt_vrsn VALUES ("
sqlAddElementVer = sqlAddElementVer & "'" & strElemDName & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strElemStat & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strElemVer & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strDataType & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strElemLLen & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strElemPLen & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strElemDLen & "', "
sqlAddElementVer = sqlAddElementVer & "'N', "
sqlAddElementVer = sqlAddElementVer & "'" & strCreator & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strLastModBy & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strLastModTS & "', "
sqlAddElementVer = sqlAddElementVer & "'" & strCreateTS & "') "

con.BeginTrans
  con.Execute sqlAddElement,1,1
'Con.Rollbacktrans

For i = 0 to UBOUND(aryElemDesc)
    strElemDesc = REPLACE(aryElemDesc(i),"*"," ")
    sqlAddElementDesc = "INSERT INTO irma06_elmt_desc VALUES ("
    sqlAddElementDesc = sqlAddElementDesc & "'" & strElemDName & "', "
    sqlAddElementDesc = sqlAddElementDesc & "'" & strElemStat & "', "
    sqlAddElementDesc = sqlAddElementDesc & "'" & i + 1 & "', "
    sqlAddElementDesc = sqlAddElementDesc & "'" & strElemDesc & "', "
    sqlAddElementDesc = sqlAddElementDesc & "'N', "
    sqlAddElementDesc = sqlAddElementDesc & "'" & strCreator & "', "
    sqlAddElementDesc = sqlAddElementDesc & "'" & strLastModBy & "', "
    sqlAddElementDesc = sqlAddElementDesc & "'" & strLastModTS & "', "
    sqlAddElementDesc = sqlAddElementDesc & "'" & strCreateTS & "') "
    con.Execute sqlAddElementDesc,1,1
'response.write    sqlAddElementDesc
     strElemDesc = ""
Next   
     con.Execute sqlAddElementVer
For i = 0 to UBOUND(aryTempKeyWords)
    If aryTempKeyWords(i) <> "" then
       If Instr(aryTempKeyWords(i),"$") then 
          aryTempKeyWords(i) = Replace(aryTempKeyWords(i),"$"," ")
       End If
    sqlAddElementKeywords = "INSERT INTO irma07_elmt_kwd VALUES ("
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'" & strElemDName & "', "
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'" & strElemStat & "', "
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'" & aryTempKeyWords(i) & "', "
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'N', "
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'" & strCreator & "', "
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'" & strLastModBy & "', "
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'" & strLastModTS & "', "
    sqlAddElementKeywords =  sqlAddElementKeywords  & "'" & strCreateTS & "') "
    con.Execute sqlAddElementKeyWords,1,1
    End If
 Next
con.CommitTrans
StrHeaderMsg = strElemBName & " was sucessfully added."
strAddNewMsg = "<A Href=add_elem_nme.asp>Add another?</a>"
strViewMsg = "<A Href=add_elem_dtls.asp?From=Query&col1=" & strElemDName & "&Col3=" & strElemStat & "&Col4=" & strElemVer & ">"
strViewMsg = strViewMsg & "View the element just updated.</A>"

'---------------------------------Update from an existing element
Case "Update"
Dim sqlUpdateElement
Dim sqlUpdateElementDesc
Dim sqlUpdateElementVer
Dim strCreateTS

strElemDName = UCASE(TRIM(Request.Form("ElementDName")))
strElemStat = UCASE(TRIM(Request.Form("Status")))
strElemBName = UCASE(TRIM(Request.Form("ElementBName")))
aryElemBName = SPLIT(strElemBName,"*")
strElemBName = UCASE(JOIN(aryElemBName))
strElemCName = UCASE(TRIM(Request.Form("ElementCName")))
strCreator = UCASE(TRIM(Request.Form("Creator")))
strCreateTS = UCASE(TRIM(Request.Form("CreateTS")))
strLastModBy = UCASE(Session("UserId"))
strLastModTS = CreateTS()
strElemVer = UCASE(TRIM(Request.Form("Version")))
strDataType = UCASE(TRIM(Request.Form("DataType")))

If UCASE(TRIM(Request.Form("PhysLen"))) <> "" then
   strElemPLen = UCASE(TRIM(Request.Form("PhysLen")))
Else
   strElemPLen = "0"
End IF
If UCASE(TRIM(Request.Form("LogLen"))) <> "" then
   strElemLLen = UCASE(TRIM(Request.Form("LogLen")))
Else
   strElemLLen = "0"
End IF
If UCASE(TRIM(Request.Form("DecLen"))) <> "" then
   strElemDLen = UCASE(TRIM(Request.Form("DecLen")))
Else
   strElemDLen = "0"
End IF

'If InStr(Request.Form("Desc"),"+") then
'   REPLACE Request.Form("Desc"),"+",chr(10)
'End If
aryElemDesc = SPLIT(Request.Form("Desc"),Chr(10))
'response.write aryelemdesc(0) & "<br>"
'response.write aryelemdesc(1) & "<br>"
'response.write(Request.Form("Desc")) & "<br>"
'response.end

sqlCheckExists= "SELECT elmt_dict_nme FROM irma05_element"
sqlCheckExists=sqlCheckExists & " WHERE elmt_dict_nme= '" & strElemDName & "'"
If rs.State=1 then
   rs.Close
End If
rs.Open sqlCheckExists
If rs.BOF = -1 then
bError = True
strHeaderMsg = "ERROR!<br>"
strHeaderMsg = strHeaderMsg & strElemBName & " does not exist or is not found in the database."
strAddNewMsg = "<A Href=add_elem_nme.asp>Add another element</a>"
End If
rs.Close

sqlUpdateElement = "UPDATE irma05_element SET "
sqlUpdateElement = sqlUpdateElement & "elmt_lst_chng_uid= '" & strLastModBy & "', "
sqlUpdateElement = sqlUpdateElement & "elmt_lst_chng_ts= '" & strLastModTS & "', "
sqlUpdateElement = sqlUpdateElement & "lst_chng_user_id= '" & strLastModBy & "', "
sqlUpdateElement = sqlUpdateElement & "lst_chng_ts= '" & strLastModTS & "' "
sqlUpdateElement = sqlUpdateElement & "WHERE elmt_dict_nme= '" & strElemDName & "' "
sqlUpdateElement = sqlUpdateElement & "AND elmt_stat_cd= '" & strElemStat & "' "

sqlUpdateElementVer = "UPDATE irma04_elmt_vrsn SET "
sqlUpdateElementVer = sqlUpdateElementVer & "elmt_vrsn_no= '" & strElemVer & "', "
sqlUpdateElementVer = sqlUpdateElementVer & "elmt_data_typ_id= '" & strDataType & "', "
sqlUpdateElementVer = sqlUpdateElementVer & "elmt_logcl_lng= '" & strElemLLen & "', "
sqlUpdateElementVer = sqlUpdateElementVer & "elmt_phys_lng= '" & strElemPLen & "', "
sqlUpdateElementVer = sqlUpdateElementVer & "elmt_dec_lng='" & strElemDLen & "', "
sqlUpdateElementVer = sqlUpdateElementVer & "lst_chng_user_id= '" & strLastModBy & "', "
sqlUpdateElementVer = sqlUpdateElementVer & "lst_chng_ts= '" & strLastModTS & "' "
sqlUpdateElementVer = sqlUpdateElementVer & "WHERE elmt_dict_nme= '" & strElemDName & "' "
sqlUpdateElementVer = sqlUpdateElementVer & "AND elmt_stat_cd= '" & strElemStat & "' "
sqlUpdateElementVer = sqlUpdateElementVer & "AND elmt_vrsn_no= '" & strElemVer & "' "

sqlDelOldElementDesc = "DELETE FROM irma06_elmt_desc "
sqlDelOldElementDesc = sqlDelOldElementDesc & " WHERE elmt_dict_nme= '" & strElemDName & "' "
sqlDelOldElementDesc = sqlDelOldElementDesc & " AND elmt_stat_cd= '" & strElemStat & "' "

'Con.RollBackTrans
con.BeginTrans
   con.Execute sqlUpdateElement
   con.Execute sqlDelOldElementDesc,1,1
'response.write sqlUpdateElement & "<br>-------"
'response.write sqlDeloldElementdesc & "<br>-------"
For i = 0 to UBOUND(aryElemDesc)
    strElemDesc = REPLACE(aryElemDesc(i),"*"," ")
    sqlUpdateElementDesc = "INSERT INTO irma06_elmt_desc VALUES ("
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & strElemDName & "', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & strElemStat & "', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & i + 1 & "', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & strElemDesc & "', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'N', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & strCreator & "', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & strLastModBy & "', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & strLastModTS & "', "
    sqlUpdateElementDesc = sqlUpdateElementDesc & "'" & UpdateTS(strCreateTS) & "') "
'response.write sqlUpdateElementdesc & "<br>"
    con.execute sqlUpdateElementDesc,1,1
    strElemDesc = ""
Next   
   con.Execute sqlUpdateElementVer
con.CommitTrans

strHeaderMsg = strElemBName & " was sucessfully updated."
strAddNewMsg = "<A Href=add_elem_nme.asp>Add another?</a>"
strViewMsg = "<A Href=add_elem_dtls.asp?From=Query&col1=" & strElemDName & "&Col3=" & strElemStat & "&Col4=" & strElemVer & ">"
strViewMsg = strViewMsg & "View the element just updated.</A>"
'Response.End
'-----------------------------------Case to delete element
Case "Delete"
Dim sqlDeleteElement
Dim sqlDeleteElementDesc
Dim sqlDeleteElementVer

strElemDName = UCASE(TRIM(Request.Form("ElementDName")))
strElemStat = UCASE(TRIM(Request.Form("Status")))
strElemBName = UCASE(TRIM(Request.Form("ElementBName")))
aryElemBName = SPLIT(strElemBName,"*")
strElemBName = UCASE(JOIN(aryElemBName))
strElemCName = UCASE(TRIM(Request.Form("ElementCName")))
strElemVer = UCASE(TRIM(Request.Form("Version")))

sqlCheckExists= "SELECT elmt_dict_nme FROM irma05_element "
sqlCheckExists=sqlCheckExists & " WHERE elmt_dict_nme = '" & strElemDName & "'"
If rs.State=1 then
   rs.Close
End If
rs.Open sqlCheckExists
If rs.BOF = -1 then
bError = True
 strHeaderMsg = "ERROR!<br>"
 strHeaderMsg = strHeaderMsg & strElemBName & " does not exist or is not found in the database."
 strAddNewMsg = "<A Href=add_elem_nme.asp>Add another element</a>"
End If
rs.Close

sqlDeleteElement = "DELETE FROM irma05_element "
sqlDeleteElement = sqlDeleteElement & " WHERE elmt_dict_nme= '" & strElemDName & "' "
sqlDeleteElement = sqlDeleteElement & " AND elmt_stat_cd= '" & strElemStat & "' "

sqlDeleteElementVer = "DELETE FROM irma04_elmt_vrsn "
sqlDeleteElementVer = sqlDeleteElementVer & " WHERE elmt_dict_nme= '" & strElemDName & "' "
sqlDeleteElementVer = sqlDeleteElementVer & " AND elmt_stat_cd= '" & strElemStat & "' "
sqlDeleteElementVer = sqlDeleteElementVer & " AND elmt_vrsn_no= '" & strElemVer & "' "

sqlDeleteElementDesc = "DELETE FROM irma06_elmt_desc "
sqlDeleteElementDesc = sqlDeleteElementDesc & " WHERE elmt_dict_nme= '" & strElemDName & "' "
sqlDeleteElementDesc = sqlDeleteElementDesc & " AND elmt_stat_cd= '" & strElemStat & "' "

con.BeginTrans
    con.Execute sqlDeleteElement
    con.Execute sqlDeleteElementVer
    con.Execute sqlDeleteElementDesc
con.CommitTrans

strHeaderMsg = strElemBName & " was sucessfully deleted."
strAddNewMsg = "<A Href=add_elem_nme.asp>Add another element.</a>"
End Select
%>
<HTML>
<BODY BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<TABLE BORDER="0" WIDTH="80%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <TR>
    <TD WIDTH="100%" HEIGHT="20" ALIGN="center">
<%If bError then%>
    <FONT FACE="Verdana" SIZE="3" COLOR="<%=strErrTextColor%>"><CENTER><H3><%=strHeaderMsg%></H3></FONT>
<%Else%>
   <FONT FACE="Verdana" SIZE="3"><CENTER><H3><%=strHeaderMsg%></H3></FONT>
<%End IF%>
	</TD>
  </TR>    
</TABLE>
<!--Body Table -->
<TABLE BORDER="0" WIDTH="80%" ALIGN="center" BGCOLOR="<%=strBackColor%>">
<TR>
   <TD ALIGN="center">
    <FONT FACE="Verdana" SIZE="3"><%=strAddNewMsg%></A></FONT>
    </TD>
 </TR>
 <TR>
   <TD ALIGN="center">
   <FONT FACE="Verdana" SIZE="3"><%=strViewMsg%></FONT>
 </TR>
</TABLE>
</BODY>
</HTML>
