<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
<head>
<title>test</title>
this is a test page
<table border="0" cellpadding="0" cellspacing="0">
   <tr>
    <td>	
     <%set rs = server.createobject("ADODB.Recordset")

       set con = server.createobject("ADODB.Connection")

       con.open "irm_a01 brkdbpx02", "yyyc716", "gugab12"
  
       rs.activeconnection = con

       SQL = "SELECT * FROM irma08_elmt_note"

       rs.open(SQL)

       Do Until rs.EOF %>
          <option VALUE="<%Response.Write rs("elmt_dict_nme")%>"></option>
          <%rs.MoveNext
       Loop
       rs.close
       con.close	
       set rs = nothing
       set con = nothing%>
      </td>
    </tr>
</table>
</head>
</body>
</html>
