
	// Customize default NavBar menu color - bgColor, fontColor, mouseoverColor
	setDefaultNavBarMenuColor("#6699CC", "white", "red");
	
	//***** Add NavBar menus *****
	addNavBarMenu("Technium", "Home Pages", "","");
	addNavBarSubMenu("Technium","Technium Homepage","http://www.technium.com");
	addNavBarSubMenu("Technium","Timesheet Homepage","/Timesheet/DataEntry.asp");
	
	addNavBarMenu("DataEntry", "Data Entry", "","");
	addNavBarSubMenu("DataEntry","Enter Weekly Timesheet","/Timesheet/DataEntry.asp");
 
	addNavBarMenu("Report", "Timesheet Report", "","");
	addNavBarSubMenu("Report","Weekly Report","/Timesheet/Weekly.asp");
	addNavBarSubMenu("Report","Semi-Monthly Report","/Timesheet/SemiMonthly.asp");
	addNavBarSubMenu("Report","Customized Report","/Timesheet/CustomReport.asp");
	
	addNavBarMenu("Profile", "Personal Profile", "","");
	addNavBarSubMenu("Profile","Edit Personal Information","/Timesheet/Profile.asp");

	addNavBarMenu("Search", "Search", "","");
	addNavBarSubMenu("Search", "Find a Technium Employee", "/Timesheet/SearchPeople.asp");

	addNavBarMenu("Accounting", "Accounting Use Only", "","");
	addNavBarSubMenu("Accounting", "Timesheet Administration", "/Timesheet/Accounting.asp");
	addNavBarSubMenu("Accounting", "Send Notification Emails", "/Timesheet/Emails.asp");



