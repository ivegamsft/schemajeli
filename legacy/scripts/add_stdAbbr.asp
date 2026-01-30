<% Response.Buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<%'<!--#INCLUDE FILE="../include/security.inc"-->
Session.Timeout = 60
Dim strCreateUId
Dim strCreateTS
Dim strLastChngUId
Dim strLastChngTS
Dim strUserId
Dim strStdAbbr
Dim strStdAbbrSrc
Dim strFrom
Dim sqlQuery
Dim strClassWord

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
sqlQuery = "Select * from irma10_std_abbr"
If rs.State = 1 then
   rs.Close
End If
'response.Write sqlQuery
'response.end
rs.open(sqlQuery)           'Open the record set

Case "GetAbbr"
Dim strAbbr

strAbbr = Request.QueryString("StdAbbr")
Set rs = Session("rs")
sqlQuery = "Select * from irma10_std_abbr"
sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme = '" & strAbbr & "'"
If rs.state = 1 then
  rs.close
End If
rs.open(sqlQuery)           'Open the record set
strStdAbbrSrc = TRIM(rs.Fields(0))
strStdAbbr = TRIM(rs.Fields(1))
If TRIM(rs.Fields(2)) = "Y" then
   strClassWord = "YES"
Else
   strClassWord = "NO"
End If
strCreateUId = TRIM(rs.Fields(4))
strLastChngUId = TRIM(rs.Fields(5))
strLastChngTS = TRIM(rs.Fields(6))
strCreateTS = TRIM(rs.Fields(7))
End Select
%>
<HTML>
<HEAD>
<TITLE>Add/Maintain Standard Abbreviations
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<SCRIPT LANGUAGE="VBSCRIPT">
Sub Window_OnLoad()
     Document.frmAddStdAbbr.StdAbbrSrc.Focus
End Sub

Sub cmdCreate_OnClick()
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)

   If objCurForm.StdAbbrSrc.Value="" then
         msgBox "Please enter an abbreviation source.",,"Error"
        objCurForm.StdAbbrSrc.Focus
   ElseIf objCurForm.StdAbbr.Value="" then
        msgBox "Please enter a standard abbreviation.",,"Error"
        objCurForm.StdAbbr.Focus
   Else
'      msgbox "Ok to submit " & objCurForm.StdAbbrSrc.value & " as source and " & objcurform.stdabbr.value & " as abbrev."
      objCurForm.Submit
  End If
End Sub  

Sub cmdUpdate_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Event.Value = "Update"
'msgbox objcurform.action
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
   If objCurForm.StdAbbrSrc.Value="" then
         msgBox "Please enter an abbreviation source.",,"Error"
        objCurForm.StdAbbrSrc.Focus
Else
   objCurForm.From.Value = "GetAbbr"
   objCurForm.Event.Value = "Edit"
   objCurForm.Submit
End If
End Sub     

Sub cmdCancel_OnClick
Dim objCurForm
Set objCurForm = Document.Forms.Item(0)
   objCurForm.Action = "add_stdabbr.asp"
   objCurForm.From.Value = ""
   objCurForm.Submit
End Sub
</SCRIPT>

<!--Header table -->
<TABLE BORDER="0" WIDTH="70%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
 <TR>
    <TD ALIGN="center">
    <FONT FACE="Verdana"><B>Specify Data - Standard abbreviation</B>
    </FONT>
<%If strFrom = "GetAbbr" then %>    
     <FONT FACE="Verdana" color="<%=strErrTextColor%>"><br>This is an existing abbreviation</B>
     </FONT>
<%End If %>     
     </TD>
</TR>
</TABLE>
<!--Body Table -->
<TABLE BGCOLOR="<%=strBackColor%>" border="0"  width="70%" align="center">
<FORM METHOD="GET" NAME="frmAddStdAbbr" Action="verif_stdabbr.asp">
    <INPUT TYPE="Hidden" NAME="OldStdAbbrSrc" VALUE="<%=strStdAbbrSrc%>">
    <INPUT TYPE="Hidden" NAME="From" VALUE="AddStdAbbr">
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
    <INPUT TYPE="Text" NAME="CreateTS" SIZE="20" VALUE="<%=strCreateTS%>" READONLY>
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
     <INPUT TYPE="Text" NAME="LastChngTS" SIZE="20" VALUE="<%=strLastChngTS%>" READONLY>
     </TD>
</TR>

<TR>
    <TD><FONT FACE="Verdana" SIZE="2">
    <B>Standard abbreviation source:</B></FONT>
    </TD>
    <TD>
    <INPUT TYPE="text" NAME="StdAbbrSrc" VALUE="<%=strStdAbbrSrc%>" SIZE="35">
    </TD>
  </TR>

  <TR>
   <TD><FONT FACE="Verdana" SIZE="2"><B>Abbreviation</B>
    </FONT></TD>

    <TD>
    <INPUT TYPE="text" NAME="StdAbbr" VALUE="<%=strStdAbbr%>" SIZE="20">
    </TD>
  </TR>

  <TR>
   <TD><FONT FACE="Verdana" SIZE="2"><B>Class word indicator</B>
    </FONT></TD>
<% If strFrom = "GetAbbr" Then %>
    <TD><SELECT NAME="ClassWord" SIZE="1">
                <OPTION SELECTED VALUE="<%=strClassWord%>"><%=strClassWord%></OPTION>
                <OPTION VALUE="N">NO</OPTION>
                <OPTION VALUE="Y">YES</OPTION>
                </SELECT>                
    </TD>
  </TR>

  <TR>
    <TD COLSPAN="2" ALIGN="center">
    <INPUT TYPE="button" VALUE="Update" NAME="cmdUpdate">&nbsp;
    <INPUT TYPE="button" VALUE="Delete" NAME="cmdDelete">&nbsp;
    <INPUT TYPE="reset" VALUE="Cancel" NAME="cmdCancel">&nbsp;
    </TD>
  </TR>  
<%Else %>
    <TD><SELECT NAME="ClassWord" SIZE="1">
                <OPTION SELECTED VALUE="N">NO</OPTION>
                <OPTION VALUE="Y">YES</OPTION>
                </SELECT>                
    </TD>
  </TR>

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
</HTML>