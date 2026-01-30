<%
' BEGIN USER CONSTANTS
Dim DSN_NAME

Const DSN_NAME = "DSN=d:\inetpub\wwwroot\d_mmsys\navsrvrs.mdb;Driver={Microsoft Access Driver (*.mdb)};DriverId=25"

' To just use a DSN, the format is shown on the next line:
'Const DSN_NAME = "DBQ=C:\InetPub\wwwroot\asp101\samples\database.mdb;Driver={Microsoft Access Driver (*.mdb)};DriverId=25"


'DSN_NAME = "DBQ=" & Server.MapPath("db_dsn.mdb") & ";Driver={Microsoft Access Driver (*.mdb)};DriverId=25;"
Const DSN_USER = "Admin"
Const DSN_PASS = "navistar"

' BEGIN SUBS & FUNCTIONS SECTION
Sub OpenConnection
	Set objDC = Server.CreateObject("ADODB.Connection")
	objDC.ConnectionTimeout = 15
	objDC.CommandTimeout = 30
	objDC.Open DSN_NAME, DSN_USER, DSN_PASS
End Sub

Sub OpenRecordset(sType)
	Dim sSqlString ' as String - building area for SQL query
	Dim sCritOperator ' as String - basically "=" or "LIKE"
	Dim sCritDelimiter ' as String - parameter delimiter "", "'", or "#"

	Set objRS = Server.CreateObject("ADODB.Recordset")
	Select Case sType
		Case "Servers" ' Open RS of the Tables in the DB
           		Set objRS = Server.CreateObject("ADODB.Recordset")

		Case "Databases"  ' Open the Selected Table
           		Set objRS = Server.CreateObject("ADODB.Recordset")
			 
        	Case "Table"  ' Open the Recordset built by the selected options			
			Set objRS = Server.CreateObject("ADODB.Recordset")

	        Case "Elements"  ' Open the Recordset built by the selected options			
			Set objRS = Server.CreateObject("ADODB.Recordset")

		Case "StdAbbr"  ' Open the Recordset built by the selected options			
			Set objRS = Server.CreateObject("ADODB.Recordset")

		Case "KeyWords"  ' Open the Recordset built by the selected options			
			Set objRS = Server.CreateObject("ADODB.Recordset")

			' Build Our SQL Statement
			sSqlString = "SELECT * FROM [" & sTableName & "]"
			
			' If we're limiting records returned - insert the WHERE Clause into the SQL
			If sCritField <> "" Then
				' Figure out if we're dealinh with Numeric, Date, or String Values
				Select Case iCritDataType
					Case adSmallInt, adInteger, adSingle, adDouble, adDecimal, adTinyInt, adUnsignedTinyInt, adUnsignedSmallInt, adUnsignedInt, adBigInt, adUnsignedBigInt, adBinary, adNumeric, adVarBinary, adLongVarBinary, adCurrency, adBoolean
						sCritOperator = "="
						sCritDelimiter = ""
					Case adDate, adDBDate, adDBTime, adDBTimeStamp
						sCritOperator = "="
						sCritDelimiter = "#"
					Case adBSTR, adChar, adWChar, adVarChar, adLongVarChar, adVarWChar, adLongVarWChar
						sCritOperator = "LIKE"
						sCritDelimiter = "'"
				End Select
				sSqlString = sSqlString & " WHERE [" & sCritField & "] " & sCritOperator & " " & sCritDelimiter & sCritValue & sCritDelimiter
			End If

			' If we're sorting - insert the ORDER BY clause
			If sSortOrder <> "none" Then
				sSqlString = sSqlString & " ORDER BY [" & sSortField & "] " & sSortOrder
			End If

			sSqlString = sSqlString & ";"

			' Open the actual Recordset using a Forward Only Cursor in Read Only Mode
			objRS.Open sSqlString, objDC, adOpenForwardOnly, adLockReadOnly
	End Select
End Sub

Sub CloseRecordset
	objRS.Close
	Set objRS = Nothing
End Sub

Sub CloseConnection
	objDC.Close
	Set objDC = Nothing
End Sub

Sub WriteTitle(sTitle)
	Response.Write "<H2>" & sTitle & "</H2>" & vbCrLf
End Sub

Sub WriteTableHeader
	Response.Write "<TABLE BORDER=1>" & vbCrLf
End Sub

Sub WriteTableRowOpen
	Response.Write "<TR>" & vbCrLf
End Sub

Sub WriteTableCell(bCellIsTitle, sContents)
	Response.Write vbTab & "<TD>"
	If bCellIsTitle Then Response.Write "<B>"
	Response.Write sContents
	If bCellIsTitle Then Response.Write "</B>"
	Response.Write "</TD>" & vbCrLf
End Sub

Sub WriteTableRowClose
	Response.Write "</TR>" & vbCrLf
End Sub

Sub WriteTableFooter
	Response.Write "</TABLE>" & vbCrLf
End Sub
' END SUBS & FUNCTIONS SECTION


' BEGIN RUNTIME CODE

Dim objDC, objRS ' DataConnection and RecordSet
Dim I ' As Integer - Standard Looping Var
Dim strTemp ' As String - Temporary area for building long strings

Dim sAction ' As String - Action String to choose what to do
Dim sTableName ' As String - ...so we know what to do it to
Dim sSortField ' As String - Field to sort by
Dim sSortOrder ' As String - ...ASC or DESC
Dim sCritField ' As String - Field for DrillDown
Dim sCritValue ' As String - ...Value to compare to
Dim iCritDataType ' As Integer - so we know how to compare

' Note to all you programmers out there!
' IE4 broke this code when my QueryString was named parameter because
' it was converting the &para to the Paragraph sign even though it was
' in the middle of a word and there was no trailing ;.  It works great
' in Netscape.  Here's another case where IE's efforts to make things
' foolproof ruined the asp code!

' Get all the parameters we'll need
sAction = Request.QueryString("action")
If sAction = "" Then sAction = "ListTables"

sTableName = Request.QueryString("tablename")

sSortField = Request.QueryString("sf")
Select Case LCase(Request.QueryString("so"))
	Case "asc"
		sSortOrder = "ASC"
	Case "desc"
		sSortOrder = "DESC"
	Case Else
		sSortOrder = "none"
End Select

sCritField = Request.QueryString("cf")
If Len(sCritField) = 0 Then sCritField = ""
sCritValue = Request.QueryString("cv")
iCritDataType = Request.QueryString("cdt")
If Len(iCritDataType) <> 0 And IsNumeric(iCritDataType) Then iCritDataType = CInt(iCritDataType)

' Start the actual DB work

' Code common to all choices.
Call OpenConnection
Call OpenRecordset(sAction)

Select Case sAction
	Case "ShowDataConnectionProperties" ' Cool to look at but not really part of the sample!
		' Fake it out so we don't have problems closing the DB
		OpenRecordset("ListTables")
		' Get all the DataConn Properties
		For I = 0 to objDC.Properties.Count - 1
			Response.Write I & " " & objDC.Properties(i).Name & ": " & objDC.Properties(I) & "<BR>" & vbCrLf
		Next 'I
	Case "ListTables"
		Call WriteTitle("Tables")

		If Not objRS.EOF Then objRS.MoveFirst
		Call WriteTableHeader

		Call WriteTableRowOpen
		Call WriteTableCell(True, "Table Name")
		Call WriteTableRowClose

		Do While Not objRS.EOF
			If objRS.Fields("TABLE_TYPE") = "TABLE" Then
				Call WriteTableRowOpen
				Call WriteTableCell(False, "<A HREF=""./db_dsn.asp?action=ViewTable&tablename=" & Server.URLEncode(objRS.Fields("TABLE_NAME")) & """>" & objRS.Fields("TABLE_NAME") & "</A>")
				Call WriteTableRowClose
			End If
			objRS.MoveNext
		Loop
		Call WriteTableFooter
	Case "ViewTable", "DrillDown" ' The same here but in the OpenRecordset SUB they're very different.
		Call WriteTitle(sTableName)

		If Not objRS.EOF Then objRS.MoveFirst
		Call WriteTableHeader
		
		Call WriteTableRowOpen
		For I = 0 to objRS.Fields.Count - 1
			' Build heading - the "sort by" links
			' Was all on the line WriteTableCell line but I split it up for readability
				' Field name for the heading
				strTemp = objRS.Fields(I).Name
				' Begin Anchor for the + Sign
				strTemp = strTemp & " (<A HREF=""./db_dsn.asp"
				' Set action
				strTemp = strTemp & "?action=DrillDown"
				' Set table name to current table
				strTemp = strTemp & "&tablename=" & Server.URLEncode(sTableName)
				' Set criteria field to whatever it currently is
				strTemp = strTemp & "&cf=" & Server.URLEncode(sCritField)
				' Set criteria value to whatever it currently is
				strTemp = strTemp & "&cv=" & Server.URLEncode(sCritValue)
				' Set criteria data type to this fields' data type
				strTemp = strTemp & "&cdt=" & iCritDataType
				' Set sort field to this field
				strTemp = strTemp & "&sf=" & Server.URLEncode(objRS.Fields(I).Name)
				' Set sort order to this ascending (hence the +)
				strTemp = strTemp & "&so=asc"">+</A>"
				' End Anchor for the + Sign
				
				' Begin Anchor for the - Sign
				' Next 8 lines are basically the same as above except for the sort order (so)
				strTemp = strTemp & "/<A HREF=""./db_dsn.asp"
				strTemp = strTemp & "?action=DrillDown"
				strTemp = strTemp & "&tablename=" & Server.URLEncode(sTableName)
				strTemp = strTemp & "&cf=" & Server.URLEncode(sCritField)
				strTemp = strTemp & "&cv=" & Server.URLEncode(sCritValue)
				strTemp = strTemp & "&cdt=" & iCritDataType
				strTemp = strTemp & "&sf=" & Server.URLEncode(objRS.Fields(I).Name)
				strTemp = strTemp & "&so=desc"">-</A>)"
				' End Anchor for the - Sign
			
			Call WriteTableCell(True, strTemp)
		Next 'I
		Call WriteTableRowClose

		Do While Not objRS.EOF
			Call WriteTableRowOpen
			For I = 0 to objRS.Fields.Count - 1
				If IsNull(objRS.Fields(I).Value) Or objRS.Fields(I).Value = "" Or VarType(objRS.Fields(I).Value)= vbNull Then
					strTemp = "&nbsp;"
				Else
					' These set the drill down values which get passed if you click on any value
					strTemp = "<A HREF=""./db_dsn.asp"
					strTemp = strTemp & "?action=DrillDown"
					strTemp = strTemp & "&tablename=" & Server.URLEncode(sTableName)
					strTemp = strTemp & "&cf=" & Server.URLEncode(objRS.Fields(I).Name)
					strTemp = strTemp & "&cv=" & Server.URLEncode(objRS.Fields(I).Value)
					strTemp = strTemp & "&cdt=" & objRS.Fields(I).Type
					strTemp = strTemp & "&sf=" & Server.URLEncode(sSortField)
					strTemp = strTemp & "&so=" & sSortOrder & """>"
					strTemp = strTemp & objRS.Fields(I).Value
					strTemp = strTemp & "</A>"
				End If
				Call WriteTableCell(False, strTemp)
			Next 'I
			Call WriteTableRowClose
			objRS.MoveNext
		Loop
		Call WriteTableFooter
End Select

' Close Data Access Objects and free DB variables
Call CloseRecordset
Call CloseConnection
' END RUNTIME CODE
%>

