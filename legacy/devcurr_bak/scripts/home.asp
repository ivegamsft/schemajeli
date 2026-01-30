<% Response.buffer = True %>
<!--#INCLUDE FILE="../include/security.inc"-->
<table border="0" width="100%" align="center">
  <tr>
     <td width="100%" colspan="5" bgcolor="#4889A2"><center><font face="Tahoma" color="fffffff">
            <p><b>Navistar meta-data Management System</b></p>
            Select an option below or use the navigation on the side
         </font>     
     </td>
   </tr>

  <tr>
      <FORM NAME="Search" METHOD="POST" ACTION="GoToForm.asp?Option=Search">
    <td width="20%">
    </td>
    <td width="25%" align="right" bgcolor="#C0C0C0"><font face="Verdana"><b>Search:</font></b>
    </td>
    <td width="25%" bgcolor="#C0C0C0"><font face="Verdana"><select name="cboSearch" size="1">
                                         <option selected value="Select a search category">Select a search category </option>
<!---rem out servers dbs                 <option value="search_srvrs.asp">Servers</option>
                                         <option value="search_dbs.asp">Databases</option>
End rem-->                               <option value="search_tbls.asp">Tables</option>
                                         <option value="search_elems.asp">Elements</option>
                                         <option value="search_stdabbr.asp">Standard Abbreviations</option>                                         
<!--rem std abbr and  cust search        <option value="search_cust.asp">Custom</option>
End rem-->                                         
      </select>
      </font>
    </td>
    <td width="10%" align="left" bgcolor="#C0C0C0"><input type="submit" value="Select" name="cmdSearch">
    </td>
    <td width="20%">
    </td>
      </FORM>      
  </tr> 
<!--This is the browse selection  

  <tr>
      <FORM NAME="Browse" METHOD="POST" ACTION="GoToForm.asp?Option=Browse">
    <td width="20%">
    </td>
    <td width="25%" align="right" bgcolor="#C0C0C0"><font face="Verdana"><b>Browse:</font></b>
    </td>
    <td width="25%" bgcolor="#C0C0C0"><font face="Verdana"><select name="cboBrowse" size="1">
                                         <option selected value="Select a category to browse">Select a category to browse </option>
                                         <option value="browse_srvrs.asp">Servers</option>
                                         <option value="browse_dbs.asp">Databases</option>
                                         <option value="browse_tbls.asp">Tables</option>
                                         <option value="browse_elems.asp">Elements</option>
                                         <option value="browse_stdabbr.asp">Standard Abbreviations</option>
          </select>
        </font>
    </td>
    <td width="10%" bgcolor="#C0C0C0"><font face="Verdana"><input type="submit" value="Select" name="cmdBrowse"></font>
    </td>
    <td width="20%">
    </td>
       </FORM>
  </tr>
End browse selection-->    

  <tr>
      <FORM NAME="Reports" METHOD="POST" ACTION="GoToForm.asp?Option=Reports">
    <td width="20%">
    </td>
    <td width="25%" align="right" bgcolor="#C0C0C0"><font face="Verdana"><b>Reports:</font></b>
    </td>
    <td width="25%" bgcolor="#C0C0C0"><font face="Verdana"><select name="cmdReports" size="1">
                                         <option selected value="Select a report type">Select a report type </option>
                                         <option value="RDBMS_rpt">RDBMS reports</option>
                                         <option value="DB_rpt">Database report</option>
                                         <option value="TBL_rpt">Table report</option>
                                         <option value="ELEM_rpt">Element report</option>
                                         <option value="DDL_sch">Generate DDL schema</option>
                                         <option value="CUST_rpr">Custom</option>
       </select>
       </font>
    <td width="10%" bgcolor="#C0C0C0"><font face="Verdana"><input type="submit" value="Select" name="cmdReports"></font>
    </td>
    <td width="20%">
    </td>
       </FORM>
  </tr>
  
  <tr>
      <FORM NAME="Design" METHOD="POST" ACTION="GoToForm.asp?Option=Design">
    <td width="20%">
    </td>
    <td width="25%" align="right" bgcolor="#C0C0C0"><font face="Verdana"><b>Design:</font></b>
    </td>
    <td width="25%" bgcolor="#C0C0C0"><font face="Verdana"><select name="cboDesign" size="1">
                                         <option selected value="Select an object to design">Select an object to design </option>
                                         <option value="design_db.asp">Database</option>
                                         <option value="design_tbl.asp">Table</option>
                                         <option value="design_elem.asp">Element</option>
        </select>
        </font>
     </td>
     <td width="10%" bgcolor="#C0C0C0"><font face="Verdana"><input type="submit" value="Select" name="cmdDesign"></font>
     </td>
     <td width="20%">
     </td>
        </FORM> 
    </tr>
    
    <tr>
       <FORM NAME="Maintain" METHOD="POST" ACTION="GoToForm.asp?Option=Maintain">
     <td width="20%">
     </td>
     <td width="25%" align="right" bgcolor="#C0C0C0"><font face="Verdana"><b>Maintain:</font></b?
     </td>
     <td width="25%" bgcolor="#C0C0C0"><font face="Verdana"><select name="cboMaintain" size="1">
                                            <option selected value="Select an maintanance function">Select an edit function </option>
                                            <option value="Database">Database</option>
                                            <option value="Table">Table</option>
                                            <option value="Element">Element</option>
         </select>
         </font>
      </td>
      <td width="10%" bgcolor="#C0C0C0"><font face="Verdana"><input type="submit" value="Select" name="cboMaintain"></font>
      </td>
      <td width="20%">
      </td>
         </FORM>
  </tr>
    
  <tr>
        <FORM NAME="Admin" METHOD="POST" ACTION="GoToForm.asp?Option=Admin">
      <td width="20%">
      </td>
      <td width="25%" align="right" bgcolor="#C0C0C0"><font face="Verdana"><b>Administration:</font></b>
      </td>
      <td width="25%" bgcolor="#C0C0C0"><font face="Verdana"><select name="cmdAdmin" size="1">
                                           <option selected value="Select an object to Administer">Select an object to Administer </option>
                                           <option value="RDBMS">RDBMS</option>
                                           <option value="Servers">Servers</option>
                                           <option value="Databases">Databases</option>
                                           <option value="Tables">Tables</option>
                                           <option value="Elements">Elements</option>
                                           <option value="Users">Users</option>
                                           <option value="Standard abbreviations">Standard abbreviations</option>
                                           <option value="Abbreviation rules">Abbreviation rules</option>
                                           <option value="Status list">Status list</option>
                                           <option value="Key word list">Key word list</option>
           </select>
           </font>
       </td>
       <td width="10%" bgcolor="#C0C0C0"><font face="Verdana"><input type="submit" value="Select" name="cmdAdmin"></font>
       </td>
       <td width="20%">
       </td>
          </FORM>
   </tr>
 </table>
</body>
</html>
