<% Response.Buffer = true 
session.timeout=60%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->

<!--Add elemenent details-->
<!--Header table-->
<body bgcolor="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<table border="0" width="60%" align="center" bgcolor="<%=strBackColor%>">
 <tr>
    <td>
    <font face="Verdana" size="5"><b>Specify Data - Element</b>
    </font>
    </td>
</tr>
</table>
<!--Body Table -->
<table bgcolor="<%=strBackColor%>" border="0"  width="100%" align="center">
<FORM METHOD="POST" NAME="NewElem" ACTION="add_new.asp?RelObject=Element">
	<tr>
     <td nowrap><font face="Verdana" color="#000000">Table Name: <%=request.form("Criteria")%></td></font>
     </td>
	 <td> <font face="Verdana" color="#000000">Status: &nbsp <input type="text" name="Status" value="DVLP" Size="6">
	</td>
    </tr>
    
	<% End If %>
    <% rs.Close %> 

  <tr>
  </tr>
  

  <tr>
    <td><font face="Verdana" color="#000000">Database</td></font>
    <td><input type="text" name="DBname" value="" Size="18">
    </td>
  </tr>

   <tr>
    <td  width="50%"><font face="Verdana" color="#000000">Description</td></font>
    <td  width="50%"><textarea name="txtDesc" rows="5" cols="50"></textarea>	
    </td>
  </tr>
  
  <tr>
    <td  width="50%"><font face="Verdana" color="#000000">Elements</td></font>
    
    </td>
  </tr>
  
  <tr>
    <td width="50%" align="center"><input type="submit" value="Submit" name="cmdSubmit">
    <td width="50%" align="center"><input type="reset" value="Reset" name="cmdReset">
      </form>
  </tr>  
</table>

</body>
</html>
>
<body bgcolor="<%=strPageBackColor%>" link=<%=strLinkColor%> alink="<%=strALinkColor%>" vlink="<%=strVLinkColor%>" text="<%=strTexColor%>" align="center">
<table border="0" width="75%" align="center" bgcolor="<%=arypagecolors(7)%>">
  <tr>
    <td width="100%" bgcolor="<%=strHeaderColor%>" height="40" align="middle"><font face="Verdana">
      <b>Design Element - Name &amp; Description</b><br>
	 Specify Data
     </FONT>
    </td>
  </tr>
</table>
<!--Body Table -->
<table border="0" bgcolor="<%=strBackColor%>" width="75%" align="center" ">
 <FORM METHOD="POST" NAME="NewElement" ACTION="../scripts/verif_Elem.asp?RelObject=Element+Step=1">
   <tr>
    <td colspan="3" align="center" style="BORDER-BOTTOM: rgb(255,255,255) solid thin">
	</td>
  </tr>
  <tr>
    <td colspan="3"><font face="Verdana" size="2">
	<b>Created by:</b>&nbsp;&nbsp;<%=Session("UserId")%>
    <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">
    </font>
	</td>
  </tr>

  <tr>
    <td colspan="3"><font face="Verdana" size="2">
     <b>Enter a business name and a 
		        <a href="query_result.asp?RelObject=ClassWord" TITLE="View class words">class word</a></b></font><br>
                <input name="txtBusnsName" size="50">&nbsp;<select name="cboClassWord" size="1">
                                       <option selected value="Select an RDBMS">Select a Class Word</option>
                                       <% If Not Session("rs").EOF Then Session("rs").MoveFirst %>
                                       <% Do While Not Session("rs").EOF%>
                                       <OPTION VALUE="<%=Session("rs").Fields(0)%>">
                                                      <%=Session("rs").Fields(0)%></OPTION>
             						   <%Session("rs").MoveNext%>
	                                   <%Loop%>
	                                   </SELECT>
<%
' Close Data Access Objects and free DB variables
    Session("rs").Close
%>
  <tr>
    <td colspan="3"><font face="Verdana" size="2">
	<b>Enter a description</font></b><br>
      <textarea cols="66" name="txtDesc" rows="5">
      </textarea>
	</td>
  </tr>
  <tr>
	<td align="center">
	   <input type="submit" value="Submit" name="cmdSubmit">&nbsp;&nbsp;&nbsp;&nbsp;
	   <input type="reset" value="Reset" name="cmdReset">
	</td>
   </tr>
</FORM>
</table>
