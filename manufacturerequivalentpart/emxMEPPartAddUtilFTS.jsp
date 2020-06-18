<%--  emxMEPPartAddUtilFTS.jsp 
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.   Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: .rca $
--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%@page import="com.matrixone.apps.manufacturerequivalentpart.Part"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<% 

    String sLanguage = request.getHeader("Accept-Language");	
	String[] sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");
    String strMode = emxGetParameter(request, "mode");
    String strRelationship = emxGetParameter(request, "relation");
    String strObjectId = emxGetParameter(request, "objectId");
    String selectedConfiguration  = "";
    String    suiteKey        = emxGetParameter(request, "suiteKey");
    String    suiteDirectory  = emxGetParameter(request, "SuiteDirectory");
	StringList objList = new StringList ();
	
	try {
		if (sCheckBoxArray != null && sCheckBoxArray.length !=0) {
	        
	        String[] strIds = new String [sCheckBoxArray.length];
	        for (int i =0; i<sCheckBoxArray.length; i++) {
	            if (sCheckBoxArray[i].indexOf("|") != -1) {
	                matrix.util.StringList slids = com.matrixone.apps.domain.util.FrameworkUtil.split(sCheckBoxArray[i], "|");
	                strIds [i] = (String)slids.get(0);
	                objList.add((String)slids.get(0));
	            }
	            else {
	                strIds [i] = sCheckBoxArray[i];
	                objList.add(sCheckBoxArray[i]);
	            }
	        }
	        if ("relationship_ManufacturerEquivalent".equals(strRelationship)) {
	            if (strObjectId !=null && !"".equals(strObjectId)) {
	                Part part = new Part(strObjectId);
	                part.addManufacturerEquivalentParts(context, strIds);
	            }
	            else {
	                throw new Exception ("valid object does not exist for connection");
	            }
	        }
	        boolean isMCCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionMaterialsComplianceCentral",false,null,null);	        
	        if(isMCCInstalled)
	        {
	        	selectedConfiguration = FrameworkProperties.getProperty(context, "emxMaterialsCompliance.StructureTree.selectConfiguration");
	        }
	        
	%>
	        <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	        <script language="JavaScript"> 
	      	//XSSOK
	            if ("AddExisting" == "<%=XSSUtil.encodeForJavaScript(context,strMode)%>") {
		      
	            	var objWin = null;
		            if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN){
		            	objWin = getTopWindow();
	                }
		            else{
		            	objWin = getTopWindow().getWindowOpener().getTopWindow();
		            }
	            	var myFrame      = findFrame(objWin,"content");     
	                var emxUITreeBar = findFrame(myFrame,"emxUITreeBar");
	                //XSSOK      
	                if(emxUITreeBar && ("Selected Equivalent" == "<%=selectedConfiguration%>"))
	                {
	                    var emxform = emxUITreeBar.document.emxform;                         
	                    var objId = myFrame.getTopWindow().trees['emxUIStructureTree'].nodes['root'].objectID;	                    
	                    var structureMenuName = emxform.structureMenuName.value;
	                    var passedParam = emxform.structure_param.options[emxform.structure_param.selectedIndex].value;
	                  	//XSSOK
	                    var strURL="<%=request.getContextPath()%>/common/emxTreeBar.jsp?objectId="+objId+"&rootStructureId="+objId+"&treemode=structure&structureTreeName="+structureMenuName+"&emxSuiteDirectory=<%=XSSUtil.encodeForJavaScript(context,suiteDirectory)%>&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>&selectedStructure="+passedParam;
	                    
	                    emxUITreeBar.location.href=strURL;
	                 }           
	                //top.getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
	                
			  if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN){
	                	findFrame(getTopWindow(),"ENCEquivalents").location.href = findFrame(getTopWindow(),"ENCEquivalents").location.href;
	                }
	                else{
	                	getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;	                
	                }                
	                getTopWindow().closeWindow();
	            }
	            else {
	            	//XSSOK
	            	alert("<%=EnoviaResourceBundle.getProperty(context, "emxMaterialsComplianceCentralStringResource", context.getLocale(),"emxMaterialComplianceCentral.Message.AddedToCompliancePortfolio")%>");
	            	 
	            }
	        </script>
	<%
	    }
	}
	catch (Exception e){
		throw new FrameworkException(e);
	}
%>   
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
