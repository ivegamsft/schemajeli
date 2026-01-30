<%
Dim aryDDL()
Dim aryPrKeyDDL()
Response.buffer = True
Session.Timeout=60

strCriteria = trim(ucase(request.form("Criteria")))
strStatus = trim(ucase(request.form("Status")))
 
Set rs = session("rs")    
SQL = "select tbl_nme, tbl_stat_cd, db_nme, tbl_ownr from irma01_table where tbl_nme = '" & strCriteria & "' " 
SQL = SQL & " and tbl_stat_cd = '" & strStatus & "' " 

'response.write SQL
  	
if rs.state=1 then
   rs.close
end if
   
rs.open(SQL)  
result = rs.BOF

if result = -1  then 
   session("tblexists") = "n"
   response.redirect ("rpt_ddl.asp")
else
   strTblOwnr = trim(ucase(rs.Fields(3).value))
   strTblNme = trim(ucase(rs.Fields(0).value))
   strDBNme = trim(ucase(rs.Fields(2).value))
   session("TableName") = strTblNme
   'response.write strDBNme
End If
rs.Close  
%>
<%
FUNCTION DefineNulls(strPrimKey,strNullCd,strDDL)
  select CASE trim(strNullCd)
	  CASE "NL"
	      strDDL = strDDL & " DEFAULT NULL "
	  CASE "ND"
	      strDDL = strDDL & " NOT NULL WITH DEFAULT "
	  CASE "NN"
	      strDDL = strDDL & "NOT NULL"
	  CASE ELSE
	  	 
		  if strPrimKey <> "" then
		    strDDL = strDDL & " NOT NULL "
		  else
		    strDDL = strDDL & " NOT NULL WITH DEFAULT "	 
	   	  end if
	   END select
	  
	   DefineNulls = strDDL     	  	  	  

END FUNCTION	  
%>

<FORM ACTION="rpt_ddl_fsave.asp" METHOD="POST" NAME="rpt_ddl" ACTION="rpt_ddl_fsave.asp">
<script language="VBScript"><!--
'---------------------------------------------------------------------------
'----------- ONCLICK SAVE DDL TO A FILE   ----------------------------------
'---------------------------------------------------------------------------
Sub SaveDDL
  Dim theForm
  Set theForm = Document.Forms.item(0) 
   
    theForm.action="rpt_ddl_fsave.asp" 
    theForm.submit()
 
End Sub
//--></script>

<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<html>

<table bgcolor="<%=strBackColor%>" height="2" border="0"  align="center">

  <tr>
    <td bgcolor="<%=strHeaderColor%>" align="center" colspan="4" ><font face="Verdana" color="#000000" size="4">DDL FOR TABLE "<%response.write ucase(request.form("criteria")) %>"</font>
    </td>
  </tr>

<% 

if rs.state=1 then
   rs.close
end if

SQL = "select count(*) from irma03_table_elmt where tbl_nme = '" & strCriteria & "'"
SQL = SQL & " and tbl_stat_cd = '" & strStatus & "'"  
rs.open(SQL)  
totCount = FormatNumber(rs.Fields(0).value) * 3 + 30
rs.close
reDim aryDDL(totCount)

SQL = "select count(*) from irma03_table_elmt where tbl_nme = '" & strCriteria & "'"
SQL = SQL & " and tbl_stat_cd = '" & strStatus & "'"  
SQL = SQL & " and prim_key_no > 0 "  
rs.open(SQL)  
prkeyCount = FormatNumber(rs.Fields(0).value) + 1
rs.close
reDim aryPrKeyDDL(prkeyCount)
 
 strOwnrTbl = replace(""& strTblOwnr & " " & strTblNme &""," ",".")
  
 aryDDL(0) =  "CREATE TABLE  "& strOwnrTbl & "" 
 
 '----------- Process Primary Keys --------------------------- 
   pkSQL = "select elmt_col_nme, elmt_logcl_lng, elmt_data_typ_id," 
   pkSQL = pkSQL & "elmt_dec_lng, elmt_null_cd, prim_key_no, seq_no " 
   pkSQL = pkSQL & " FROM irma03_table_elmt a, irma04_elmt_vrsn b, irma05_element c"
   pkSQL = pkSQL & " WHERE a.tbl_nme = '" & strCriteria & "'"
   pkSQL = pkSQL & " and a.tbl_stat_cd = '" & strStatus & "'" 
   pkSQL = pkSQL & " and a.elmt_dict_nme = b.elmt_dict_nme and a.elmt_stat_cd = b.elmt_stat_cd"
   pkSQL = pkSQL & " and a.elmt_vrsn_no = b.elmt_vrsn_no"
   pkSQL = pkSQL & " and b.elmt_dict_nme = c.elmt_dict_nme and b.elmt_stat_cd = c.elmt_stat_cd"
   pkSQL = pkSQL & " and prim_key_no > 0 "
   pkSQL = pkSQL & " order by a.prim_key_no"
   
   rs.open(pkSQL)
   
   strDDL = "("  
   strKeyDDL = "("
   i=1	
   do while not rs.EOF
      strColNme = trim(ucase(rs.Fields(0).value))
	  	  	  	   	
	  strKeyDDL = strKeyDDL & strColNme & ","  
	  aryPrKeyDDL(i) = strKeyDDL
	  i=i+1
      strKeyDDL = ""
	  rs.movenext 
  Loop 
  rs.close
  aryPrKeyDDL(i-1) = replace(aryPrKeyDDL(i-1), ",", ")")
 
 ' ---------- Process the rest of the table ------------  
   ddlSQL = ddlSQL & "select elmt_col_nme, elmt_logcl_lng, elmt_data_typ_id," 
   ddlSQL = ddlSQL & "elmt_dec_lng, elmt_null_cd, prim_key_no, seq_no " 
   ddlSQL = ddlSQL & " FROM irma03_table_elmt a, irma04_elmt_vrsn b, irma05_element c"
   ddlSQL = ddlSQL & " WHERE a.tbl_nme = '" & strCriteria & "'"
   ddlSQL = ddlSQL & " and a.tbl_stat_cd = '" & strStatus & "'" 
   ddlSQL = ddlSQL & " and a.elmt_dict_nme = b.elmt_dict_nme and a.elmt_stat_cd = b.elmt_stat_cd"
   ddlSQL = ddlSQL & " and a.elmt_vrsn_no = b.elmt_vrsn_no"
   ddlSQL = ddlSQL & " and b.elmt_dict_nme = c.elmt_dict_nme and b.elmt_stat_cd = c.elmt_stat_cd"
   ddlSQL = ddlSQL & " order by a.seq_no"
    
   rs.open(ddlSQL)
	
   do while not rs.EOF
      strColNme = trim(ucase(rs.Fields(0).value))
	  strPrimKey = trim(rs.Fields(5).value)
      strElmtNullCd = trim(rs.Fields(4).value)
	  strElmtDataTyp = trim(rs.Fields(2).value)
	  strElmtlogclLng = trim(rs.Fields(1).value)
	  strDecLng = trim(rs.Fields(3).value) 
	  
	  if strElmtDataTyp = "TIMESTMP" then
	     strElmtDataTyp = "TIMESTAMP"
	  end if
	  	        
	  strDDL = strDDL & " " & strColNme & "    " & (strElmtDataTyp) & " "
	  
	   '--- don't pring length for the following data types
	  if strElmtDataTyp <> "DATE" and strElmtDataTyp <> "TIMESTAMP" and strElmtDataTyp <> "INTEGER" and strElmtDataTyp <> "SMALLINT" and strElmtDataTyp <> "LONGVAR" and strElmtDataTyp <> "DECIMAL" then
 		   strDDL = strDDL & "("  &  strElmtLogclLng  & ")"
	  end if	       
   	  
	  if strElmtDataTyp = "DECIMAL" and strDecLng > 0 then
	     strDDL = strDDL & "("  &  strElmtLogclLng  & "," & strDecLng & ")"  
	  end if
	  
	  if strElmtDataTyp = "DECIMAL" and strDecLng = 0 then
	     strDDL = strDDL & "("  &  strElmtLogclLng  & ")"
	  end if	 
	  
	  strDDL = DefineNulls(strPrimKey,strElmtNullCd,strDDL)  	  
	  	  
	  strDDL = strDDL & ","
	  aryDDL(i) = strDDL 
	  i=i+1
	  strDDL = ""
	  
      rs.movenext 
  Loop 
  rs.close 
  
 if ubound(aryPrKeyDDL) > 1 then
   aryDDL(i) = "PRIMARY KEY" 
   i=i+1
   for k=0 to ubound(aryPrKeyDDL)%>
     <tr><td>
     <% aryDDL(i) = aryPrKeyDDL(k) 
     i=i+1   
   Next
 else  
   aryDDL(i-1) = replace(aryDDL(i-1), ",", ")") 
 end if

 if trim(strDBNme) = "" then
    strDBNme="N/A"
 end if
 
 session("tblabbr")=left(strTblNme,7)
 strTblSpace = left(strTblNme,2)
 strTblSpace = strTblSpace & replace(left(strTblNme,7),"T","S",3,1)
 aryDDL(i) = "IN " & strDBNme & "." & strTblSpace 
 aryDDL(i+1) = ";"

 if ubound(aryPrKeyDDL) > 1 then
   strIndx = left(strTblNme,2)
   strIndx = strIndx & replace(left(strTblNme,7),"T","X",3,1) & "A"
   aryDDL(i+2) = "CREATE TYPE 2 UNIQUE INDEX " & strTblOwnr & "." & strIndx
 
   aryDDL(i+3) = "ON " & strTblOwnr & "." & strTblNme
 
   i=i+4
   for k=0 to ubound(aryPrKeyDDL)%>
     <tr><td>
   <% aryDDL(i) = aryPrKeyDDL(k) 
      i=i+1   
   Next
 
   i=i+1
   aryDDL(i) = "USING"
   i=i+1
   aryDDL(i) = "VCAT ED4"
   i=i+1
   aryDDL(i) = "FREEPAGE 020"
   i=i+1
   aryDDL(i) = "PCTFREE 20"
   i=i+1
   aryDDL(i) = "CLUSTER"
   i=i+1
   aryDDL(i) = "BUFFERPOOL BP0"
   i=i+1
   aryDDL(i) = "CLOSE NO;"
 end if
 
 aryDDL(i+2) = "COMMIT WORK ;"
 for i=0 to ubound(aryDDL)%>
    <tr><td>
<%  response.write aryDDL(i)  
    if aryDDL(i) = "COMMIT WORK ;" then
	   exit for
	end if   %>
    </td>
	</tr>
 <%  Next %>
 
 <% session("DDL") = aryDDL %>
 
 <script language="VBScript"><!--
 Sub cmdCancel_OnClick
   history.back
 End Sub
 //--></script>
  
 <tr>
	<td></td>
    <td>
	<Input Type="button" VALUE="Cancel" NAME="cmdCancel">&nbsp&nbsp&nbsp&nbsp
	<INPUT TYPE="Hidden" NAME="Status" VALUE="<%=strStatus%>">
	<%if Session("UAuth") = "MNTN" or Session("UAuth") = "ADMN" then %>
	    <input type="submit" value="Email DDL" onclick="SaveDDL()">
    <%end if %>
	</td>
 </tr>
</FORM>
</table>
</body>
</html>
