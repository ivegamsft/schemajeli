
FUNCTION ValidTblChars(NAME)
DIM aryForbiddenChars(30)
DIM iCount

ValidChar = "True"
	aryForbiddenChars(0)= "!"
	aryForbiddenChars(1)= "@"
	aryForbiddenChars(2)= "#"
	aryForbiddenChars(3)= "$"
	aryForbiddenChars(4)= "%"
	aryForbiddenChars(5)= "^"
	aryForbiddenChars(6)= "&"
	aryForbiddenChars(7)= "*"
	aryForbiddenChars(8)= "("
	aryForbiddenChars(9)= ")"
	aryForbiddenChars(10)= "["
	aryForbiddenChars(11)= "{"
	aryForbiddenChars(12)= "]"
	aryForbiddenChars(13)= "}"
	aryForbiddenChars(14)= chr(34)
	aryForbiddenChars(15)= "'"
	aryForbiddenChars(16)= ";"
	aryForbiddenChars(17)= "\"
	aryForbiddenChars(18)= "|"
	aryForbiddenChars(19)= ","
	aryForbiddenChars(20)= ","
	aryForbiddenChars(21)= "."
	aryForbiddenChars(22)= ">"
	aryForbiddenChars(23)= "/"
	aryForbiddenChars(24)= "?"
	aryForbiddenChars(25)= "`"
	aryForbiddenChars(26)= "~"
	aryForbiddenChars(27)= "-"
	aryForbiddenChars(28)= "="
	aryForbiddenChars(29)= "+"
    aryForbiddenChars(30)= chr(32) & chr(32)

For iCOUNT = 0 to UBOUND(aryForbiddenChars)
    If InStr(1,NAME,aryForbiddenChars(iCOUNT)) THEN
        ValidTblChars=aryForbiddenChars(iCOUNT)
        Exit For
	else
	    ValidTblChars="True"
	End if
Next
END FUNCTION

