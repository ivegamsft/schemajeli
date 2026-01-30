<%
 Response.Buffer = TRUE
 Session.Timeout=60
 Server.ScriptTimeOut = 1800
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<!--#INCLUDE FILE="../include/rpt_helper.inc"-->
<%

Dim rs
Dim strRelObjReport
Dim strRelObjReportType
Dim strRelObjStatus
Dim strRelObjServer
Dim strRelObjName
Dim sqlSubQuery
Dim sqlQuery
Dim iFieldCount
Dim iLoopCount
Dim iHeaderCount
Dim aryHeader(9)
Dim iRows
Dim IRowCount
Dim aryCriteria(9)
Dim aryDatabase()

Set rs = Session("rs")

strRelObjReport = TRIM(Request.Form("RelObjReport"))
strRelObjReportType = TRIM(Request.Form("RelObjReportType"))
strRelObjStatus = UCASE(TRIM(Request.Form("RelObjStatus")))
strRelObjServer = TRIM(Request.Form("RelObjServer"))
strRelObjName = UCASE(TRIM(Request.Form("RelObjName")))
strReportDate = NOW()
strReportGenBy = Session("UserID")

'-------------------------Display the server detail report
Select Case strRelObjReport
	Case "Server"
    aryServerDetails = GetServerDetails(strRelObjServer)
    aryDatabases = GetDatabasesInServer(strRelObjServer)
    iDbCount = GetDatabasesInServerCount(strRelObjServer)
    strServerName = aryServerDetails(0)
    strLocation = aryServerDetails(1)
    strOSName = aryServerDetails(2)
    strOSVer = aryServerDetails(3)
    strDesc = aryServerDetails(4)
    strCreateUid = aryServerDetails(5)
    strCreateTS = aryServerDetails(6)
    strLastChngUid = aryServerDetails(7)
    strLastChngTS = aryServerDetails(8)
%>  <!--#INCLUDE FILE="../include/Rpt_Head.inc"-->
    <!--#INCLUDE FILE="../include/Rpt_SrvrSum.inc"-->
<%  For iLoopCount = 0 to iDbCount -1
        strDbName = aryDatabases(iLoopCount,0)
        strDbDesc = aryDatabases(iLoopCount,1)
        strDbStatus = aryDatabases(iLoopCount,1)
        iTblCount = GetTablesInDatabaseCount(strDbName,strDbStatus)%>
        <!--#INCLUDE FILE="../include/Rpt_SrvrSumDb.inc"-->
<%       Response.Flush 
     Next%>
     </TABLE>
     <!--#INCLUDE FILE="../include/Rpt_Foot.inc"-->
<%
'-------------------------Display the database detail report
    Case "Database"
      Select Case strRelObjReportType
        Case "Detail"
        aryDbDetail = GetDatabaseDetails(strRelObjName, strRelObjStatus)
        If aryDbDetail(1) <> "Error" Then
           aryTbls = GetTablesInDatabase(strRelObjName, strRelObjStatus)
           iTableCount = GetTablesInDatabaseCount(strRelObjName, strRelObjStatus)
           strDbBName = aryDbDetail(0)
           strDbStatus = aryDbDetail(1)
           strServer = aryDbDetail(2)
           strRDBMS = aryDbDetail(3)
           strRDBMSVer = aryDbDetail(4)
           strDesc = aryDbDetail(5)
           strCreateUid = aryDbDetail(6)
           strCreateTS = aryDbDetail(7)
           strLastChngUid = aryDbDetail(8)
           strLastChngTS = aryDbDetail(9)%>
            <!--#INCLUDE FILE="../include/Rpt_Head.inc"-->
            <!--#INCLUDE FILE="../include/Rpt_DbDtl.inc"-->
<%          For iLoopCount = 0 to iTableCount -1
                strTableName = aryTbls(iLoopCount,0)
                strTableStatus = aryTbls(iLoopCount,1)
                iElemCount = GetElementsInTableCount(strTableName, strTableStatus)
                strTableDesc = GetTableDescription(strTableName, strTableStatus)
%>
                <!--#INCLUDE FILE="../include/Rpt_DbDtlTbl.inc"-->
<%              Response.Flush 
            Next%>
         </TABLE>
         <!--#INCLUDE FILE="../include/Rpt_Foot.inc"-->
<%     Else
%>
         <!--#INCLUDE FILE="../include/Rpt_Error.inc"-->
<%   End IF
            
'-------------------------Display the database full report    
        Case "Full"  
        aryDbDetail = GetDatabaseDetails(strRelObjName, strRelObjStatus)
        If aryDbDetail(1) <> "Error" Then
          aryTbls = GetTablesInDatabase(strRelObjName, strRelObjStatus)
          iTableCount = GetTablesInDatabaseCount(strRelObjName, strRelObjStatus)
          strDbBName = aryDbDetail(0)
          strDbStatus = aryDbDetail(1)
          strServer = aryDbDetail(2)
          strRDBMS = aryDbDetail(3)
          strRDBMSVer = aryDbDetail(4)
          strDesc = aryDbDetail(5)
          strCreateUid = aryDbDetail(6)
          strCreateTS = aryDbDetail(7)
          strLastChngUid = aryDbDetail(8)
          strLastChngTS = aryDbDetail(9)
%>
           <!--#INCLUDE FILE="../include/Rpt_Head.inc"-->
           <!--#INCLUDE FILE="../include/Rpt_DbFull.inc"-->
<%         For iLoopCount = 0 to iTableCount -1
               strTableName = aryTbls(iLoopCount,0)
               strTableStatus = aryTbls(iLoopCount,1)
               iElemCount = GetElementsInTableCount(strTableName, strTableStatus)
               aryCurTable = GetTableDetails(strTableName, strTableStatus)
               strTableOwner = aryCurTable(2)             
               strTableCreateUid = aryCurTable(5)
               strTableCreateTS = aryCurTable(6)
               strTableLstChngUid = aryCurTable(7)
               strTableLstChngTS = aryCurTable(8)
               strTableDesc = aryCurTable(9)
%>
               <!--#INCLUDE FILE="../include/Rpt_DbFullDtl.inc"-->
<% 
               aryElements = GetElementsInTable(strTableName, strTableStatus)
               For iElemCount = 0 to UBOUND(aryElements) -1
                aryCurElementDetails = GetElementDetails(aryElements(iElemCount,0),aryElements(iElemCount,1),aryElements(iElemCount,2)) 
                strElemBName = aryCurElementDetails(0)
                strElemDName = aryCurElementDetails(1)
                strElemCName = aryCurElementDetails(2)
                strElemStatus = aryCurElementDetails(3)
                strElemVer = aryCurElementDetails(4)
                strElemDataType = aryCurElementDetails(5)
                strElemLLen = aryCurElementDetails(6)
                strElemPLen = aryCurElementDetails(7)
                strElemDLen = aryCurElementDetails(8)
                strElemPrimKey = aryElements(iElemCount,3)
                strElemAltColName = aryElements(iElemCount,4)
                strElemCreateUid = aryCurElementDetails(9)
                strElemCreateTS = aryCurElementDetails(10)
                strElemLstChngUid = aryCurElementDetails(11)
                strElemLstChngTS = aryCurElementDetails(12)
                strElemDesc = aryCurElementDetails(13)
%>              
               <!--#INCLUDE FILE="../include/Rpt_DbFullDtlTbl.inc"-->
<%             Next  
           Response.Flush
           If Not iLoopCount = iTableCount -1 Then
%>
         <TR BGCOLOR="<%=strLineColor%>">
         <TD HEIGHT="10" colspan="8">
             </TD>
             </TR>
<%         End If
           Next%>
         </TABLE>
         <!--#INCLUDE FILE="../include/Rpt_Foot.inc"-->
<%     Else
%>
         <!--#INCLUDE FILE="../include/Rpt_Error.inc"-->
<%   End IF
            
     
      End Select
'-------------------------Display the table summary report
	Case "Table"
     Select Case strRelObjReportType
        Case "Summary"
        aryTableDetails = GetTableDetails(strRelObjName, strRelObjStatus)
        If aryTableDetails(0) <> "Error" Then
          iElemCount = GetElementsInTableCount(strRelObjName, strRelObjStatus)
          aryElement = GetElementsInTable(strRelObjName, strRelObjStatus)
          strTblOwner = aryTableDetails(2)
          strDatabase = aryTableDetails(3)
          strDbStatus = aryTableDetails(4)
          strCreateUid = aryTableDetails(5)
          strCreateTS = aryTableDetails(6)
          strLastChngUid = aryTableDetails(7)
          strLastChngTS = aryTableDetails(8)
          strDesc = aryTableDetails(9)
%>
          <!--#INCLUDE FILE="../include/Rpt_Head.inc"-->
          <!--#INCLUDE FILE="../include/Rpt_TblSum.inc"-->
<%        aryElements = GetElementsInTable(strRelObjName, strRelObjStatus)
          For iElemCount = 0 to UBOUND(aryElements) -1
             aryCurElementDetails = GetElementDetails(aryElements(iElemCount,0),aryElements(iElemCount,1),aryElements(iElemCount,2)) 
             strElemBName = aryCurElementDetails(0)
             strElemDName = aryCurElementDetails(1)
             strElemCName = aryCurElementDetails(2)
             strElemStatus = aryCurElementDetails(3)
             strElemVer = aryCurElementDetails(4)
             strElemDataType = aryCurElementDetails(5)
             strElemLLen = aryCurElementDetails(6)
             strElemPLen = aryCurElementDetails(7)
             strElemDLen = aryCurElementDetails(8)
             strElemPrimKey = aryElements(iElemCount,3)
             strElemAltColName = aryElements(iElemCount,4)
             strElemCreateUid = aryCurElementDetails(9)
             strElemCreateTS = aryCurElementDetails(10)
             strElemLstChngUid = aryCurElementDetails(11)
             strElemLstChngTS = aryCurElementDetails(12)
             strElemDesc = aryCurElementDetails(13)
%>           <!--#INCLUDE FILE="../include/Rpt_TblSumElem.inc"-->
<%           Response.Flush 
          Next%>
          </TABLE>
          <!--#INCLUDE FILE="../include/Rpt_Foot.inc"-->
<%     Else
%>
         <!--#INCLUDE FILE="../include/Rpt_Error.inc"-->
<%   End IF

'-------------------------Display the table detail report
        Case "Detail"
        aryTableDetails = GetTableDetails(strRelObjName, strRelObjStatus)
        If aryTableDetails(0) <> "Error" Then
           iElemCount = GetElementsInTableCount(strRelObjName, strRelObjStatus)
           strTblOwner = aryTableDetails(2)
           strDatabase = aryTableDetails(3)
           strDbStatus = aryTableDetails(4)
           strCreateUid = aryTableDetails(5)
           strCreateTS = aryTableDetails(6)
           strLastChngUid = aryTableDetails(7)
           strLastChngTS = aryTableDetails(8)
           strDesc = aryTableDetails(9)
%>
        <!--#INCLUDE FILE="../include/Rpt_Head.inc"-->
        <!--#INCLUDE FILE="../include/Rpt_TblDtl.inc"-->
<%      aryElements = GetElementsInTable(strRelObjName, strRelObjStatus)
        For iElemCount = 0 to UBOUND(aryElements) -1
           aryCurElementDetails = GetElementDetails(aryElements(iElemCount,0),aryElements(iElemCount,1),aryElements(iElemCount,2)) 
           strElemBName = aryCurElementDetails(0)
           strElemDName = aryCurElementDetails(1)
           strElemCName = aryCurElementDetails(2)
           strElemStatus = aryCurElementDetails(3)
           strElemVer = aryCurElementDetails(4)
           strElemDataType = aryCurElementDetails(5)
           strElemLLen = aryCurElementDetails(6)
           strElemPLen = aryCurElementDetails(7)
           strElemDLen = aryCurElementDetails(8)
           strElemPrimKey = aryElements(iElemCount,3)
           strElemAltColName = aryElements(iElemCount,4)
           strElemCreateUid = aryCurElementDetails(9)
           strElemCreateTS = aryCurElementDetails(10)
           strElemLstChngUid = aryCurElementDetails(11)
           strElemLstChngTS = aryCurElementDetails(12)
           strElemDesc = aryCurElementDetails(13)
%>         <!--#INCLUDE FILE="../include/Rpt_TblDtlElem.inc"-->
<%         Response.Flush 
        Next%>
        </TABLE>
        <!--#INCLUDE FILE="../include/Rpt_Foot.inc"-->
           
<%     Else
%>
         <!--#INCLUDE FILE="../include/Rpt_Error.inc"-->
<%   End IF
            
      End Select
'-------------------------Display the element detail report
    Case "Element"
    strCurElement = GetElementDName(strRelObjName)
    If strCurElement <> "Error" then
       aryCurElementDetails = GetElementDetails(strCurElement,strRelObjStatus,"1") 
       strElemBName = aryCurElementDetails(0)
       strElemDName = aryCurElementDetails(1)
       strElemCName = aryCurElementDetails(2)
       strElemStatus = aryCurElementDetails(3)
       strElemVer = aryCurElementDetails(4)
       strElemDataType = aryCurElementDetails(5)
       strElemLLen = aryCurElementDetails(6)
       strElemPLen = aryCurElementDetails(7)
       strElemDLen = aryCurElementDetails(8)
       strElemCreateUid = aryCurElementDetails(9)
       strElemCreateTS = aryCurElementDetails(10)
       strElemLstChngUid = aryCurElementDetails(11)
       strElemLstChngTS = aryCurElementDetails(12)
       strElemDesc = aryCurElementDetails(13)      
       aryTables = GetWhereUsed(strElemDName, strElemStatus, strElemVer)
       iTblCount = UBOUND(aryTables)
%>  
    <!--#INCLUDE FILE="../include/Rpt_Head.inc"-->
    <!--#INCLUDE FILE="../include/Rpt_ElemDtl.inc"-->
<%  
    For iLoopCount = 0 to UBOUND(aryTables)
      strTblName = aryTables(iLoopCount,0)
      strTblStatus = aryTables(iLoopCount,1)%>
      <!--#INCLUDE FILE="../include/Rpt_ElemDtlElem.inc"-->
<%    Response.Flush 
      Next
%>
  </TABLE>
  <!--#INCLUDE FILE="../include/Rpt_Foot.inc"-->
<%     Else
%>
         <!--#INCLUDE FILE="../include/Rpt_Error.inc"-->
<%   End IF
End Select
%>
