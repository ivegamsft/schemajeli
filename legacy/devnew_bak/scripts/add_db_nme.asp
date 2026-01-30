<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<%
Session.Timeout = 60
Dim strDbName
Dim strDbBName
Dim strDbStatus
Dim strDbRdbmsCd
Dim strDbRdbmsVer
Dim strRdbms
Dim strDbDesc
Dim strCreateUId
Dim strLastChngUId
Dim strLastChngTS
Dim strCreateTS
Dim strFrom
Dim strServer
Dim aryServer()
Dim iLoopCount
Dim sqlQuery
Dim strHistory
Dim bCanDelete
Dim bShowErr

bShowErr = False
Set rs = Session("rs")
sqlQuery = "Select DISTINCT srvr_nme from irma12_srvr"
If rs.State = 1 then
   rs.Close
End If
rs.open(sqlQuery)
iLoopCount = 0
Do until rs.EOF = True
   ReDim PRESERVE aryServer(iLoopCount)
   aryServer(iLoopCount) = UCASE(TRIM(rs.Fields(0)))
   iLoopCount = iLoopCount + 1
   rs.MoveNext
Loop
rs.Close

strFrom = Request.QueryString("From")

Select Case strFrom
Case ""
strDbName = ""
strDbBName = ""
strDbStatus = "DVLP"
strDbRdbms = ""
strDbRdbmsVer = ""
strDbDesc = ""
strCreateUId = Session("UserId")
strLastChngUId = Session("UserId")
strLastChngTS= CreateTS()
strCreateTS = CreateTS()
strHistory="Add"
bCanDelete = True
If Request.QueryString("Error") = "True" Then
   bShowErr = True
End If

Case "Query"
strDbName = Request.QueryString("DbName")
strDbStatus = Request.QueryString("Status")
strServer = Request.QueryString("Server")
sqlQuery = "Select tbl_nme "
sqlQuery = sqlQuery & " FROM irma01_table "
sqlQuery = sqlQuery & " WHERE db_nme = '" & strDbName & "'"
sqlQuery = sqlQuery & " AND db_stat_cd = '" & strDbStatus & "'"
'Response.write sqlquery
'response.end
If rs.state = 1 then
  rs.close
End If
rs.open(sqlQuery) 
If rs.BOF <> -1 then
   bCanDelete = False
Else
   bCanDelete = True
End If
rs.Close

sqlQuery = "Select a.db_busns_nme, a.db_nme, a.db_stat_cd, a.rdbms_nme, a.rdbms_vrsn_no, "
sqlQuery = sqlQuery & " a.text_160_desc, a.creat_uid, a.lst_chng_uid, a. lst_chng_ts, a.creat_ts, "
sqlQuery = sqlQuery & " b.srvr_nme "
sqlQuery = sqlQuery & " FROM irma11_db a, irma13_db_srvr b"
sqlQuery = sqlQuery & " WHERE a.db_nme = b.db_nme "
sqlQuery = sqlQuery & " AND a.db_stat_cd = b.db_stat_cd "
sqlQuery = sqlQuery & " AND b.db_nme = '" & strDbName & "'"
sqlQuery = sqlQuery & " AND b.db_stat_cd = '" & strDbStatus & "'"
sqlQuery = sqlQuery & " AND b.srvr_nme = '" & strServer & "'"
'Response.write sqlquery
If rs.state = 1 then
  rs.close
End If
rs.open(sqlQuery) 
strDbBName = TRIM(rs.Fields(0))
strDbName = TRIM(rs.Fields(1))
strDbStatus = TRIM(rs.Fields(2))
strRdbmsCd = TRIM(rs.Fields(3))
   Select Case strRDBMSCd
    Case "ACCS"
       strRDBMS="Access"
    Case "DB2"
       strRDBMS="IBM DB2"
    Case "INFRX"
       strRDBMS="Informix"
    Case "ORCL"
       strRDBMS="Oracle"
    Case "RDB"
      strRDBMS="RDB"
    Case "SQL"
       strRDBMS="SQL Server"
    Case "SYBS"
      strRDBMS="Sybase"
    Case ""
      strRDBMS="Unknown"
    End Select
strRdbmsVer = TRIM(rs.Fields(4))
strDbDesc = TRIM(rs.Fields(5))
strCreateUId = TRIM(rs.Fields(6))
strLastChngUId = TRIM(rs.Fields(7))
strLastChngTS = TRIM(rs.Fields(8))
strCreateTS = TRIM(rs.Fields(9))
strServer = TRIM(rs.Fields(10))
End Select

%>
<HTML>
<HEAD>
<TITLE>Add/Maintain Database
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<SCRIPT LANGUAGE="VBSCRIPT">
 
Sub Window_OnLoad()
     Document.frmAddDb.DbBName.Focus
End Sub
<!--#INCLUDE FILE="../include/Valid_DbNme.inc"-->

Sub cmdCreate_OnClick()
   Dim objCurForm
   Dim strDbName
   Dim strValidChar
   Set objCurForm = Document.Forms.Item(0)
   strDbName = UCASE(objCurForm.DbName.Value)
   strValidChar = ValidDbChars(strDbName)
   If objCurForm.Server.Value="" then
     msgBox "Please select a server.",,"Error"
     objCurForm.Server.Focus
     Exit Sub
   ElseIf objCurForm.DbBName.Value="" then
     msgBox "Please enter a database busisness name.",,"Error"
     objCurForm.DbBName.Focus
     Exit Sub
   ElseIf strDbName = "" then
     msgBox "Please enter a database name.",,"Error"
     objCurForm.DbName.Focus
     Exit Sub
   ElseIf strValidChar <> "True" Then
     msgBox "The database name contains the forbidden character " & chr(34) & strValidChar & chr(34) & "." & chr(10) & "Please correct",,"Error"
     objCurForm.DbName.Focus
     objCurForm.DbName.Select
     Exit Sub
   ElseIf Not ValidDbName(strDbName) then
     objCurForm.DbName.Focus
     objCurForm.DbName.Select
     Exit Sub
   ElseIf objCurForm.RDBMS.Value="" then
     msgBox "Please select an RDBMS.",,"Error"
     objCurForm.RDBMS.Focus
     Exit Sub
   ElseIf objCurForm.RDBMSVer.Value="" then
     msgBox "Please enter an RDBMS version.",,"Error"
     objCurForm.RDBMS.Focus
     Exit Sub
   ElseIf Len(objCurForm.DbDesc.Value) > 160 then
     msgBox "Database descriptions cannot be > 160 characters.",,"Error"
     objCurForm.DbDesc.Focus
     objCurForm.DbDesc.Select
     Exit Sub
    Else
      objCurForm.Submit
   End If
End Sub  

Sub cmdUpdate_OnClick
Dim objCurForm
Dim strOldDBName
Dim strNewDbName
Dim strValidChar

Set objCurForm = Document.Forms.Item(0)
strOldDbName = objCurForm.OldDbName.Value
strNewDbName = objCurForm.DbName.Value
strValidChar = ValidDbChars(strDbName)

If objCurForm.CanChange = "False" Then
   If strOldDBName <> strNewDbName then
      msgbox "You cannot change the name of a database if it contains tables."
      objCurForm.DbName.Value = strOldDbName
   End If
ElseIf objCurForm.Server.Value="" then
     msgBox "Please select a server.",,"Error"
     objCurForm.Server.Focus
     Exit Sub
ElseIf objCurForm.DbBName.Value="" then
     msgBox "Please enter a database busisness name.",,"Error"
     objCurForm.DbBName.Focus
     Exit Sub
ElseIf objCurForm.RDBMS.Value="" then
     msgBox "Please select an RDBMS.",,"Error"
     objCurForm.RDBMS.Focus
     Exit Sub
ElseIf objCurForm.RDBMSVer.Value="" then
     msgBox "Please enter an RDBMS version.",,"Error"
     objCurForm.RDBMS.Focus
     Exit Sub
ElseIf Len(objCurForm.DbDesc.Value) > 160 then
     msgBox "Database descriptions cannot be > 160 characters.",,"Error"
     objCurForm.DbDesc.Focus
     objCurForm.DbDesc.Select
     Exit Sub
Else
   objCurForm.Event.Value = "Update"
   objCurForm.Submit
End IF
End Sub

Sub cmdEdit_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   If objCurForm.DbName.Value="" then
         msgBox "Please enter an database name.",,"Error"
        objCurForm.DbName.Focus
Else
   objCurForm.From.Value = "Query"
   objCurForm.Event.Value = "Edit"
   objCurForm.Submit
End If
End Sub     

Sub GetVersion()
Dim objCurForm
Dim strRDBSel

Set objCurForm = Document.Forms.Item(0)
strRdbSel = objCurForm.RDBMS.Value   
   Select case strRdbSel
     Case "ACCS"
       objCurForm.RDBMSVer.Value = "7.0"
     Case "DB2"
       objCurForm.RDBMSVer.Value = "8.0"
     Case "INFRX"
       objCurForm.RDBMSVer.Value = "7.31FC2"
     Case "ORCL"
       objCurForm.RDBMSVer.Value = "8.0"
     Case "RDB"
       objCurForm.RDBMSVer.Value = "5.0"
     Case "SQL"
       objCurForm.RDBMSVer.Value = "6.5"
     Case "SYBS"
       objCurForm.RDBMSVer.Value = "5.0"
     Case Else
       objCurForm.RDBMSVer.Value = ""
     End Select
End Sub

Sub cmdCancel_OnClick
Dim objCurForm 
Set objCurForm = Document.Forms.Item(0)

If objCurForm.History.Value="Add" then
   objCurForm.Method="Post"
   objCurForm.Action="add_db_nme.asp"
   objCurForm.Submit
Else
   history.back
End If
End Sub

Sub cmdDelete_OnClick
Dim objCurForm 
Dim iAnswer
Set objCurForm = Document.Forms.Item(0)
iAnswer=msgbox("Are you sure you want to delete this database?",4,"Confirm delete")
If iAnswer=6 then
   objCurForm.Method="Post"
   objCurForm.Event.Value="Delete"
   objCurForm.Action="verif_db.asp"
   objCurForm.Submit
End If
End Sub
</SCRIPT>
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
 <TR>
 <TD ALIGN="center">
   <FONT FACE="Verdana"><B>Specify Data</B> - Database<BR>Details
   </FONT>
<%If strFrom = "Query" then %>    
    <FONT FACE="Verdana" color="<%=strErrTextColor%>"><br>This is an existing database</B>
    </FONT>
<%End If
  If bShowErr then%>     
    <FONT FACE="Verdana" color="<%=strErrTextColor%>"><br>The database name was not found.  Please re-enter</B>
    </FONT>
<%End If%>
  </TD>
  </TR>
</TABLE>
<!--Body Table -->
<TABLE BGCOLOR="<%=strBackColor%>" border="0" width="100%" align="center">
<FORM METHOD="POST" NAME="frmAddDb" Action="verif_db.asp">
  <INPUT TYPE="HIDDEN" NAME="OldDbName" VALUE="<%=strDbName%>">
  <INPUT TYPE="HIDDEN" NAME="OldServerName" VALUE="<%=strServer%>">
  <INPUT TYPE="HIDDEN" NAME="From" VALUE="AddDb">
  <INPUT TYPE="HIDDEN" NAME="Event" VALUE="Add">
  <INPUT TYPE="HIDDEN" NAME="History" VALUE="<%=strHistory%>">           
  <INPUT TYPE="HIDDEN" NAME="DbStatus" VALUE="<%=strDbStatus%>">           
  <INPUT TYPE="HIDDEN" NAME="CanChange" VALUE="<%=bCanDelete%>">           
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
    <B>Server</B>
    </FONT>
  </TD>
<%Select Case strFrom
  Case "" %>
    <TD><SELECT NAME="Server" SIZE="1">
      <OPTION SELECTED>------Select a Server------</OPTION>
      <% For i=0 to UBOUND(aryServer) %>
           <OPTION VALUE="<%=aryServer(i)%>"><%=aryServer(i)%></OPTION>
      <% Next %>  
    </SELECT>
  </TD>
  </TR>

  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
    <B>Database Business Name:</B></FONT>
  </TD>
  <TD>
    <INPUT TYPE="text" NAME="DbBName" VALUE="<%=strDbBName%>" SIZE="35">
  </TD>
  </TR>
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
    <B>Database Name:</B></FONT>
  </TD>
  <TD>
    <INPUT TYPE="text" NAME="DbName" VALUE="<%=strDbName%>" SIZE="35">
    </TD>
  </TR>
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
   <B>RDBMS</B>
    </FONT>
  </TD>
  <TD>
    <SELECT NAME="RDBMS" SIZE="1" ONCHANGE="GetVersion">
    <OPTION SELECTED>----Select an RDBMS----</OPTION>
    <OPTION VALUE="ACCS">Access</OPTION>
    <OPTION VALUE="DB2">IBM DB2</OPTION>
    <OPTION VALUE="INFRX">Informix</OPTION>
    <OPTION VALUE="ORCL">Oracle</OPTION>
    <OPTION VALUE="RDB">RDB</OPTION>
    <OPTION VALUE="SQL">SQL Server</OPTION>
    <OPTION VALUE="SYBS">Sybase</OPTION>                                                
    </SELECT>                
  </TD>
  </TR>
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2"><B>RDBMS Version</B>
    </FONT></TD>
  </TD>
  <TD>
    <INPUT TYPE="text" NAME="RDBMSVer" VALUE="<%=strRDBMSVer%>" SIZE="8" READONLY>
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4"><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Description</B></FONT>
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4"><TEXTAREA ROWS="2" NAME="DbDesc" COLS="80" NOSOFTBREAKS WRAP="soft"></TEXTAREA>
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4">
    <FONT FACE="Verdana" SIZE="2">
    <B>This database will be created on <%=strCreateTS%> by <%=strCreateUID%><BR>
    </B>
    </FONT>
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="2" ALIGN="center">
    <INPUT TYPE="button" VALUE="Create" NAME="cmdCreate">&nbsp;
    <INPUT TYPE="button" VALUE="   Edit   " NAME="cmdEdit">&nbsp;
    <INPUT TYPE="reset" VALUE="Cancel" NAME="cmdCancel">&nbsp;
  </TD>
  </TR>  

<%Case "Query" %>

  <TD>
    <INPUT TYPE="text" NAME="Server" VALUE="<%=strServer%>" SIZE="35" READONLY>
  </TD>
  </TR>
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
    <B>Database Business Name:</B></FONT>
  </TD>
  <TD>
    <INPUT TYPE="text" NAME="DbBName" VALUE="<%=strDbBName%>" SIZE="35">
  </TD>
  </TR>
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
    <B>Database Name:</B></FONT>
  </TD>
  <TD>
    <INPUT TYPE="text" NAME="DbName" VALUE="<%=strDbName%>" SIZE="35" READONLY>
  </TD>
  </TR>
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2">
    <B>RDBMS:</B></FONT>
  </TD>
  <TD><SELECT NAME="RDBMS" SIZE="1" ONCHANGE="GetVersion">
      <OPTION SELECTED VALUE="<%=strRDBMSCd%>"><%=strRDBMS%></OPTION>
      <OPTION VALUE="ACCS">Access</OPTION>
      <OPTION VALUE="DB2">IBM DB2</OPTION>
      <OPTION VALUE="INFRX">Informix</OPTION>
      <OPTION VALUE="ORCL">Oracle</OPTION>
      <OPTION VALUE="RDB">RDB</OPTION>
      <OPTION VALUE="SQL">SQL Server</OPTION>
      <OPTION VALUE="SYBS">Sybase</OPTION>                                                
      </SELECT>                
  </TD>
  </TR>
  <TR>
  <TD><FONT FACE="Verdana" SIZE="2"><B>RDBMS Version</B>
    </FONT>
 </TD>
  </TD>
  <TD><INPUT TYPE="text" NAME="RDBMSVer" VALUE="<%=strRDBMSVer%>" SIZE="8">
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4"><FONT FACE="Verdana" SIZE="2" COLOR="#000000">
    <B>Description</B></FONT>
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4"><TEXTAREA ROWS="2" NAME="DbDesc" COLS="80"  NOSOFTBREAKS WRAP="soft"><%=strDbDesc%></TEXTAREA>
  </TD>
  </TR>
  <TR>
  <TD COLSPAN="4">
     <FONT FACE="Verdana" SIZE="2">
     <B>This database was created by <%=strCreateUID%><BR>
        and was last modified on <%=strLastChngTS%> by <%=strLastChngUID%>.<BR>
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
</HTML>