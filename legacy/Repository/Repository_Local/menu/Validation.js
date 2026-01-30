
function validateNumber() {
	// Get the source element.
	var el = event.srcElement;
	alert(el.name);
	alert(el.parentElement.parentElement.parentElement.parentElement.id);
	alert(el.parentElement.parentElement.rowIndex);
	alert(document.all("Sunday")(0).value);
	
	//Get the row (tag <tr>) that this element resides
	var tr=el.parentElement.parentElement;
	//Get the table that this element resides (tag <Table>)
	var table=tr.parentElement.parentElement;
	
	//Determine the index of this project
	if	(table.id=="Billable")
		var index=parseInt(tr.rowIndex)-1;
	else 
		var index=parseInt(tr.rowIndex)+3;
	
	alert(index);
	// Valid numbers
	event.returnValue = true;

	if (el.value>24.0) {
		alert("Your working hours can not be greater than 24!");
		event.returnValue = false;
	};
};

