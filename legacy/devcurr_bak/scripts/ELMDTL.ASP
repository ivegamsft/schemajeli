<% response.buffer = true %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<body>

<P><b>Data Element Details For: <%=Request.QueryString("Col1")%></b></P>             

<% SQL = "SELECT a.elmt_stat_cd, a.creat_user_id, a.creat_ts, a.elmt_busns_nme," %>
<% SQL = SQL & " elmt_col_nme, b.elmt_vrsn_no, b.elmt_data_typ_id," %>
<% SQL = SQL & " elmt_logcl_lng, elmt_phys_lng, elmt_dec_lng" %>
<% SQL = SQL & " FROM irma05_element a, irma04_elmt_vrsn b" %>
<% SQL = SQL & " WHERE a.elmt_dict_nme='" & Request.QueryString("Col1") & "'" %>
<% SQL = SQL & " and a.elmt_stat_cd='" & Request.QueryString("Col3") & "'" %>
<% SQL = SQL & " and b.elmt_vrsn_no='" & Request.QueryString("Col4") & "'" %>
<% SQL = SQL & " and a.elmt_dict_nme = b.elmt_dict_nme" %>
<% SQL = SQL & " and a.elmt_stat_cd = b.elmt_stat_cd" %>
<!<%=SQL%>

<% Server.scripttimeout = 1800 %>
<% session("TimeOutChk") = "Y" %>

<%    Set rs = session("rs") %>

<%    rs.open(SQL) %>

<!<%=rs.Fields(6).Value%>

<font size=2><font face="arial">  

<table border="0" width="50%" cellpadding="0" cellspacing="0">
<tr>
<td><b><font size=2><font face="arial"> Status:  &nbsp</b> </td>
<td><font size=2><font face="arial"><%=rs.Fields(0).Value%></td>
</tr>
<tr>
<td><b><font size=2><font face="arial"> Creator:&nbsp </b> </td>
<td><font size=2><font face="arial"><%=rs.Fields(1).Value%> </td>
</tr>
<tr>
<td nowrap><b><font size=2><font face="arial"> Create Date: &nbsp</b></td>
<td><font size=2><font face="arial"><%=rs.Fields(2).Value%> </td>
</tr>
<tr>
<td nowrap><b><font size=2><font face="arial"> Business Name: &nbsp</b></td>
<td nowrap> <font size=2><font face="arial"><%=rs.Fields(3).Value%> </td>
</tr> 
<tr>
<td nowrap><b> <font size=2><font face="arial">Column Name: &nbsp</b></td> 
<td nowrap><font size=2><font face="arial"><%=rs.Fields(4).Value%> </td>
</tr>
<tr> 
<td nowrap><b> <font size=2><font face="arial">Version:&nbsp </b> </td>
<td nowrap><font size=2><font face="arial"><%=rs.Fields(5).Value%> </td>
</tr>
<tr>
<td nowrap><font size=2><font face="arial"><b> Data Type: &nbsp</b> </td>
<td nowrap><font size=2><font face="arial"><%=rs.Fields(6).Value%> </td>
</tr> 
<tr>
<td nowrap><b> <font size=2><font face="arial">Logical Length:&nbsp </b> </td>
<td nowrap> <font size=2><font face="arial"><%=rs.Fields(7).Value%> </td>
</tr>
<tr> 
<td nowrap><b><font size=2><font face="arial"> Physical Length:&nbsp</b> </td>
<td nowrap> <font size=2><font face="arial"><%=rs.Fields(8).Value%> </td>
</tr>
<tr> 
<td nowrap><b><font size=2><font face="arial"> Decimal Length:&nbsp</b> </td>
<td nowrap> <font size=2><font face="arial"><%=rs.Fields(9).Value%> </td>
</tr>
</table>
<%rs.close%>


<% SQLD = "SELECT seq_no, text_80_desc FROM irma06_elmt_desc WHERE elmt_dict_nme='" & Request.QueryString("Col1") & "' and elmt_stat_cd='" & Request.QueryString("Col3") & "' order by seq_no " %>

<%    rs.open(SQLD) %>


<br>
<br>
<b><font size=2><font face="arial">  Description:</b> 

<% Do While Not rs.EOF%>

<table border="0" width="100%" cellpadding="0" cellspacing="0">
     <td nowrap align="left">
      <font size=2><font face="arial">  
      <%=rs.Fields(1).Value %>
     </td>
      <% rs.movenext %>

<%Loop%> 

</table>

<%    session("TimeOutChk") = "N" %>
<%    Server.scripttimeout = 90 %>


<% rs.Close %>

<br>
<br>
<b><font size=2><font face="arial">Tables Where Element is Used:</b> 

<% SQLT = "SELECT tbl_nme, tbl_stat_cd from irma03_table_elmt"%>
<% SQLT = SQLT & " WHERE elmt_dict_nme='" & Request.QueryString("Col1") & "'"%>
<!<% SQLT = SQLT & " and elmt_stat_cd='" & Request.QueryString("Col3") & "'"%>
<!<% SQLT = SQLT & " and elmt_vrsn_no='" & Request.QueryString("Col4") & "'" %>
<% SQLT = SQLT & " order by tbl_nme" %>

<%    rs.open(SQLT) %>
<br>
<table border="0" cellpadding="0" cellspacing="0">
<% Do While Not rs.EOF%>
     <tr>
       <td nowrap align="left">
         <font size=2><font face="arial">  
         <%=rs.Fields(0).Value%>
        </td>
        <td nowrap align="left">
         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp<%=rs.Fields(1).Value%>
        </td>
       </tr>
      <% rs.movenext %>
  
<%Loop%> 

</table>

<% rs.close %>

</body>
</html>
  