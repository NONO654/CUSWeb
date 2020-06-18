<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
 <%
	String objectId = request.getParameter("objectId");
 %>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home</title>
    <style>
        #iframeTop{
            width: 100%;
            height: 400px;
        }
        #iframeLeft{
            width: 62%;
            height: 360px;
            float: left;
			margin-top:0px;
			margin:0;
			padding:0;
        }
        #iframeContent{
            width: 36%;
            height: 360px;
			float: left;
			margin-top:-10px;
			
        }
	
		
    </style>
<body>
<div>
    <iframe id="iframeLeft" name="iframeLeft" scrolling="yes" frameborder="0" src="csscBOMList.jsp?objectId=<%=objectId%>"></iframe>
   
    <iframe id="iframeContent" name="iframeContent" scrolling="yes" frameborder="0" src="csscParameterView.jsp?objectId=<%=objectId%>"></iframe>
</div>
</body>
</html>
