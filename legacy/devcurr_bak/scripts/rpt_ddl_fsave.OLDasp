<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
 <%
 
aryDDL = session("DDL")  

 Set fs = Server.CreateObject("Scripting.FileSystemObject")
 if not fs.folderExists("c:/ddl") then
    fs.createFolder("c:/ddl")
 end if

filename="c:/ddl/" + session("tblabbr")
 '-- get "permission denied" if append a .txt, .doc, etc extension
 if not fs.fileExists(filename) then
    set myfile=fs.createTextfile(filename,8,TRUE)
	'if file isn't closed and opened after create, the format gets messed up
	myfile.close
	set myfile=fs.openTextfile(filename,8,TRUE)
 else
    fs.deletefile(filename)
    set myfile=fs.openTextfile(filename,8,TRUE)
 end if	    

 for i=0 to ubound(aryDDL)
   myfile.writeLine(aryDDL(i)+" ")
   if aryDDL(i) = "COMMIT WORK ;" then
	  exit for
   end if   
 Next
 
 myfile.close

Set ts = nothing
Set myfile = nothing

'-- Beth's method
'set ol = server.createobject("mailx.smtpmailx")
'ol.mto = "rena.brener@navistar.com"
'ol.from= "rena.brener@navistar.com"
'ol.emailaddress = session("emailaddress")
'ol.host ="mail.navistar.com"
'ol.body(0) = "test message"
'ol.action = 3
'if err <> 0 then
' response.write "couldn't connect"
'end if
' 
'ol.flags=64
'ol.action = 15      ' ERROR - Busy executing assyncronous command"
'if err <> 0 then
' response.write err & "error sending"
'end if 

'ol.action = 8
'set ol=Nothing
'----------------------------------------------------

'set objMail = CreateObject("CDONTS.Newmail")
'objmail.from = "rena.brener@Navistar.com"
'objmail.to = "rena.brener@Navistar.com"
'objmail.BodyFormat = cdoBodyFormatHTML
'objmail.AttachFile (filename, "your DDL")
'objmail.send '-- ERROR - permission denied   
'-----------------------------------------------------
'set objSession = CreateObject("CDONTS.Session")
'objsession.logonSMTP "Rena", "rena.brener@navistar.com"
'set objOutbox = objsession.outbox      'ERROR - permission denied
'set objMessage = pbjOutBox.Messages.Add
'set objMessage.Text = "test Message"
'set objMessage.Importance = cdoHigh
'objMessage.Recipients.Add "Rena", "rena.brener@navistar.com", cdoTo
'objMessage.Send


 StrHeaderMsg = "DDL for table " & UCASE(session("TableName")) & " was saved in " & filename
 strAddNewMsg = "<A Href=rpt_ddl.asp>Generate another DDL?</a>"
 strViewMsg = "<A Href=query_result.asp?RelObject=Table&Criteria=" & UCASE(session("TableName")) & ">"
 strViewMsg = strViewMsg & "Work on this table?</A>" 

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
   <font face="Verdana" size="3"><%=strViewMsg%></font>
 </tr>
</table> 
</HTML>

