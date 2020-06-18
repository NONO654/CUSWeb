<%@page import="com.matrixone.apps.program.ProgramCentralConstants"%>
<%@page import="java.lang.reflect.Method"%>
<%@page import="com.matrixone.apps.program.StatusReport"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%
	String sHeader 		= request.getParameter("header");	
	String sMethodName = request.getParameter("method");	
	MapList mlObjects = new MapList();
	MapList finalObjectList = new MapList();
	StatusReport report = (StatusReport)session.getAttribute("store");
	Method method = null;
	try{
		method = report.getClass().getMethod(sMethodName);
	}catch(Exception e) {
		e.printStackTrace();
	}
	mlObjects = (MapList)method.invoke(report);
	int mlObjectSize = mlObjects.size();
	for(int i = 0; i<mlObjectSize; i++){
		Map objectMap = (Map)mlObjects.get(i);
		if(!(finalObjectList.contains(objectMap))){
			finalObjectList.add(objectMap);
		}
	}
	
	session.putValue("objectList", finalObjectList);
	
	int iCount = finalObjectList.size();
	int iHeightTimeline = 0;
	
	if(iCount > 0) {
		iHeightTimeline = iCount * 30;
		iHeightTimeline += 60;
		if(iHeightTimeline < 180) {
			iHeightTimeline = 180;
		}
	}
	String localeString = context.getLocale().toString();
	String languageString = context.getLocale().getLanguage();
	String firstLetter = languageString.substring(0,1).toUpperCase();
	String remainingString = languageString.substring(1);
	languageString = firstLetter + remainingString;
%>

<html style="height:100%">
	<head>
		<style rel='stylesheet' type='text/css'>
			div.chartHeader {
				background-color	: #5f747d;			
				background			: -moz-linear-gradient(left,  #5f747d 0% , #7e929a 50%, #5f747d 100%);
				border				: 1pt solid #5f747d;				
				-moz-box-shadow		: 2px 2px 3px #aaa;
				box-shadow			: 2px 2px 3px #aaa;				
				color				: #FFFFFF;
				font-family			: Verdana, Arial, Helvetica, sans-serif;
				font-weight			: bold;
				height				: 20px;
				text-align			: center;	
				vertical-align		: middle;	
				width				: 100%;
				text-shadow			: #333333 1px 1px;
				font-size			: 10pt;
				margin-bottom		: 5px;
			}
		</style>
			
		<script type='text/javascript'>	
			function init() {

				var heightTimeline 	= <%=iHeightTimeline%>; 
				var heightTable 	= 310;
				var heightBody 		= 0;
				var widthBody 		= 0;
				var header			= '<%=sHeader%>';
				var languageString  = '<%=languageString%>';
				var localeString  	= '<%=localeString%>';
				if(window.innerHeight) 	{ heightBody = window.innerHeight;			widthBody = window.innerWidth - 19;		 	} 
				else 					{ heightBody = document.body.clientHeight;	widthBody = document.body.clientWidth - 19;	} 
				
				if((heightTimeline + heightTable) < heightBody) { 
					heightTable = heightBody - heightTimeline - 2; 
					if(header != null) {
						heightTable = heightTable - 27;
					}
					document.body.style.overflow = 'hidden';					
				} else {
					document.body.style.width = widthBody + "px";
				}

				var divTimeline	= document.getElementById("divTimeline");
				divTimeline.style.height = "100%";
				divTimeline.style.width = "100%";
				divTimeline.innerHTML 	= '<object id="timeline" type="text/html" data="../programcentral/gantt/emxGanttChart.jsp?mode=basic&viewName=Planned&ganttType=null&languageString=' + languageString + '&localeString=' + localeString + '" ' + 'width="100%" height="100%" style="padding:0px;margin:0px"></object>';
			}

		</script>
	</head>
	<body style="height:100%;margin:0;padding:0;overflow:auto;" onload="init()">
<% 	if(iCount > 0) { %>	
		<div id="divTimeline"></div>
<% 	} %>	
	</body>	
</html>
