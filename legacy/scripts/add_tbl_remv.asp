<!--#INCLUDE FILE="../include/security.inc"-->
<%  '---------------- SAVE PRIMARY KEYS ---------------------
aryKeys = SPLIT(Request.QueryString("prkeys"),",")
set dictElmPkeys = CreateObject("Scripting.Dictionary")

'response.write prkeys
k=1
for i = 0 to UBOUND(aryKeys) - 1
   dictElmPkeys.Add k, aryKeys(i)
   'response.write k
   k=k+1
Next

%>
<%

session("EntryPoint") = "add_tbl_insrt"
session("altEntry") = "add_tbl_remv"
aryPick = SPLIT(Request.QueryString("savePicks"),",") 

'response.write(Request.QueryString("prkeys"))
'response.write(Request.QueryString("savePicks"))
'response.write(UBOUND(aryPick))

set dictElmPicks = Session("cart")
oldcount = dictElmPicks.count 

if oldcount = 1 then
   dictElmPicks.Remove(1)
   'dictElmPkeys.remove(1)
end if	
   
 For i=0 to UBOUND(aryPick) - 1 
   key = aryPick(i)
   key = key + 1
  'response.write key
   dictElmPicks.Remove(key)
   'response.write dictElmPkeys.item(key)
   dictElmPkeys.remove(key)
 Next
    
' REASSIGN keys to fill in empty key positions that were left by remove
  
 break1 = "oldkey"
 break2 = "newkey"
 
 oldkey = aryPick(0) + 2
 remkey = aryPick(0) + 1

 if remkey <> oldcount then  
  for i = UBOUND(aryPick) + 1 to oldcount  
  	 if oldkey <= oldcount then
	  'response.write break1
	  'response.write oldkey
	  newkey = oldkey - UBOUND(aryPick)
	  dictElmPicks.key(oldkey) = newkey
	  dictElmPkeys.key(oldkey) = newkey
	  'response.write break2
	  'response.write newkey
	  oldkey = oldkey + 1
     end if
  Next
end if
 
' SAVE elements in the cart  <--------------
set Session("cart") = dictElmPicks
set dictElmPicks = nothing

' SAVE primary keys in the cart  <--------------
set Session("prkeys") = dictElmPkeys
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
