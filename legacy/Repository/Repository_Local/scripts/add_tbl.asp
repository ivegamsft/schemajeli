<!--#INCLUDE FILE="../include/security.inc"-->
<% Session.Timeout=60 %>

<% if Request.QueryString("Entry") = "query_result" or Request.QueryString("Entry") = "add_tbl_nme" then
      Entry = Request.QueryString("Entry")
   else	  
      Entry = session("EntryPoint") 
   end if %>
   
<%' response.write Request.QueryString("Entry") %>

<% session("dupExist") = "n" %>
<% session("elmExist") = "n" %>
      
<%Set rs = session("rs")%>    
<%if Entry = "add_tbl_nme" then 
     SQL = "select tbl_nme, tbl_stat_cd, db_nme from irma01_table where tbl_nme = Trim('" & ucase((request.form("criteria"))) & "')" 
  	
	 if rs.state=1 then
	    rs.close
	 end if	
		
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

     frstTime = "y"    
	 
     session("saveTableExists") = tblexists  
	 
	 session("descrLines") = " " 
	 
End If

If Entry = "query_result" then
   tblexists = "y" 
   frstTime = "y" 
   session("saveTableExists") = tblexists
End If 

tblexists = session("saveTableExists")
%>
<HTML>
<HEAD>
<TITLE>Add/Maintain Table
</TITLE>
</HEAD>
<BODY MARGINHEIGHT="0" MARGINWIDTH="0" LEFTMARGIN="0" RIGHTMARGIN="0" TOPMARGIN="0" BOTTOMMARGIN="1" BGCOLOR="<%=strPageBackColor%>" link=<%=strLinkColor%> alink=<%=strALinkColor%> vlink=<%=strVLinkColor%> text=<%=strTextColor%>>
<!--Nav menu-->
<!--#INCLUDE FILE="../include/navmenu.inc"-->

<SCRIPT LANGUAGE="VBScript"><!--
'---------------------------------------------------------------------------
'----------- ONCLICK SEARCH FOR ELEMENTS TO ADD TO TABLE COLLECTION --------
'---------------------------------------------------------------------------
Sub Search_Check(cnt)
  Dim theForm
  Set theForm = Document.Forms.item(0)
  
  chkCount=0
  iLoc=9999
  errors="n"

'msgbox cnt
' cnt is the number of items in the collection. this was needed because the
' theForm.ElemtList.Length is abending if there is only one element displayed.
 
  if cnt = 1 then
    if trim(theForm.prkey.value) <> "" then 
	   if not IsNumeric(theForm.prkey.value) then
          theForm.prkey.focus
	      errors = "y" 
          msgBox "Please enter a numeric key value!"
       else
	      if theForm.prkey.value = 0 then 
		     errors = "y" 
             msgBox "Please enter a none-zero key value!"
		  else	 
             pkey = theForm.prkey.value
          end if
	   end if
	 else 
	     pkey = theForm.prkey.value
	end if   
 end if	   
  
 if cnt > 1 then
    for i=0 to cnt -1
	  if trim(theForm.prkey(i).value) <> "" then 
	    
	      if not IsNumeric(theForm.prkey(i).value)  then
			theForm.prkey(i).focus
		    errors = "y"
            msgBox "Please enter a numeric key value!"
		   else
		    if theForm.prkey(i).value = 0 then
			   errors = "y"
               msgBox "Please enter a none-zero key value!"
			else  
			   pkey = pkey & theForm.prkey(i).value & "," 
			end if   
          end if
		else
		 pkey = pkey & theForm.prkey(i).value & ","
		end if 
	 
	next
    
'--- identify dups in primary key selections
    if cnt > 1 then 
     for i=0 to cnt -1
	  for k=i+1 to cnt - 1
	    if trim(theForm.prkey(i).value) <> ""  then
	      if trim(theForm.prkey(i).value) = trim(theForm.prkey(k).value) then
			   theForm.prkey(k).focus
		       errors = "y"
        	   msgBox "Please enter a unique primary key value!"
		  end if
	   end if
	  next 
	 next
    end if	 	
	 
    for i=0 to theForm.ElemtList.length - 1
       if theForm.ElemtList(i).Checked then
        iLoc=i
	    chkCount = chkCount + 1
	   end if 
     Next
    'msgbox iLoc

	if (chkCount > 1) then
	   msgBox "Please check off only one element to insert after"
	   errors = "y"
   	end if
  'end if
 end if
	
 if (theForm.elmsrch.value = "") then
    msgBox "Please enter the first N characters or a full element name into SEARCH box"
    errors = "y"
 end if
	
 if errors = "n" then
    theForm.action="add_tbl_dtls.asp?savLoc="& iLoc &"&prkeys="& pkey &"" 
    theForm.submit()
 end if 
 
End Sub

'-------------------------------------------------------------------------
'----------- ONCLICK REMOVE ELEMENTS FROM TABLE COLLECTION ---------------  
'-------------------------------------------------------------------------
Sub Remove(cnt)
  Dim theForm
  Set theForm = Document.Forms.item(0)
  Dim RemPicks()

  chkCount=0
  rLoc=9999
  errors="n"

' cnt is the number of items in the collection. this was needed because the
' theForm.ElemtList.Length is abending if there is only one element displayed.
'msgbox cnt

 if cnt = 1 then
    if trim(theForm.prkey.value) <> "" then 
	 'msgbox  theForm.prkey.value
	   if not IsNumeric(theForm.prkey.value) then
          theForm.prkey.focus
	      errors = "y" 
          msgBox "Please enter a numeric key value!"
       else
	      if theForm.prkey.value = 0 then
		     errors = "y" 
             msgBox "Please enter a none_zero key value!"
          else  
			 pkey = theForm.prkey.value
		  end if	 
       end if
	 else 
	   pkey = theForm.prkey.value
	end if   
 end if	   

 if cnt > 1 then 
    for i=0 to cnt -1
      if trim(theForm.prkey(i).value) <> "" then
	     if not IsNumeric(theForm.prkey(i).value) then
	        theForm.prkey(i).focus
		    errors = "y"
            msgBox "Please enter a numeric key value!"
			exit for
		   else
		    if theForm.prkey(i).value = 0 then
			   theForm.prkey(i).focus
		       errors = "y"
               msgBox "Please enter a none-zero key value!"
			   exit for
			else   
              pkey = pkey & theForm.prkey(i).value & ","
            end if
	      end if
		else
		 pkey = pkey & theForm.prkey(i).value & ","
		end if 
	 next
 end if   
     	 
if cnt > 1 then	  
   indx = theForm.ElemtMove.length
   REDIM preserve remPicks(indx)  
   for i=0 to theForm.ElemtMove.length - 1
     if theForm.ElemtMove(i).Checked then
       remPicks(i) = i
	   chkCount = chkCount + 1
	 end if 
   Next
end if

if cnt = 1 then
   if theForm.ElemtMove.Checked then
      rpicks = 1
	  chkCount = 1
   end if
end if	
 	   
'msgbox chkCount

 if (chkCount <> 1) then
	msgBox "Please check off ONE element to remove"
	errors = "y"
 end if
 	
'--- identify dups in primary key selections
 
 if cnt > 1 then 
    for i=0 to cnt -1
	  for k=i+1 to cnt - 1
	    if trim(theForm.prkey(i).value) <> ""  then
	      if trim(theForm.prkey(i).value) = trim(theForm.prkey(k).value) then
			   theForm.prkey(k).focus
		       errors = "y"
        	   msgBox "Please enter a unique primary key value!"
               exit for 
		  end if
	   end if
	  next 
	next
 end if	 	
	

if cnt > 1 then 
   for i=0 to cnt -1
    if theForm.ElemtMove(i).Checked then
      rpicks = rpicks & remPicks(i) & ","
    end if
	Next
End if	
   	
if errors = "n" then
    theForm.action="add_tbl_remv.asp?savePicks="& rpicks &"&prkeys="& pkey &""  
    theForm.submit()
end if
	
End Sub

'-----------------------------------------------------------------
'-------- ONCLICK MOVE ELEMENTS WITHIN TABLE ---------------------  
'-----------------------------------------------------------------
Sub Move(cnt)
  Dim theForm
  Set theForm = Document.Forms.item(0)
  Dim RemPicks()

  chkCount=0
  insCount=0
  rLoc=9999
  errors="n"
 
checked = "n"	 
if cnt > 1 then	  
   indx = theForm.ElemtMove.length
   REDIM preserve remPicks(indx)  
   for i=0 to theForm.ElemtMove.length - 1
     if theForm.ElemtMove(i).Checked then
	   if i > 0 then
	      if theForm.ElemtList(i-1).Checked then
		     msgBox "Please check off a valid insertion point"
			 chkCount = chkCount + 1
		     errors = "y"
			 exit for
		  end if
	   end if	  	  
	   if theForm.ElemtList(i).Checked then
	      msgBox "Please check off a valid insertion point"
		  chkCount = chkCount + 1
	      errors = "y"
		  exit for
	   end if	  
	   if chkCount > 0 and checked = "n" then
	      msgBox "Please check off consecutive elements to move"
	      errors = "y"
		  exit for
	   end if 	  
	   remPicks(i) = i
	   chkCount = chkCount + 1
	   checked = "y"
	 else 
	   checked = "n"   
	 end if 
   Next
end if

if cnt = 1 then
   if theForm.ElemtMove.Checked then
      rpicks = 1
	  chkCount = 1
   end if
end if	
 	   
'msgbox chkCount

 if (chkCount < 1) then
	msgBox "Please check off at least ONE element to move"
	errors = "y"
 end if
 	
for i=0 to theForm.ElemtList.length - 1
       if theForm.ElemtList(i).Checked then
        iLoc=i
	    insCount = insCount + 1
	   end if 
Next
' msgbox iLoc

if (insCount = 0) then
	msgBox "Please check off an element to insert after"
	errors = "y"
end if 

if (insCount > 1) then
	msgBox "Please check off ONE element to insert after"
	errors = "y"
end if 

if cnt > 1 and errors = "n" then 
   for i=0 to cnt -1
   if theForm.ElemtMove(i).Checked then
      rpicks = rpicks & remPicks(i) & ","
   end if
   Next
End if	   	

' SAVE PRIMARY KEYS IN CASE A CHANGE WAS MADE BEFORE -MOVE- CLICK
	
 if cnt > 1 then
   for i=0 to cnt -1
	  pkey = pkey & theForm.prkey(i).value & ","
   next
 end if	

 if cnt = 1 then
   pkey = theForm.prkey.value	
 end if	
 
if errors = "n" then
   theForm.action="add_tbl_move.asp?savLoc="& iLoc &"&savePicks="& rpicks &"&prkeys="& pkey &""  
   theForm.submit()
end if
	
End Sub
'---------------------------------------------------------------------------
'------------ ONCLICK - DONE - COMMIT CHANGES TO THE DATABASE ---------------------
'---------------------------------------------------------------------------
Sub Done(cnt)
  Dim theForm 
  Set theForm = Document.Forms.item(0)

  errors = "n"
  
   if cnt = 1 then
    if trim(theForm.prkey.value) <> ""  then 
	 'msgbox  theForm.prkey.value
	   if not IsNumeric(theForm.prkey.value) then
          theForm.prkey.focus
	      errors = "y" 
          msgBox "Please enter a numeric key value!"
	   else 
	      if theForm.prkey.value = 0 then
		     theForm.prkey.focus
	         errors = "y" 
             msgBox "Please enter a none-zero key value!"	  
          end if
       end if 
	end if   
 end if	   

 if cnt > 1 then 
    for i=0 to cnt -1
	  if trim(theForm.prkey(i).value) <> "" then
	    if not IsNumeric(theForm.prkey(i).value) then
	        theForm.prkey(i).focus
		    errors = "y"
            msgBox "Please enter a numeric key value!"
			exit for
		else
		    if theForm.prkey(i).value = 0 then
			   theForm.prkey(i).focus
		       errors = "y"
               msgBox "Please enter a none-zero key value!"
			   exit for
			end if
	    end if
	  end if 
	 next
 end if	 
 
 '--- identify dups in primary key selections
 
 if cnt > 1 then 
    for i=0 to cnt -1
	  for k=i+1 to cnt - 1
	    if trim(theForm.prkey(i).value) <> ""  then
	      if trim(theForm.prkey(i).value) = trim(theForm.prkey(k).value) then
			   theForm.prkey(k).focus
		       errors = "y"
        	   msgBox "Please enter a unique primary key value!"
               exit for
		  end if
	   end if
	  next 
	next
 end if	 

  
 ' SAVE PRIMARY KEYS IN CASE A CHANGE WAS MADE BEFORE -DONE- CLICK
	
 if cnt > 1 then
   for i=0 to cnt -1
	  pkey = pkey & theForm.prkey(i).value & ","
   next
 end if	

 if cnt = 1 then
   pkey = theForm.prkey.value	
 end if	
 
 if errors = "n" then  
   theForm.Action="add_tbl_db.asp?prkeys="& pkey &""
   theForm.Submit
 end if 

End sub

Sub cmdCancel_OnClick
 Dim theForm 
 Set theForm = Document.Forms.item(0)
  theForm.action="add_tbl_nme.asp"
  theForm.Submit
 End Sub 
 
//--></SCRIPT>
 
<!--#INCLUDE FILE="../include/colors.inc"-->
<!-- Entry Points:  query_result.asp ( from search tables display page )
					add_tbl_nme.asp  ( from enter table name to maintain page)
-->

<!--Header table -->
<TABLE BORDER="0" WIDTH="100%" ALIGN="center" BGCOLOR="<%=strHeaderColor%>">
 <TR>
    <TD ALIGN="center">
    <FONT FACE="Verdana" SIZE="3"><B>Specify Data</B> - Table<BR>Add elements</FONT>
	
 <%	if Entry = "query_result" then 
	    session("TableName") = Request.QueryString("Col0") 
        if Request.QueryString("Col1") <> "DVLP" then
		   session("Status") = "DVLP"
		   strErrMessage = "You can only edit tables in development status.<BR>"
           strErrMessage = strErrMessage & "The table you selected was in production.<BR>"
           strErrMessage = strErrMessage & "A copy has been made in development status for you.<BR>" %>
		   <BR><FONT FACE="Verdana" COLOR="<%=strErrTextColor%>">
           <%=strErrMessage%>
           </FONT>
	<%	else   
      	   session("Status") = Request.QueryString("Col1")
        end if
     End If %> 

    </TD>
</TR>
</TABLE>
<TABLE BGCOLOR="<%=strBackColor%>" border="0"  width="100%" align="center"> 
<FORM ACTION="add_tbl_dtls.asp" METHOD="POST" NAME="NewTbl" >

  <% if Entry = "add_tbl_nme" then 
        session("TableName") = request.form("Criteria")
        session("Status") = "DVLP" 
     end if   
	
	' response.write(entry)
    
	    
	 if Entry = "query_result" then 
	    session("TableName") = Request.QueryString("Col0") 
        if Request.QueryString("Col1") <> "DVLP" then
		   session("Status") = "DVLP"
		   strErrMessage = "You can only edit tables in development status.<BR>"
           strErrMessage = strErrMessage & "The table you selected was in production.<BR>"
           strErrMessage = strErrMessage & "A copy has been made in development status for you.<BR>"
		else   
      	   session("Status") = Request.QueryString("Col1")
        end if
     End If %> 

<TR>	 
 <TD NOWRAP><FONT FACE="Verdana" COLOR="#000000" SIZE="2"><B>Table Name</B> &nbsp  <INPUT TYPE="text" NAME="TableName" VALUE="<%=Session("TABLENAME")%>" size=32 READONLY >
    &nbsp;&nbsp;&nbsp <B>Status</B> &nbsp <%=Session("Status")%>  </FONT>
	</TD>
</TR>


 <%  if frsttime = "y" and tblexists = "y" then  %>
 <% ' DISPLAY DATABASE NAME  -----------------------  %>
        <TR>
       <% SQL = "select db_nme from irma01_table where tbl_nme = '" & Session("TableName") & "'" 
  	    SQL = SQL & "and tbl_stat_cd = '" & session("Status") & "'"
		Set rs = session("rs") 
		If rs.State = 1 Then
           rs.Close
        End IF
        rs.open(SQL) %> 
	 	<TD><FONT FACE="Verdana" COLOR="#000000" SIZE="2"><B>Database</B></FONT>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp <INPUT TYPE="text" NAME="DBname" VALUE="<%=rs.Fields(0).Value %>" Size="18" tabindex="1">
       <% session("dbname") = rs.Fields(0).Value %>
	    <% rs.Close  %>
        </TR>
    <% Else %>
        <TR>
		<TD><FONT FACE="Verdana" COLOR="#000000"SIZE="2"><B>Database</B></FONT>
	    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp <INPUT TYPE="text" NAME="DBname" VALUE="<%=session("DBNAME")%>" Size="18" tabindex="1">
		</TD>
		</TR>
   <% End if %>
 
<TR>
</TR>
<TR>
<TD><FONT FACE="Verdana" COLOR="#000000" SIZE="2"><B>Description</B></FONT></TD>
</TR>

<TR>
<TD>
<!--- DISPLAY EXISTING TABLE DESCRIPTION (coming from tbl. search screen)--->

<% if tblexists = "n" and frstTime = "y" then%>
     <TEXTAREA NAME="tbldesc" COLS="80" ROWS="5" WRAP="hard" ALIGN=TOP TABINDEX="2">
     </TEXTAREA>
<%end if %>

<% Set rs = session("rs") %>  
<% if (tblexists = "y" and frstTime = "y") then
    	
      SQLD = "SELECT seq_no, text_80_desc FROM irma02_table_desc" 
      SQLD = SQLD & " WHERE tbl_nme='" & Session("TableName") & "' " 
      SQLD = SQLD & " and tbl_stat_cd='" & Session("Status") & "' order by seq_no "

    Set objDescr = CreateObject("Scripting.Dictionary")
    
	i=0 
	rs.open(SQLD) %>
	<TEXTAREA NAME="tbldesc" COLS="80" ROWS="5" WRAP="hard" ALIGN=TOP TABINDEX="2"><%
	Do While Not rs.EOF
	  response.write(rs.Fields(1).Value) & chr(10)
	  descr = trim(rs.Fields(1).Value) & chr(10)
	  objDescr.Add i, descr
	  rs.movenext
	  i = i + 1
	Loop%></TEXTAREA>
	<%rs.Close
    set session("descrLines") = objDescr  
else
  if isObject(session("descrLines")) then
     set objDescr = session("descrLines")%>
	  <TEXTAREA NAME="tbldesc" COLS="80" ROWS="5" WRAP="hard" ALIGN=TOP><%
	  for i=0 to objDescr.count - 1
	     response.write(objDescr.Item(i)) 
	  Next%></TEXTAREA>
<%end if
end if	  
 %>

</TD> 
</TR>

<TR>  <TD>    </TD>  </TR>
<TR>  <TD>    </TD>  </TR>

<TD><FONT FACE="Verdana" COLOR="#000000" SIZE="2"><B>&nbsp Move/Remove &nbsp&nbsp&nbsp Insert After &nbsp&nbsp&nbsp Elements</B></B></TD></FONT>
<TD><FONT FACE="Verdana" COLOR="#000000" SIZE="2"><B>Key</B></TD></FONT> 
<TD><FONT FACE="Verdana" COLOR="#000000" SIZE="2"><B>Status</B></TD></FONT>


<% if tblexists = "y" and frstTime = "y" then 
        
	 set dictElmPicks = CreateObject("Scripting.Dictionary")  
	 set dictElmNames = CreateObject("Scripting.Dictionary") 
     set dictElmPkeys = CreateObject("Scripting.Dictionary") 
	 set Session("names") = dictElmNames 
	 
' DISPLAY ELEMENTS ----------------------------------'
     SQL = "SELECT seq_no, a.elmt_dict_nme, prim_key_no, a.elmt_stat_cd, a.elmt_vrsn_no, b.rowid" 
     SQL = SQL & " FROM irma03_table_elmt a, irma04_elmt_vrsn b " 
     SQL = SQL & " WHERE tbl_nme='" & Session("TableName") & "'" 
     SQL = SQL & " and tbl_stat_cd='" & Session("Status") & "'"
	 SQL = SQL & " and a.elmt_dict_nme = b.elmt_dict_nme"
     SQL = SQL & " and a.elmt_stat_cd = b.elmt_stat_cd"
	 SQL = SQL & " and a.elmt_vrsn_no = b.elmt_vrsn_no"
	 SQL = SQL & " order by seq_no" %>

     <% rs.open(SQL) %>
     <% Do While Not rs.EOF%>
     <TR>
     <TD NOWRAP ALIGN="left">&nbsp;&nbsp;&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp <FONT FACE="Verdana" SIZE=2 "color="#000000">   
	
	 <INPUT NAME="ElemtMove" VALUE=<%=RS.FIELDS(0)%> type="checkbox"> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
	 <INPUT NAME="ElemtList" VALUE=<%=RS.FIELDS(1)%> type="checkbox"> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
	 
	 <%=rs.Fields(1).Value%> 
	 </TD>  
	 <TD NOWRAP ALIGN="left">
	 <INPUT TYPE="text" NAME="prkey" VALUE="<%=rs.Fields(2) %> " Size="2">
	 </TD>
	 <TD NOWRAP ALIGN="left">  
       &nbsp <%=rs.Fields(3).Value%>
	 </FONT></TD> 
     </TR>

<%
    session("elmExist") = "y"
    key=rs.Fields(0)
	descr=rs.Fields(5)
    dictElmPicks.Add key, descr
    ' response.write (dictElmPicks.item(rs.Fields(5)))
	
	name=rs.Fields(1).Value
	dictElmNames.Add key, name
	set Session("names") = dictElmNames
	
	pkey=rs.Fields(2).Value
	dictElmPkeys.Add key, pkey
	set Session("prkeys") = dictElmPkeys
	
	rs.movenext
   Loop     
   rs.Close  
 
   set Session("cart") = dictElmPicks 
 End If %>

<%
if Entry = "add_tbl_insrt" then 
   set dictElmNames = CreateObject("Scripting.Dictionary")
   set Session("names") = dictElmNames

   if isObject(Session("prkeys")) then
      set dictElmPkeys = CreateObject("Scripting.Dictionary") 
      set dictElmPkeys = Session("prkeys") 
   'response.write dictElmPkeys.item(1)
   end if
    
   if IsObject(Session("cart")) then 
     set dictElm = Session("cart")
     for i=1 to dictElm.Count
      rowId = dictElm.item(i)
      SQL = "SELECT elmt_dict_nme, elmt_stat_cd, rowid" 
      SQL = SQL & " FROM irma04_elmt_vrsn" 
      SQL = SQL & " WHERE rowid= '" & rowId & "' "
%>  
<% rs.open(SQL) %> 
   <TR>
     <TD NOWRAP ALIGN="left">&nbsp;&nbsp;&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp <FONT FACE="Verdana" SIZE=2 "color="#000000"> 
	   <INPUT NAME="ElemtMove" VALUE=<%=RS.FIELDS(0)%> type="checkbox"> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
	   <INPUT NAME="ElemtList" VALUE=<%=RS.FIELDS(1)%> type="checkbox"> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
	   <%=rs.Fields(0).Value%> 
	 </TD>  
	 <TD NOWRAP ALIGN="left">
	 <INPUT TYPE="text" NAME="prkey" VALUE="<%=dictElmPkeys.item(i)%> " Size="2">&nbsp&nbsp
	 </TD>
	 <TD NOWRAP ALIGN="left">  
	   <%session("elmExist") = "y"%>
       <%=rs.Fields(1).Value%>
	   <%name=rs.Fields(0).Value %>
	   <%dictElmNames.Add i, name%>
   </FONT></TD> 
   </TR>
<% rs.Close %>  
<% Next %>  
 <% end if %>
 <% set Session("names") = dictElmNames %>
<% end if %>

<%
'for each key in dictElmNames
'  response.write dictElmNames.item(key) 
'next
%>
<TR>  <TD>    </TD>  </TR>
<TR>  <TD>    </TD>  </TR>
<TR>  <TD>    </TD>  </TR>


<%elmtcnt=0
  if IsObject(Session("cart")) then 
      set dictElm = session("cart") 
	  elmtcnt = dictElm.count
      'response.write(dictElm.count)
  end if %>
<TR>
<TD><INPUT TYPE="button"  VALUE="    Add Elements   " onclick="Search_Check(<%response.write(elmtcnt)%>)" tabindex="4">
  <FONT FACE="Verdana" SIZE=3 COLOR="<%=strLinkColor%>"> &nbsp;&nbsp <b>SEARCH</b> &nbsp </FONT>
  <INPUT TYPE="text" NAME="elmsrch" VALUE="" SIZE="18" TABINDEX="5">
</TD>
</TR>
<TR>
<TD>
<INPUT TYPE="button"  VALUE="  Move Elements  "  onclick="Move(<%response.write(elmtcnt)%>)" TABINDEX="6"><FONT FACE="Verdana" SIZE=3 COLOR="<%=strLinkColor%>"> &nbsp;&nbsp <b> Check off elements to be moved and an insertion point. </b> &nbsp </FONT>

</TD>
</TR>


<TR>
   <TD><INPUT TYPE="button" VALUE="Remove Element" onclick="Remove(<%response.write(elmtcnt)%>)" tabindex="7">
   <FONT FACE="Verdana" SIZE=3 COLOR="<%=strLinkColor%>"> &nbsp;&nbsp <b>Click on element to remove </b>&nbsp </FONT>
   <!--&nbsp;&nbsp;&nbsp <input type="reset" value="Reset" name="cmdReset"></td> -->
</TR>  
<TR>
   <TD><INPUT TYPE="button" VALUE="           DONE           " onclick="Done(<%response.write(elmtcnt)%>)" tabindex="8">
   <FONT FACE="Verdana" SIZE=3 COLOR="<%=strLinkColor%>"> &nbsp;&nbsp <b>Post changes to the database</b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp </FONT>
   <INPUT TYPE="reset" VALUE="Cancel" NAME="cmdCancel" TABINDEX="9">
</TR>
<%frstTime = "n" %>

<SCRIPT LANGUAGE="VBScript"><!--
  Sub Window_OnLoad()
    Document.NewTbl.DBname.Focus
  end sub

//--></SCRIPT>
</FORM>
</TABLE>
</BODY>
</HTML>