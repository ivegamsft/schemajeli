<% response.buffer = true %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->

<HTML>
<HEAD>
<TITLE>Add/Maintain Table
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->


<%  '---------------- SAVE PRIMARY KEYS ---------------------
aryKeys = SPLIT(Request.QueryString("prkeys"),",")
set objKeys = CreateObject("Scripting.Dictionary")

'response.write prkeys
k=1
for i = 0 to UBOUND(aryKeys) - 1
   objKeys.Add k, aryKeys(i)
   'response.write k
   k=k+1
Next

'response.write UBOUND(aryKeys) 
if UBOUND(aryKeys) = 0 then
   objKeys.Add 1, aryKeys(0)
end if   

set Session("prkeys") = objKeys
%>

<%    Set rs = session("rs") %>
<%session("InsrtLoc") = Request.QueryString("SavLoc") %>
<%' response.write(session("InsrtLoc"))%>

<SCRIPT LANGUAGE="VbScript">

  Sub SaveElmSel(cnt)
  Dim MyForm
  dim MySelection
  dim elmPicks() 
  Set MyForm = Document.Forms.item(0)
  Dim indx
  if cnt > 1 then
    indx = MyForm.chkElem.length
  else
 	indx = 1
  end if
  REDIM preserve elmPicks(indx)  
  i=0
  k=1
  checked="n"
  
  if cnt > 1 then
   do while i < MyForm.chkElem.length
     if MyForm.chkElem(i).Checked then
       elmPicks(k) = MyForm.rowid(i).value
	   checked="y"
       k = k + 1	  
	 end if
	 i = i + 1
   Loop 
  else
    if MyForm.chkElem.Checked then
	   elmPicks(k) =  MyForm.rowid.value
       'msgbox MyForm.rowid.value
        checked="y"
    end if	   
  end if

  if k = 1 then
    picks = elmPicks(1) & ","
  end if
  	
  i=1 
  do while k > 1
    picks = picks & elmPicks(i) & ","
    i = i + 1
	k = k - 1
  Loop

'   MsgBox picks 
   if checked = "y" then
      MyForm.Action="add_tbl_insrt.asp?savePicks="& picks &""
      MyForm.Submit
   else
      msgbox "Please choose at lease one element to add to the table or click CANCEL"	  
   end if 
	  
End sub

//--></SCRIPT>
 
<FORM ACTION="add_tbl_insrt.asp" METHOD="POST" NAME="add_tbl_insrt" onsubmit="return Search_Check(this)">
<!-- DISPLAY ELEMENTS THAT MATCH SEARCH STRING -------------------->
<% =Request.QueryString("InsertLoc") %>
<TABLE BGCOLOR="<%=strBackColor%>" border="0" width="90%" align="center">
  <TR>
    <TD WIDTH="100%" BGCOLOR="<%=strHeaderColor%>" height="40" align="center"><FONT FACE="Verdana" ><B>Search Results for Elements Starting with &nbsp <%=request.form("elmsrch")%>:</FONT></B>
    </TD>
  </TR>    
</TABLE>

<INPUT TYPE=HIDDEN NAME-FILLER VALUE=NOTHING>

<% dupFound = session("dupExist")
if dupFound = "y" then
  session("EntryPoint") = "add_tbl_insrt"
%>
   <SCRIPT LANGUAGE="VBScript"><!--
   call msg
   sub msg
    Dim theForm
    Set theForm = Document.Forms.item(0)
     message = "You've selected a duplicate element!" + (Chr(13)& Chr(10)) + "Please select another element"
     msgbox message, 0, "Element Selection"
	 theForm.action="add_tbl.asp" 
     theForm.submit()
   end sub 
    -->
</SCRIPT>
 <% end if%> 
 
<% ' CHECK if more than 100 elements are returned -----
SrchCriter = UCASE(request.form("elmsrch")) 

 SQL = "SELECT count(*) FROM irma04_elmt_vrsn  " 
 SQL = SQL & " WHERE elmt_dict_nme like '" & SrchCriter & "%'"  
 SQL = SQL & " and elmt_vrsn_no = 1" 
 
 rs.open(SQL) 
 'response.write(rs.Fields(0).Value)
 int cnt
 cnt = rs.Fields(0).Value
 if (FormatNumber(cnt) > 100) then
  session("EntryPoint") = "add_tbl_insrt" 
  %>
   <SCRIPT LANGUAGE="VBScript"><!--
   call msg1
   sub msg1
     Dim theForm
     Set theForm = Document.Forms.item(0)
     message = "Please enter a more specific search criteria!" + (Chr(13)& Chr(10)) + "Your search returned more then 100 elements"
     msgbox message, 0, "Search Criteria"
     theForm.action="add_tbl.asp" 
     theForm.submit()
   end sub 
    -->
</SCRIPT>
 <% end if%> 
   
 <% if (FormatNumber(cnt) = 0) then
  session("EntryPoint") = "add_tbl_insrt" 
  %>
   <SCRIPT LANGUAGE="VBScript"><!--
   call msg2
   sub msg2
     Dim theForm
     Set theForm = Document.Forms.item(0)
     message = "Please enter a more specific search criteria!" + (Chr(13)& Chr(10)) + "Your search returned zero elements"
     msgbox message, 0, "Search Criteria"
     theForm.action="add_tbl.asp" 
     theForm.submit()
   end sub 
 -->
</SCRIPT>

<% end if 
rs.close%>

<% SQL = "SELECT elmt_dict_nme, elmt_stat_cd, elmt_vrsn_no, rowid" %>
<% SQL = SQL & " FROM irma04_elmt_vrsn " %>
<% SQL = SQL & " WHERE elmt_dict_nme like '" & SrchCriter & "%'"  %>
<%' SQL = SQL & " and elmt_vrsn_no = 1" %>
<% SQL = SQL & " order by elmt_dict_nme" %>

<!-- %><%=SQL%> -->

<TABLE BGCOLOR="<%=strBackColor%>" width="90%" border="0" cellpadding="0" cellspacing="0" align="center">
<TH NOWRAP ALIGN="left" BGCOLOR="<%=strHeaderColor%>"><FONT FACE="Verdana">&nbsp;&nbsp;&nbsp;&nbsp Element Name</TH> 
<TH NOWRAP ALIGN="center" BGCOLOR="<%=strHeaderColor%>"><FONT FACE="Verdana">Status</TH> 
<TH NOWRAP ALIGN="center" BGCOLOR="<%=strHeaderColor%>"><FONT FACE="Verdana">Version</TH> 

<%  rs.open(SQL) %>
<%  Do While  Not rs.EOF %>
        <TR>
		<TD NOWRAP ALIGN="left">
		  <INPUT TYPE="checkbox" NAME="chkElem" VALUE=<%=RS.FIELDS(1)%> >
		  <FONT SIZE=2><FONT FACE="arial">  
          <%=rs.Fields(0).Value%>
		  <INPUT TYPE="hidden" NAME="rowid" VALUE=<%=RS.FIELDS(3)%>  >
	    </TD>
        <TD NOWRAP ALIGN="center">
          <FONT SIZE=2><FONT FACE="arial">  
          <%=rs.Fields(1).Value%>
		</TD>  
		<TD ALIGN="center"> &nbsp<INPUT TYPE="text" NAME="elmvrsn" VALUE="<%=rs.Fields(2).Value%>" size="2">
	    </TD> 
	    </TR>
     	<% rs.movenext %>
		<%i = i + 1%>
<%   Loop %>
<%    rs.Close %>
 
<TR>  <TD> <BR>   </TD>  </TR>

 <SCRIPT LANGUAGE="VBScript"><!--
 Sub cmdCancel_OnClick
   history.back
 End Sub
 //--></SCRIPT>
 
 <TD><INPUT TYPE="button" VALUE="Add Element to Table" onclick="SaveElmSel(<%response.write(cnt)%>)">
  &nbsp;&nbsp <INPUT TYPE="reset" VALUE="Reset" NAME="cmdReset">
  &nbsp;&nbsp <INPUT TYPE="button" VALUE="Cancel" NAME="cmdCancel"></TD>

<TR>
<TD>

<% '------------ SAVE TABLE DESCRIPTION ----------------- 
   
aryTblDesc = SPLIT(Request.Form("tbldesc"),Chr(10))
Set obj1Descr = CreateObject("Scripting.Dictionary")

'for i=1 to UBOUND(aryTblDesc)
for i=0 to UBOUND(aryTblDesc) 
  obj1Descr.Add i, aryTblDesc(i)
   'response.write i
   'response.write aryTblDesc(i)
Next 

set session("descrLines") = obj1Descr

'--------- Validate & SAVE DATABASE NAME ---------------------------

dbnme = trim(UCASE(request.form("DBname"))) 
session("dbname")=dbnme

if dbnme <> "" then 
 SQL = "SELECT db_nme FROM irma11_db WHERE db_nme = '" & dbnme & "'" 
 rs.open(SQL) 
 'response.write SQL
 'response.write Request.Form("DBname") 

 if rs.EOF then
  session("EntryPoint") = "add_tbl_insrt" 
  %>
   <SCRIPT LANGUAGE="VBScript"><!--
   call msg4
   sub msg4
     Dim theForm
     Set theForm = Document.Forms.item(0)
     message = "Database name not found!" + (Chr(13)& Chr(10)) + "Please enter a valid database name"
     msgbox message, 0, "Invalid Name"
     theForm.action="add_tbl.asp" 
     theForm.submit()
   end sub 
    -->
</SCRIPT>
 <% end if
end if 
If rs.State = 1 then
   rs.Close
End if
%>
<!--<%response.write(session("saveTableExists"))%> -->
</TD>
</TR>
</TABLE>

</FORM>
</BODY>
</HTML>
   