<!--#INCLUDE FILE="../include/security.inc"-->
<%
'Request.QueryString("savePicks")

session("EntryPoint") = "add_tbl_insrt"

'response.write(session("InsrtLoc"))

aryPick = SPLIT(Request.QueryString("savePicks"),",") 

' response.write(UBOUND(aryPick))

if IsObject(Session("cart")) then
   set dictElmPicks = Session("cart")
   set dictElmNames = Session("names")
   set dictElmPkeys = Session("prkeys") 
   idxstart = dictElmPicks.count + 1
   ' response.write idxstart
else 
   set dictElmNames = CreateObject("Scripting.Dictionary") 
   set dictElmPkeys = CreateObject("Scripting.Dictionary")
   set dictElmPicks = CreateObject("Scripting.Dictionary")
   idxstart=0
End if

'----------------------------------------------------------------------
'CHECK FOR DUPLICATE selectins against existing elements
'----------------------------------------------------------------------
'for each key in dictElmNames
'  response.write dictElmNames.item(key) 
'next

dupFound="n"
dups=0

Set rs = session("rs") 
if session("elmExist") = "y" then
  for i=0 to UBOUND(aryPick) - 1
    rowId = aryPick(i)
    SQL = "SELECT elmt_dict_nme FROM irma04_elmt_vrsn" 
    SQL = SQL & " WHERE rowid= '" & rowId & "' "
    rs.open(SQL)  
   for k=1 to dictElmNames.count 
      if rs.Fields(0).Value = dictElmNames.item(k) then
          dupFound = "y"
		  'response.write dupFound
      end if
   Next
  rs.close
 Next
end if

'-------------------------------------------------
'Check for duplicate selections among current picks
'-------------------------------------------------
indx=(UBOUND(aryPick))
dim aryElm()
redim preserve aryElm(indx)

for i=0 to UBOUND(aryPick) - 1
    rowId = aryPick(i)
    SQL = "SELECT elmt_dict_nme FROM irma04_elmt_vrsn" 
    SQL = SQL & " WHERE rowid= '" & rowId & "' "
    rs.open(SQL)  
	aryElm(i)=rs.Fields(0).Value
    rs.close
Next

for i=0 to UBOUND(aryElm) - 1
  dupcnt=0
  for k=0 to UBOUND(aryElm) - 1
     if aryElm(i) = aryElm(k) then
	    dupcnt = dupcnt + 1
	 end if	
	 if dupcnt > 1 then
       'response.write dupcnt
       dupFound = "y" 
     end if   
  Next	 
  'response.write aryElm(i)
Next

session("dupExist") = dupFound
if dupFound = "y" then
   response.redirect ("add_tbl_errors.asp")
end if   

'----------------------------------------------------------------

iLoc = session("InsrtLoc")
upbound = dictElmPicks.Count	

'iLoc is being set to 9999 if insertion point wasn't checked off

if iLoc = "9999" then	
   For i=0 to UBOUND(aryPick) - 1
     'response.write aryPick(i)
	 'response.write upbound
	 upbound = upbound + 1
     descr = aryPick(i) 
     dictElmPicks.Add upbound, descr
     dictElmPkeys.Add upbound, ""
    Next
else
   ' REASSIGN keys to make room for a new element
   for i = iLoc to dictElmPicks.Count - 2
   	  dictElmPicks.key(upbound) = upbound + UBOUND(aryPick)
 	  dictElmPkeys.key(upbound) = upbound + UBOUND(aryPick)
	  upbound = upbound - 1
	  'response.write UBOUND(aryPick)
	Next
    for i=0 to UBOUND(aryPick) - 1
       descr = aryPick(i) 
       key = iLoc + 2 + i
	   dictElmPicks.Add key, descr
	   dictElmPkeys.Add key, ""
	   'response.write key
       'response.write dictElmPicks.item(key)
     Next
End if 



session("InsrtLoc") = "nothing"
   
' SAVE additional elements in cart  <--------------
set Session("cart") = dictElmPicks
set Session("prkeys") = dictElmPkeys

set dictElmPicks = nothing
set dictElmNames = nothing
set dictElmPkeys = nothing

 'for each key in dictElmPicks
 '   response.write dictElmPicks.item(key) 
 'next
%>

<%response.redirect ("add_tbl.asp")
%>

</P>
</BODY>
</HTML>
