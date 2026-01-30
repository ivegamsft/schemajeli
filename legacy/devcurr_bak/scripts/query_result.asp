<%
 Response.Buffer = TRUE
 Session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%

Dim DConn
Dim cmdDC
Dim rs
Dim Item
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
Dim iDataSrc      '1=access 2=informix(session variable)
Dim aryDetailQString(5)      'Hold the detail query string
Dim arymaintainQString(5)      'Hold the maintain query string
Dim aryCriteria(9)
Dim strQBackColor
Dim strQPageBackColor
Dim strQTextColor
Dim strOrderBy
Dim strHistory
' Retrieve QueryString Variables and convert them to a usable form
strRelObject = Request.QueryString("RelObject")
sqlOperator = Request.QueryString("Operator")
strOrderBy = Request.QueryString("OrderBy")
'Response.write(Request.QueryString)
'Response.end
'********aryHeaderCount holds the header information, 
'*******but the first 2 postions are reserved for the detail and the maintain icons in the output
'*******remember to add 3 to the header count (zero based)

If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then
    aryHeader(0)=""
	aryHeader(1)=""
else
   aryHeader(0)=""
   aryHeader(1)=""
end if
Select Case strRelObject
	
	Case "Server"
        aryCriteria(0) = "View-Servers"
		iDataSrc = 2
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
'        strHistory = "search_srvrs.asp"

	Case "Database"
        aryCriteria(0) = UCASE(Request.QueryString("Criteria"))
        If InStr(aryCriteria(0),"$") then
           aryCriteria(0) = Replace(aryCriteria(0),"$","%")
        End If
		iDataSrc = 2
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
        strHistory = "<!--#INCLUDE FILE=" & Chr(34) & "../scripts/search_dbs.asp" & Chr(34) & "-->"

	Case "Table"
        aryCriteria(0) = UCASE(Request.QueryString("Criteria"))
        If InStr(aryCriteria(0),"$") then
           aryCriteria(0) = Replace(aryCriteria(0),"$","%")
        End If
		'If aryCriteria(0) = "" then
		 '   aryCriteria(0) = UCASE(Request.Form("Criteria"))
	    'End If
		iDataSrc = 2
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
        strHistory = "<!--#INCLUDE FILE=" & Chr(34) & "../scripts/search_tbls.asp" & Chr(34) & " -->"

	Case "ElementKywds"        'From keyword search
        iDataSrc = 2
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
           strHistory = "<!--#INCLUDE FILE=" & Chr(34) & "../scripts/search_elem_kywd.asp" & Chr(34) & "-->"
        
   Case "Element"
        iDataSrc = 2
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
        strHistory = "<!--#INCLUDE FILE=" & Chr(34) & "../scripts/search_elem.asp" & Chr(34) & "  -->"
        
   Case "Abbreviation"
		iDataSrc = 2
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
        strHistory = "<!--#INCLUDE FILE=" & Chr(34) & "../scripts/search_stdabbr.asp" & Chr(34) & "-->"
           
   Case "ClassWord"
		iDataSrc = 2
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

' Create and establish data connection
'check for connection type
select case iDataSrc 
    Case 1
       Set DConn = Server.CreateObject("ADODB.Connection")
       DConn.ConnectionTimeout = 15
       DConn.CommandTimeout = 30
       'Access connection code
       DConn.Open "DBQ=" & Server.MapPath("../navservers.mdb") & ";Driver={Microsoft Access Driver (*.mdb)};DriverId=25;MaxBufferSize=8192;Threads=20;"
       Set cmdDC = Server.CreateObject("ADODB.Command")
       cmdDC.ActiveConnection = DConn
       cmdDC.CommandText = sqlQuery
       cmdDC.CommandType = 1
       ' Create recordset and retrieve values using command object
       Set rs = Server.CreateObject("ADODB.Recordset")
       ' Opening record set with a forward-only cursor (the 0) and in read-only mode (the 1)
       rs.Open cmdDC, , 0, 1
   Case 2
       Set rs = Session("rs")
        If rs.State = 1 then
           rs.Close
        End IF
        rs.open(sqlQuery)           'Open the record set
    end select
'response.write sqlquery
'response.end
%>
<!--Begin building table header for display-->
<BODY BGCOLOR="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<TABLE CELLSPACING="0" BORDER="0" WIDTH="100%" ALIGN="center">
<A NAME="top"></A>
  <TR BGCOLOR="<%=strHeaderColor%>">
      <TD HEIGHT="20" ALIGN="center" COLSPAN="<%=iheaderCount - 1 %>"><FONT FACE="Verdana" COLOR="<%=strTextColor%>">
<%If request.QueryString("Dupl") = "Yes" then %>     
	 <FONT FACE="Verdana" COLOR="<%=strErrTextColor%>">
     <B>The name you entered would have created a duplicate alias.<BR>Here is the element that matched your criteria.</B><BR>
     </FONT>
<%End If %>
     <B>Query results for query &quot;

     	 <%For iLoopVar=0 to UBOUND(aryCriteria)
		     If aryCriteria(iLoopVar+1)= "" then
			     response.write(aryCriteria(iLoopVar))
				 exit for
			 else
			     response.write(aryCriteria(iLoopVar) & " &quot; and &quot; ")
			 end if
        Next %>
		&quot;</B><BR><%=strhistory%></FONT>
     </TD>
  </TR>
  <TR>
     <TD ALIGN="center"><FONT FACE="Verdana">
<!--             <%=rs.RecordCount%>&nbsp;Total records returned  -->
	</TD> 
  </TR>
<%If iResultType = 1 then %>
  <TR ALIGN="left">
     <TD HEIGHT="40" COLSPAN="<%=iheaderCount - 1 %>"><FONT FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2">
	 <B>Click on the <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0">&nbsp;icon for more details.</B></FONT>
     </TD>
   </TR>
	<%  'Maintain authority
		   If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then %>
              <TR ALIGN="left">
                 <TD HEIGHT="40" COLSPAN="<%=iheaderCount - 1 %>"><FONT FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2">
               	 <B>Click on the <IMG SRC="../images/write.gif" TITLE="Maintain object" BORDER="0">&nbsp;icon to maintain.</B></FONT>
                 </TD>
              </TR>
			  <%End If
Else%>
        <TR>
		   <TD>
		   </TD>
		</TR>     
<%End If%>

<!--Check for proper body table headers-->
</TABLE>
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" CELLSPACING="0">
    <THEAD>	
		<% 
		If iResultType = 1 then    'Regular report
		  If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then   'Check for maintain authority
		     For iLoopvar=0 to iHeaderCount -1%>
    		  <TH BGCOLOR="<%=strHeaderColor%>" align="left"></B><FONT FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>&nbsp;&nbsp;
	    	  </TH>
     		 <% Next 
			 Else
        		For iLoopvar=1 to iHeaderCount-1    'No maintain authortity  
				%>
   		        <TH BGCOLOR="<%=strHeaderColor%>" align="left"><FONT FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>&nbsp;&nbsp;
       		    </TH>
	          <% Next
			End IF
		  Else
		     For iLoopvar=0 to iHeaderCount -1    'Special report
			   %>
        	  <TH BGCOLOR="<%=strHeaderColor%>" align="left"><B><FONT FACE="Verdana" COLOR="<%=strTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>&nbsp;&nbsp;
	    	     </B>
              </TH>
    		 <% Next 
      	End If%>
	</THEAD>
<%
' Loop through recordset and display results
If Not rs.EOF Then rs.MoveFirst

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
   <TR BGCOLOR="<%=strQBackColor %>"> 
	  <%'Output data in each row
               Select Case strRelObject
					   Case "Server"
                 	    For iLoopVar = 0 to iFieldCount%>
                            <TD><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
							</FONT>
							</TD>
						<%Next 	

                  Case "Database"
                       If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
						  <TD WIDTH="2"><A HREF="view_db_dtls.asp?DbName=<%=UCASE(TRIM(rs.Fields(0)))%>&Status=<%=UCASE(TRIM(rs.Fields(1)))%>&Server=<%=UCASE(TRIM(rs.Fields(2)))%>">
	      				      <IMG SRC="../images/report80_trans.gif" BORDER="0"></A>&nbsp;
  			     	      </TD>
    					    <TD WIDTH="2">
                            <A HREF="add_db_nme.asp?From=Query&DbName=<%=UCASE(TRIM(rs.Fields(0)))%>&Status=<%=UCASE(TRIM(rs.Fields(1)))%>&Server=<%=UCASE(TRIM(rs.Fields(2)))%>">
                              <IMG SRC="../images/write.gif" TITLE="Maintain object" BORDER="0"></A>&nbsp;
						   </TD>
						<%Else%>
						  <TD WIDTH="2"><A HREF="view_db_dtls.asp?DbName=<%=UCASE(TRIM(rs.Fields(0)))%>&Status=<%=UCASE(TRIM(rs.Fields(1)))%>&Server=<%=UCASE(TRIM(rs.Fields(2)))%>">
					        <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0"></A>&nbsp;
						 </TD>
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
                            <TD><FONT FACE="Verdana" COLOR="<%=strQTextColor %>" Size="1"><%=UCASE(TRIM(rs.Fields(iLoopVar)))%>&nbsp;&nbsp;
	                        </FONT>
							</TD>
                        <%strQTextColor="#000000"
                           Next

                  Case "Table"
                       If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
						  <TD WIDTH="2"><A HREF="view_tbl_dtls.asp?Col0=<%=TRIM(rs.Fields(0))%>&Col1=<%=TRIM(rs.Fields(1))%>">
	      				      <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0"></A>&nbsp;
  			     	      </TD>
						  <TD WIDTH="2">
						     <A HREF="add_tbl.asp?Col0=<%=TRIM(rs.Fields(0))%>&Col1=<%=TRIM(rs.Fields(1))%>&Entry=query_result">
					         <IMG SRC="../images/write.gif" TITLE="Maintain object" BORDER="0"></A>&nbsp;
						   </TD>
						<%Else%>
						 <TD WIDTH="2"><A HREF="view_tbl_dtls.asp?Col0=<%=TRIM(rs.Fields(0))%>&Col1=<%=TRIM(rs.Fields(1))%>">
					        <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0"></A>&nbsp;
						 </TD>
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
                            <TD><FONT FACE="Verdana" COLOR="<%=strQTextColor %>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
	                        </FONT>
							</TD>
                        <%strQTextColor="#000000"
                           Next%>

			         <%Case "ElementKywds"
                        If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
                          <TD WIDTH="2"><A HREF="view_elem_dtls.asp?Col1=<%=TRIM(rs.Fields(0))%>&Col3=<%=TRIM(rs.Fields(2))%>&Col4=<%=TRIM(rs.Fields(3))%>">
     					      <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0"></A>&nbsp;
     					  </TD>
    					  <TD WIDTH="2"><A HREF="add_elem_dtls.asp?from=Query&Col1=<%=TRIM(rs.Fields(0))%>&Col3=<%=TRIM(rs.Fields(2))%>&Col4=<%=TRIM(rs.Fields(3))%>">
		     			      <IMG SRC="../images/write.gif" TITLE="Maintain object" BORDER="0"></A>&nbsp;
        				  </TD>
						<%Else%>
		                  <TD WIDTH="2"><A HREF="view_elem_dtls.asp?col1=<%=TRIM(rs.Fields(0))%>&Col3=<%=TRIM(rs.Fields(2))%>&Col4=<%=TRIM(rs.Fields(3))%>">
				       	      <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0"></A>&nbsp;
     					  </TD>
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
<!--turn on wrapping-->
              <TD NOWRAP><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
<!--Turn off wrapping
            <TD><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
-->
						</FONT>
							</TD>
						<%strQTextColor="#000000"
                          Next 	

		          Case "Element"
                        If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then%>
                          <TD WIDTH="2"><A HREF="view_elem_dtls.asp?Col1=<%=TRIM(rs.Fields(0))%>&Col3=<%=TRIM(rs.Fields(2))%>&Col4=<%=TRIM(rs.Fields(3))%>">
     					      <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0"></A>&nbsp;
     					  </TD>
    					  <TD WIDTH="2"><A HREF="add_elem_dtls.asp?From=Query&col1=<%=TRIM(rs.Fields(0))%>&Col3=<%=TRIM(rs.Fields(2))%>&Col4=<%=TRIM(rs.Fields(3))%>">
		     			      <IMG SRC="../images/write.gif" TITLE="Maintain object" BORDER="0"></A>&nbsp;
        				  </TD>
						<%Else%>
		                  <TD WIDTH="2"><A HREF="view_elem_dtls.asp?col1=<%=TRIM(rs.Fields(0))%>&Col3=<%=TRIM(rs.Fields(2))%>&Col4=<%=TRIM(rs.Fields(3))%>">
				       	      <IMG SRC="../images/report80_trans.gif" TITLE="View details" BORDER="0"></A>&nbsp;
     					  </TD>
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
<!--turn on wrapping-->
              <TD NOWRAP><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;

<!--Turn off wrapping
            <TD><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
-->
							</FONT>
							</TD>
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
                            <TD><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
							</FONT>
							</TD>
						<%strQTextColor="#000000"
						Next 	

					   Case "ClassWord"
                 	    For iLoopVar = 0 to iFieldCount%>
                            <TD><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" Size="1"><%=TRIM(rs.Fields(iLoopVar))%>&nbsp;&nbsp;
							</FONT>
							</TD>
						<%Next 	
                      End Select
         

         'next record
		
         iRows = iRows + 1
		 iRowCount=iRowCount+1
         If iRows = 99 OR rs.EOF Then
            Response.Flush%>
         </TR>
         <TR>
           <TD HEIGHT="40" COLSPAN="<%=iheaderCount - 1 %>">
              <FONT FACE="Verdana" SIZE="2">
                     Continuing...(some browsers do not handle large tables well)
                     <BR><A HREF="#TOP">Back to top</A></FONT>
              </TD>
          </TR>
          <THEAD>	
		<% 
		If iResultType = 1 then    'Regular report
		  If Session("UAuth")="MNTN" or Session("UAuth")="ADMN" then   'Check for maintain authority
		     For iLoopvar=0 to iHeaderCount -1%>
    		  <TH BGCOLOR="<%=strHeaderColor%>" align="left"></B><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>
	    	  </TH>
     		 <% Next 
			 Else
        		For iLoopvar=1 to iHeaderCount-1    'No maintain authortity  
				%>
   		        <TH BGCOLOR="<%=strHeaderColor%>" align="left"><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>
       		    </TH>
	          <% Next
			End IF
		  Else
		     For iLoopvar=0 to iHeaderCount -1    'Special report
			   %>
        	  <TH BGCOLOR="<%=strHeaderColor%>" align="left"><B><FONT FACE="Verdana" COLOR="<%=strQTextColor%>" SIZE="2"><%=aryHeader(iLoopVar)%>
	    	     </B>
              </TH>
    		 <% Next 
      	End If%>
	</THEAD>
	   <%iRows=0
        end if
 rs.MoveNext

Loop%>
<SCRIPT LANGUAGE="VBScript">
Sub GoBack()
   history.back -1
End Sub
</SCRIPT>
<TR ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
   <TD COLSPAN="<%=iHeaderCount%>"><FONT FACE="Verdana" COLOR="<%=strTextColor %>" size="2""><B>End of Report - <%=iRowCount%> Total</B>
       <BR><A HREF="#TOP">Back to top</A>
<%If iResultType <> 2 or strRelObject = "Abbreviation" then %>
       <BR><A HREF="Back" ONCLICK="GoBack">Search Again</A>
<%End If %>
       </FONT>
   </TD>
</TR>
</TABLE>
<%
' Close Data Access Objects and free DB variables
   'extra clean up for access data source
	If iDataSrc = 1 then
		Set cmdDC = Nothing
        DConn.Close
		Set DConn = Nothing
	End if
    rs.Close
%>