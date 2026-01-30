<% response.buffer = true %>
<% Session.timeout = 60 %>
<!--#INCLUDE FILE="../include/security.inc"-->
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<body>

<B>Data Elements</B> 
<br>
<br>            

<% SQL = " SELECT unique elmt_dict_nme from irma07_elmt_kwd where" %>


<% if request.form("keyword1") <> "" then 
      SQL = SQL & " elmt_dict_nme in (select  elmt_dict_nme" 
      SQL = SQL & " from irma07_elmt_kwd WHERE key_word_nme = " 
      SQL = SQL & " '" & ucase(request.form("keyword1")) & "')" 
  end if %>

<%  if request.form("keyword2") <> "" then
        SQL = SQL & " and elmt_dict_nme in (select  elmt_dict_nme" 
        SQL = SQL & " from irma07_elmt_kwd WHERE key_word_nme = "  
        SQL = SQL & " '" & ucase(request.form("keyword2")) & "' )"
end if %>
 
<%  if request.form("keyword3") <> "" then
        SQL = SQL & " and elmt_dict_nme in (select  elmt_dict_nme" 
        SQL = SQL & " from irma07_elmt_kwd WHERE key_word_nme = "  
        SQL = SQL & " '" & ucase(request.form("keyword3")) & "' )"
end if %>

<% if request.form("keyword4") <> "" then
        SQL = SQL & " and elmt_dict_nme in (select  elmt_dict_nme" 
        SQL = SQL & " from irma07_elmt_kwd WHERE key_word_nme = "  
        SQL = SQL & " '" & ucase(request.form("keyword4")) & "' )"
end if %>

<% if request.form("keyword5") <> "" then
        SQL = SQL & " and elmt_dict_nme in (select  elmt_dict_nme" 
        SQL = SQL & " from irma07_elmt_kwd WHERE key_word_nme = "    
	SQL = SQL & " '" & ucase(request.form("keyword5")) & "' )"
end if %>

<!<%=SQL%>


<p>Click on the <img src="../images/report_trans.gif" border=0 align="middle" >
 &nbsp;icon for more details on that data element.</p>


<%    x = 0 %>
   
    <% SQLB = "SELECT a.elmt_dict_nme, elmt_col_nme, a.elmt_busns_nme,"
       SQLB = SQLB & " a.elmt_stat_cd, b.elmt_vrsn_no"
       SQLB = SQLB & " FROM irma05_element a, irma04_elmt_vrsn b"
       SQLB = SQLB & " WHERE a.elmt_dict_nme = b.elmt_dict_nme"
       SQLB = SQLB & " and a.elmt_stat_cd=b.elmt_stat_cd"
       SQLB = SQLB & " and a.elmt_dict_nme in ( " & SQL & " ) order by elmt_dict_nme" %>
<% =SQLB %>

<%    Set rs = session("rs") %>
<%    rs.open(SQLB) %>

<% Do While Not rs.EOF%>
<%     If x = 0 then %>
        <table border="0" width="60%" cellpadding="0" cellspacing="0">
      
	<tr>
         <th align="center" bgcolor="lightblue"> </th>
	 <th align="center" bgcolor="lightblue"><font size=2><font face="arial">Dictionary Name</th> 
	 <th align="center" bgcolor="lightblue"><font size=2><font face="arial">Column Name    </th> 
	 <th align="center" bgcolor="lightblue"><font size=2><font face="arial">Business Name   </th>
         <th align="center" nowrap bgcolor="lightblue"><font size=2><font face="arial">Status Code &nbsp    </th>
         <th align="center" nowrap bgcolor="lightblue"><font size=2><font face="arial">Version Number  </th>

       </tr>
<%     End If %>
       <tr>

<% col1 = "y" %>

<%    For Each J in rs.Fields %>
<%      if col1 = "y" then    %>     
        
<%       if clrsw = "y" then   %> 
	    <td nowrap bgcolor=#EFEFEF align="left">&nbsp;
<%       Else %>
            <td nowrap bgcolor=white align="left">&nbsp;
<%       End If %> 
	  <a href="elmdtl.asp?Col1=<%=rs.Fields(0).Value%>&Col3=<%=rs.Fields(3).Value%>&Col4=<%=rs.Fields(4).Value%>"><img src="../images/report80_trans.gif" border="0" align="middle">
          </a> 
           
         </td>
<%       col1 = "n" %>
<%       End if   %>

<%       if clrsw = "y" then   %> 
	    <td nowrap bgcolor=#EFEFEF align="left">&nbsp;
<%       Else %>
            <td nowrap bgcolor=white align="left">&nbsp;
<%       End If %>

         <font size=1><font face="arial">  
         <% Response.Write J.Value %>   
             </td>  	    
<%       Next %>
<%       x = x + 1   %>
<%       col1 = "y"  %>
<%       reset = "N" %> 

<%       if clrsw = "y" then %>
<%          clrsw = "n" %>
<%       Else %>
<%          clrsw = "y" %>
<%       End If %>

<%       rs.movenext %>
 
<%       If x = 100 OR rs.EOF Then %>
<%          response.flush %>
<%            reset = "Y" %>        
            </tr>
            </table>
<%          x = 0 %>
<%       End If %>
     
<%       If reset = "Y" and not rs.EOF Then %>
	    <P>                </P>	
            <B>  CONTINUING... </B>
            <P>                </P>	
<%       End If %>
       
<%   Loop %>

<%    rs.Close %>


<br>
<B> END OF DATA <B>

<table border="0" width="100%">
  <tr>	
     <td><hr></td>
  </tr>
</table>

<center>
<table border="0" cellpadding="0" cellspacing="0">
  <tr>
     <td>
	<img src="../images/line2.gif" align="absbottom" hspace="0" border="0">
     </td>
  </tr>	

  
  <tr>	
     <td>
	<font size="2" face="Times">
	<p align="center">meta-data Management Version 1.0<br>Last Revised: July 8, 1999<br>
	Copyright © 1999 Navistar International Transportation Corp..<br>

  </td>
  </tr>

</table>
</center>


</body>
</html>
   