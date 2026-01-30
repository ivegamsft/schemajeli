<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<table border="0" width="100%" align="center">
  <tr>
    <td width="100%" bgcolor="#4889a2" height="40" align="middle"><b><font face="Verdana"
    color="#ffffff">Design Element</font></b> </td>
  </tr>
</table>
<!--Body Table -->

<table border="1" bgcolor="#c0c0c0" width="50%" align="center">
  <tr>
    <td><form method="post" name="NewElem" action="scripts/verif_elem.asp">
    <input type="hidden" name="UserId" Value="<%=Session("UserId")%>">
    </td>
  </tr>
  <tr>
    <td align="middle" colspan="2" style="BORDER-BOTTOM: rgb(255,255,255) solid thin"><font
    face="Verdana" size="3" color="#000000"><b>Revise column name</b></font></td>
  </tr>
  <tr>
    <td><font face="Verdana" size="3" color="#000000">Business name</font></td>
    <td>&nbsp; </td>
  </tr>
  <tr>
    <td width="50%">Dictionary name</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td width="50%">Column name<p>(messages)</td>
    <td width="50%"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"><input type="text" name="T1" size="20"><input type="checkbox" name="C1"
    value="ON"></td>
  </tr>
    </form>
    </table>

