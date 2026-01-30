<!--#INCLUDE FILE="../include/security.inc"-->
<%  '---------------- Retrieve PRIMARY KEYS ---------------------

aryKeys = SPLIT(Request.QueryString("prkeys"),",")
set dictElmPkeys = CreateObject("Scripting.Dictionary")

k=1
for i = 0 to UBOUND(aryKeys) - 1
   dictElmPkeys.Add k, aryKeys(i)
   'response.write aryKeys(i)
   k=k+1
Next

set aryKeys = nothing
'------- Retrieve Insert location -------------------------
iLoc = Request.QueryString("SavLoc") 

%>
<%

session("EntryPoint") = "add_tbl_insrt"
session("altEntry") = "add_tbl_move"
aryPick = SPLIT(Request.QueryString("savePicks"),",") 

dim elmPicks() 
indx = UBOUND(aryPick)
REDIM preserve elmPicks(indx) 
dim keyPicks()
REDIM preserve keyPicks(indx) 

'response.write(Request.QueryString("prkeys"))
'response.write(Request.QueryString("savePicks"))
'response.write(UBOUND(aryPick))

set dictElmPicks = Session("cart")

'  1-based
oldcount = dictElmPicks.count 

'--- Remove items that need to be moved
 For i=0 to UBOUND(aryPick) - 1 
   key = aryPick(i)
   key = key + 1
   elmPicks(i) =  dictElmPicks.Item(key)
   keyPicks(i) = dictElmPkeys.Item(key)
   dictElmPicks.Remove(key)
   dictElmPkeys.Remove(key)
 Next
    
'-- REASSIGN keys to fill in empty key positions that were
'-- left by remove
  
 oldkey = aryPick(0) + UBOUND(aryPick) + 1
 remkey = aryPick(0) + 1
 
 for i = oldkey to oldcount  
     newkey = oldkey - UBOUND(aryPick)
	 dictElmPicks.key(oldkey) = newkey
	 dictElmPkeys.key(oldkey) = newkey
	 oldkey = oldkey + 1
  Next

upbound = dictElmPicks.Count	

'---Adjust input location if items were removed
indx = UBOUND(aryPick)
if aryPick(indx-1) < iLoc then
     'response.write " aryPick(indx-1)="
     'response.write aryPick(indx-1)
     'response.write " iLoc ="
     'response.write iLoc
  iLoc = iLoc - UBOUND(aryPick)
end if	 
 
'--- Reassign keys of elements to make room for the insertion  
'        ins.loc to tot. items
 for i = iLoc to upbound - 2 
   dictElmPicks.key(upbound) = upbound + UBOUND(aryPick)
   dictElmPkeys.key(upbound) = upbound + UBOUND(aryPick)
   
   'response.write "key: "
   'response.write upbound + UBOUND(aryPick)
      
   upbound = upbound - 1
 Next
 
'--- Insert elements that need to be moved
for i=0 to UBOUND(aryPick) - 1
   descr = elmPicks(i) 
   keydescr = keyPicks(i)
   key = iLoc + 2 + i
   if dictElmPicks.exists(key) then
      dictElmPicks.remove(key)
	  dictElmPkeys.remove(key)
   end if	
    
   dictElmPicks.Add key, descr
   dictElmPkeys.Add key, keydescr
   'response.write keydescr
Next

'for i=1 to 7
'  response.write " "
'  response.write i  
'  response.write " "
'  response.write dictElmPicks.item(i)
'Next

 
' SAVE elements in the cart  <--------------
set Session("cart") = dictElmPicks
set dictElmPicks = nothing

' SAVE primary keys in the cart  <--------------
set Session("prkeys") = dictElmPkeys
set dictElmPkeys = nothing
 'for each key in dictElmPicks
 '   response.write dictElmPicks.item(key) 
' next
%>

<% '------------ SAVE TABLE DESCRIPTION ----------------- 
   
aryTblDesc = SPLIT(Request.Form("tbldesc"),Chr(10))
Set obj1Descr = CreateObject("Scripting.Dictionary")

for i=0 to UBOUND(aryTblDesc)
   obj1Descr.Add i, aryTblDesc(i)
Next 

set session("descrLines") = obj1Descr
set objlDescr = nothing

'--------- SAVE DATABASE NAME ---------------------------
session("dbname") = Request.Form("DBname")

%> 

<%response.redirect ("add_tbl.asp")
%>

</p>
</body>
</html>
