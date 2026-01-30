<% response.buffer = true %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<body>

<B>Tables</B>             

<% SQL = "SELECT tbl_nme, tbl_stat_cd, tbl_creat_uid, tbl_lst_chng_uid FROM irma01_table elmt_dict_nme" 
   SQL = SQL & " WHERE tbl_nme like '" & UCASE(Request.Form("Criteria")) & "%'"   
   SQL = SQL & " order by tbl_nme" %>

<% session.timeout = 1 %>
<% Server.scripttimeout = 1800 %>
<% session("TimeOutChk") = "Y" %>

<p>Click on the <img src="../images/report_trans.gif" border=0 align="middle" >
 &nbsp;icon for more details on that table.</p>

<%    Set rs = session("rs") %>

<%    STime = Time %>
<%    rs.open(SQL) %>
<%    ETime = Time %>

<%    x = 0 %>

<%    Do While Not rs.EOF%>
<%     If x = 0 then %>
        <table border="0" width="70%" cellpadding="0" cellspacing="0">
      
	<tr>
         <th nowrap align="center" bgcolor="lightblue"> </th>
	 <th nowrap align="center" bgcolor="lightblue"><font size=2><font face="arial">Table Name</th> 
	 <th nowrap align="center" bgcolor="lightblue"><font size=2><font face="arial">&nbsp Table Status &nbsp</th> 
	 <th nowrap align="center" bgcolor="lightblue"><font size=2><font face="arial">&nbsp Created By &nbsp </th>
	 <th nowrap align="center" bgcolor="lightblue"><font size=2><font face="arial">&nbsp Last Changed By &nbsp</th>        	
	      
       </tr>
<%     End If %>
       <tr>

<% col1 = "y" %>

<%    For Each J in rs.Fields %>
<%       if col1 = "y" then    %>     
         
<%       if clrsw = "y" then   %> 
	    <td nowrap bgcolor=#EFEFEF align="left">&nbsp;
<%       Else %>
            <td nowrap bgcolor=white align="left">&nbsp;
<%       End If %> 
	     <a href="tbldtl.asp?Col0=<%=rs.Fields(0).Value%>&Col1=<%=rs.Fields(1).Value%>"><img src="../images/report80_trans.gif" border="0" align="middle" >
             </a>            
          </td>
<%        col1 = "n" %>
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
<%       x = x + 1 %>
<%       col1 = "y" %>
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

<%    session("TimeOutChk") = "N" %>
<%    session.timeout = 20 %>
<%    Server.scripttimeout = 90 %>

<%    rs.Close %>

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
	<p align="center">Metadata Management Version 1.0<br>Last Revised: July 8, 1999<br>
	Copyright © 1999 Navistar International Transportation Corp.<br>

  </td>
  </tr>

</table>
</center>


</body>
</html>
   