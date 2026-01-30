<%
Dim DSN_NAME
Dim objDC
Dim objRS
Dim sql
Dim iLoop
DSN_NAME = "studentdb"

Set objDC = Server.CreateObject("ADODB.Connection")
Set objRS = Server.CreateObject("ADODB.Recordset")

objDC.ConnectionTimeout = 15
objDC.CommandTimeout = 30
objDC.Open DSN_NAME

sql = "SELECT b.classname, b.classdesc, a.studentFname, a.studentLName, a.studentid"
sql = sql & " FROM tblStudent a, tblClass b" 
sql = sql & " WHERE a.studentid = b.studentid"
sql = sql & " ORDER BY b.classdesc;"

objRS.Open sql, objDC

%>
<html>
<head>
</head>
<body>
<a "#Top"></A>
<table border="1" align="Center">
 
<%
Do until objRs.EOF = True
%>
<tr>
<%   For iLoop = 0 to objrs.Fields.count -1 %>
<td>
<%       Response.Write objrs.Fields(iloop)   %>
</td>  
<%      Next%>
</tr>
<%    objrs.movenext  %>

<%Loop%>
</tr>
<%
	Set objRS = Nothing
	objDC.Close
	Set objDC = Nothing

%>
<tr>
<td colspan="5">
<a href="showallstudents.asp">This will show the students</a>
</td>  
</tr>

<tr>
<td colspan="5">
<a href="showallclasses.asp">This will show the classes</a>
</td>
</tr>

<tr>
<td colspan="5">
<a href="#Top">Back to top</a>
</td>
</tr>

<tr>
<td colspan="5">
<a href="showall.asp">Home</a>
</td>
</tr>

</table>
</body>
</html>
