<%@ page pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<%
String objectId=request.getParameter("objectId");
%> 
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Home</title>
    <style>
        
        #iframeLeft{
            width: 50%;
            height: 700px;
            float: left;
        }
        #iframeContent{
            width: 50%;
            height: 700px;
        }
    </style>
	
	<script>
	function closeWindow(){
		window.parent.close();
	}
	function submitValidate() 
	{
		
     var obj =document.getElementById("iframeLeft").contentWindow.document.getElementsByName("favorite");
	 var shipArray=[];
		 for(var i in obj){
			 if(obj[i].checked){
				 shipArray.push(obj[i].value);
			 }
		 }
		 if(shipArray==""||shipArray==null){
			alert("请选择适用船型！");
			return;
		}
		 
		
	 var obj =document.getElementById("iframeContent").contentWindow.document.getElementsByName("favorite");
	 var scopeArray=[];
		 for(var i in obj){
			 if(obj[i].checked){
				 scopeArray.push(obj[i].value);
			 }
		 }
		 if(scopeArray==""||scopeArray==null){
			alert("请选择适用范围！");
			return;
		}
		
		var shipScope = shipArray.toString()+";"+scopeArray.toString();
		
		if(confirm("是否确认提交？")){
			document.tableTasksFrom.action="csscSelection3.jsp?objectId=<%=objectId%>&shipScop="+shipScope;		
			document.tableTasksFrom.submit();
				
		}
	
	
	}
	</script>
<body>

<div>
    <form name="tableTasksFrom" id="tableTasksFrom" method="post"	class="registerform" onsubmit="return submitValidate();  " action="do_upload.jsp" target="_parent" ENCTYPE="multipart/form-data">
		<iframe id="iframeLeft" name="iframeLeft" frameborder="0" src="csscSelectionLeft.jsp?objectId=<%=objectId%>"></iframe>
		<iframe id="iframeContent" name="iframeContent" frameborder="0" src="csscSelectionRight.jsp?objectId=<%=objectId%>"></iframe>
	</form>
</div>
</body>

