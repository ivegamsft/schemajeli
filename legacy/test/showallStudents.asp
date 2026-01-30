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

        sql = "Select * from tblStudent;"
        objRS.Open sql, objDC

%>
<html>
<head>
</head>
<body>
<table border="1" align="center">
  
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
<td colspan="3">
<a href="showallclasses.asp">This will show the classes</a>
</td>
</tr>

<tr>
<td colspan="3">
<a href="showallstudentsclasses.asp">This will show the students in the classes</a>
</td>
</tr>

<tr>
<td colspan="3">
<a href="showall.asp">Home</a>
</td>
</tr>

</table>
</body>
</html>
