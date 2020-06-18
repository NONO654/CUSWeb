<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="styles/emxUIDefault.css"/>
<link rel="stylesheet" type="text/css" href="styles/scrollpane/jquery.jscrollpane.css"/>

<script type="text/javascript" src="scripts/jquery-latest.js"></script>
<script type="text/javascript" src="scripts/scrollpane/jquery.jscrollpane.min.js"></script>

<script type="text/javascript" src="scripts/emxChannelUI.js"></script>
<script type="text/javascript">
$(document).ready(function ()		
        {
		//get channels
		
		var url= getBaseURL();
		var dataURI = url+"/rest/channels";
		$.ajax({ 
					url: dataURI,
                    dataType: 'json',
                    cache: false
                  }).done(function( data ) {
                        processChannelData(data);
                  });

			
        });</script>

</head>
<body>
<div class="hp-container"></div>
</body>
</html>
