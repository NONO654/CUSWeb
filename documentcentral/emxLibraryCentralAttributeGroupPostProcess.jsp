<%--
   emxLibraryCentralAttributeGroupPostProcess.jsp

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%  
    String attributeGroupName   = emxGetParameter(request, "Name");
	String attributeGroupName_encodedForJS = XSSUtil.encodeForJavaScript(context, attributeGroupName);
	String attributeGroupName_encodedForURL = XSSUtil.encodeForURL(context, attributeGroupName);
	String strCharSet =  (String )emxGetParameter(request,"charSet");
    if(strCharSet == null || strCharSet.trim().equals(""))
    {
        strCharSet = "UTF8";
    }
	
	// Changes added by PSA11 start (IR-539822-3DEXPERIENCER2019x)
	String attributeGroupObjectId   = emxGetParameter(request, "objectId");
	String attributeGroupObjectId_encodedForJS = XSSUtil.encodeForJavaScript(context, attributeGroupObjectId);
	// Changes added by PSA11 end
	
    StringBuffer sbUrl          = new StringBuffer("../common/emxTree.jsp?treeMenu=type_MCMAttributeGroupTreeMenu&mode=insert&AppendParameters=true");
    sbUrl.append("&treeLabel=");
    sbUrl.append(attributeGroupName_encodedForURL);
    sbUrl.append("&objectName=");
    sbUrl.append(attributeGroupName_encodedForURL);
    sbUrl.append("&AGName=");
    sbUrl.append(attributeGroupName_encodedForURL);
    sbUrl.append("&suiteKey=LibraryCentral");
    sbUrl.append("&DefaultCategory=MCMAttributeGroupProperties");
    
    StringBuffer updatedURL = new StringBuffer("../common/emxForm.jsp?form=type_AttributeGroup&toolbar=LBCAttributeGroupPropertiesToolBar&HelpMarker=emxhelpattributegroup&formHeader=emxMultipleClassification.Common.Properties&Export=False&findMxLink=false&emxSuiteDirectory=documentcentral&mode=insert&suiteKey=LibraryCentral&StringResourceFileId=emxLibraryCentralStringResource&SuiteDirectory=documentcentral&objectBased=false&submitAction=refreshCaller&otherTollbarParams=treeLabel,objectName,mode,AGName");
    updatedURL.append("&treeLabel=");
    updatedURL.append(attributeGroupName_encodedForURL);
    updatedURL.append("&objectName=");
    updatedURL.append(attributeGroupName_encodedForURL);
    updatedURL.append("&AGName=");
    updatedURL.append(attributeGroupName_encodedForURL);
    String updatedURLStr = FrameworkUtil.encodeURL(updatedURL.toString(), strCharSet);
%>

<script language ="javascript">
    try{
		    // Changes added by PSA11 start (IR-539822-3DEXPERIENCER2019x)
      		<%-- getTopWindow().changeObjectLabelInTree("<%=attributeGroupName_encodedForJS%>", "<%=attributeGroupName_encodedForJS%>", true, true); --%>
    		getTopWindow().changeObjectLabelInTree("<%=attributeGroupObjectId_encodedForJS%>", "<%=attributeGroupName_encodedForJS%>", true, true);
			// Changes added by PSA11 end 
			 
			 var currbc = getTopWindow().bclist.getCurrentBC();
    			if(currbc && currbc.categoryObj)
    			{
    		    	currbc.categoryObj.items[0].url = "<%=updatedURLStr%>";
    		    }
    		    
            var wndContent            = getTopWindow().findFrame(getTopWindow(),"content");
            wndContent.location.href  = "<%=sbUrl.toString()%>";		
    }catch(e) {   
      getTopWindow().refreshTablePage(); 
 
    }
</script>




