<%--
  LogicalFeatureDeleteProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>
<%@page import="java.util.HashSet"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import = "java.util.Enumeration" %>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
    

<%
String action = "";
String msg = "";
String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
String strMode = emxGetParameter(request,"mode");
String strLanguage = context.getSession().getLanguage();
String UnsavedMarkUp = EnoviaResourceBundle.getProperty(context,"Configuration","emxFeature.Alert.UnsavedMarkUp",strLanguage);
String portalCmdName = (String)emxGetParameter(request, "portalCmdName");
System.out.println(portalCmdName);

if(null!=strMode && strMode.equalsIgnoreCase("deleteMF")){
	try{
		String OIDsToDelete = emxGetParameter(request,"OIDsToDelete");
        if(OIDsToDelete!=null){
	        java.util.StringTokenizer stTk = new java.util.StringTokenizer(OIDsToDelete,"[,],,");
	        StringList sLOIDsToDelete = new StringList();
	        while(stTk.hasMoreElements())
	        {
	        	sLOIDsToDelete.addElement(stTk.nextToken().toString());
	        }
	        ManufacturingFeature.deleteObject(context, sLOIDsToDelete);               
            action = "removeandrefresh";
        	out.println("action=");
        	out.println(action);
        	out.println(",");
        	out.println("msg=");
        	out.println(msg);
        	out.println(";");	            
        }    		
    }catch(Exception e){
        msg = e.toString();   
		if (msg!=null && msg.indexOf("Check trigger blocked event")>= 0) {
			action = "checkTrigger";
			out.println("action=");
			out.println(action);
			out.println(",");
			out.println("msg=");
			out.println(msg);
			out.println(";");
		}else{
            action = "error";
			out.println("action=");
			out.println(action);
			out.println(",");
			out.println("msg=");
			out.println(msg);
			out.println(";");
		}                                   
    }
	out.println("action=");
	out.println(action);
	out.println(",");
	out.println("msg=");
	out.println(msg);
	out.println(";");	
}else{
	StringList strObjectIdList = new StringList();
	if(arrTableRowIds[0].endsWith("|0")){
        %>
           <script language="javascript" type="text/javaScript">
                 alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");                  
           </script>
        <%
         } else{ 
             boolean unsavedData= false;
             for(int i=0;i<arrTableRowIds.length;i++) {
                 StringList emxTableRowIds = FrameworkUtil.split(arrTableRowIds[i], "|");
                 if(emxTableRowIds.size()==3 && !((String)emxTableRowIds.get(1)).isEmpty()){
                     unsavedData=true;
                     break;
                 }
     	    }
     	    if(unsavedData == true){
     	        %>
                 <script language="javascript" type="text/javaScript">
       	            alert("<emxUtil:i18n localize='i18nId'>emxFeature.Alert.UnsavedMarkUp</emxUtil:i18n>");
       	        </script>
                 <%
     	    }else{ 			    
     	        String tempRelID = "";
     	        String strObjectID = "";
     	        StringTokenizer strTokenizer = null;
     	        %>
     	        <script language="javascript" type="text/javaScript">
     	        var cBoxArray = new Array();
     	        </script>
     	        <%
     	        for(int i=0;i<arrTableRowIds.length;i++) {
			    	if(arrTableRowIds[i].indexOf("|") > 0){
			              strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
			              tempRelID = strTokenizer.nextToken();				              				              
			              strObjectID = strTokenizer.nextToken() ;				              
			              strObjectIdList.add(strObjectID);
			          }else{
			        	  strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
			        	  strObjectID = strTokenizer.nextToken() ;
			        	  strObjectIdList.add(strObjectID);				        	  
			          }
			    	%>
			    	<script language="javascript" type="text/javaScript">
		            cBoxArray["<%=i%>"]="<%=XSSUtil.encodeForJavaScript(context,strObjectID)%>";
		            </script>
		            <%
		     	 }
			     ConfigurationUtil util = new ConfigurationUtil();
			     boolean isFrozen = false; 
			     for(int i =0 ;i<strObjectIdList.size();i++){
                    isFrozen = util.isFrozenState(context,(String)strObjectIdList.get(i));
			    	if(isFrozen){
			    			break;
			    	}
			      }
			      if(isFrozen){
			    		%>
			            <script language="javascript" type="text/javaScript">
			                  alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.ManufacturingFeatureReleased</emxUtil:i18n>");  
			                 // getTopWindow().close();			              
			            </script>
			    		<%
			      }else{
			    		%>
			            <script language="javascript" type="text/javaScript">
				            var cBoxArray = new Array();
				        </script>
			    		<%
			            for(int i=0;i<strObjectIdList.size();i++){
				            	String strObjectIDJS = (String)strObjectIdList.get(i); %>
				                <script language="javascript" type="text/javaScript">
				                    cBoxArray["<%=i%>"]="<%=XSSUtil.encodeForJavaScript(context,strObjectIDJS)%>";	
				                </script><%
					    }
			    		%>
			    		<script language="javascript" type="text/javaScript">
				            var VarPortalCmdName = "<%=XSSUtil.encodeForJavaScript(context,portalCmdName)%>";  
				            var contentFrameObj = findFrame(getTopWindow(),VarPortalCmdName);
			                if(contentFrameObj == null || contentFrameObj == undefined){
					           contentFrameObj = findFrame(getTopWindow(),"detailsDisplay");
		                    }	
			                if(contentFrameObj == null || contentFrameObj == undefined){
				              contentFrameObj = findFrame(getTopWindow(),"content");
				            }
				            if(contentFrameObj.isDataModified()){//if SB is Modified- will not allow to delete object
				            	alert("<%=UnsavedMarkUp%>");
				            }else{//If SB is not having any Markup
				                var RemMPRelIDs = '<%=XSSUtil.encodeForJavaScript(context,strObjectIdList.toString())%>';
					            var urlParams = "mode=deleteMF&OIDsToDelete="+RemMPRelIDs;
					            var vRes = emxUICore.getDataPost("../configuration/ManufacturingFeatureDeleteProcess.jsp", urlParams);
								var iIndex = vRes.indexOf("action=");
								var iLastIndex = vRes.indexOf(",");
								var action = vRes.substring(iIndex + "action=".length, iLastIndex);
								var iIndex2 = vRes.indexOf("msg=");
								var iLastIndex2 = vRes.indexOf(";");
								var msg = vRes.substring(iIndex2+ "msg=".length, iLastIndex2);
								msg = msg.trim();
								action = action.trim();
				                if("removeandrefresh"===action){//if Delete action is OK remove selected node from UX
				                   var oXML                = contentFrameObj.oXML;
				                   var selctedRowIds       = new Array(cBoxArray.length - 1);
				                   for(var i = 0; i < cBoxArray.length; i++){	  
					      		      var selectedRow  = emxUICore.selectNodes(oXML, "/mxRoot/rows//r[@o = '" + cBoxArray[i] + "']");
					      		      var oId = selectedRow[0].attributes.getNamedItem("o").nodeValue;
					      		      var rId = selectedRow[0].attributes.getNamedItem("r").nodeValue;
					      		      var pId = selectedRow[0].attributes.getNamedItem("p").nodeValue;
					      		      var lId = selectedRow[0].attributes.getNamedItem("id").nodeValue;
					      		      var rowIds = rId+"|"+oId+"|"+pId+"|"+lId;
					      		      selctedRowIds[i] = rowIds;
				      	           }
				      	           contentFrameObj.emxEditableTable.removeRowsSelected(selctedRowIds);  
				      	           if("FTRMFContextManufacturingFeatures"===VarPortalCmdName ||"FTRSystemArchitectureManufacturingFeatures"===VarPortalCmdName ){//only incase of Product Context Tree need to refreshed to remove selected Objects
					      	           var parentRefresh = getTopWindow().window;
					                   for(var i = 0; i < cBoxArray.length; i++){
					                 		var objectId = cBoxArray[i];
					                 		parentRefresh.deleteObjectFromTrees(objectId, false);
					                    }
				      	           }
					            }else if("checkTrigger"===action){
					      	           if((msg !== null)||(msg.length > 0)){
						      	           //alert(msg);
						      	           window.location.href = "../components/emxMQLNotice.jsp";
					      	           }
					            }else{
					               if((msg !== null)||(msg.length > 0)){
                                       alert(msg)
					      	       }
					      	    }//if delete Returns error show msg
				        	}//Ajax Call if Data is NOT modified
				           </script> <% 
			      }//if Frozen not selected
     	    }//if not markup selected
     	  }//If Root not selected
     	}//if mode not passed
	   %>

