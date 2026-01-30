<%
'DBPULLDWN.INC
Dim objDC, objRS

' Create and establish data connection
Set objDC = Server.CreateObject("ADODB.Connection")
objDC.ConnectionTimeout = 15
objDC.CommandTimeout = 30
'Application("DB_PATH") = "D:\inetpub\wwwroot\d_mmsys" 
'Application("DB_CONNECTION_STRING")="DBQ="& amp;Application("DB_PATH")&"\navservers.mdb;DefaultDir="& Application("DB_PATH") &"; Driver={Microsoft Access Driver(*.mdb)}; DriverId=25;FIL=MS Access; ImplicitCommitSync=Yes; MaxBufferSize=512; MaxScanRows=8; PageTimeout=5;Threads=3; UserCommitSync=Yes;"  
'Use this line to use Access
objDC.Open "DBQ=" & Server.MapPath("D:\inetpub\wwwroot\d_mmsys\navservers.mdb") & ";Driver={Microsoft Access Driver (*.mdb)};DriverId=25;MaxBufferSize=8192;Threads=20;"

'Our SQL Server code - use above line to use sample on your server
'objDC.Open  Application("SQLConnString"), Application("SQLUsername"), Application("SQLPassword")


' Create recordset and retrieve values using the open connection
Set objRS = Server.CreateObject("ADODB.Recordset")
' Opening record set with a forward-only cursor (the 0) and in read-only mode (the 1)

' If a request for a specific id comes in, then do it o/w just show pulldown
If Len(Request.QueryString("id")) <> 0 Then
	' request record for requested id
	objRS.Open "SELECT * FROM tblAllSrvrs, objDC, 0, 1
	' Show selected record
	If Not objRS.EOF Then
		objRS.MoveFirst
' Loop through recordset and display results
If Not objRS.EOF Then
	objRS.MoveFirst
	Do While Not objRS.EOF
		<OPTION VALUE="<%= objRS.Fields("srvr_nme") & " " & objRS.Fields("srvr_desc")%></OPTION>
     	objRS.MoveNext
	     Loop
	%>
	</SELECT>
End If

' Close Data Access Objects and free DB variables
objRS.Close
Set objRS =  Nothing
objDC.Close
Set objDC = Nothing
%>
