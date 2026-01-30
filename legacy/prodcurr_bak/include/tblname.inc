<%
<!--#INCLUDE FILE="../include/ASCCodes.inc"-->
'TBLNAME.INC

PUBLIC FUNCTION ParseName(NAME)
'This function will validate a new table name

error=False

If Len(NAME) > 18 Then
   errortxt="Table Name exceeds 18 characters"
   error=True
End If

'Return first 2 characters of table name and check against the 
'ASC Codes table located in ASCCodes.inc file.

if !ValidASC(NAME.substr(1,2))
   errortxt="First 2 characters have to be an Application System Code"
   error=True
End If

if !ValidASC(NAME.substr(1,3))
   errortxt="Third character has to be P"
   error=True
End If
  
if NAME.substr(3,1) != "T"
   errortxt="Third character has to be T"
   error=True
End If

If !IsNumeric(NAME.substr(5,3) Then
   errortxt="5th, 6th and 7th characters have to be numeric"
   error=True
End If

If NAME.substr(8,1) != "_"
   errortxt="8th character has to be an underscore"
   error=True
End If

END FUNCTION

%>
