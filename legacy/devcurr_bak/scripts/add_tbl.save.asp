<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>

<%Entry=session("EntryPoint") %>

<%if Entry = "add_tbl_nme" then 
     SQL = "select tbl_nme, tbl_stat_cd, db_nme from irma01_table where tbl_nme = Trim('" & (request.form("criteria")) & "')" 
  	 Set rs = session("rs") 
	 rs.open(SQL)  
	 result = rs.BOF
	 rs.Close 
	 
	 if result = -1  then
	  	 tblexists = "n" 
	 Else 
	    tblexists = "y" 
	 End If 
   
     if tblexists = "y" then 
		response.redirect ("query_result.asp?RelObject=Table&Criteria=" & request.form("Criteria"))
	 End If 
   else
     tblexists = "y" 
End If 

session("saveTableExists") = tblexists%>

<script language="JavaScript"><!--
function Search_Check(theForm)
{
     if (theForm.elmsrch.value == "")
     {
        alert("Please enter the first N characters or a full element name into SEARCH box");
        return (false);
     } 
     else
	 { 
	    theForm.submit();
        return (true);
     }
} 
 
 //--></script>

<SCRIPT LANGUAGE="VbScript">

Sub Done()
  Dim MyForm 
  Set MyForm = Document.Forms.item(0)
'  msgbox MyForm.tbldesc.value - preserves format (request.form doesn't)
' parse each line, compare to document values and store in session array'
  MyForm.Action="add_tbl_db.asp"
  MyForm.Submit
End sub
 //--></script>
 
<!--#INCLUDE FILE="../include/colors.inc"-->

<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<!-- Entry Points:  query_result.asp ( from search tables display page )
					add_tbl_nme.asp  ( from enter table name to maintain page)
-->
<!--Header table -->
<!--<body bgcolor="<%=strMenuSelColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">-->
<body>
<table border="0" width="80%" align="center" bgcolor="<%=strMenuSelColor%>">
 <tr>
    <td align="center">
    <font face="Verdana" size="5"><b>Specify Data</b>
    </font>
    </td>
</tr>
</table>

<table bgcolor="<%=strBackColor%>" border="0"  width="80%" align="center"> 
<FORM ACTION="add_tbl_dtls.asp" METHOD="POST" NAME="NewTbl" onsubmit="return Search_Check(this)">
<tr>
  <% if Entry = "add_tbl_nme" then %>
    <td nowrap><font face="Verdana" color="#000000" size="2"><b>Table Name </b> &nbsp  <input type="text" name="TableName" value="<%=request.form("Criteria")%>" size=32 READONLY >
    &nbsp;&nbsp;&nbsp <b>Status</b> &nbsp DVLP</font>
	</td>
  <% else %>
     <td nowrap><font face="Verdana" color="#000000" size="2"><b>Table Name</b> &nbsp  <input type="text" name="TableName" value="<%=Request.QueryString("Col0")%>" size=32 READONLY >
    &nbsp;&nbsp;&nbsp <b>Status</b> &nbsp <%=Request.QueryString("Col1")%>  </font>
	</td>
  <% end if %>		
</tr>

  <tr>
     
     <% if Entry = "" then
        SQL = "select db_nme from irma01_table where tbl_nme = Trim('" & (Request.QueryString("Col0")) & "')" 
  	    Set rs = session("rs") 
	    rs.open(SQL) %> 
	 	<td><font face="Verdana" color="#000000" size="2"><b>Database</b></font>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp <input type="text" name="DBname" value="<%=rs.Fields(0).Value %>" Size="18">
      <% rs.Close  %>
    <% Else %>
	    <td><font face="Verdana" color="#000000"size="2"><b>Database</b></font>
	    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp <input type="text" name="DBname" value="" Size="18">
	<% End if %>
	</td>
  </tr>
<tr>
<br></tr>
  <tr>
   <td><font face="Verdana" color="#000000" size="2"><b>Description</b></font></td>
  <tr>

<td>
<textarea name="tbldesc" cols="80" rows="5" WRAP=OFF align=top>
  
<% Set rs = session("rs") %>  
<% if Entry = "" then  
	 '-DISPLAY EXISTING TABLE DESCRIPTION (coming from tbl. search screen)---
	SQLD = "SELECT seq_no, text_80_desc FROM irma02_table_desc" 
    SQLD = SQLD & " WHERE tbl_nme='" & Request.QueryString("Col0") & "' " 
    SQLD = SQLD & " and tbl_stat_cd='" & Request.QueryString("Col1") & "' order by seq_no "

    Set objDescr = CreateObject("Scripting.Dictionary")
    rs.open(SQLD)

    Do While Not rs.EOF 
      key = rs.Fields(0).Value 
      descr = rs.Fields(1).Value 
 	  objDescr.Add key, descr   
      rs.movenext 
    Loop 
   rs.Close 
     
   for i=1 to objDescr.count
     response.write(objDescr.Item(i))  & chr(13) 
   Next
     
   End If %>

</textarea>
   
</td> 
</tr>

<tr>  <td>    </td>  </tr>
<tr>  <td>    </td>  </tr>

 <!-- DISPLAY ELEMENTS  ---------------------------------->

<td><font face="Verdana" color="#000000" size="2"><b>Elements</b></b></td></font>
<tr>  <td>    </td>  </tr>
</td>
</tr>
<% if Entry = "" then  
   SQL = "SELECT seq_no, elmt_dict_nme, prim_key_no, elmt_stat_cd, elmt_vrsn_no" 
   SQL = SQL & " FROM irma03_table_elmt " 
   SQL = SQL & " WHERE tbl_nme='" & Request.QueryString("Col0") & "'" 
   SQL = SQL & " and tbl_stat_cd='" & Request.QueryString("Col1") & "'"
   SQL = SQL & " order by seq_no" %>
<!<%=SQL%>
<br>
<br>

<% rs.open(SQL) %>
<% Do While Not rs.EOF%>
   <tr>
     <td nowrap align="left"><font face="Verdana" size=2 "color="#000000">   
	   &nbsp;&nbsp;&nbsp <input name="Elements" value=<%=rs.Fields(1)%> type="checkbox">
	   <%=rs.Fields(1).Value%> 
	 </td>  
	 <td nowrap align="left">  
       <%=rs.Fields(3).Value%>
	 </font></td> 
   </tr>
   <% rs.movenext %>
<% Loop     %>
<% rs.Close %> 
<% End If   %>

<% 

if Entry = "add_tbl_db" then 
  dim dictElmPicks 
  set dictElmPicks = Session("cart")
  for each key in dictElmPicks
	response.write dictElmPicks(key) 
  next
  end if  
%>
  

<tr>  <td>    </td>  </tr>
<tr>  <td>    </td>  </tr>
<tr>  <td>    </td>  </tr>
<tr>
  <td><input type="submit"  value="     Add Elements    " name="cmdSubmit">
  <font face="Verdana" size=3 color="<%=strLinkColor%>"> &nbsp;&nbsp SEARCH &nbsp </font>
   <input type="text" name="elmsrch" value="" Size="18">
</td>
</tr>
<tr>
   <td><input type="button" value="Remove Elements" onclick="Remove()">
   &nbsp;&nbsp;&nbsp <input type="reset" value="Reset" name="cmdReset"></td>
</tr>  
<tr>
  	<td><input type="button" value="            DONE            " onclick="Done()">
</tr>

</form>
</table>
</body>
</html>