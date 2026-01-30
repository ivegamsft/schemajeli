<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<%
Session.Timeout = 60
Dim strOrgTblName
Dim strCopyTblName
Dim strOrgTblStatus
Dim strCopyTblStatus
Dim strCreateUId
Dim strLastChngUId
Dim strLastChngTS
Dim strCreateTS
Dim strFrom
Dim iLoopCount
Dim sqlQuery
Dim strHistory
Dim bShowErr

Set rs = Session("rs")
Set con=Session("Con")
strFrom = Request.Form("From")
strCreateUId = Session("UserId")
strLastChngUId = Session("UserId")
strLastChngTS= CreateTS()
strCreateTS = CreateTS()

Select Case strFrom
Case ""

Case "Copy"
Dim aryIrma02
Dim aryIrma03
Dim iCount
Dim bHasElements
Dim bHasDescription

strOrgTblName = UCASE(TRIM(Request.Form("OrgTblName")))
strOrgTblStatusCd = UCASE(TRIM(Request.Form("SavedOrgTblStatusCd")))
strCopyTblName = UCASE(TRIM(Request.Form("CopyTblName")))

'-------------Check for duplicate name
sqlQuery = "SELECT DISTINCT tbl_nme "
sqlQuery = sqlQuery & " FROM irma01_table "
sqlQuery = sqlQuery & " WHERE tbl_nme = '" & strCopyTblName & "'"
If rs.State = 1 Then
  rs.Close
End If
rs.Open(sqlQuery)
If Not rs.BOF = -1 then
  rs.Close%>
  <FORM ACTION="copy_tbl.asp" METHOD="post">
  <INPUT TYPE="Hidden" NAME="CopyTblName" VALUE="<%= strCopyTblName %>">
  <INPUT TYPE="Hidden" NAME="OrgTblName" VALUE="<%= strOrgTblName %>">
  <INPUT TYPE="Hidden" NAME="OrgTblStatusCd" VALUE="<%= strOrgTblStatusCd %>">
  <INPUT TYPE="Hidden" NAME="From" VALUE="Error">
  </FORM>
  <SCRIPT LANGUAGE="VBScript">
  Sub Window_OnLoad()
     Document.Forms.Item(0).Submit
  End Sub
  </SCRIPT>   
  <%Response.End
End If
'------------Get the original table description
sqlQuery = "SELECT seq_no, text_80_desc "
sqlQuery = sqlQuery & " FROM irma02_table_desc "
sqlQuery = sqlQuery & " WHERE tbl_nme = '" & strOrgTblName & "'"
sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & strOrgTblStatusCd & "'"
sqlQuery = sqlQuery & " ORDER BY seq_no "
'response.write sqlquery
If rs.State = 1 Then
  rs.Close
End If
rs.Open(sqlQuery)
iCount = 0
If Not rs.BOF = - 1 Then
   Do Until rs.EOF = True
     iCount = iCount + 1
     rs.MoveNext
  Loop
  rs.MoveFirst
  ReDim aryIrma02(iCount -1,1)
  iCount = 0
  Do Until rs.EOF = True
    aryIrma02(iCount,0) = rs.Fields(0)
    aryIrma02(iCount,1) = rs.Fields(1)
    iCount = iCount + 1
    rs.MoveNext
    bHasDescription = True
  Loop
Else
  bHasDescription = False
End If
rs.Close

'----------------Get the original table elements
sqlQuery = "SELECT seq_no, elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no, prim_key_no,"
sqlQuery = sqlQuery & " alt_col_nme, creat_user_id, elmt_null_cd "
sqlQuery = sqlQuery & " FROM irma03_table_elmt "
sqlQuery = sqlQuery & " WHERE tbl_nme = '" & strOrgTblName & "'"
sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & strOrgTblStatusCd & "'"
sqlQuery = sqlQuery & " ORDER BY seq_no "
If rs.State = 1 Then
  rs.Close
End If
rs.Open(sqlQuery)
iCount=0
If Not rs.BOF = -1 Then
  Do Until rs.EOF = True
     iCount = iCount + 1
     rs.MoveNext
  Loop
  rs.MoveFirst
  ReDim aryIrma03(iCount -1,7)
'response.write icount & "***<BR>"
  iCount = 0
  Do Until rs.EOF = True
     aryIrma03(iCount,0) = rs.Fields(0)
     aryIrma03(iCount,1) = rs.Fields(1)
     aryIrma03(iCount,2) = rs.Fields(2)
     aryIrma03(iCount,3) = rs.Fields(3)
     aryIrma03(iCount,4) = rs.Fields(4)
     aryIrma03(iCount,5) = rs.Fields(5)
     aryIrma03(iCount,6) = rs.Fields(6)
     aryIrma03(iCount,7) = rs.Fields(7)
     iCount = iCount + 1
     rs.MoveNext
  Loop
  bHasElements = True
Else
  bHasElements = False
End If
rs.Close
'--------------Set the sql to be processed for the new table
   newTblSQL = "INSERT INTO irma01_table VALUES ("
   newTblSQL = newTblSQL & " '" & strCopyTblName & "' , "
   newTblSQL = newTblSQL & " 'DVLP', "
   newTblSQL = newTblSQL & " '1', "
   newTblSQL = newTblSQL & " 'YZDBDAT', "
   newTblSQL = newTblSQL & " '" & strCreateUID & "', "
   newTblSQL = newTblSQL & " '" & strLastChngUID & "', "
   newTblSQL = newTblSQL & " '" & strLastChngTS & "', "
   newTblSQL = newTblSQL & "'N', "
   newTblSQL = newTblSQL & " '" & strCreateUID & "', "
   newTblSQL = newTblSQL & " '" & strLastChngUID & "', "
   newTblSQL = newTblSQL & " '" & strLastChngTS & "', "
   newTblSQL = newTblSQL & " '" & strCreateTS & "', "
   newTblSQL = newTblSQL & " '',"                         'blank dbname
   newTblSQL = newTblSQL & " '' ) "                       'blank db status
'   response.write newTblSQL & "<BR>------------new table--------<BR>"
'Con.rollbacktrans
con.BeginTrans
   con.Execute newTblSql,1,1

If bHasDescription Then   
  For iCount = 0 to UBOUND(aryIrma02)  
     newDescrSQL = "INSERT INTO irma02_table_desc VALUES ("
     newDescrSQL = newDescrSQL & " '" & strCopyTblName & "' , "
     newDescrSQL = newDescrSQL & " 'DVLP', "
     newDescrSQL = newDescrSQL & " '" & aryIrma02(iCount,0) & "', "
     newDescrSQL = newDescrSQL & " '" & aryIrma02(iCount,1) & "',"
     newDescrSQL = newDescrSQL & "'N', "
     newDescrSQL = newDescrSQL & " '" & strCreateUID & "', "
     newDescrSQL = newDescrSQL & " '" & strLastChngUID & "', "
     newDescrSQL = newDescrSQL & " '" & strLastChngTS & "', "
     newDescrSQL = newDescrSQL & " '" & strCreateTS & "') "
  '   response.write newDescrSql & "<BR>-------------table description--------<BR>"
     con.Execute newDescrSQL,1,1
  Next
End IF

If bHasElements Then
  For iCount = 0 to UBOUND(aryIrma03)
     newElmtSQL = "INSERT INTO irma03_table_elmt VALUES ("
     newElmtSQL = newElmtSQL & " '" & strCopyTblName& "' , "
     newElmtSQL = newElmtSQL & " 'DVLP', "
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,0) & "', "
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,1) & "', "
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,2) & "', "
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,3) & "', "
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,4) & "', "      
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,5) & "', "
     newElmtSQL = newElmtSQL & "'N', "
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,6) & "', "   
     newElmtSQL = newElmtSQL & " '" & strLastChngUID & "', "
     newElmtSQL = newElmtSQL & " '" & strLastChngTS & "', "
     newElmtSQL = newElmtSQL & " '" & strCreateTS & "', "
     newElmtSQL = newElmtSQL & " '" & aryIrma03(iCount,7) & "') "
  '   response.write newElmtSQL & "<BR>-----element description--------<BR>"
     con.Execute newElmtSQL,1,1
  Next
End If
Con.CommitTrans
If rs.State = 1 Then
   rs.Close
End If
Response.Redirect("add_tbl.asp?Col0=" & strCopyTblName & "&Col1=DVLP&Entry=query_result")
Response.End

Case "Query"
strOrgTblName = UCASE(TRIM(Request.Form("OrgTblName")))
strOrgTblStatusCd = UCASE(TRIM(Request.Form("OrgTblStatusCd")))
strCopyTblName = UCASE(TRIM(Request.Form("CopyTblName")))
    Select Case strOrgTblStatusCd
    Case "DVLP"
        strOrgTblStatus = "Development"
    Case "ITST"
        strOrgTblStatus = "IT Status"
    Case "PRDT"
        strOrgTblStatus = "Production"
    Case "APRV"
        strOrgTblStatus = "Approval"
    End Select
sqlQuery = "Select tbl_nme, tbl_stat_cd "
sqlQuery = sqlQuery & " FROM irma01_table "
sqlQuery = sqlQuery & " WHERE tbl_nme LIKE '" & strOrgTblName & "%'"
sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & strOrgTblStatusCd & "'"
If rs.state = 1 then
  rs.close
End If
rs.open(sqlQuery) 
If rs.BOF = -1 then
   bError = True
Else
   bError = False
End If

Case "Error"
strOrgTblName = UCASE(TRIM(Request.Form("OrgTblName")))
strOrgTblStatusCd = UCASE(TRIM(Request.Form("OrgTblStatusCd")))
strCopyTblName = UCASE(TRIM(Request.Form("CopyTblName")))
Select Case strOrgTblStatusCd
Case "DVLP"
    strOrgTblStatus = "Development"
   Case "ITST"
    strOrgTblStatus = "IT Status"
  Case "PRDT"
    strOrgTblStatus = "Production"
  Case "APRV"
    strOrgTblStatus = "Approval"
End Select
bError = True
End Select

%>
<HTML>
<HEAD>
<TITLE>Copy tables
</TITLE>
<!--Copy Table-->
<SCRIPT LANGUAGE="VBScript">
Sub Window_OnLoad()
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)
     objCurForm.OrgTblName.Focus
End Sub

<!--#INCLUDE FILE="../include/Valid_tblNme.inc"-->

Sub CopyTableData
   Dim objCurForm
   Dim strOrgTblName
   Dim strCopyTableName
   Dim strValidChar
   Set objCurForm = Document.Forms.Item(0)
   strOrgTblName = UCASE(objCurForm.Tables.Value)
   strOrgTblStatusCd = UCASE(objCurForm.SavedOrgTblStatusCd.Value)
   strCopyTblName = UCASE(objCurForm.CopyTblName.Value)
   strValidChar = ValidTblChars(strCopyTblName)
   If strOrgTblName ="" then
     msgBox "Please select a table to copy.",,"Error"
     objCurForm.Tables.Focus
     Exit Sub
   ElseIf objCurForm.CopyTblName.Value="" then
     msgBox "Please enter a new table name.",,"Error"
     objCurForm.CopyTblName.Focus
     Exit Sub
   ElseIf strValidChar <> "True" Then
     msgBox "The table name contains the forbidden character " & chr(34) & strValidChar & chr(34) & "." & chr(10) & "Please correct",,"Error"
     objCurForm.CopyTblName.Focus
     objCurForm.CopyTblName.Select
     Exit Sub
   Else
      objCurForm.Action="copy_tbl.asp"
      objCurForm.From.Value = "Copy"
      objCurForm.OrgTblName.Value = strOrgTblName
      objCurForm.OrgTblStatusCd.Value = strOrgTblStatusCd
      objCurForm.CopyTblName.Value = strCopyTblName
      objCurForm.Submit
   End If
End Sub  

Sub GetTables
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
If objCurForm.OrgTblName.Value="" then
   MsgBox "Please enter a table name",,"Error"
   objCurForm.OrgTblName.Focus
Else
   objCurForm.Action="copy_tbl.asp"
   objCurForm.From.Value = "Query"
   objCurForm.Submit
End If
End Sub

Sub Requery
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
    objCurForm.CopyTblName.Value = ""
    GetTables
End Sub

Sub Cancel
Dim objCurForm 
Set objCurForm = Document.Forms.Item(0)

If objCurForm.History.Value="" then
   objCurForm.From.Value=""
   objCurForm.Method="Post"
   objCurForm.Action="copy_tbl.asp"
   objCurForm.Submit
Else
   history.back
End If
End Sub
</SCRIPT>
</HEAD>
<!--Header table -->
<BODY BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE BORDER="0" WIDTH="80%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
<TR>
  <TD ALIGN="center">
  <FONT FACE="Verdana"><B>Specify Data</B> - Copy Table</FONT>
<% If bError then%>     
  <FONT FACE="Verdana" color="<%=strErrTextColor%>"><br>The table name was not found<BR>or a duplicate name was enetered.<BR>Please re-enter</B>
  </FONT>
<%End If%>
  </TD>
</TR>
</TABLE>
<!--Body Table -->
<TABLE BGCOLOR="<%=strBackColor%>" border="0" width="80%" align="center">
<FORM METHOD="POST" NAME="CopyTable" Action="copy_tbl.asp">
  <INPUT TYPE="HIDDEN" NAME="SavedOrgTblName" VALUE="<%=strOrgTblName%>">
  <INPUT TYPE="HIDDEN" NAME="SavedOrgTblStatusCd" VALUE="<%=strOrgTblStatusCd%>">
  <INPUT TYPE="HIDDEN" NAME="From" VALUE="Copy">
  <INPUT TYPE="HIDDEN" NAME="History" VALUE="<%=strHistory%>">           

<%Select Case strFrom

Case "" %>
<TR>
  <TD ALIGN="RIGHT"><FONT FACE="Verdana" SIZE="2">Enter table to copy</FONT>
  </TD>
  <TD ALIGN="LEFT">
  <INPUT TYPE="TEXT" VALUE="" NAME="OrgTblName" SIZE="24">
  </TD>
  <TD>
  <SELECT NAME="OrgTblStatusCd" SIZE="1">
  <OPTION SELECTED VALUE="DVLP">Development</OPTION>
  <OPTION VALUE="APRV">Approval</OPTION>  
  <OPTION VALUE="ITST">ITA Status</OPTION>
  <OPTION VALUE="PRDT">Production</OPTION>
  </SELECT>
  </TD>
</TR>
<TR>
  <TD COLSPAN="3" ALIGN="center">
  <INPUT TYPE="button" VALUE="Get Table" NAME="cmdGetTables" onclick="GetTables">&nbsp;&nbsp;
  <INPUT TYPE="reset" VALUE="Cancel" NAME="cmdCancel" ONCLICK="Cancel">
  </TD>
</TR>  

<%Case "Query", "Error" %>
<TR>
  <TD ALIGN="RIGHT"><FONT FACE="Verdana" SIZE="2">Enter Table to Copy</FONT>
  </TD>
  <TD>
  <INPUT TYPE="TEXT" NAME="OrgTblName" SIZE="24" VALUE="<%=strOrgTblName%>">
  </TD>
  <TD>
  <SELECT NAME="OrgTblStatusCd" SIZE="1">
  <OPTION SELECTED VALUE="<%=strOrgTblStatusCd%>"><%=strOrgTblStatus%></OPTION>
  <OPTION VALUE="DVLP">Development</OPTION>
  <OPTION VALUE="APRV">Approval</OPTION>  
  <OPTION VALUE="ITST">ITA Status</OPTION>
  <OPTION VALUE="PRDT">Production</OPTION>
  </SELECT>
  </TD>
</TR>
<TR>
  <TD COLSPAN="3" ALIGN="center"><FONT FACE="Verdana" SIZE="2"><B>Table Name(s)</B></FONT>
  </TD>
</TR>
<%If Not bError then%>
<TR>
  <TD>&nbsp;
  </TD>
  <TD>
  <SELECT SIZE="10" NAME="Tables">
<%    Do While rs.EOF <> True   %>
    <OPTION Value="<%=TRIM(rs.Fields(0))%>"><%=rs.Fields(0)%></OPTION>
<%rs.MoveNext
  Loop
  rs.Close%>
  </SELECT>
  </TD>
  <TD>&nbsp;
  </TD>
</TR>
<% End IF   %>
<TR>
  <TD ALIGN="RIGHT"><FONT FACE="Verdana" SIZE="2">Enter New Table Name</FONT>
  </TD>
  <TD>
  <INPUT TYPE="TEXT" NAME="CopyTblName" VALUE="<%=strCopyTblName%>" SIZE="24">
  </TD>
  <TD>&nbsp;
  </TD>
</TR>
<TR>
  <TD COLSPAN="3">
  <FONT FACE="Verdana" SIZE="2"><B>This table will be copied on <%=strCreateTS%> by <%=strCreateUID%><BR>
  </TD>
</TR>
<TR>
  <TD ALIGN="RIGHT">
  <INPUT TYPE="BUTTON" VALUE="Copy Table" NAME="cmdCopy" ONCLICK="CopyTableData">
  </TD>
  <TD ALIGN="CENTER">
  <INPUT TYPE="BUTTON" VALUE="Requery" NAME="cmdRequery" ONCLICK="Requery">
  </TD>
  <TD ALIGN="LEFT">
  <INPUT TYPE="BUTTON" VALUE="Cancel" NAME="cmdCancel" ONCLICK="Cancel">
  </TD>
</TR>
<%

End Select
%>
</FORM>
</TABLE>
</BODY>
</HTML>