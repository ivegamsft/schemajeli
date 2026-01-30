<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Response.buffer = True
Session.Timeout=60
Dim strPath
Dim strFolder
Dim strFileName
Dim strDDL

strPath = session("savepath")&"\ddl\"
strFileName = UCASE(TRIM(session("tblabbr"))) & "_" & UCASE(TRIM(Session("UserId"))) & ".txt"
aryDDL = session("DDL")

 Set fs = Server.CreateObject("Scripting.FileSystemObject")

 '-- get "permission denied" if append a .txt, .doc, etc extension
 if not fs.fileExists(strPath & "\" & strFilename) then
    set myfile=fs.CreateTextfile(strPath & "\" & strFilename)
	'if file isn't closed and opened after create, the format gets messed up
	myfile.close
	set myfile=fs.openTextfile(strPath & "\" & strFilename,2,TRUE)
	
 else
    fs.deletefile(strPath & "\" & strFilename)
    set myfile=fs.openTextfile(strPath & "\" & strFilename,2,TRUE)
 end if	    

 for i=0 to ubound(aryDDL)
   myfile.writeLine(aryDDL(i)+" ")
   strDDL = strDDL & aryDDL(i) & " " & chr(10)
   if aryDDL(i) = "COMMIT WORK ;" then
	  exit for
   end if   
 Next
 
 myfile.close

Set fs = nothing
Set myfile = nothing

strTO=Session("EmailAddr")
strSubject = "DDL for table " & UCASE(session("TableName"))
strCC ="rephlpteam@USAEXCH01.navistar.com"

Set objCDOMail = Server.CreateObject("CDONTS.NewMail")
	objCDOMail.From = "rephlpteam@USAEXCH01.navistar.com"
    objCDOMail.To = strTo
	objCDOMail.CC = strCC
    objCDOMail.Subject = strSubject
	objCDOMail.Body = strBody
	strPathFile = strPath & "\" & strFilename
	strDescr = "DDL for table  " & UCASE(session("TableName"))
	objCDOMail.AttachFile strPathFile, strDescr
    objCDOMail.Send
    If err <> 0 then
       response.write err.number & "<BR>" & err.description
       response.end
    End If
	
Set objCDOMail = Nothing
set strPath = Nothing 
	
 StrHeaderMsg = "The DDL for table " & UCASE(session("TableName")) 
 StrHeaderMsg = StrHeaderMsg & " has been sent to you via email as an attachment."
 strAddNewMsg = "<A Href=rpt_ddl.asp>Generate another DDL</a>"
 strViewFileMsg = "<A Href=../ddl/" & strFilename & " TARGET=_blank>View a printable copy</A>"
 strViewMsg = "<A Href=add_tbl.asp?Col0=" & UCASE(session("TableName")) & "&Col1=" & Request.Form("Status") & "&Entry=query_result>"
 strViewMsg = strViewMsg & "Work on this table</A>" 

%>
<HTML>

<body bgcolor="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<table border="0" width="80%" align="center" bgcolor="<%=strHeaderColor%>">
  <tr>
    <td width="100%" height="20" align="center">
<%If bError then%>
    <font face="Verdana" size="3" COLOR="<%=strErrTextColor%>"><Center><h3><%=strHeaderMsg%></H3></FONT>
<%Else%>
   <font face="Verdana" size="3"><Center><h3><%=strHeaderMsg%></H3></FONT>
<%End IF%>
	</td>
  </tr>    
</Table>
<table border="0" width="80%" align="center" bgcolor="<%=strBackColor%>">
<tr>
   <td align="center">
    <font face="Verdana" size="3"><%=strAddNewMsg%></a></FONT>

    </TD>
 </tr>
<tr>
   <td align="center">
    <font face="Verdana" size="3"><%=strViewFileMsg%></a></FONT>

    </TD>
 </tr>

 <tr>
   <td align="center">
   <font face="Verdana" size="3"><%=strViewMsg%></font>
 </tr>
</table> 
</HTML>

