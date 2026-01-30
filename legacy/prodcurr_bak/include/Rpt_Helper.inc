<%
'----------------------------------Servers
Function GetAllServers()
Dim rs
Dim aryServers
Dim iCounter
Set rs = Session("rs")
	    sqlQuery = "SELECT a.srvr_nme "
        sqlQuery = sqlQuery & " FROM irma12_srvr a "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        ReDim aryServers(iCounter)
        If Not rs.BOF then
           rs.MoveFirst
        End If
        iCounter = 0
        Do Until rs.EOF = TRUE
           aryServers(iCounter,0) = RTRIM(rs.Fields(0))
           iCounter = iCounter + 1
        Loop
GetAllServers = aryServers        
End Function

Function GetServerDetails(NAME)
Dim aryServer(8)
Dim sqlQuery
Dim rs

Set rs = Session("rs")

	    sqlQuery = "SELECT a.srvr_nme, a.cmpny_loc_abbr, a.srvr_os_nme, "
        sqlQuery = sqlQuery & " a.srvr_os_vrsn_no, a.text_160_desc, a.creat_uid, a.creat_ts, "
        sqlQuery = sqlQuery & " a.lst_chng_uid, a.lst_chng_ts "
        sqlQuery = sqlQuery & " FROM irma12_srvr a "
        sqlQuery = sqlQuery & " WHERE a.srvr_nme = '" & NAME & "'"
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        aryServer(0) = RTRIM(rs.Fields(0))     'Server Name
        aryServer(1) = RTRIM(rs.Fields(1))     'Location
        aryServer(2) = RTRIM(rs.Fields(2))     'OSName 
        aryServer(3) = RTRIM(rs.Fields(3))     'OSVer 
        aryServer(4) = RTRIM(rs.Fields(4))      'Desc 
        aryServer(5) = RTRIM(rs.Fields(5))     'CreateUid
        aryServer(6) = RTRIM(rs.Fields(6))     'CreateTS
        aryServer(7) = RTRIM(rs.Fields(7))     'LastChngUid
        aryServer(8) = RTRIM(rs.Fields(8))     'LastChngTS
        rs.Close
        GetServerDetails = aryServer
End Function

Function GetDatabasesInServer(NAME)
Dim aryDatabases
Dim sqlQuery
Dim rs

Set rs = Session("rs")

	    sqlQuery = "SELECT db_nme, db_stat_cd "
        sqlQuery = sqlQuery & " FROM irma13_db_srvr "
        sqlQuery = sqlQuery & " WHERE srvr_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " ORDER BY db_nme, db_stat_cd "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        ReDim aryDatabases(iCounter,1)
        If Not rs.BOF then
           rs.MoveFirst
        End If
        iCounter = 0
        Do Until rs.EOF = True
           aryDatabases(iCounter,0) = RTRIM(rs.Fields(0))
           aryDatabases(iCounter,1) = RTRIM(rs.Fields(1))
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        rs.Close
GetDatabasesInServer = arydatabases
End Function

Function GetDatabasesInServerCount(NAME)
Dim aryDatabases
Dim sqlQuery
Dim rs

Set rs = Session("rs")

	    sqlQuery = "SELECT db_nme "
        sqlQuery = sqlQuery & " FROM irma13_db_srvr "
        sqlQuery = sqlQuery & " WHERE srvr_nme = '" & NAME & "'"
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        rs.Close
GetDatabasesInServerCount = iCounter
End Function

'--------------------------------Databases

Function GetAllDatabases()
Dim aryDatabases
Dim sqlQuery
Dim iCounter
Dim rs

Set rs = Session("rs")

	    sqlQuery = "SELECT db_nme, db_stat_cd "
        sqlQuery = sqlQuery & " FROM irma13_db_srvr "
        sqlQuery = sqlQuery & " ORDER BY db_nme, db_stat_cd "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        ReDim aryDatabases(iCounter,1)
        If Not rs.BOF then
           rs.MoveFirst
        End If
        iCounter = 0
        Do Until rs.EOF = True
           aryDatabases(0) = RTRIM(rs.Fields(0))
           aryDatabases(1) = RTRIM(rs.Fields(1))
           rs.MoveNext
        Loop
        rs.Close
GetAllDatabases = arydatabases
End Function

Function GetDatabaseDetails(NAME,STATUS)
Dim aryDatabase(9)
Dim sqlQuery
Dim rs

Set rs = Session("rs")

   	    sqlQuery = "SELECT a.db_busns_nme, a.db_stat_cd, b.srvr_nme, a.rdbms_nme, a.rdbms_vrsn_no, "
        sqlQuery = sqlQuery & " a.text_160_desc, a.creat_uid, a.creat_ts, a.lst_chng_uid, a.lst_chng_ts "
        sqlQuery = sqlQuery & " FROM  irma11_db a, irma13_db_srvr b "
        sqlQuery = sqlQuery & " WHERE a.db_nme = b.db_nme "
        sqlQuery = sqlQuery & " AND a.db_stat_cd = b.db_stat_cd "
        sqlQuery = sqlQuery & " AND a.db_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND a.db_stat_cd = '" & STATUS & "'"
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
'        response.write sqlquery
'        response.end
        If rs.BOF = -1 Then
           aryDatabase(1) = "Error"
           GetDatabaseDetails = aryDatabase
           rs.Close
           Exit Function
        End IF
        aryDatabase(0) = RTRIM(rs.Fields(0))     'Database Bname
        aryDatabase(1) = RTRIM(rs.Fields(1))     'Database status
        aryDatabase(2) = RTRIM(rs.Fields(2))     'In Server
        aryDatabase(3) = RTRIM(rs.Fields(3))     'RDBMS
        aryDatabase(4) = RTRIM(rs.Fields(4))     'RDBMS ver
        aryDatabase(5) = RTRIM(rs.Fields(5))     'Desc
        aryDatabase(6) = RTRIM(rs.Fields(6))     'Database creator
        aryDatabase(7) = RTRIM(rs.Fields(7))     'Database create ts
        aryDatabase(8) = RTRIM(rs.Fields(8))     'Database last chng by
        aryDatabase(9) = RTRIM(rs.Fields(9))     'Database last chng TS
        rs.Close
        GetDatabaseDetails = aryDatabase
End Function

Function GetTablesInDatabase(NAME,STATUS)
Dim sqlQuery
Dim aryDatabases
Dim iCounter
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT tbl_nme, tbl_stat_cd "
        sqlQuery = sqlQuery & " FROM irma01_table "
        sqlQuery = sqlQuery & " WHERE db_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND db_stat_cd = '" & STATUS & "'"
        sqlQuery = sqlQuery & " ORDER BY tbl_nme, tbl_stat_cd "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        ReDim aryTables(iCounter,1)
        If Not rs.BOF then
           rs.MoveFirst
        End If
        iCounter = 0
        Do Until rs.EOF = True
           aryTables(iCounter,0) = RTRIM(rs.Fields(0))
           aryTables(iCounter,1) = RTRIM(rs.Fields(1))
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        rs.Close
GetTablesInDatabase = aryTables
End Function

Function GetTablesInDatabaseCount(NAME,STATUS)
Dim sqlQuery
Dim iCounter
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT tbl_nme "
        sqlQuery = sqlQuery & " FROM irma01_table "
        sqlQuery = sqlQuery & " WHERE db_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND db_stat_cd = '" & STATUS & "'"
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
GetTablesInDatabaseCount = iCounter
End Function

'---------------------------------Tables
Function GetAllTables()
Dim sqlQuery
Dim aryElements
Dim strElemDesc
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT tbl_nme, tbl_stat_cd "
        sqlQuery = sqlQuery & " FROM irma01_table "
        sqlQuery = sqlQuery & " ORDER BY tbl_nme, tbl_stat_cd "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        ReDim aryTables(iCounter,1)
        If Not rs.BOF then
           rs.MoveFirst
        End If
        iCounter = 0
        Do Until rs.EOF = TRUE
           aryTables(iCounter,0) = RTRIM(rs.Fields(0))
           aryTables(iCounter,1) = RTRIM(rs.Fields(1))
           iCounter = iCounter + 1
        Loop
        rs.Close

GetAllTables = aryTables
End Function

Function GetTableDetails(NAME,STATUS)
Dim aryTable(9)
Dim strDesc
Dim rs

Set rs = Session("rs")
	    sqlQuery = "SELECT tbl_nme, tbl_stat_cd, tbl_ownr, db_nme, db_stat_cd, "
        sqlQuery = sqlQuery & " tbl_creat_uid, creat_ts, tbl_lst_chng_uid, "
        sqlQuery = sqlQuery & " tbl_lst_chng_ts "
        sqlQuery = sqlQuery & " FROM irma01_table "
        sqlQuery = sqlQuery & " WHERE tbl_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & STATUS & "'"               
        If rs.State = 1 then
            rs.Close
        End If
        rs.Open(sqlQuery)
        If rs.BOF = -1 Then
           aryTable(0) = "Error"
           GetTableDetails = aryTable
           rs.Close
           Exit Function
        End If
        aryTable(0) = RTRIM(rs.Fields(0))     'Table name
        aryTable(1) = RTRIM(rs.Fields(1))     'Table status
        aryTable(2) = RTRIM(rs.Fields(2))     'Table owner
        aryTable(3) = RTRIM(rs.Fields(3))     'Database
        aryTable(4) = RTRIM(rs.Fields(4))     'Database status
        aryTable(5) = RTRIM(rs.Fields(5))     'Table creator
        aryTable(6) = RTRIM(rs.Fields(6))     'Table create ts
        aryTable(7) = RTRIM(rs.Fields(7))     'Table last chng by
        aryTable(8) = RTRIM(rs.Fields(8))     'Table last chng TS
        rs.Close
	    sqlQuery = "SELECT text_80_desc, seq_no "
        sqlQuery = sqlQuery & " FROM irma02_table_desc "
        sqlQuery = sqlQuery & " WHERE tbl_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & STATUS & "'"               
        If rs.State = 1 then
            rs.Close
        End If
        rs.Open(sqlQuery)
        If not rs.BOF = -1 then
           strDesc = RTRIM(rs.Fields(0))     'Table desc
           rs.MoveNext
           Do Until rs.EOF = True
              strDesc = strDesc & "<br>" & RTRIM(rs.Fields(0))
              rs.MoveNext
           Loop
        Else
          strDesc = "N/A"
        End If
        rs.Close
        aryTable(9) = strDesc
GetTableDetails = aryTable
End Function

Function GetTableDescription(NAME,STATUS)
Dim sqlQuery
Dim strTableDesc
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT text_80_desc, seq_no "
        sqlQuery = sqlQuery & " FROM irma02_table_desc "
        sqlQuery = sqlQuery & " WHERE tbl_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & STATUS & "'"
        sqlQuery = sqlQuery  & " ORDER BY seq_no "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        If rs.BOF = -1 then
           strTableDesc = "N/A"
           GetTableDescription = strTableDesc
           rs.Close
           Exit Function
        End IF
        strTblDesc = rs.Fields(0)
        rs.MoveNext
        Do Until rs.EOF = True
           strTblDesc = strTblDesc & "<BR>" & RTRIM(rs.Fields(0))  'Table Desc
           rs.MoveNext
        Loop
        rs.Close
GetTableDescription = strTblDesc
End Function

Function GetElementsInTable(NAME,STATUS)
Dim sqlQuery
Dim aryElements
Dim iElemCounter
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no, prim_key_no, alt_col_nme "
        sqlQuery = sqlQuery & " FROM irma03_table_elmt "
        sqlQuery = sqlQuery & " WHERE tbl_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & STATUS & "'"
        sqlQuery = sqlQuery & " ORDER BY prim_key_no, elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iElemCounter = iElemCounter + 1
           rs.MoveNext
        Loop
        ReDim aryElements(iElemCounter,4)
        If not rs.BOF then
           rs.MoveFirst
        End If
        iElemCounter = 0
        Do Until rs.EOF = TRUE
           aryElements(iElemCounter,0) = RTRIM(rs.Fields(0))
           aryElements(iElemCounter,1) = RTRIM(rs.Fields(1))
           aryElements(iElemCounter,2) = RTRIM(rs.Fields(2))
           aryElements(iElemCounter,3) = RTRIM(rs.Fields(3))
           aryElements(iElemCounter,4) = RTRIM(rs.Fields(4))
           iElemCounter = iElemCounter + 1
           rs.MoveNext
        Loop
        rs.Close
GetElementsInTable = aryElements
End Function

Function GetElementsInTableCount(NAME,STATUS)
Dim sqlQuery
Dim aryElement
Dim strElemDesc
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT elmt_dict_nme "
        sqlQuery = sqlQuery & " FROM irma03_table_elmt "
        sqlQuery = sqlQuery & " WHERE tbl_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND tbl_stat_cd = '" & STATUS & "'"
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        rs.Close
GetElementsInTableCount = iCounter
End Function

'----------------------------------Elements
Function GetAllElements()
Dim sqlQuery
Dim aryElements
Dim strElemDesc
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT elmt_dict_nme, elmt_busns_nme, elmt_col_nme "
        sqlQuery = sqlQuery & " FROM irma05_element "
        sqlQuery = sqlQuery & " ORDER BY elmt_dict_nme "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        ReDim aryElements(iCounter,2)
        If Not rs.BOF then
           rs.MoveFirst
        End If
        iCounter = 0
        Do Until rs.EOF = TRUE
           aryElements(iCounter,0) = RTRIM(rs.Fields(0))
           aryElements(iCounter,1) = RTRIM(rs.Fields(1))
           aryElements(iCounter,2) = RTRIM(rs.Fields(2))
           iCounter = iCounter + 1
        Loop
        rs.Close

GetAllElements = aryElements
End Function

Function GetElementDetails(NAME,STATUS,VERSION)
Dim sqlQuery
Dim aryElement(13)
Dim strElemDesc
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT a.elmt_busns_nme, a.elmt_dict_nme, a.elmt_col_nme, a.elmt_stat_cd, b.elmt_vrsn_no, "
        sqlQuery = sqlQuery & " b.elmt_data_typ_id, b.elmt_logcl_lng, b.elmt_phys_lng, b.elmt_dec_lng, "
        sqlQuery = sqlQuery & " a.elmt_creat_uid, a.creat_ts, a.elmt_lst_chng_uid, a.elmt_lst_chng_ts, "
        sqlQuery = sqlQuery & " c.text_80_desc, c.seq_no "
        sqlQuery = sqlQuery & " FROM irma05_element a, irma04_elmt_vrsn b, outer irma06_elmt_desc c "
        sqlQuery = sqlQuery & " WHERE a.elmt_dict_nme = b.elmt_dict_nme "       
        sqlQuery = sqlQuery & " AND a.elmt_stat_cd = b.elmt_stat_cd "       
        sqlQuery = sqlQuery & " AND b.elmt_dict_nme = c.elmt_dict_nme "       
        sqlQuery = sqlQuery & " AND b.elmt_stat_cd = c.elmt_stat_cd "       
        sqlQuery = sqlQuery & " AND b.elmt_dict_nme = '" & NAME & "'"
        sqlQuery = sqlQuery & " AND b.elmt_stat_cd = '" & STATUS & "'"               
        sqlQuery = sqlQuery & " AND b.elmt_vrsn_no = '" & VERSION & "'"
        sqlQuery = sqlQuery  & " ORDER BY seq_no "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        'If rs.BOF = -1 then
        '  aryElement(0) = "Error"
        '  GetElementDetails = aryElement
        '  rs.Close
        '  exit function 
		'end if
          aryElement(0) = TRIM(rs.Fields(0)) 'ElemBName
          aryElement(1) = TRIM(rs.Fields(1)) 'ElemDName
          aryElement(2) = TRIM(rs.Fields(2)) 'ElemCName
          aryElement(3) = TRIM(rs.Fields(3)) 'ElemStatus
          aryElement(4) = TRIM(rs.Fields(4)) 'ElemVersion
          aryElement(5) = TRIM(rs.Fields(5)) 'ElemDataType
          aryElement(6) = TRIM(rs.Fields(6)) 'ElemlLen
          aryElement(7) = TRIM(rs.Fields(7)) 'ElemPLen
          aryElement(8) = TRIM(rs.Fields(8)) 'ElemDecLen
          aryElement(9) = TRIM(rs.Fields(9)) 'ElemCreator
          aryElement(10) = TRIM(rs.Fields(10)) 'ElemCreateTS
          aryElement(11) = TRIM(rs.Fields(11)) 'ElemLastChng
          aryElement(12) = TRIM(rs.Fields(12)) 'ElemLastChngTS
          strElemDesc = rs.Fields(13)
          rs.MoveNext
          Do Until rs.EOF = True
             strElemDesc = strElemDesc & "<BR>" & RTRIM(rs.Fields(13))  'ElemDesc
             rs.MoveNext
          Loop
		  strElemDesc = strElemDesc & "<BR>" 
          aryElement(13) = strElemDesc
          rs.Close
          GetElementDetails = aryElement          
End Function

Function GetElementDescription(NAME,STATUS)
Dim sqlQuery
Dim strElemDesc
Dim rs

Set rs = Session("rs")

        sqlQuery = "SELECT text_80_desc, seq_no "
        sqlQuery = sqlQuery & " FROM irma06_elmt_desc "
        sqlQuery = sqlQuery & " WHERE elmt_dict_nme = '" & NAME & "'"
        sqlQuery = sqlQuery  & " ORDER BY seq_no "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        strElemDesc = rs.Fields(12)
        rs.MoveNext
        Do Until rs.EOF = True
           strElemDesc = strElemDesc & "<BR>" & RTRIM(rs.Fields(12))  'ElemDesc
           rs.MoveNext
        Loop
        aryElement(12) = strElemDesc
        rs.Close
GetElementDescription = strElemDesc
End Function

Function GetWhereUsed(ELEMENTDNAME, STATUS, VERSION)
Dim sqlQuery
Dim aryTables
Dim iCounter
Dim rs

Set rs = Session("rs")
        sqlQuery = "SELECT tbl_nme, tbl_stat_cd "
        sqlQuery = sqlQuery & " FROM irma03_table_elmt "
        sqlQuery = sqlQuery & " WHERE elmt_dict_nme = '" & ELEMENTDNAME & "'"
        sqlQuery = sqlQuery & " AND elmt_stat_cd = '" & STATUS & "'"               
        sqlQuery = sqlQuery & " AND elmt_vrsn_no = '" & VERSION & "'"               
        sqlQuery = sqlQuery & " ORDER BY tbl_nme, tbl_stat_cd "
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        iCounter = 0
        Do Until rs.EOF = True
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        ReDim aryTables(iCounter,1)
        If Not rs.BOF then
           rs.MoveFirst
        End If
        iCounter = 0
        Do Until rs.EOF = True
           aryTables(iCounter,0) = UCASE(TRIM(rs.Fields(0)))
           aryTables(iCounter,1) = UCASE(TRIM(rs.Fields(1)))
           iCounter = iCounter + 1
           rs.MoveNext
        Loop
        rs.Close
GetWhereUsed = aryTables
End Function

Function GetElementDName(NAME)
Dim sqlQuery
Dim aryElement
Dim iCounter
Dim rs

Set rs = Session("rs")
        sqlQuery = "SELECT elmt_dict_nme "
        sqlQuery = sqlQuery & " FROM irma05_element "
        If InStr(NAME," ") Then
           sqlQuery = sqlQuery & " WHERE elmt_busns_nme = '" & NAME & "'"
        ElseIf InStr(NAME, "_") Then
           sqlQuery = sqlQuery & " WHERE elmt_col_nme = '" & NAME & "'"
        ElseIf InStr(NAME,"-") Then
           sqlQuery = sqlQuery & " WHERE elmt_dict_nme = '" & NAME & "'"
        Else
           sqlQuery = sqlQuery & " WHERE elmt_dict_nme = '" & NAME & "'"
        End IF
        If rs.State = 1 then
           rs.Close
        End If
        rs.Open(sqlQuery)
        If Not rs.BOF = -1 then
           GetElementDName = RTRIM(rs.Fields(0))
        Else
           GetElementDName = "Error"
        End IF
        rs.Close
End Function
%>