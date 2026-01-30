<% Response.buffer = True %>
<%'<!--#INCLUDE FILE="../include/security.inc"-->
%>
<script language = "JavaScript">
<!-- hide

// initialize the value of "browser"
var browser = "oldAndInTheWay";
var bName = navigator.appName;
var bVersion = parseInt(navigator.appVersion);

// check for Netscape
if (bName == "Netscape") {
  browser = "ns" + bVersion;
} else {
  // check for MSIE
  if (bName == "Microsoft Internet Explorer") {
    if (bVersion >= 4) {
      browser = "ie" + bVersion;
    } else {
      browser = "ie3";
    }
  }
}

// -->
</script>