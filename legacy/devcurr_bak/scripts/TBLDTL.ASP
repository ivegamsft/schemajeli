<% response.buffer = true %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<body>

<%    Set rs = session("rs") %>

<P><b>Table Details For: <%=Request.QueryString("Col0")%></b></P>             

<! DISPLAY TABLE DESCRIPTION -------------------------------

<% SQLD = "SELECT seq_no, text_80_desc FROM irma02_table_desc" %> 
<% SQLD = SQLD & " WHERE tbl_nme='" & Request.QueryString("Col0") & "' " %> 
<% SQLD = SQLD & " and tbl_stat_cd='" & Request.QueryString("Col1") & "' order by seq_no " %>
<!<%=SQLD%>

<br>
<b><font size=2><font face="arial">  Description:</b> 
<br>

<% rs.open(SQLD) %>

<% Do While Not rs.EOF%>
<table border="0" width="50" cellpadding="0" cellspacing="0">
     <td nowrap align="left">
      <font size=2><font face="arial">  
      <%=rs.Fields(1).Value%>
     </td>
      <% rs.movenext %>

<%Loop%> 

</table>

<%    session("TimeOutChk") = "N" %>
<%    Server.scripttimeout = 90 %>


<% rs.Close %>

<! DISPLAY UPDATE STATISTICS --------------------------------------

<% SQLS = "SELECT tbl_creat_uid, creat_ts, tbl_lst_chng_uid, tbl_lst_chng_ts FROM irma01_table" %> 
<% SQLS = SQLS & " WHERE tbl_nme='" & Request.QueryString("Col0") & "' " %> 
<% SQLS = SQLS & " and tbl_stat_cd='" & Request.QueryString("Col1") & "' " %>
<!<%=SQLS%>

<% rs.open(SQLS) %>

<br>
<br>
<b><font size=2><font face="arial">  Table Update Statistics:</b> 


<br>Table Created by <%=rs.Fields(0).Value%> at <%=rs.Fields(1).Value%>
<br>Table Updated by <%=rs.Fields(2).Value%> at <%=rs.Fields(3).Value%>   
<br>

<%    rs.Close %>


<!-- DISPLAY TABLE ELEMENTS ---------------------------->

<br>
<br>
<b><font size=2><font face="arial">  Elements:</b> 

<% SQL = "SELECT seq_no, elmt_dict_nme, prim_key_no, elmt_stat_cd, elmt_vrsn_no" %>
<% SQL = SQL & " FROM irma03_table_elmt " %>
<% SQL = SQL & " WHERE tbl_nme='" & Request.QueryString("Col0") & "'" %>
<% SQL = SQL & " and tbl_stat_cd='" & Request.QueryString("Col1") & "'" %>
<% SQL = SQL & " order by seq_no" %>
<!<%=SQL%>

<% Server.scripttimeout = 1800 %>
<% session("TimeOutChk") = "Y" %>

<br>
<br>
<table border="0" width="50%" cellpadding="0" cellspacing="0">
<%    rs.open(SQL) %>
<%    Do While Not rs.EOF%>
        <tr>
	<td>
         <a href="elmdtl.asp?Col1=<%=rs.Fields(1).Value%>&Col3=<%=rs.Fields(3).Value%>&Col4=<%=rs.Fields(4).Value%>"><img src="../images/report80.gif" border="0" align="middle" >
         </a>            
        </td>
           
	<td nowrap align="left">&nbsp;&nbsp;&nbsp;&nbsp
          <font size=2><font face="arial">  
          <%=rs.Fields(1).Value%>
	</td>
        <td nowrap align="left">
          <font size=2><font face="arial">  
          <%=rs.Fields(3).Value%>
	</td> 
	 </tr>
     	<% rs.movenext %>
<%   Loop %>
</table>
<%    session("TimeOutChk") = "N" %>
<%    Server.scripttimeout = 90 %>

<%    rs.Close %>

</body>
</html>
   