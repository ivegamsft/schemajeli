<%
Response.buffer = True
'-----------------Save navigation information
Dim strPath
Dim strFileName

strPath = session("savepath")&"logs\"
strFileName = replace(date, "/", "-")&"pgs.txt" 
Set objFile = Server.CreateObject("Scripting.FileSystemObject")
set objCurFile = objFile.GetFile(strPath & strFilename)
Set objFileText = objCurFile.OpenAsTextStream(8,0)
objFileText.Write Session.SessionId & "," & TIME & ", Exit" 
objFileText.writeBlankLines(1)
Set objFile = Nothing
Set objCurFile = Nothing
Set objFileText = Nothing
%>
<!--#INCLUDE FILE="../include/colors.inc"-->
<SCRIPT LANGUAGE="VBScript">
Sub Window_OnLoad
    Window.SetTimeout "ReDirLogin",2000
End Sub
Sub ReDirLogin
   Parent.location.Href = "http://wwwnio.navistar.com/edw/dataaccess/default.htm"
   Window.ClearTimeout
End Sub
</SCRIPT>
<HTML>
<HEAD>
<TITLE>Session timeout</TITLE>
</HEAD>
<BODY BACKGROUND="../images/watermrk.jpg" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<TABLE ALIGN="center">
<TR>
<TD HEIGHT="70">
</TD>
</TR>
<TR>
<TD ALIGN="CENTER"><FONT FACE="Verdana" SIZE="2"><H2><B>
     You have successfully ended your session.<BR>
     Thank you for using the <B>Navistar Repository System.</B></H2><BR>
     You will now be redirected to the <A HREF="http://wwwnio.navistar.com/edw/dataaccess/default.htm" TARGET="_top">Enterprise Data Warehouse data access page.</B></A></TD>
</TR>
</TABLE>
</BODY>
</HTML>
<%
Session.Abandon
Response.End
%>