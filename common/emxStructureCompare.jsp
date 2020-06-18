<%--  emxStructureCompare.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxStructureCompare.jsp.rca 1.5.3.2 Wed Oct 22 15:48:29 2008 przemek Experimental przemek $
--%>
 
<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<%
 String strTableName		 =	emxGetParameter(request, "table");
 String strAppendColumnsName =  emxGetParameter(request, "appendColumns");
 String sObjIds 			 = emxGetParameter(request, "objIDs");
 String isIndentedView 			 = emxGetParameter(request, "isIndentedView"); 
 if(strTableName == null){
     strTableName		    =	emxGetParameter(request, "selectedTable");
 }
 if(strAppendColumnsName == null){
	 strAppendColumnsName = "NULL";
 }
 String strObjectIds		=	emxGetParameter(request, "objectIds");
  
 String sObjId = "";
 String objectIdList = "";
   
 if (null != sObjIds)
 {	 
 	String[] objIdArr = sObjIds.split(",");
 	sObjId = objIdArr[1];
 	objectIdList = objIdArr[0] + "," + objIdArr[1];
 }
 
 String strRel				=	emxGetParameter(request, "relationship");
 String strDir				=	emxGetParameter(request, "direction"); 
 String strExpandProgram	=	emxGetParameter(request, "expandProgram");
 String strToolBar			  =	emxGetParameter(request, "toolbar");
 String strconnectionProgram  =	emxGetParameter(request, "connectionProgram");
 String sTimeStamp 			  = emxGetParameter(request, "SCTimeStamp");
 
 if ( strTableName == null )
     strTableName = "";
 if ( strRel == null )
     strRel = "";
 if ( strDir == null )
     strDir = "";
 if ( strExpandProgram == null )
     strExpandProgram = "";
 if ( strToolBar == null )
     strToolBar = "";
 if ( strconnectionProgram == null )
     strconnectionProgram = "";
 
 String strQueryString = request.getQueryString();
 
 if ( strQueryString == null )
 {
     strQueryString = "";
 }
 
String strQueryStringTemp = strQueryString;
if ( strQueryString.indexOf("&objectId=") != -1 )
 {
     strQueryStringTemp = strQueryString.replace("&objectId=","&ParentobjectId=");
 }
 
%> 

<html>
<head>
	<script type="text/javascript" language="JavaScript" src="scripts/emxUITableUtil.js"></script>
	<script type="text/javascript" language="JavaScript" src="scripts/emxUIStructureCompareUtils.js"></script>
	<script type="text/javascript" language="javascript" src="scripts/emxUIConstants.js"></script>
	<script type="text/javascript" language="JavaScript" src="scripts/emxUICore.js"></script>
	<script type="text/javascript" language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
	<script type="text/javascript" language="JavaScript" src="scripts/emxUIToolbar.js"></script>
	<script type="text/javascript" language="JavaScript" src="scripts/emxNavigatorHelp.js"></script>

	<script type="text/javascript">
        addStyleSheet("emxUIDefault");
		addStyleSheet("emxUIDOMLayout");       
		addStyleSheet("emxUIDialog");
		addStyleSheet("emxUIToolbar");
		addStyleSheet("emxUIMenu");
	</script>

	<script type="text/javascript">
		var tableName;
		var timeStamp;
		var objectIds;
		
		<%if(strTableName==null){
		%>
				tableName = getTopWindow().getWindowOpener().tableName;
	    	<% try{
	        %>
	            tableName!=null;
	        <%}catch(Exception ex){
	           	String sErrorMsg = "NullPointer Exception: " + ex.getMessage();
	        %>
	        	alert(<%=sErrorMsg%>);
	        <% }
	   	 }%>
		
			
		<%if(strObjectIds==null ){ 
		%>	
			objectIds =getTopWindow().getWindowOpener().arrObjectId;
		<%}
		
		%>
		
		 timeStamp=getTopWindow().getWindowOpener().timeStamp;
		 
		function resetPage()
		{
			var scTimeStamp = "<xss:encodeForJavaScript><%=sTimeStamp%></xss:encodeForJavaScript>";
			//var sbForm = findFrame(this, 'formStructureCompare');
			//sbForm.reset();
			document.location.href ="../common/emxStructureCompareCleanUpSession.jsp?scTimeStamp="+scTimeStamp;
		}

		function fireURL(){
			
		var table = "<%=XSSUtil.encodeForJavaScript(context, strTableName)%>";	
		var relation = "<%=XSSUtil.encodeForJavaScript(context, strRel)%>";		
		var strDir = "<%=XSSUtil.encodeForJavaScript(context, strDir)%>";
		var expProgram = "<%=XSSUtil.encodeForJavaScript(context, strExpandProgram)%>";
		var toolbar = "<%=XSSUtil.encodeForJavaScript(context, strToolBar)%>"; 
		var connProgram = "<%=XSSUtil.encodeForJavaScript(context, strconnectionProgram)%>"; 
		
		var objTo = parent.document.getElementById("to");
		var objFrom = parent.document.getElementById("from");
		
		var queryString = "<%=XSSUtil.encodeForJavaScript(context, strQueryStringTemp)%>";  
		
	    /*added for IR-036362V6R2011*/
		var appendColumns = "<xss:encodeForJavaScript><%=strAppendColumnsName%></xss:encodeForJavaScript>";
	    if(appendColumns !== "NULL"){
	    	queryString += "&appendColumns="+appendColumns;
	    }
	    
		/*end*/
	    
		var queryStringIndented = "";
	    if ( getTopWindow().getWindowOpener().urlParameters != null ){

	    	queryStringIndented = getTopWindow().getWindowOpener().urlParameters.value;
	    	
		    if ( queryStringIndented.indexOf("isIndentedView") != -1 )
		    {
		    	
		        isIndentedView = queryStringIndented.substr(queryStringIndented.indexOf("isIndentedView"));
		        isIndentedView = isIndentedView.substring(0,isIndentedView.indexOf("&"));
		        varIndView = isIndentedView.split("=");   
		        
		        if ( varIndView[1]!= null && varIndView[1] == "true" )
		        {  
		            if ( table == "" )
		            {
       		   			if ( queryStringIndented.indexOf("table") != -1 )
       		   			{
      		   				table = queryStringIndented.substr(queryStringIndented.indexOf("table")); 
		       				table = table.substring(0,table.indexOf("&"));
		       	            queryString +="&"+table; 
		       	        }
		            }else
		            {
		                queryString +="&table="+table; 
		            }
		            if ( relation == "" ) 
	                {
      		   			if ( queryStringIndented.indexOf("relationship") != -1 )
      		   			{
      		   				relation = queryStringIndented.substr(queryStringIndented.indexOf("relationship")); 
	       				    relation = relation.substring(0,relation.indexOf("&"));
	       	                queryString +="&"+relation;
	       	            }	
	                }else
	                {
	                   queryString +="&relationship="+relation;
	                }
	                
	                if ( expProgram == "" )
	                {
	                    if ( queryStringIndented.indexOf("expandProgram") != -1 )
	                    {
	                        expProgram = queryStringIndented.substr(queryStringIndented.indexOf("expandProgram")); 
	       				    expProgram = expProgram.substring(0,expProgram.indexOf("&"));
	                        queryString +="&"+expProgram;
	                    }      
	                }else 
	                {
	                   queryString +="&expandProgram="+expProgram;
	                }
	                if ( toolbar == "" )
	                {
	                    if ( queryStringIndented.indexOf("toolbar") != -1 )
	                    {
	                        toolbar = queryStringIndented.substr(queryStringIndented.indexOf("toolbar")); 
	       				    toolbar = toolbar.substring(0,toolbar.indexOf("&"));
	                        //queryString +="&"+toolbar;
	                    }      
	                }else
	                {
	                   queryString +="&toolbar="+toolbar; 
	                }
	                if ( connProgram == "" )
	                {
	                    if ( queryStringIndented.indexOf("connectionProgram") != -1 )
	                    {
	                        connProgram = queryStringIndented.substr(queryStringIndented.indexOf("connectionProgram")); 
	       				    connProgram = connProgram.substring(0,connProgram.indexOf("&"));
	                        queryString +="&"+connProgram;
	                    }
	                }else
	                {
	                     queryString +="&connectionProgram="+connProgram;
	                } 
	                //direction
	                var dir = "";
	                if(objTo && objFrom)
	                {
                		if(objTo.checked == true && objFrom.checked == true){	                		
                			dir = "both";
                		}
                		if(objTo.checked == true && objFrom.checked == false){	                		
                			dir = "to";
                		}
                		if(objTo.checked == false && objFrom.checked == true){	                		
                			dir = "from";
                		}
                	}else{
                		if ( strDir == "" ) 
		                {
	      		   			if ( queryStringIndented.indexOf("direction=") != -1 )
	      		   			{
	      		   				strDir = queryStringIndented.substr(queryStringIndented.indexOf("direction="));
		       				    strDir = strDir.substring(0,strDir.indexOf("&"));
		       	                dir = strDir;
		       	            }	
		                }else
		                {
		                   dir = strDir;
		                }
                	}
                	queryString +="&direction="+dir;	                
	                
	                  
		        } else{
		        	if ( table == "" )
		            {
       		   			if ( queryStringIndented.indexOf("table") != -1 )
       		   			{
       		   				table = queryStringIndented.substr(queryStringIndented.indexOf("table")); 
		       				table = table.substring(0,table.indexOf("&"));
		       	            queryString +="&"+table; 
		       	        }
		            }else
		            {
		                queryString +="&table="+table; 
		            }
		        }
		    }  
		}
	    
	    var incompleteParameters = false;
	    
	    if(table == "") {
	    	incompleteParameters = true;
	    	} 

    	if(relation == "" || dir == "") 
    	{
	    	 if(expProgram == "") 
	    	 {
	    		 incompleteParameters = true;  	 
	    	 }
	    } 

		if(incompleteParameters){
			alert(emxUIConstants.STR_DIALOG_CONFIG_ERROR_MSG);
			getTopWindow().closeWindow();
		}
		
		var sTimeStamp = "<%=XSSUtil.encodeForJavaScript(context, sTimeStamp)%>";
		
		var url = "emxStructureCompareCriteria.jsp?structureCompareTimeStamp"+sTimeStamp+"&timeStamp="+timeStamp+"&objectIds="+"<%=XSSUtil.encodeForURL(context, objectIdList)%>";
 			url += "&"+queryString;
			var sbForm = findFrame(this, 'formStructureCompare');
			
			if(sbForm){
				sbForm.location = url;   
				return false;
			}
		  	else return true;
		}		
		turnOnProgress();		
		
		
	</script>
</head>	



<%--
	1. 	Get table from request, if not get from getTopWindow().getWindowOpener().tableName;
		if you dont get, throw an error message
	2.  similar task to be done on object ids. But, no error.
	3. No need to use the time stamp here. If it is required at later stages, we create and send it.
	3. if object id's are got here, then populate the text boxes with the names accordingly.-Done!!!
	4. Populate 3rd text box bug fix-Fixed

 --%>
<%
	String strLanguage = request.getHeader("Accept-Language");
	String helpDone = UINavigatorUtil.getI18nString(
	        			"emxFramework.FreezePane.Action.Apply",
	        			"emxFrameworkStringResource", strLanguage);
	String helpCancel = UINavigatorUtil.getI18nString(
	        			"emxFramework.FreezePane.Action.Reset",
	        			"emxFrameworkStringResource", strLanguage);
	
	String sHelpMarker = "emxhelp_structurecomparedialog";//modify the string based on FSP after finalization
	//Modified for Bug - 344115
	String toolbarURL = "PrinterFriendly=false&export=false&HelpMarker="+sHelpMarker;
%>
<body id="sbCompareDialog" onload = "turnOffProgress()">
	<!--  Header -->	
    <div id="pageHeadDiv">	
				
		<table border="0" cellspacing="0" cellpadding="0" width="98%" align="center">
			<tr>
				<td >
					<!-- Modified for Bug - 344115 -->
					<script language="JavaScript" src="emxToolbarJavaScript.jsp?<%= toolbarURL %>" type="text/javascript"></script>
					<div  class="toolbar-container" id="divToolbarContainer">
						<div id="divToolbar" class="toolbar-frame"></div>
					</div>
				</td>
			</tr>
		</table>
		
		<table >
			<tr>
				<td><img src="images/utilSpacer.gif" width="1" height="5" alt="" /></td>
			</tr>
		</table>
	</div>
	<!--  Body -->
	<div id="divPageBody">
		<iframe	name="formStructureCompare"
						src=javascript:parent.fireURL()
						height="100%"
						width="100%"										
						border="0"
						frameborder="no"
						marginwidth="0"
						marginheight="0">
		</iframe>
	</div>
	<!--  Footer -->
	<div id="divPageFoot">
		<table >
			<tr>
				<td align="right">
					<table >
						<tr>
							<td><a href="javascript:onDone()" class="button"><button class="btn-primary" type="button"><xss:encodeForHTML><%=helpDone%></xss:encodeForHTML></button></a></td>
							<td>&nbsp;&nbsp;</td>
							<td>
								<div id="cancelImage"><a href="javascript:resetPage()"><button class="btn-default" type="button"><xss:encodeForHTML><%=helpCancel%></xss:encodeForHTML></button></a></div>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
</body>
</html>
