<%
 Response.Buffer = TRUE
 Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%

Dim rs
Dim iResultType         '1=View all fields 2=View only details (for generic reports)
Dim strRelObject
Dim strRelObjName
Dim sqlOperator
Dim sqlSubQuery
Dim sqlQuery
Dim iFieldCount
Dim iLoopVar
Dim iHeaderCount
Dim aryHeader(9)
Dim iRows
Dim IRowCount
Dim aryCriteria(9)
Dim strQBackColor
Dim strQPageBackColor
Dim strQTextColor
Dim strOrderBy
Dim strHistory
'***********Retrieve QueryString Variables and convert them to a usable form
strRelObject = Request.QueryString("RelObject")
sqlOperator = Request.QueryString("Operator")
strOrderBy = Request.QueryString("OrderBy")

aryHeader(0)=""
aryHeader(1)=""
Select Case strRelObject
	
	Case "Server"
        aryCriteria(0) = "View-Servers"
        iResultType=2   'no edit 
		sqlQuery = "SELECT srvr_nme, srvr_os_nme, text_160_desc, cmpny_loc_abbr " 
		sqlQuery = sqlQuery & " FROM irma12_srvr " 
        Select Case strOrderBy
            Case "Server",""
         		sqlQuery = sqlQuery & " ORDER BY srvr_nme " 
            Case "OS"
         		sqlQuery = sqlQuery & " ORDER BY srvr_os_nme " 
            Case "Desc"
         		sqlQuery = sqlQuery & " ORDER BY text_160_desc " 
            Case "Location"
         		sqlQuery = sqlQuery & " ORDER BY cmpny_loc_abbr " 
            End Select
		iHeaderCount = 4
        aryCriteria(0) = "View$Servers"
		aryHeader(0)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Server&OrderBy=Server TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Server Name</a>"
		aryHeader(1)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Server&OrderBy=OS TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">OS Name</a>"
		aryHeader(2)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Server&OrderBy=Desc TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Description</a>"
   		aryHeader(3)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Server&OrderBy=Location TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Location</a>"
        aryCriteria(0) = "View Servers"

	Case "Database"
        aryCriteria(0) = UCASE(Request.QueryString("Criteria"))
        If InStr(aryCriteria(0),"$") then
           aryCriteria(0) = Replace(aryCriteria(0),"$","%")
        End If
        iResultType = 1
	    sqlQuery = "SELECT a.db_nme, a.db_stat_cd, b.srvr_nme, a.rdbms_nme, a.rdbms_vrsn_no "
        sqlQuery = sqlQuery & " FROM irma11_db a, irma13_db_srvr b"
		sqlQuery = sqlQuery & " WHERE a.db_nme = b.db_nme "
		sqlQuery = sqlQuery & " AND a.db_stat_cd = b.db_stat_cd "
        If sqlOperator = "LIKE" then  
            sqlQuery = sqlQuery & " AND a.db_nme LIKE '" & aryCriteria(0) & "%'"
        Else
            sqlQuery = sqlQuery & " AND a.db_nme = '" & aryCriteria(0) & "'"
        End If
        Select Case strOrderBy
            Case "DbName",""
                 sqlQuery = sqlQuery & " ORDER BY a.db_nme "
            Case "Status"
                 sqlQuery = sqlQuery & " ORDER BY a.db_stat_cd "
            Case "Server"
                 sqlQuery = sqlQuery & " ORDER BY b.srvr_nme "
            Case "RDBMS"
                 sqlQuery = sqlQuery & " ORDER BY a.rdbms_nme "
            Case "RDBMSVer"
                 sqlQuery = sqlQuery & " ORDER BY a.rdbms_vrsn_no "
            End Select
        iHeaderCount = 7
        If InStr(aryCriteria(0),"%") then
           aryCriteria(0) = Replace (aryCriteria(0),"%","$")
        End If
		aryHeader(2) = "<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Database&OrderBy=DbName TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Database Name</a>"
        aryHeader(3) = "<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Database&OrderBy=Status TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Status</a>"
		aryHeader(4) = "<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Database&OrderBy=Server TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Server Name</a>"
        aryHeader(5) = "<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Database&OrderBy=RDBMS TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">RDBMS</a>"
        aryHeader(6) = "<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Database&OrderBy=RDBMSVer TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">RDBMS Ver</a>"
        strHistory = "search_dbs.asp"
        
	Case "Table"
        aryCriteria(0) = UCASE(Request.QueryString("Criteria"))
        If InStr(aryCriteria(0),"$") then
           aryCriteria(0) = Replace(aryCriteria(0),"$","%")
        End If
        iResultType = 1
        sqlQuery= "SELECT tbl_nme, tbl_stat_cd, tbl_creat_uid, tbl_lst_chng_uid FROM irma01_table elmt_dict_nme" 
        sqlQuery = sqlQuery & " WHERE tbl_nme like '" & aryCriteria(0) & "%'"   
        Select Case strOrderBy
            Case "TableName",""
                sqlQuery = sqlQuery & " ORDER BY tbl_nme" 
            Case "Status"
                sqlQuery = sqlQuery & " ORDER BY tbl_stat_cd" 
            Case "Creator"
                sqlQuery = sqlQuery & " ORDER BY tbl_creat_uid"
            Case "LastChng"
                sqlQuery = sqlQuery & " ORDER BY tbl_lst_chng_uid DESC" 
            End Select
		iHeaderCount = 6
        If InStr(aryCriteria(0),"%") then
           aryCriteria(0) = Replace (aryCriteria(0),"%","$")
        End If
		aryHeader(2)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Table&OrderBy=TableName TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Table Name</a>"
		aryHeader(3)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Table&OrderBy=Status TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Status</a>"
		aryHeader(4)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Table&OrderBy=Creator TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Created By</a>"
		aryHeader(5)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Table&OrderBy=LastChng TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Changed By</a>"
        strHistory = "search_tbls.asp"
        
	Case "ElementKywds"        'From keyword search
        iResultType = 1
		'sqlSubQuery = "from irma07_elmt_kwd WHERE key_word_nme = "
        If request.form("keyword1") <> "" then 
           sqlSubQuery = sqlSubQuery & " select elmt_dict_nme from irma07_elmt_kwd WHERE key_word_nme = " 
           sqlSubQuery = sqlSubQuery & " '" & ucase(request.form("keyword1")) & "')" 
           aryCriteria(0)= Request.Form("keyword1")
        end if 

        if request.form("keyword2") <> "" then
	       sqlSubQuery = sqlSubQuery & " and a.elmt_dict_nme in ("
           sqlSubQuery = sqlSubQuery & " select elmt_dict_nme from irma07_elmt_kwd WHERE key_word_nme = " 
           sqlSubQuery = sqlSubQuery & " '" & ucase(request.form("keyword2")) & "' )"
           aryCriteria(1)= Request.Form("keyword2")
        end if 

        if request.form("keyword3") <> "" then
           sqlSubQuery = sqlSubQuery & " and a.elmt_dict_nme in ("
           sqlSubQuery = sqlSubQuery & " select elmt_dict_nme from irma07_elmt_kwd WHERE key_word_nme = " 
           sqlSubQuery = sqlSubQuery & " '" & ucase(request.form("keyword3")) & "' )"
           aryCriteria(2)= Request.Form("keyword3")
        end if

        if request.form("keyword4") <> "" then
		   sqlSubQuery = sqlSubQuery & " and a.elmt_dict_nme in ("
           sqlSubQuery = sqlSubQuery & " select elmt_dict_nme from irma07_elmt_kwd WHERE key_word_nme = " 
           sqlSubQuery = sqlSubQuery & " '" & ucase(request.form("keyword4")) & "') "
           aryCriteria(3)= Request.Form("keyword4")
        end if 

        if request.form("keyword5") <> "" then
		   sqlSubQuery = sqlSubQuery & " and a.elmt_dict_nme in ("
           sqlSubQuery = sqlSubQuery & " select elmt_dict_nme from irma07_elmt_kwd WHERE key_word_nme = " 
           sqlSubQuery = sqlSubQuery & " '" & ucase(request.form("keyword5")) & "') "
           aryCriteria(4)= Request.Form("keyword5")
        end if
           sqlQuery = "SELECT a.elmt_dict_nme, a.elmt_busns_nme,"
           sqlQuery = sqlQuery & " a.elmt_stat_cd, b.elmt_vrsn_no"
           sqlQuery = sqlQuery & " FROM irma05_element a, irma04_elmt_vrsn b"
           sqlQuery = sqlQuery & " WHERE a.elmt_dict_nme = b.elmt_dict_nme"
           sqlQuery = sqlQuery & " and a.elmt_stat_cd=b.elmt_stat_cd"
           sqlQuery = sqlQuery & " and a.elmt_dict_nme in ( " & sqlSubQuery & "  order by a.elmt_dict_nme"
		   iHeaderCount = 6
		   aryHeader(2)="Dictionary Name"
		   aryHeader(3)="Business Name"
           aryHeader(4)="Status"
		   aryHeader(5)="Version"
           strHistory = "search_elem_kywds.asp"
           
   Case "Element"
        iResultType = 1
		aryCriteria(0) = UCASE(Request.QueryString("Criteria"))
        If InStr(aryCriteria(0),"$") then
           aryCriteria(0) = Replace(aryCriteria(0),"$","%")
        End If
        sqlQuery = "SELECT a.elmt_dict_nme, a.elmt_busns_nme,"
        sqlQuery = sqlQuery & " a.elmt_stat_cd, b.elmt_vrsn_no"
        sqlQuery = sqlQuery & " FROM irma05_element a, irma04_elmt_vrsn b"
        sqlQuery = sqlQuery & " WHERE a.elmt_dict_nme = b.elmt_dict_nme"
        sqlQuery = sqlQuery & " and a.elmt_stat_cd=b.elmt_stat_cd"
        If sqlOperator = "LIKE" then  
           sqlQuery = sqlQuery & " and a.elmt_dict_nme " & sqlOperator & " '" & aryCriteria(0) & "%'"
        Else
           sqlQuery = sqlQuery & " and a.elmt_dict_nme = '"  & aryCriteria(0) & "'"
        End If
        Select Case strOrderBy
            Case "DName",""
               sqlQuery = sqlQuery & " ORDER BY a.elmt_dict_nme"
            Case "BName"
               sqlQuery = sqlQuery & " ORDER BY a.elmt_busns_nme"
            Case "Status"
               sqlQuery = sqlQuery & " ORDER BY a.elmt_stat_cd"
            Case "Version"
               sqlQuery = sqlQuery & " ORDER BY b.elmt_vrsn_no"
            End Select
        iHeaderCount = 6
        If InStr(aryCriteria(0),"%") then
           aryCriteria(0) = Replace (aryCriteria(0),"%","$")
        End If
		aryHeader(2)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Element&OrderBy=DName TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Dictionary Name</a>"
		aryHeader(3)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Element&OrderBy=BName TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Business Name</a>"
        aryHeader(4)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Element&OrderBy=Status TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Status</a>"
		aryHeader(5)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&Operator=" & sqlOperator & "&RelObject=Element&OrderBy=Version TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Version</a>"
        strHistory = "search_elem.asp"

   Case "Abbreviation"
        iResultType = 2
		aryCriteria(0) = UCASE(Request.QueryString("Criteria"))
        If InStr(aryCriteria(0),"$") then
           aryCriteria(0) = Replace(aryCriteria(0),"$","%")
        End If
		sqlQuery = "SELECT std_abbr_srce_nme, std_abbr_nme, clas_word_i " 
		sqlQuery = sqlQuery & " FROM irma10_std_abbr" 
 		sqlQuery = sqlQuery & " WHERE std_abbr_srce_nme LIKE '" & aryCriteria(0) & "%'"
    	sqlQuery = sqlQuery & " OR std_abbr_nme LIKE '" & aryCriteria(0) & "%'"
        Select Case strOrderBy
           Case "Word", ""
              sqlQuery = sqlQuery & " ORDER BY std_abbr_srce_nme"
           Case "Abbr"
              sqlQuery = sqlQuery & " ORDER BY std_abbr_nme"
           Case "ClassWrd"
              sqlQuery = sqlQuery & " ORDER BY clas_word_i DESC"
           End Select
		iHeaderCount = 3
        If InStr(aryCriteria(0),"%") then
           aryCriteria(0) = Replace (aryCriteria(0),"%","$")
        End If
		aryHeader(0)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Abbreviation&OrderBy=Word TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Full word or phrase</A>"
		aryHeader(1)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Abbreviation&OrderBy=Abbr TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Abbreviation</A>"
		aryHeader(2)="<A HREF=query_result.asp?Criteria=" & aryCriteria(0) & "&RelObject=Abbreviation&OrderBy=ClassWrd TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Class Word?</A>"		
        strHistory = "search_stdabbr.asp"
           
   Case "ClassWord"
        strUAuth = ""
        iResultType = 2 
        aryCriteria(0) = "View Class Words"
  		sqlQuery = "SELECT std_abbr_srce_nme, std_abbr_nme" 
        sqlQuery = sqlQuery & " FROM irma10_std_abbr" 
   		sqlQuery = sqlQuery & " WHERE clas_word_i = 'Y'"
 		Select Case strOrderBy
            Case "Word",""
                sqlQuery = sqlQuery & " ORDER BY std_abbr_srce_nme"
            Case "Abbr", ""
                sqlQuery = sqlQuery & " ORDER BY std_abbr_nme"
            End Select
      		iHeaderCount = 2
            aryHeader(0)="<a href=query_result.asp?RelObject=ClassWord&OrderBy=Word TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Full word or phrase</A>"
            aryHeader(1)="<a href=query_result.asp?RelObject=ClassWord&OrderBy=Abbr TITLE=" & chr(34) & "Sort by this column" & chr(34) & ">Abbreviation</a>"
End Select
If InStr(aryCriteria(0),"$") then
    aryCriteria(0) = Replace(aryCriteria(0),"$","%")
End If

'strRelObject = Request.QueryString
'Response.Write(strRelObject)
'Response.Write(Request.QueryString)
'Response.Write("Hello")
'Response.Write(aryCriteria(0)) 'for debugging sql
'Response.Write(aryCriteria(1)) 'for debugging sql
'Response.Write(aryCriteria(2)) 'for debugging sql
'Response.Write(aryCriteria(3)) 'for debugging sql
'Response.Write(sqlQuery) 'for debugging sql
'Response.Write(sqlsubQuery) 'for debugging sql
'Response.Write(Request.Form("ObjName"))
'Response.End

Set rs = Session("rs")
If rs.State = 1 then
   rs.Close
End IF
rs.open(sqlQuery)           'Open the record set
If rs.BOF <> -1 Then
  Do Until rs.EOF = True
    iRowCount = iRowCount + 1 'count the records
    rs.MoveNext
  Loop
  rs.MoveFirst
Else
  iRowCount = 0
End If
'response.write sqlquery
'response.end
%>
<!--Begin building table header for display-->
<html>
<head>
<title>Add/Maintain Server
</title>
</head>
<body MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
  <a NAME="top"></a>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->
<!--Header table -->

<table CELLSPACING="0" BORDER="0" WIDTH="100%" ALIGN="center">
  <tr BGCOLOR="<%=strHeaderColor%>">
  <td HEIGHT="20" ALIGN="center" COLSPAN="<%=iheaderCount - 1 %>"><font FACE="Verdana" COLOR="<%=strTextColor%>">
<%If request.QueryString("Dupl") = "Yes" then %>     
	<font FACE="Verdana" COLOR="<%=strErrTextColor%>">
    <b>The name you entered would have created a duplicate alias.<br>Here is the element that matched your criteria.</b><br>
    </font>
<%End If %>
    <b>Query results for query &quot;

     	 <%For iLoopVar=0 to UBOUND(aryCriteria)
		     If aryCriteria(iLoopVar+1)= "" then
			     response.write(aryCriteria(iLoopVar))
				 exit for
			 else
			     response.write(aryCriteria(iLoopVar) & " &quot; and &quot; ")
			 end if
        Next %>
		&quot;</b><br><%=iRowCount%> record(s) returned</font>
  </td>
  </tr>
  <tr>
  <td ALIGN="center"><font FACE="Verdana">
  </td> 
  </tr>
<%If iResultType = 1 then %>
  <tr ALIGN="left">
  <td HEIGHT="40" COLSPAN="<%=iheaderCount - 1 %>"><font FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2">
	<b>Click on the <img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26">&nbsp;icon for more details.</b></font>
  </td>
  </tr>
<%  'Maintain authority
	If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then %>
  <tr ALIGN="left">
  <td HEIGHT="40" COLSPAN="<%=iheaderCount - 1 %>"><font FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2">
    <b>Click on the <img SRC="../images/write.gif" TITLE="Maintain object" BORDER="0" WIDTH="24" HEIGHT="27">&nbsp;icon to maintain.</b></font>
  </td>
  </tr>
	<%End If
Else%>
  <tr>
  <td>
  </td>
  </tr>     
<%End If%>

<!--Check for proper body table headers-->
</table>
<table BORDER="0" WIDTH="100%" ALIGN="center" CELLSPACING="0">
  <thead>	
<% 
If iResultType = 1 then    'Regular report
  If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then   'Check for maintain authority
     For iLoopvar=0 to iHeaderCount -1%>
  <th BGCOLOR="<%=strHeaderColor%>" align="left">
    <font FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>&nbsp;&nbsp;
  </th>
  <% Next 
  Else
     For iLoopvar=1 to iHeaderCount-1%>
  <th BGCOLOR="<%=strHeaderColor%>" align="left">
    <font FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>&nbsp;&nbsp;
  </th>
  <% Next
  End IF
Else
  For iLoopvar=0 to iHeaderCount -1    'Special report
   %>
  <th BGCOLOR="<%=strHeaderColor%>" align="left"><b><font FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>&nbsp;&nbsp;</b>
  </th>
 <% Next 
End If%>
  </thead>
<%
' Loop through recordset and display results
' Get the number of fields (zero based)
iFieldCount = rs.Fields.Count - 1
iRows=0      'Initialize total row count
iRowCount=0   'Initialize outout row count
' Alternate row colors while outputting rows
Do While Not rs.EOF
 If strQBackColor=strPageBackColor Then 
   strQBackColor=strBackColor
   strQTextColor=strTextColor
 Else
   strQBackColor=strPageBackColor
   strQTextColor=strTextColor
End If%>
  <tr BGCOLOR="<%=strQBackColor %>">
<%'Output data in each row
Select Case strRelObject
  Case "Server"
    For iLoopVar = 0 to iFieldCount%>
      <td><font FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
	    </font>
	  </td>
	<%Next 	

  Case "Database"
    If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
	  <td WIDTH="2"><a HREF="view_db_dtls.asp?DbName=<%=UCASE(TRIM(rs.Fields(0)))%>&amp;Status=<%=UCASE(TRIM(rs.Fields(1)))%>&amp;Server=<%=UCASE(TRIM(rs.Fields(2)))%>">
	    <img SRC="../images/report80_trans.gif" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
  	  </td>
      <td WIDTH="2">
        <a HREF="add_db_nme.asp?From=Query&amp;DbName=<%=UCASE(TRIM(rs.Fields(0)))%>&amp;Status=<%=UCASE(TRIM(rs.Fields(1)))%>&amp;Server=<%=UCASE(TRIM(rs.Fields(2)))%>">
        <img SRC="../images/write.gif" TITLE="Maintain object" BORDER="0" WIDTH="24" HEIGHT="27"></a>&nbsp;
      </td>
	<%Else%>
	  <td WIDTH="2"><a HREF="view_db_dtls.asp?DbName=<%=UCASE(TRIM(rs.Fields(0)))%>&amp;Status=<%=UCASE(TRIM(rs.Fields(1)))%>&amp;Server=<%=UCASE(TRIM(rs.Fields(2)))%>">
        <img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
	  </td>
	<%End if
    For iLoopVar = 0 to iFieldCount
      If iLoopvar=2 then
        Select Case rs.Fields(2)
          Case "PRDT"
            strQTextColor=strProdColor
          Case "DVLP"
            strQTextColor=strDvlpColor
          Case "APRV"
            strQTextColor=strAprvColor
          Case "ITST"
             strQTextColor=strItstColor  
          Case Else
              strQTextColor=strQTextColor
          End Select
      End If%>
      <td><font FACE="Verdana" COLOR="<%=strQTextColor %>" Size="1"><%=UCASE(TRIM(rs.Fields(iLoopVar)))%>&nbsp;&nbsp;
	    </font>
      </td>
      <%strQTextColor="#000000"
    Next

   Case "Table"
     If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
	   <td WIDTH="2"><a HREF="view_tbl_dtls.asp?Col0=<%=TRIM(rs.Fields(0))%>&amp;Col1=<%=TRIM(rs.Fields(1))%>">
	     <img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
  	   </td>
	   <td WIDTH="2">
		 <a HREF="add_tbl.asp?Col0=<%=TRIM(rs.Fields(0))%>&amp;Col1=<%=TRIM(rs.Fields(1))%>&amp;Entry=query_result">
		 <img SRC="../images/write.gif" TITLE="Maintain object" BORDER="0" WIDTH="24" HEIGHT="27"></a>&nbsp;
	    </td>
	 <%Else%>
		<td WIDTH="2"><a HREF="view_tbl_dtls.asp?Col0=<%=TRIM(rs.Fields(0))%>&amp;Col1=<%=TRIM(rs.Fields(1))%>">
		  <img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
		</td>
	 <%End if
     For iLoopVar = 0 to iFieldCount
       If iLoopvar=1 then
         Select Case rs.Fields(1)
           Case "PRDT"
             strQTextColor=strProdColor
           Case "DVLP"
             strQTextColor=strDvlpColor
           Case "APRV"
             strQTextColor=strAprvColor
           Case "ITST"
             strQTextColor=strItstColor  
           Case Else
             strQTextColor=strQTextColor
           End Select
       End If%>
       <td><font FACE="Verdana" COLOR="<%=strQTextColor %>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
	     </font>
	   </td>
       <%strQTextColor="#000000"
     Next

  Case "ElementKywds"
    If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
      <td WIDTH="2"><a HREF="view_elem_dtls.asp?Col1=<%=TRIM(rs.Fields(0))%>&amp;Col3=<%=TRIM(rs.Fields(2))%>&amp;Col4=<%=TRIM(rs.Fields(3))%>">
     	<img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
      </td>
      <td WIDTH="2"><a HREF="add_elem_dtls.asp?from=Query&amp;Col1=<%=TRIM(rs.Fields(0))%>&amp;Col3=<%=TRIM(rs.Fields(2))%>&amp;Col4=<%=TRIM(rs.Fields(3))%>">
		<img SRC="../images/write.gif" TITLE="Maintain object" BORDER="0" WIDTH="24" HEIGHT="27"></a>&nbsp;
      </td>
	<%Else%>
	  <td WIDTH="2"><a HREF="view_elem_dtls.asp?col1=<%=TRIM(rs.Fields(0))%>&amp;Col3=<%=TRIM(rs.Fields(2))%>&amp;Col4=<%=TRIM(rs.Fields(3))%>">
		<img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
      </td>
	<%End if
    For iLoopVar = 0 to iFieldCount
      If iLoopvar=2 then
        Select Case rs.Fields(2)
          Case "PRDT"
            strQTextColor=strProdColor
          Case "DVLP"
            strQTextColor=strDvlpColor
          Case "APRV"
            strQTextColor=strAprvColor
          Case "ITST"
            strQTextColor=strItstColor  
          Case Else
            strQTextColor=strQTextColor
        End Select
      End If%>
      <td NOWRAP><font FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
		</font>
	  </td>
	  <%strQTextColor="#000000"
    Next 	

  Case "Element"
    If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
      <td WIDTH="2"><a HREF="view_elem_dtls.asp?Col1=<%=TRIM(rs.Fields(0))%>&amp;Col3=<%=TRIM(rs.Fields(2))%>&amp;Col4=<%=TRIM(rs.Fields(3))%>">
     	<img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
      </td>
      <td WIDTH="2"><a HREF="add_elem_dtls.asp?From=Query&amp;col1=<%=TRIM(rs.Fields(0))%>&amp;Col3=<%=TRIM(rs.Fields(2))%>&amp;Col4=<%=TRIM(rs.Fields(3))%>">
         <img SRC="../images/write.gif" TITLE="Maintain object" BORDER="0" WIDTH="24" HEIGHT="27"></a>&nbsp;
      </td>
	<%Else%>
	  <td WIDTH="2"><a HREF="view_elem_dtls.asp?col1=<%=TRIM(rs.Fields(0))%>&amp;Col3=<%=TRIM(rs.Fields(2))%>&amp;Col4=<%=TRIM(rs.Fields(3))%>">
		<img SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0" WIDTH="26" HEIGHT="26"></a>&nbsp;
      </td>
	<%End if
    For iLoopVar = 0 to iFieldCount
      If iLoopvar=2 then
        Select Case rs.Fields(2)
          Case "PRDT"
            strQTextColor=strProdColor
          Case "DVLP"
            strQTextColor=strDvlpColor
          Case "APRV"
            strQTextColor=strAprvColor
          Case "ITST"
            strQTextColor=strItstColor  
          Case Else
            strQTextColor=strQTextColor
          End Select
      End If%>
      <td NOWRAP><font FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
		</font>
	  </td>
	  <%strQTextColor="#000000"
    Next 	

  Case "Abbreviation" 
	For iLoopVar = 0 to iFieldCount
      If iLoopvar=2 then
        Select Case rs.Fields(2)
          Case "Y"
            strQTextColor="#FF0000"
          Case Else
            strQTextColor="#000000"                 
          End Select
      End If%>
      <td><font FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
		</font>
	  </td>
	  <%strQTextColor="#000000"
	  Next 	

  Case "ClassWord"
    For iLoopVar = 0 to iFieldCount%>
      <td><font FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
		</font>
	  </td>
	<%Next 	
  End Select
'next record
iRows = iRows + 1
iRowCount=iRowCount+1
  If iRows = 99 OR rs.EOF Then
  Response.Flush%>
  </tr>
  <tr>
  <td HEIGHT="40" COLSPAN="<%=iheaderCount - 1 %>">
    <font FACE="Verdana" SIZE="2">Continuing...(some browsers do not handle large tables well)<br><a HREF="#TOP">Back to top</a></font>
  </td>
  </tr>
  <thead>	

<%If iResultType = 1 then    'Regular report
	If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then   'Check for maintain authority
      For iLoopvar=0 to iHeaderCount -1%>
    	<th BGCOLOR="<%=strHeaderColor%>" align="left"></b><font FACE="Verdana" COLOR="<%=strQTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>
	    </th>
      <% Next 
	Else
      For iLoopvar=1 to iHeaderCount-1    'No maintain authortity  
	  %>
   		<th BGCOLOR="<%=strHeaderColor%>" align="left"><font FACE="Verdana" COLOR="<%=strQTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>
       	</th>
	  <% Next
	End IF
  Else
	For iLoopvar=0 to iHeaderCount -1    'Special report
	%>
      <th BGCOLOR="<%=strHeaderColor%>" align="left">
      <b><font FACE="Verdana" COLOR="<%=strQTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%></b>
      </th>
    <% Next 
  End If%>
  </thead>
  <%iRows=0
End If
rs.MoveNext
Loop%>
  <tr ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
  <td COLSPAN="<%=iHeaderCount%>"><font FACE="Verdana" COLOR="<%=strTextColor %>" size="2">
    <b>End of Report - <%=iRowCount%> Record(s)</b>
<% If iRowCount > 25 then %>
    <br><a HREF="#TOP">Back to top</a>
<%End If %>
<%If iResultType <> 2 or strRelObject = "Abbreviation" then %>
    <br><a HREF="<%=strHistory%>">Search Again</a>
<%End If %>
  </font>
  </td>
  </tr>
</table>
</body>
</html>
<%rs.Close%>
