<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/cmpny_cds.inc"-->
<%
Session.Timeout = 60
Dim strServerName
Dim strServerOs
Dim strServerOsVer
Dim strServerLoc
Dim strServerDesc
Dim strCreateUId
Dim strLastChngUId
Dim strLastChngTS
Dim strCreateTS
Dim strFrom
Dim sqlQuery

strFrom = Request.QueryString("From")

Select Case strFrom
Case ""
strCreateUId = Session("UserId")
strCreateTS = CreateTS()
strLastChngUId = Session("UserId")
strLastChngTS = CreateTS()
strUserId = ""
strUserLName = ""
strUserFName =""
Set rs = Session("rs")
sqlQuery = "Select * from irma12_srvr"
If rs.State = 1 then
   rs.Close
End If
'response.Write sqlQuery
'response.end
rs.open(sqlQuery)           'Open the record set

Case "GetServer"
Dim strServerOsCd
Dim strServerLocCd
strServerName = Request.QueryString("ServerName")
Set rs = Session("rs")
sqlQuery = "Select * from irma12_srvr "
sqlQuery = sqlQuery & " WHERE srvr_nme = '" & strServerName & "'"
If rs.state = 1 then
  rs.close
End If
rs.open(sqlQuery)           'Open the record set
strServerName = TRIM(rs.Fields(0))
strServerOsCd = TRIM(rs.Fields(1))
For i = 0 to UBOUND(arySrvrOs)
   If strServerOsCd = arySrvrOs(i,0) Then
      strServerOs = arySrvrOs(i,1)
      Exit For
    Else
       strServerOs = "Unknown"
    End If
Next
strServerVer = TRIM(rs.Fields(2))
strServerLocCd = TRIM(rs.Fields(3))
For i = 0 to UBOUND(aryCmpnyLoc)
   If strServerLocCd = aryCmpnyLoc(i,0) Then
      strServerLoc = aryCmpnyLoc(i,1)
      Exit For
    Else
       strServerLoc = "Unknown"
    End If
Next

strServerDesc = TRIM(rs.Fields(4))
strCreateUId = TRIM(rs.Fields(5))
strLastChngUId = TRIM(rs.Fields(6))
strLastChngTS = TRIM(rs.Fields(7))
strCreateTS = TRIM(rs.Fields(8))
End Select
%>
<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.frmAddServer.ServerName.Focus
End Sub

Sub cmdCreate_OnClick()
   Dim objCurForm
   Dim strDesc
   Set objCurForm = Document.Forms.Item(0)

   If objCurForm.ServerName.Value="" then
         msgBox "Please enter a server name.",,"Error"
        objCurForm.ServerName.Focus
   ElseIf objCurForm.ServerOs.SelectedIndex = 0 then
        msgBox "Please select a server operating system.",,"Error"
        objCurForm.ServerOs.Focus
   ElseIf objCurForm.ServerOsVer.Value = "" then
        msgBox "Please enter an operating system version.",,"Error"
        objCurForm.ServerOs.Focus
   ElseIf objCurForm.ServerLoc.SelectedIndex = 0 then
        msgBox "Please select a server location.",,"Error"
        objCurForm.ServerLoc.Focus
   ElseIf objCurForm.ServerDesc.Value = "" then
        msgBox "Please enter a description.",,"Error"
        objCurForm.ServerDesc.Focus
   ElseIf LEN(objCurForm.ServerDesc.Value) > 160 then
        msgBox "The dscription is limeted to 160 characters.",,"Error"
        objCurForm.ServerDesc.Focus

   Else
   strDesc=REPLACE(objCurForm.ServerDesc.Value," ","*")
   objCurForm.ServerDesc.Value=""
   objCurForm.ServerDesc.Value=strDesc
'      msgbox "Ok to submit " & objCurForm.ServerName.value & "<br>" & _
'    strDesc & " as descrption<br>and " & objcurform.ServerOs.value & " as os."
    objCurForm.Submit
  End If
End Sub  

Sub cmdUpdate_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Event.Value = "Update"
   objCurForm.Submit
End Sub

Sub cmdDelete_OnClick
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Event.Value = "Delete"
   objCurForm.Submit
End Sub

Sub cmdEdit_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   If objCurForm.ServerName.Value="" then
         msgBox "Please enter a server name.",,"Error"
        objCurForm.ServerName.Focus
Else
   objCurForm.From.Value = "GetServer"
   objCurForm.Event.Value = "Edit"
   objCurForm.Submit
End If
End Sub     

Sub cmdCancel_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Action = "add_server.asp"
   objCurForm.From.Value = ""
   objCurForm.Submit
End Sub
</SCRIPT>
<!--Header table -->
<BODY BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE BORDER="0" WIDTH="80%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
 <TR>
    <TD ALIGN="center">
    <FONT FACE="Verdana"><B>Specify Data - Server</B>
    </FONT>
<%If strFrom = "GetServer" then %>    
     <FONT FACE="Verdana" color="<%=strErrTextColor%>"><br>This is an existing server</B>
     </FONT>
<%End If %>     
     </TD>
</TR>
</TABLE>
<!--Body Table -->
<TABLE BGCOLOR="<%=strBackColor%>" border="0"  width="80%" align="center">
<FORM METHOD="GET" NAME="frmAddServer" Action="verif_server.asp">
    <INPUT TYPE="Hidden" NAME="OldServerName" VALUE="<%=strServerName%>">
    <INPUT TYPE="Hidden" NAME="From" VALUE="AddServer">
    <INPUT TYPE="Hidden" NAME="Event" VALUE="Add">
  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
    <B>Created By</B>
    </TD></FONT>
    <TD>
    <INPUT TYPE="Text" NAME="CreateUId" SIZE="10" VALUE="<%=strCreateUId%>" READONLY>
    </TD>
</TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
    <B>Create Date:</B></FONT>
    </TD>
    <TD>
    <INPUT TYPE="Text" NAME="CreateTS" SIZE="25" VALUE="<%=strCreateTS%>" READONLY>
    </TD>
  </TR>

  <TR>
    <TD><FONT FACE="Verdana" SIZE="2">
	<B>Last Modified by:</B>
    </FONT>
    </TD>
    <TD>
    <INPUT TYPE="Text" NAME="LastChngUId" SIZE="10" VALUE="<%=strLastChngUId%>" READONLY>
    </TD>
</TR>

<TR>
     <TD><FONT FACE="Verdana" SIZE="2">
	 <B>Last Modified:</B>
     </FONT>
     </TD>
     <TD>
     <INPUT TYPE="Text" NAME="LastChngTS" SIZE="25" VALUE="<%=strLastChngTS%>" READONLY>
     </TD>
</TR>

<TR>
    <TD><FONT FACE="Verdana" SIZE="2">
    <B>Server name:</B></FONT>
    </TD>
    <TD>
    <INPUT TYPE="text" NAME="ServerName" VALUE="<%=strServerName%>" SIZE="20">
    </TD>
  </TR>
<% If strFrom = "GetServer" Then %>
  <TR>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Operating system</B>
   </FONT></TD>

    <TD>
      <SELECT NAME="ServerOS" SIZE="1">
      <OPTION SELECTED VALUE="<%=strServerOs%>"><%=strServerOs%></OPTION>
      <% For i=0 to UBOUND(arySrvrOs) %>
           <OPTION VALUE="<%=arySrvrOS(i,0)%>"><%=arySrvrOS(i,1)%></OPTION>
      <% Next %>  
      </SELECT>
    </TD>

  </TR>

  <TR>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Operating system version</B>
   </FONT></TD>
    <TD>
    <INPUT TYPE="text" NAME="ServerOSVer" VALUE="<%=strServerOsVer%>" SIZE="5">
    </TD>

  </TR>

  <TR>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Location</B>
   </FONT></TD>

    <TD>
      <SELECT NAME="ServerLoc" SIZE="1">
      <OPTION SELECTED VALUE="<%=strServerLocCd%>"><%=strServerLoc%></OPTION>
      <% For i=0 to UBOUND(aryCmpnyLoc) %>
           <OPTION VALUE="<%=aryCmpnyLoc(i,0)%>"><%=aryCmpnyLoc(i,1)%></OPTION>
      <% Next %>  
      </SELECT>
    </TD>
  </TR>

<tr>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Description</B>
   </FONT></TD>

   <td>
   <TEXTAREA ROWS="4" NAME="ServerDesc" COLS="40"><%=strServerDesc%>
   </TEXTAREA>
  <TR>
    <TD COLSPAN="2" ALIGN="center">
    <INPUT TYPE="button" VALUE="Update" NAME="cmdUpdate">&nbsp;
    <INPUT TYPE="button" VALUE="Delete" NAME="cmdDelete">&nbsp;
    <INPUT TYPE="reset" VALUE="Cancel" NAME="cmdCancel">&nbsp;
    </TD>
  </TR>  

<%Else %>
  <TR>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Operating system</B>
   </FONT></TD>

    <TD>
      <SELECT NAME="ServerOS" SIZE="1">
      <OPTION SELECTED>----Select an operating system----</OPTION>
      <% For i=0 to UBOUND(arySrvrOs) %>
           <OPTION VALUE="<%=arySrvrOS(i,0)%>"><%=arySrvrOS(i,1)%></OPTION>
      <% Next %>  
      </SELECT>
    </TD>

  </TR>

  <TR>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Operating system version</B>
   </FONT></TD>
    <TD>
    <INPUT TYPE="text" NAME="ServerOSVer" VALUE="<%=strServerOsVer%>" SIZE="5">
    </TD>

  </TR>

  <TR>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Location</B>
   </FONT></TD>

    <TD>
      <SELECT NAME="ServerLoc" SIZE="1">
      <OPTION SELECTED>------Select a server location------</OPTION>
      <% For i=0 to UBOUND(aryCmpnyLoc) %>
           <OPTION VALUE="<%=aryCmpnyLoc(i,0)%>"><%=aryCmpnyLoc(i,1)%></OPTION>
      <% Next %>  
      </SELECT>
    </TD>
  </TR>

<tr>
   <TD><FONT FACE="Verdana" SIZE="2">
   <B>Description</B>
   </FONT></TD>

   <td>
   <TEXTAREA ROWS="4" NAME="ServerDesc" COLS="40"></TEXTAREA>

  <TR>
    <TD COLSPAN="2" ALIGN="center">
    <INPUT TYPE="button" VALUE="Create" NAME="cmdCreate">&nbsp;
    <INPUT TYPE="button" VALUE="  Edit  " NAME="cmdEdit">&nbsp;
    <INPUT TYPE="reset" VALUE="Reset " NAME="cmdReset">&nbsp;
    </TD>
  </TR>  
<%End IF
%>
</FORM>
</TABLE>
</BODY>