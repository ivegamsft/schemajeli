<% 
Response.Buffer = true
session.Timeout=60
%>
<!--#INCLUDE FILE="../include/security.inc"-->
<!--#INCLUDE FILE="../include/colors.inc"-->
<%
Dim strUAuth
Dim strMenuSel         'Holds the menu selected
Dim aryMenuOption()    'Holds the menu option for each menu
Dim strHelpText        'Holds the help text for each screen
Dim iOptionCount       'Count the options

strMenuSel = Request.QueryString("Menu")    'Gets the menu requested

Select Case strMenuSel
   Case "Search"
      strHelpText="select an item to search for from the selection box."
      ReDim aryMenuOption(4,1)
      aryMenuOption(0,0)="search_dbs.asp"
      aryMenuOption(0,1)="Databases"
      aryMenuOption(1,0)="search_tbls.asp"
      aryMenuOption(1,1)="Tables"
      aryMenuOption(2,0)="search_elem.asp"
      aryMenuOption(2,1)="Elements"
      aryMenuOption(3,0)="search_elem_kywds.asp"
      aryMenuOption(3,1)="Element Key Words"
      aryMenuOption(4,0)="search_stdabbr.asp"
      aryMenuOption(4,1)="Standard Abbreviations"

   Case "Reports"
      strHelpText="Select a report from the selection box."
      ReDim aryMenuOption(3,1)
      aryMenuOption(0,0)="rpt_main.asp"
      aryMenuOption(0,1)="Relational Object Report"           
      aryMenuOption(1,0)="query_result.asp?RelObject=ClassWord"
      aryMenuOption(1,1)="View class words"      
      aryMenuOption(2,0)="query_result.asp?RelObject=Server"
      aryMenuOption(2,1)="Server report"
	  aryMenuOption(3,0)="rpt_ddl.asp"
	  aryMenuOption(3,1)="Generate DDL"
      'aryMenuOption(4,0)="db_rpt"
      'aryMenuOption(4,1)="Database report"

     Case "Maintain"
      strHelpText="Select an item to add or maintain from the selection box."
      ReDim aryMenuOption(3,1)
      aryMenuOption(0,0)="add_db_nme.asp"
      aryMenuOption(0,1)="Maintain/Add Database"           
      aryMenuOption(1,0)="add_tbl_nme.asp"
      aryMenuOption(1,1)="Maintain/Add Table"
      aryMenuOption(2,0)="add_elem_nme.asp?Option=Maintain"
      aryMenuOption(2,1)="Maintain Element"
      aryMenuOption(3,0)="add_elem_nme.asp"
      aryMenuOption(3,1)="Add Element"

   Case "Administration"
      strHelpText="Select an item to Administer from the selection box."
      ReDim aryMenuOption(4,1)
      aryMenuOption(0,0)="add_server.asp"
      aryMenuOption(0,1)="Servers"
      aryMenuOption(1,0)="add_stdabbr.asp"
      aryMenuOption(1,1)="Standard Abbreviations"
      aryMenuOption(2,0)="add_user.asp"
      aryMenuOption(2,1)="Users"
      aryMenuOption(3,0)="copy_tbl.asp"
      aryMenuOption(3,1)="Copy Table"
      aryMenuOption(4,0)="status_move.asp"
      aryMenuOption(4,1)="Status Move"

Case "Help"
      strHelpText="Select a help topic from the selection box."
      ReDim aryMenuOption(8,1)
      aryMenuOption(0,0)="HowTo"
      aryMenuOption(0,1)="Using the repository"
      aryMenuOption(1,0)="Reports"
      aryMenuOption(1,1)="Generating Reports"
      aryMenuOption(2,0)="Search"
      aryMenuOption(2,1)="Searching for objects"
      aryMenuOption(3,0)="Maintain"
      aryMenuOption(3,1)="Maintaining Objects"
      aryMenuOption(4,0)="Admin"
      aryMenuOption(4,1)="Adminstering Objects"
      aryMenuOption(5,0)="welcome.asp"
      aryMenuOption(5,1)="Return to main page"
      aryMenuOption(6,0)="Codes"
      aryMenuOption(6,1)="View Codes"
      aryMenuOption(7,0)="Procs"
      aryMenuOption(7,1)="Procedures"
      aryMenuOption(8,0)="Support"
      aryMenuOption(8,1)="Support"

   Case Else 
      strHelpText=""
    End Select
%>
<html>
<head>
<title>Navigation Menu
</title>
<script LANGUAGE="VBSCRIPT">
Sub cmdGo_OnClick()
   Dim objCurForm
   Set objCurForm = Document.Forms.Item(0)

   If objCurForm.Item(0).SelectedIndex=0 then
      msgBox "Please select an item.",,"Error"
   ElseIf objCurForm.CurMenu.Value = "Help" Then
     Select Case objCurForm.cboHelp.Value
     Case "HowTo"
         window.open "../help/hlp_howTo.htm","ReportHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case "Reports"
         window.open "../help/hlp_reports.htm","ReportHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case "Search"
         window.open "../help/hlp_search.htm","SearchHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case "Maintain"
	    window.open "../help/hlp_maintain.htm","MaintaintHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case "Admin"
        window.open "../help/hlp_admin.htm","AdminHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case "Support"
        window.open "../help/hlp_support.htm","SupportHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case "Codes"
        window.open "../help/hlp_codes.htm","CodesHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case "Procs"
        window.open "../help/hlp_procs.htm","ProcsHelp", "toolbar=no, left=420, top=30, resizeable=yes, scrollbars=yes, width=350, height=500, maximize=no, menubar=no, systemMenu=no" 
     Case Else
        objCurForm.Submit
     End Select
   Else
      objCurForm.Submit
  End If
End Sub 

Sub ArrowOn(imgName)
    document.images(imgName).src = "../images/arrow.gif"
End Sub

Sub ArrowOff(imgName)
    document.images(imgName).src = "../images/blank17x13.gif"
End Sub

</script>
<!--Begin menu here-->
<style>
.reg        {color:rgb(204,204,153); text-decoration: none; font-weight:bold}
a.reg:Hover {color:rgb(255,255,204); font-weight:bold}
.current    {color:white; font-weight:bold}
.exit       {color:rgb(0,51,153); font-weight:bold}
.exit:Hover {color:red; font-weight:bold}

.special    {
              font-size: xx-small;
            }
            
A:link      {color:rgb(204,204,153); text-decoration:none;}
A:visited   {color:rgb(204,204,153); text-decoration:none;} 
A:active    {color:rgb(204,204,153); text-decoration:none;}
</style>
</head>
<body BGCOLOR="<%=strMenuBackColor%>" LINK="<%=strLinkColor%>" ALINK="<%=strALinkColor%>" VLINK="<%=strVLinkColor%>" text="<%=strTextColor%>" marginwidth="0" marginheight="0" leftmargin="0" topmargin="0">
<form NAME="<%=strMenuSel%>" METHOD="POST" ACTION="GoToForm.asp?Option=<%=strMenuSel%>" target="main">
<table BORDER="0" WIDTH="100%" HEIGHT="75" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuHeaderColor%>">
  <tr>
  <td WIDTH="90%" HEIGHT="90%" ALIGN="center" VALIGN="bottom"><font FACE="Tahoma" SIZE="2" COLOR="<%=strMenuTextColor%>">
  <b><%=TRIM(Session("UserName"))%> is currently logged in to the Navistar Repository System</b><br>
  Use the navigation menu below to move around the repository.
  </font>
  </td>
  <td WIDTH="10%" VALIGN="bottom" ALIGN="right" ROWSPAN="2">
  <a HREF="http://wwwnio.navistar.com/edw" TARGET="_blank">
  <img SRC="../images/edwlogo.gif" WIDTH="102" HEIGHT="89" BORDER="0" ALT="Enterprise Data Warehouse" HSPACE="0" VSPACE="0" NAME="logo"> 
  </a>
  </td>
  </tr>
  <tr>
  <td WIDTH="90%" HEIGHT="5%" BGCOLOR="<%=strMenuBackColor%>" ALIGN="center" VALIGN="middle">
  <table BORDER="0" WIDTH="100%" HEIGHT="100%" CELLSPACING="0" CELLPADDING="0" BGCOLOR="<%=strMenuBackColor%>">
  <tr>
  <td WIDTH="5%" BGCOLOR="<%=strMenuBackColor%>" ALIGN="center" VALIGN="bottom">
<!--Begin custom menu-->
<% If strMenuSel = "Search" then %>   
     <font face="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
     <img SRC="../images/arrow.gif" BORDER="0" HSPACE="0" VSPACE="0" WIDTH="17" HEIGHT="13">
     <a CLASS="current" TITLE="Select an object to search for from the selection box">Search</a>|
     </font>
<%   Else  %>
     <font FACE="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
     <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="search" WIDTH="17" HEIGHT="13">      
     <a CLASS="reg" HREF="nav_menu.asp?Menu=Search" TITLE="Click to search for objects" onMouseOver="ArrowOn(1)" onMouseOut="ArrowOff(1)">
     Search</a>|
     </font>
<% End If %>

<% If strMenuSel = "Reports" then %>   
     <font face="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
     <img SRC="../images/arrow.gif" WIDTH="17" HEIGHT="13">
     <a CLASS="current" TITLE="Select a report option from the selection box">Reports</a>|
     </font>
<% Else  %>
     <font FACE="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
     <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="reports" WIDTH="17" HEIGHT="13">      
     <a CLASS="reg" HREF="nav_menu.asp?Menu=Reports" TITLE="Click to report on an object" onMouseOver="ArrowOn(2)" onMouseOut="ArrowOff(2)">
       Reports</a>|
     </font>
<% End If

   If Session("UAuth")="MNTN" Then
      If strMenuSel = "Maintain" then %>   
         <font face="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
         <img SRC="../images/arrow.gif" WIDTH="17" HEIGHT="13">
         <a CLASS="current" TITLE="Select an object to maintain from the selection list">Maintain</a>|
         </font>
<%    Else  %>
         <font FACE="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
         <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="maintain" WIDTH="17" HEIGHT="13">      
         <a CLASS="reg" HREF="nav_menu.asp?Menu=Maintain" TITLE="Click to maintain objects" onMouseOver="ArrowOn(3)" onMouseOut="ArrowOff(3)">
           Maintain</a>|
         </font>
         <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="spacer" WIDTH="17" HEIGHT="13">
<%    End If 
   Else 
      If Session("UAuth")="ADMN" Then
         If strMenuSel = "Maintain" then %>   
            <font face="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
            <img SRC="../images/arrow.gif" WIDTH="17" HEIGHT="13"><a CLASS="current" TITLE="Select an object to maintain from the selection list">Maintain</a>|
            </font>
<%       Else  %>
            <font FACE="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
            <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="maintain" WIDTH="17" HEIGHT="13">      
            <a CLASS="reg" HREF="nav_menu.asp?Menu=Maintain" TITLE="Click to maintain objects" onMouseOver="ArrowOn(3)" onMouseOut="ArrowOff(3)">
             Maintain</a>|
            </font>
<%       End If 

         If strMenuSel = "Administration" then %>   
             <font face="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
             <img SRC="../images/arrow.gif" WIDTH="17" HEIGHT="13"><a CLASS="current" TITLE="Select an adminstrative function from the selection box">Administration</a>|
             </font>
<%       Else  %>
             <font FACE="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
             <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="admin" ID="admin" WIDTH="17" HEIGHT="13">      
             <a CLASS="reg" HREF="nav_menu.asp?Menu=Administration" TITLE="Click for the adminstration menu" onMouseOver="ArrowOn(4)" onMouseOut="ArrowOff(4)">
             Administration</a>|
             </font>
<%       End If 
      Else %> 
      <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="spacer2" WIDTH="17" HEIGHT="13">
      <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="spacer3" WIDTH="17" HEIGHT="13">
<%    End if
   End If

   If strMenuSel = "Help" then %>   
    <font face="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
    <img SRC="../images/arrow.gif" WIDTH="17" HEIGHT="13">
    <a CLASS="current" TITLE="Select a help topic from the selection box">Help</a>|
    </font>
<% Else  %>
    <font FACE="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
    <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="help" WIDTH="17" HEIGHT="13">      
    <a CLASS="reg" HREF="nav_menu.asp?Menu=Help" TITLE="Click for the help menu" onMouseOver="ArrowOn(5)" onMouseOut="ArrowOff(5)">
     Help</a>|
    </font>
<% End if%> 
    <font FACE="Verdana" size="1" COLOR="<%=strMenuTextColor%>">
    <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="exit" WIDTH="17" HEIGHT="13">      
    <a CLASS="exit" HREF="exit.asp" TARGET="_top" TITLE="Exit the Navistar Repository" onMouseOver="ArrowOn(6)" onMouseOut="ArrowOff(6)">
     Exit</a>|
     <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="exitspace" WIDTH="17" HEIGHT="13">
     <img SRC="../images/blank17x13.gif" BORDER="0" HSPACE="0" VSPACE="0" NAME="exitspace2" WIDTH="17" HEIGHT="13">
    </font>
    <img SRC="../images/arrow.gif" WIDTH="17" HEIGHT="13">
    <select Class="special" NAME="cbo<%=strMenuSel%>" OnChange="cmdGo_OnClick">
                                   <option SELECTED>--------Select an Item--------</option>
                                   <% For iOptionCount = 0 to UBOUND(aryMenuOption)%>
                                   <option VALUE="<%= aryMenuOption(iOptionCount,0)%>">
      				                  <%= aryMenuOption(iOptionCount,1)%></option>
									  <%Next%>
	                                   </select>
     <input Class="special" TYPE="button" NAME="cmdGo" VALUE="Go" Class="Special">
     <input TYPE="HIDDEN" NAME="CurMenu" VALUE="<%=strMenuSel%>">
     </form>
     </td>
</tr>
</table>
</td>
</tr>
</table>
</body>
</html>
