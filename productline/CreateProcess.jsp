<%--
  CreateProcess.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
   @quickreview HAT1 ZUD 16:02:03  HL -  To enable Content column for Test Cases. 
   @quickreview HAT1 ZUD 16:02:16  HL - ( xHTML editor for Use case) To enable Content column for Test Cases.
   @quickreview HAT1 ZUD 16:05:03 Populating title as per autoName of Name in Web form.
   @quickreview HAT1 ZUD 16:05:17  IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated.
   @quickreview KIE1 ZUD 16:11:04  IR-298234-3DEXPERIENCER2018x: R417-FUN045210:FQA: Test Case side tree structure is not getting refreshed after creation of Parameter under test case.
   
 --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<jsp:useBean id="createBean"
    class="com.matrixone.apps.framework.ui.UIForm" scope="session" />

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.TestCase"%>
<%@page import ="java.util.Date" %>
<%@page import ="java.util.Calendar" %>

<%@page import="java.text.DateFormat" %>
<%@page import="java.text.SimpleDateFormat" %> 
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="org.apache.commons.fileupload.*,java.util.*,java.io.*"%>
<%@page import="java.util.List"%>
<%@page import ="com.matrixone.apps.framework.ui.UIUtil" %>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.TreeOrderUtil"%>

<%@page import = "com.matrixone.apps.domain.DomainConstants"%>



<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>

<%
	String strObjId = emxGetParameter(request, "objectId");
	String objId = emxGetParameter(request, "newObjectId");
 	String openerFrame = emxGetParameter(request, "openerFrame");
 	String Mode = emxGetParameter(request, "Mode");
 	String form = emxGetParameter(request,"form");
	
	String relID = emxGetParameter(request,"relId");
	context = (Context) request.getAttribute("context");
	String strRelationship = null;
		
	if(UIUtil.isNotNullAndNotEmpty(relID)){
		DomainRelationship relObj = DomainRelationship.newInstance(context,relID);
		boolean closeRel = relObj.openRelationship(context);    
		strRelationship = relObj.getTypeName();    
		
		if(strRelationship.equals("Requirement Validation")){
			relObj.setAttributeValue(context, PropertyUtil.getSchemaProperty(context, "attribute_TreeOrder"),""+TreeOrderUtil.getNextTreeOrderValue()); 
		}
		
		relObj.closeRelationship(context, closeRel);  
	} 
  	
 	// HAT1 ZUD: To enable Content Column for Test Case. (Using mode in if condition)
    if(("refresh").equalsIgnoreCase(emxGetParameter(request, "Mode")) || ("refreshTopWindow").equalsIgnoreCase(emxGetParameter(request, "Mode"))) 
    {
 	
    %>
    <script language="javascript">
	
    // ++ HAT1 ZUD: HL -  To enable Content column for Test Cases
    
	// Set the rich Text
	var windowDocument = findFrame(getTopWindow(), 'slideInFrame');
	// It can means it's from CATIA
	if (!windowDocument) {
		windowDocument = getTopWindow();
	}
	
	var refreshModeParam  = "objectId="+"<%=strObjId%>";
		refreshModeParam += "&openerFrame="+"<%=openerFrame%>";
		refreshModeParam += "&newObjectId="+"<%=objId%>";
	var opnFrame = "<%=XSSUtil.encodeForJavaScript(context,openerFrame)%>";
	
	var refreshed = opnFrame;
	
	//Refresh the topwindow
	function refreshTopWindow()
	{
     	var frame=findFrame(getTopWindow(),opnFrame);
     	frame.editableTable.loadData();
     	frame.emxEditableTable.refreshStructureWithOutSort();
     	//Update BPS fancytree
     	var isTreeActive = getTopWindow().objStructureFancyTree.isActive;
     	if(isTreeActive == false)
     		 getTopWindow().objStructureFancyTree.isActive = true; //False for SB. Temporaraly set to true here
     	getTopWindow().objStructureFancyTree.addChild("<%=XSSUtil.encodeForURL(context,strObjId)%>","<%=objId%>");

   	   	if(isTreeActive == false)
   		     getTopWindow().objStructureFancyTree.isActive = false; //False for SB = No tree from BPS point of view
	}
	//When content data is not empty.
	if (windowDocument && windowDocument.objectCreationType && windowDocument.objectCreationContentData) {
	
		var data = new FormData();
	    data.append('type', windowDocument.objectCreationType);
	    data.append('objectId', "<xss:encodeForJavaScript><%=objId%></xss:encodeForJavaScript>");
	    data.append('contentText', windowDocument.objectCreationContentText);
	    data.append('contentData', windowDocument.objectCreationContentData); //must be last item!!
	
	    windowDocument.jQuery.ajax({
	        type: 'POST',
	        cache: false,
	        contentType: false,
	        processData: false,
	        url: "../resources/richeditor/res/setRichContent" + "?" + windowDocument.objectCreationCsrfParams,
	        data: data,
	        complete: function(data) {},
            error: function(xhr, status, error){
            	var message = typeof xhr.responseText == 'string' ? JSON.parse(xhr.responseText).status : xhr.responseText; 
            	console.log(error + ":" + message);
            },
	        dataType: 'text',
	        async: false
	    });
	}
	//Refreshing the topwindow table of TC listing when content data is empty.
	if(refreshed)
	{
    	refreshTopWindow();
	}
	</script>
	<%
	if("PARCreateParameterWebForm".equalsIgnoreCase(form))
	{
	%>
	
	 <script language="javascript">
	 var $fields = parent.$("form[name='emxCreateForm'] #Name, form[name='emxCreateForm'] #Title, form[name='emxCreateForm'] :input[name='Description'],"
             + " form[name='emxCreateForm'] #Value, form[name='emxCreateForm'] #Min, form[name='emxCreateForm'] #Max");
         $.each($fields, function(i, field){
             var toBeUpdated = true;
             if (field.id == "Value")
             {
                 if ("[object HTMLSelectElement]" == field.valueOf())
                 {
                     field.options[0].selected = true;
                     //field.value = "TRUE";
                     toBeUpdated = false;
                 }
             }
             if (toBeUpdated)
             {
                 field.value = "";
                 if (field.id == "Name")
                 {
                     field.disabled = true;
                     field.requiredValidate = "";
                 }
             }
         });
         
         var $fieldsToCheck = parent.$("form[name='emxCreateForm'] :checkbox[name='autoNameCheck'], form[name='emxCreateForm'] #minIncludedId,  form[name='emxCreateForm'] #maxIncludedId");
         $.each($fieldsToCheck, function(i, fieldToCheck){
            fieldToCheck.checked = true; 
         });
	
	</script>
<%
	}
    }
	
	
	
%>


</body>
</html>
