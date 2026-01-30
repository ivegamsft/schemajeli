<%

'--------- Validate & SAVE DESCRIPTION & DATABASE NAME ---------------------------

aryTblDesc = SPLIT(Request.Form("tbldesc"),Chr(10))
Set obj1Descr = CreateObject("Scripting.Dictionary")

for i=0 to UBOUND(aryTblDesc) 
  obj1Descr.Add i, aryTblDesc(i)
   'response.write i
   'response.write aryTblDesc(i)
Next 

set session("descrLines") = obj1Descr

'---------------- SAVE PRIMARY KEYS ---------------------
aryKeys = SPLIT(Request.QueryString("prkeys"),",")
set objKeys = CreateObject("Scripting.Dictionary")

k=1
for i = 0 to UBOUND(aryKeys) - 1
   objKeys.Add k, aryKeys(i)
   k=k+1
Next

if UBOUND(aryKeys) = 0 then
   objKeys.Add 1, aryKeys(0)
end if   

set Session("prkeys") = objKeys

'----------------------------------------------
dbnme = trim(UCASE(request.form("DBname"))) 
session("dbname") = dbnme

Set rs = session("rs")
if dbnme <> "" then 
 SQL = "SELECT db_nme FROM irma11_db WHERE db_nme = '" & dbnme & "'" 
 rs.open(SQL) 
 
 if rs.EOF then
    rs.close
    session("dbNmError") = "y"
    response.redirect ("add_tbl_errors.asp")
 else
    session("dbNmError") = "n"
    rs.close
 end if  

end if 

%>

<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/date.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->

<%   
cnt=request.form("elmtcnt")  
'response.write(request.form("elmtcnt"))
    
errors="n"

Set con=Session("Con")
Set rs = session("rs")

'con.rollbackTrans 
'response.end

session("EntryPoint") = "add_tbl_db"

'  INSERT NEW TABLE

'tbl_nme              char(18)                                no
'tbl_stat_cd          char(4)                                 no
'updt_cnt             smallint                                no
'tbl_ownr             char(8)                                 no
'tbl_creat_uid        char(8)                                 no
'tbl_lst_chng_uid     char(8)                                 yes
'tbl_lst_chng_ts      datetime year to second                 no
'err_i                char(1)                                 no
'creat_user_id        char(8)                                 no
'lst_chng_user_id     char(8)                                 yes
'lst_chng_ts          datetime year to second                 yes
'creat_ts             datetime year to second                 no
'db_nme               char(18)                                yes
'db_stat_cd

strLastModBy=Session("USERID")
strLastModTS=CreateTS()

'--------------------- ADD TABLE ----------------------------------	
if session("saveTableExists") = "n" then
   newTblSQL = "INSERT INTO irma01_table VALUES ("
   newTblSQL = newTblSQL & " '" & UCASE(session("TableName")) & "' , "
   newTblSQL = newTblSQL & " '" & session("Status") & "', "
   newTblSQL = newTblSQL & " '" & "1" & "', "
   newTblSQL = newTblSQL & " '" & "YZDBDAT" & "', "
   newTblSQL = newTblSQL & " '" & strLastModBy & "', "
   newTblSQL = newTblSQL & " '" & strLastModBy & "', "
   newTblSQL = newTblSQL & " '" & strLastModTs & "', "
   newTblSQL = newTblSQL & "'N', "
   newTblSQL = newTblSQL & " '" & strLastModBy & "', "
   newTblSQL = newTblSQL & " '" & strLastModBy & "', "
   newTblSQL = newTblSQL & " '" & strLastModTs & "', "
   newTblSQL = newTblSQL & " '" & strLastModTs & "', "
   newTblSQL = newTblSQL & " '" & session("dbname") & "',"
   newTblSQL = newTblSQL & "'PRDT') "
   'response.write newTblSQL
 
   'con.CommitTrans
   con.BeginTrans
   
   con.Execute newTblSQL
 
 'If rs.state =1 then
 '  rs.Close
 'End If
      
 'rs.open(SQL)
 'If rs.state =1 then
 '  rs.Close
 'End If
 
'----------- INSERT NEW DESCRIPTION ---------------------------
 
'tbl_nme              char(18)                                no
'tbl_stat_cd          char(4)                                 no
'seq_no               smallint                                no
'text_80_desc         char(80)                                no
'err_i                char(1)                                 no
'creat_user_id        char(8)                                 no
'lst_chng_user_id     char(8)                                 yes
'lst_chng_ts          datetime year to second                 yes
'creat_ts             datetime year to second                 no

aryTblDesc = SPLIT(Request.Form("tbldesc"),Chr(10))
    
'response.write UBOUND(aryTblDesc)
k=1

for i=0 to UBOUND(aryTblDesc)  
   strTblDesc = REPLACE(aryTblDesc(i),Chr(13),"") 
   
   newDescrSQL = "INSERT INTO irma02_table_desc VALUES ("
   newDescrSQL = newDescrSQL & " '" & UCASE(session("TableName")) & "' , "
   newDescrSQL = newDescrSQL & " '" & session("Status") & "', "
   newDescrSQL = newDescrSQL & " '" & k & "', "
   newDescrSQL = newDescrSQL & " '" & strTblDesc & "',"
   newDescrSQL = newDescrSQL & "'N', "
   newDescrSQL = newDescrSQL & " '" & strLastModBy & "', "
   newDescrSQL = newDescrSQL & " '" & strLastModBy & "', "
   newDescrSQL = newDescrSQL & " '" & strLastModTs & "', "
   newDescrSQL = newDescrSQL & " '" & strLastModTs & "') "
   
   con.Execute newDescrSQL,1,1
   
   'response.write newDescrSQL
    	
   k=k+1
Next
   
' INSERT NEW TABLE ELEMENTS

'tbl_nme              char(18)                                no
'tbl_stat_cd          char(4)                                 no
'seq_no               smallint                                no
'elmt_dict_nme        char(32)                                no
'elmt_stat_cd         char(4)                                 no
'elmt_vrsn_no         smallint                                no
'prim_key_no          char(2)                                 no
'alt_col_nme          char(18)                                yes
'err_i                char(1)                                 no
'creat_user_id        char(8)                                 no
'lst_chng_user_id     char(8)                                 yes
'lst_chng_ts          datetime year to second                 yes
'creat_ts             datetime year to second                 no
'elmt_null_cd         char(2)                                 yes 

 '------for debugging----'
 'con.CommitTrans
   
 if IsObject(Session("cart")) then 
     set dictElm = Session("cart")

	 aryPkeys = SPLIT(Request.QueryString("prkeys"),",")
    
	 'response.write Request.QueryString("prkeys")
	 	 	 
	 'response.write dictElm.Count
	 k=0
	 for i=1 to dictElm.Count 
       rowId = dictElm.item(i)
       SQL = "SELECT elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no" 
       SQL = SQL & " FROM irma04_elmt_vrsn" 
       SQL = SQL & " WHERE rowid= '" & rowId & "' "
	   
	   rs.open SQL
       
	   'response.write rs.Fields(0).value
	   'response.write rs.Fields(1).value
	   
	   strElmDictNme = trim(rs.Fields(0).value)
	   strElmStatCd = rs.Fields(1).value
       strElmVrsnNo = rs.Fields(2).value 
	   
	   rs.close
	   
	   newElmtSQL = "INSERT INTO irma03_table_elmt VALUES ("
       newElmtSQL = newElmtSQL & " '" & UCASE(session("TableName")) & "' , "
       newElmtSQL = newElmtSQL & " '" & session("Status") & "', "
	   newElmtSQL = newElmtSQL & " '" & i & "', "
	   newElmtSQL = newElmtSQL & " '" & strElmDictNme & "', "
	   newElmtSQL = newElmtSQL & " '" & strElmStatCd & "',"
       newElmtSQL = newElmtSQL & "' " & strElmVrsnNo & "',"
	   'newElmtSQL = newElmtSQL & "'1',"
	   
	   if (UBOUND(aryPkeys) = 0 or UBOUND(aryPkeys) = -1) then
	      newElmtSQL = newElmtSQL & " '" & trim(Request.QueryString("prkeys")) & "',"
	   else
	     newElmtSQL = newElmtSQL & " '" & trim(aryPkeys(k)) & "', "
	   end if	  
	   
	   newElmtSQL = newElmtSQL & "'N/A', "
	   newElmtSQL = newElmtSQL & "'N', "
       newElmtSQL = newElmtSQL & " '" & strLastModBy & "', "
	   newElmtSQL = newElmtSQL & " '" & strLastModBy & "', "
	   newElmtSQL = newElmtSQL & " '" & strLastModTs & "', "
       newElmtSQL = newElmtSQL & " '" & strLastModTs & "', "
       newElmtSQL = newElmtSQL & "' ' )"
	   
       'response.write newElmtSQL
       con.Execute newElmtSQL,1,1
   
       k=k+1	 
	 Next

 end if
 con.CommitTrans
 StrHeaderMsg = UCASE(session("TableName")) & " was sucessfully added."
 strAddNewMsg = "<A Href=add_tbl_nme.asp>Add another?</a>"
 strViewMsg = "<A Href=query_result.asp?RelObject=Table&Criteria=" & UCASE(session("TableName")) & ">"
 strViewMsg = strViewMsg & "View the table just added.</A>" 
end if	


'--------------------- MODIFY TABLE ----------------------------------
if session("saveTableExists") = "y" then 
   modTblSQL = "UPDATE irma01_table SET "
   modTblSQL = modTblSQL & "tbl_nme = '" & UCASE(session("TableName")) & "' , "
   modTblSQL = modTblSQL & "tbl_stat_cd ='" & session("Status") & "', "
   'modTblSQL = modTblSQL & "updt_cnt ='" & "1" & "', "
   modTblSQL = modTblSQL & "tbl_lst_chng_uid = '" & strLastModBy & "', "
   modTblSQL = modTblSQL & "tbl_lst_chng_ts = '" & strLastModTs & "', "
   modTblSQL = modTblSQL & "lst_chng_user_id = '" & strLastModBy & "', "
   modTblSQL = modTblSQL & "lst_chng_ts = '" & strLastModTs & "', "
   modTblSQL = modTblSQL & "db_nme = '" & trim(session("dbname")) & "',"
   modTblSQL = modTblSQL & "db_stat_cd = 'PRDT' "
   modTblSQL = modTblSQL & "WHERE tbl_nme = '" & UCASE(session("TableName")) & "' and "
   modTblSQL = modTblSQL & "tbl_stat_cd ='" & session("Status") & "' "
   'response.write modTblSQL

   con.BeginTrans
   
   con.Execute modTblSQL

'--------------- DELETE OLD TABLE DESCRIPTION --------------------
  SQL = "SELECT creat_user_id, creat_ts FROM irma02_table_desc" 
  SQL = SQL & " WHERE tbl_nme= '" & UCASE(session("TableName")) & "' "
  SQL = SQL & " AND tbl_stat_cd= '" & session("Status") & "' " 
	   
  rs.open(SQL)
  
  if not rs.BOF then  	   
    strCreatUserId = rs.Fields(0).value
    strCreatTs = UpdateTs(rs.Fields(1).value)
  else
    strCreatUserId=Session("USERID")
    strCreatTs=CreateTS()
  end if	
    
  rs.close
  
  sqlDelOldTblDesc = "DELETE FROM irma02_table_desc "
  sqlDelOldTblDesc = sqlDelOldTblDesc & " WHERE tbl_nme= '" & UCASE(session("TableName")) & "' "
  sqlDelOldTblDesc = sqlDelOldTblDesc & " AND tbl_stat_cd= '" & session("Status") & "' " 
  'response.write sqlDelOldTblDesc
  con.Execute sqlDelOldTblDesc
 
 '----------- INSERT NEW TABLE DESCRIPTION -----------------------
 
aryTblDesc = SPLIT(Request.Form("tbldesc"),Chr(10))
    
'response.write UBOUND(aryTblDesc)
k=1

for i=0 to UBOUND(aryTblDesc)  
   strTblDesc = REPLACE(aryTblDesc(i),Chr(13),"") 
   
   newDescrSQL = "INSERT INTO irma02_table_desc VALUES ("
   newDescrSQL = newDescrSQL & " '" & UCASE(session("TableName")) & "' , "
   newDescrSQL = newDescrSQL & " '" & session("Status") & "', "
   newDescrSQL = newDescrSQL & " '" & k & "', "
   newDescrSQL = newDescrSQL & " '" & strTblDesc & "',"
   newDescrSQL = newDescrSQL & "'N', "
   newDescrSQL = newDescrSQL & " '" & strCreatUserId & "', "
   newDescrSQL = newDescrSQL & " '" & strLastModBy & "', "
   newDescrSQL = newDescrSQL & " '" & strLastModTs & "', "
   newDescrSQL = newDescrSQL & " '" & strCreatTs & "') "
   
   con.Execute newDescrSQL,1,1
   
   'response.write newDescrSQL
    	
   k=k+1
Next
 
 '--------------- DELETE OLD TABLE ELEMENTS --------------------
  SQL = "SELECT creat_user_id, creat_ts FROM irma01_table" 
  SQL = SQL & " WHERE tbl_nme= '" & UCASE(session("TableName")) & "' "
  SQL = SQL & " AND tbl_stat_cd= '" & session("Status") & "' " 
	   
  rs.open(SQL)
  
  if not rs.BOF then  	   
    strCreatUserId = rs.Fields(0).value
    strCreatTs = UpdateTs(rs.Fields(1).value)
  else
    strCreatUserId=Session("USERID")
    strCreatTs=CreateTS()
  end if	
  rs.close
    
  sqlDelOldTblElm = "DELETE FROM irma03_table_elmt "
  sqlDelOldTblElm = sqlDelOldTblElm & " WHERE tbl_nme= '" & UCASE(session("TableName")) & "' "
  sqlDelOldTblElm = sqlDelOldTblElm & " AND tbl_stat_cd= '" & session("Status") & "' " 
  'response.write sqlDelOldTblElm
  con.Execute sqlDelOldTblElm

'--------------INSERT NEW TABLE ELEMENTS ----------------------- 
 if IsObject(Session("cart")) then 
     set dictElm = Session("cart")

	 aryPkeys = SPLIT(Request.QueryString("prkeys"),",")
     'response.write Request.QueryString("prkeys")
	
	 k=0
	 for i=1 to dictElm.Count 
       rowId = dictElm.item(i)
       SQL = "SELECT elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no" 
       SQL = SQL & " FROM irma04_elmt_vrsn" 
       SQL = SQL & " WHERE rowid= '" & rowId & "' "
	   
	   rs.open SQL
        
	   strElmDictNme = trim(rs.Fields(0).value)
	   strElmStatCd = rs.Fields(1).value
       strElmVrsnNo = rs.Fields(2).value 
	   
	   rs.close
	   
	   newElmtSQL = "INSERT INTO irma03_table_elmt VALUES ("
       newElmtSQL = newElmtSQL & " '" & UCASE(session("TableName")) & "' , "
       newElmtSQL = newElmtSQL & " '" & session("Status") & "', "
	   newElmtSQL = newElmtSQL & " '" & i & "', "
	   newElmtSQL = newElmtSQL & " '" & strElmDictNme & "', "
	   newElmtSQL = newElmtSQL & " '" & strElmStatCd & "',"
	   'newElmtSQL = newElmtSQL & "'1',"
	   newElmtSQL = newElmtSQL & " '" & strElmVrsnNo & "',"
	   
	   if (UBOUND(aryPkeys) = 0 or UBOUND(aryPkeys) = -1) then
	      newElmtSQL = newElmtSQL & " '" & TRIM(Request.QueryString("prkeys")) & "',"
	   else
	     newElmtSQL = newElmtSQL & " '" & TRIM(aryPkeys(k)) & "', "
	     'response.write  aryPkeys(k)
	     'response.write newElmtSQL 
	   end if	  
	   
	   newElmtSQL = newElmtSQL & "'N/A', "
	   newElmtSQL = newElmtSQL & "'N', "
       newElmtSQL = newElmtSQL & " '" & strCreatUserId & "', "
	   newElmtSQL = newElmtSQL & " '" & strLastModBy & "', "
	   newElmtSQL = newElmtSQL & " '" & strLastModTs & "', "
       newElmtSQL = newElmtSQL & " '" & strCreatTs & "', "
       newElmtSQL = newElmtSQL & "' ' )"
	   
	   'response.write newElmtSQL
       con.Execute newElmtSQL,1,1
   
       k=k+1	 
	 Next

 end if
 
 set dictElm = nothing
 con.CommitTrans

 StrHeaderMsg = UCASE(session("TableName")) & " was sucessfully modified."
 strAddNewMsg = "<A Href=add_tbl_nme.asp>Add another?</a>"
 strViewMsg = "<A Href=add_tbl.asp?Col0=" & UCASE(session("TableName")) & "&Col1=" & Session("Status") & "&Entry=query_result>"
 strViewMsg = strViewMsg & "View the table you just modified.</A>" 
  
end if 
%>
<HTML>
<body bgcolor="<%=strPageBackColor%>" link="<%=strLinkColor%>" alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTextColor%>">
<table border="0" width="80%" align="center" bgcolor="<%=strHeaderColor%>">
  <tr>
    <td width="100%" height="20" align="center">
<%If bError then%>
    <font face="Verdana" size="3" COLOR="<%=strErrTextColor%>"><Center><h3><%=strHeaderMsg%></H3></FONT>
<%Else%>
   <font face="Verdana" size="3"><Center><h3><%=strHeaderMsg%></H3></FONT>
<%End IF%>
	</td>
  </tr>    
</Table>
<table border="0" width="80%" align="center" bgcolor="<%=strBackColor%>">
<tr>
   <td align="center">
    <font face="Verdana" size="3"><%=strAddNewMsg%></a></FONT>
    </TD>
 </tr>
 <tr>
   <td align="center">
   <font face="Verdana" size="3"><%=strViewMsg%></font>
 </tr>
</table> 
</HTML>
