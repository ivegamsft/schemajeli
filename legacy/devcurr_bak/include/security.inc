<%
Response.buffer = True
UserId = Session("UserID")
'-----------------Save navigation information
Dim strPageLogPath
Dim strPageLogFileName

strPageLogPath = session("savepath")&"logs\"
strPageLogFileName = replace(date, "/", "-") & "pgs.txt" 
Set objFile = Server.CreateObject("Scripting.FileSystemObject")
set objCurFile = objFile.GetFile(strPageLogPath & strPageLogFilename)
Set objFileText = objCurFile.OpenAsTextStream(8,0)
objFileText.Write Session.SessionId & "," & TIME & "," & Request.ServerVariables("SCRIPT_NAME") & "," & Request.ServerVariables("QUERY_STRING")
objFileText.writeBlankLines(1)
Set objFile = Nothing
Set objCurFile = Nothing
Set objFileText = Nothing
'---------------begin session checking
If IsEmpty(UserID) or IsNull(UserId) or UserId = "" Then
%>
<SCRIPT LANGUAGE="VBScript">
Sub Window_OnLoad
    Window.SetTimeout "ReDirLogin",3000
End Sub
Sub ReDirLogin
   Parent.location.Href = "../scripts/login.asp"
   Window.ClearTimeout
End Sub
</SCRIPT>
<HTML>
<HEAD>
<TITLE>Session timeout</TITLE>
</HEAD>
<BODY BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE ALIGN="center">
<TR>
<TD><FONT FACE="Verdana" SIZE="2" COLOR="#FF0000"><B>
     The current session has timed out, or you have not established a session.<BR>
     You will be now be redirected to the <A HREF="../scripts/login.asp" TARGET="_top">login page.</B></A></TD>
</TR>
</TABLE>
</BODY>
</HTML>
<%
	Session.Abandon
    Response.End
End If
%>
