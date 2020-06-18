<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>


<html>
<head> 
<script language="JavaScript" src="../common/scripts/emxUICore.js"></script> 

<script type="text/javascript" language="javascript">
	var contentFrame = findFrame(getTopWindow(), "content"),
		deskpanel = getTopWindow().document.getElementById('mydeskpanel'),
		rgdMyDesk = getTopWindow().document.getElementById('RGDMyDesk'),
		rgdMyDeskHidden = rgdMyDesk.style.display === 'none',
		desks = deskpanel.querySelector(".menu-content").querySelectorAll('div[style]');
	if (rgdMyDeskHidden) {
		for (var i = 0; i < desks.length; i++) { // hide all desks
			desks[i].style.display = 'none';
		}
		rgdMyDesk.style.display = 'block'; // show RGN desk
	}
	rgdMyDesk.querySelectorAll('li > a')[0].click(); // select template menu item
</script>

</head>
<body>
</body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
