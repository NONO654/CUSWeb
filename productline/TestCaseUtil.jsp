
<%--
TestCaseUtil.jsp

Copyright (c) 1999-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,
Inc.  Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program
static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/TestCaseUtil.jsp 1.3.2.1.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";
--%>

<%-- @quickreview ZUD 	DJH 	26 	JUNE 		2013 	Corection IR-232722V6R2014x  When Use Case or Test Case is created, Tree view is not reflected immediately--%>
<%-- @quickreview ZUD 	DJH 	26 	JUNE 		2013 	Corection IR-IR-234830V6R2014x , IR-234683V6R2014x   Message Not Translated to Japanese--%>
<%-- @quickreview ZUD 	DJH 	02 	JULY 		2013 	Corection IR-IR-234830V6R2014x , IR-234683V6R2014x   Message Not Translated to Japanese--%>
<%-- @quickreview ZUD 	DJH 	26 	JUNE 		2014 	HL Sequence Order to Tree Order Migration--%>
<%-- @quickreview KIE1 	ZUD 	6 	NOVEMBER 	2014 	Corection IR-331850 FTR_VariantConfigurationFullATP_TC66_TestCase creation KO under Logical Features and Configuration Features  --%>
<%-- @quickreview KIE1 	HAT1 	3 	DECEMBER 	2014 	IR-340217-3DEXPERIENCER2015x NHIV6R2015x-FUN045462: Unwanted error message is displayed when user create Testcase under EC --%>
<%-- @quickreview JX5   QYG		13 	February 	2015	HL Widgetization - Manage Test Case under EC in TestCaseCreate Mode --%>
<%-- @quickreview KIE1 	ZUD 	26 	MARCH 		2015 	Corection IR-340186-3DEXPERIENCER2016 TestCase creation form does not display complete label.   --%>
<%-- @quickreview JX5 	QYG 	26 	JUNE 		2015 	Autoname Checked by Default in creation forms   --%>
<%-- @quickreview JX5   T94		18  AUG			2015    IR-367209-3DEXPERIENCER2016x Newly created sub test case and sub use case are not displayed  in tree structure. --%>
<%-- @quickreview HAT1  ZUD     03      FEB             2016    HL -  To enable Content column for Test Cases.--%>
<%-- @quickreview HAT1  ZUD     16      FEB             2016    HL -  (xHTML editor for Use Case.) To enable Content column for Test Cases.--%>
<%-- @quickreview HAT1  ZUD     03      MAY             2016    Populating title as per autoName of Name in Web form.--%>
<!-- @quickreview HAT1  ZUD     17      MAY             2016    IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated. -->
<!-- @quickreview ZUD      16:08:17 : Reserve/UnReserve Command for RMT Types in attribute Tab -->
<!-- @quickreview KIE1     16:11:15 : R417-FUN045210:FQA: Test Case side tree structure is not getting refreshed after creation of Parameter under test case. -->
<%-- @quickreview KIE1 ZUD 16:12:14 : R419-UX: Improper header for Create Requirement Specification, Requirement, Chapter, comment slideIn. --%>
<%-- @quickreview KIE1 ZUD 17:02:16 : IR-396572-3DEXPERIENCER2018x: R418:FUN054695: Exception and error code is show along with the message when we try to revise non revisable Sub Test Case in context of other Test Case. --%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
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



<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.TreeOrderUtil"%>

<%@page import = "com.matrixone.apps.domain.DomainConstants"%>




<html>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript">
function refresh(){
	var frame = findFrame(getTopWindow(),'detailsDisplay')
	if(frame.editableTable !=null&&frame.emxEditableTable!=null){
		//there is no portal displayed
		frame.editableTable.loadData();
		frame.emxEditableTable.refreshStructureWithOutSort();
	}else{
		//the table is in a portal
		var channel = findCurrentChannel();
		if(channel!=null){
			//the channel is found 
			channel.editableTable.loadData();
			channel.emxEditableTable.refreshStructureWithOutSort();
		}else{
			//default behavior;
	  			refreshTablePage();
	  		}
	}
}
</script>
<%
String strMode = null;
String strParentOID = null;
boolean bExceptionVal = false;
String strUiType=null;
try
{
  //get the tree id passed from Dialog jsp
  String jsTreeID = emxGetParameter(request, "jsTreeId");
  String estCompletionDate = emxGetParameter(request,"strDate");

  //get the mode called
  strMode = emxGetParameter(request, "Mode");
  //get the parent object id
  strParentOID = emxGetParameter(request, "parentOID");
  strUiType = emxGetParameter(request, "uiType");

  //Instantiate the common and util beans
  ProductLineCommon commonBean = new ProductLineCommon();
  if ((strMode.equalsIgnoreCase("CreateSubTestCase")))
    {
	 	String strObjId = emxGetParameter(request, "objectId");
	 	String openerFrame = emxGetParameter(request, "openerFrame");
    	//
	 	String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxProduct.form.create.autonamechecked");
    	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
    		autonameChecked = "true";
    	}
%>
    	<script language="javascript" type="text/javaScript">  //HAT1 ZUD: xHTML editor for Use case (subUse case)      	// HAT1 ZUD: Populating title as per autoName of Name in Web form --> nameField=autoName
    	var url= "../common/emxCreate.jsp?submitAction=xmlMessage&postProcessURL=../productline/CreateProcess.jsp?Mode=refresh&direction=from&relationship=relationship_SubTestCase&type=type_TestCase&policy=policy_TestCase&typeChooser=true&nameField=program&form=PLCCreateTestCase&showApply=true&suiteKey=ProductLine&windowMode=slidein&targetLocation=slidein";
    	url += "&objectId="+"<%=strObjId%>";
    	url += "&openerFrame="+"<%=openerFrame%>";
    	
    	getTopWindow().showSlideInDialog(url, true, window.name,"",550); 			
    	</script>
<%
    }if ((strMode.equalsIgnoreCase("CreateTestCase"))){
    	String strObjId = emxGetParameter(request, "objectId");
	 	String openerFrame = emxGetParameter(request, "openerFrame");
    	//
	 	String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxProduct.form.create.autonamechecked");
    	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
    		autonameChecked = "true";
    	}
%>
    	<script language="javascript" type="text/javaScript">
    	var url= "../common/emxCreate.jsp?submitAction=xmlMessage&postProcessURL=../productline/TestCaseUtil.jsp?Mode=refresh&direction=from&relationship=relationship_RequirementValidation&type=type_TestCase&policy=policy_TestCase&typeChooser=true&nameField=both&form=PLCCreateTestCase&showApply=true&suiteKey=ProductLine&windowMode=slidein&targetLocation=slidein";
    	url += "&objectId="+"<%=strObjId%>";
    	url += "&openerFrame="+"<%=openerFrame%>";
    	url += "&autoNameChecked="+"<%=autonameChecked%>";
    	getTopWindow().showSlideInDialog(url, true, window.name,"",550);    			
    	</script>
 <%
//Functionality to remove a Test Case object
    }else if (strMode.equalsIgnoreCase("disconnect")){
	ENOCsrfGuard.validateRequest(context, session, request,response);
    boolean canRemove = false;
    //get the table row ids of the test case objects selected
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");

    //get the object ids of the tablerow ids passed

    //get the relationship ids of the table row ids passed
    Map relIdMap=ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
    String[] arrRelIds = (String[]) relIdMap.get("RelId");
    String[] strObjectIds = (String[]) relIdMap.get("ObjId");
    String portalCmdName = emxGetParameter(request, "portalCmdName");
    //Call the removeObjects method of ProductLineCommon to remove the selected object
    boolean bFlag = commonBean.removeObjects(context,arrRelIds);

%>
    <script language="javascript" type="text/javaScript">
    if(parent.editableTable)
	{
      parent.editableTable.loadData();
      parent.emxEditableTable.refreshStructureWithOutSort();
	}
    else
    {
    	window.refreshTablePage();
    }
    refreshStructureTree();
//]]>
    </script>
<%
    }
    else if (strMode.equalsIgnoreCase("Reserve")) {
        String sOID = request.getParameter("objectId");
         HashMap requestMap = new HashMap();
         requestMap.put("objectId", sOID);
         requestMap.put("rowIds", "");
         
         HashMap programMap = new HashMap();
         programMap.put("requestMap",requestMap);
         
         HashMap Ret = (HashMap) JPO.invoke(context,
                 "emxTestCaseBase", null, "commandReserveTree", JPO.packArgs(programMap),
                 HashMap.class);
    %>
    <script language="javascript" type="text/javaScript">
        parent.location.href = parent.location.href;
    </script> 
    <%
         
    }
    else if (strMode.equalsIgnoreCase("UnReserve")) {
        String sOID = request.getParameter("objectId");
         HashMap requestMap = new HashMap();
         requestMap.put("objectId", sOID);
         requestMap.put("rowIds", "");
         
         HashMap programMap = new HashMap();
         programMap.put("requestMap",requestMap);
         
         HashMap Ret = (HashMap) JPO.invoke(context,
                 "emxTestCaseBase", null, "commandUnreserveExtendedTree", JPO.packArgs(programMap),
                 HashMap.class);
    %>
    <script language="javascript" type="text/javaScript">
        parent.location.href = parent.location.href;
    </script> 
    <%
         
    } 
  if (strMode.equalsIgnoreCase("refresh")){
  	  String openerFrame = emxGetParameter(request, "openerFrame");
  	  String strObjId = emxGetParameter(request, "objectId");
	  String objId = emxGetParameter(request, "newObjectId");
  	  %>
  	   <script language="JavaScript">
  	   var openerFrame = "<%=XSSUtil.encodeForJavaScript(context,openerFrame)%>";
  	   var frame=findFrame(getTopWindow(),openerFrame);
  	   frame.editableTable.loadData();
  	   frame.emxEditableTable.refreshStructureWithOutSort();
  	   //Update BPS fancytree
  	   var isTreeActive = getTopWindow().objStructureFancyTree.isActive;
  	   if(isTreeActive == false)
  		 getTopWindow().objStructureFancyTree.isActive = true; //False for SB. Temporaraly set to true here
	   getTopWindow().objStructureFancyTree.addChild("<%=XSSUtil.encodeForURL(context,strObjId)%>","<%=objId%>");//addChild(parentId, objectId)
	   
	   if(isTreeActive == false)
		   getTopWindow().objStructureFancyTree.isActive = false; //False for SB = No tree from BPS point of view
	   //
  	   </script>
  	<%
    }

  //Functionality to delete a Test Case object
  if (strMode.equalsIgnoreCase("Delete"))
  {
	ENOCsrfGuard.validateRequest(context, session, request,response);
    boolean canDelete = false;
    //get the table row ids of the test case objects selected
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String portalCmdName = emxGetParameter(request, "portalCmdName");
    String strObjectIds[] = null;

    //get the object ids of the tablerow ids passed
    strObjectIds = ProductLineUtil.getObjectIds(arrTableRowIds);

    //Checking if the selected Test Cases can be deleted
    canDelete = TestCase.canDeleteTestCases(context,strObjectIds,strParentOID,"delete");

    if(canDelete) {
        //Call the deleteObjects method of ProductLineCommon to delete the selected object
        boolean bFlag = commonBean.deleteObjects(context,strObjectIds,false);
    }
%>
<script language="javascript" type="text/javaScript">
<!-- hide JavaScript from non-JavaScript browsers -->
//<![CDATA[
    if(parent.editableTable)
	{
    	parent.editableTable.loadData();
      	parent.emxEditableTable.refreshStructureWithOutSort();
	}
    else
    {
    	window.refreshTablePage();
    }
      refreshStructureTree();
//]]>
</script>
<%
  }

  //create and create another  functionality to create new testcase objects
  if ((strMode.equalsIgnoreCase("CreateAnother"))||strMode.equalsIgnoreCase("Create"))
  {
	ENOCsrfGuard.validateRequest(context, session, request,response);
    //instantiate and process the form bean
    com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();

    //Processing the form using FormBean.processForm
    formBean.processForm(session,request);

    //Instantiating the Use Case bean
    TestCase testcaseBean = (TestCase)DomainObject.newInstance(context,ProductLineConstants.TYPE_TEST_CASE,"ProductLine");
    String objId = null;
    //Setting the latest Locale in context
     Locale Local = request.getLocale();
     context.setLocale(Local);
    //Calling the create Test Case Method of TestCase.java
    objId = testcaseBean.create(context,formBean);

    String strParentOId = (String)formBean.getElementValue("objectId");
    String openerFrame      = emxGetParameter(request,"openerFrame");
    %>

	<script language="JavaScript">
	if(parent.openerFrame.editableTable)
	{
		parent.openerFrame.editableTable.loadData();
		parent.openerFrame.emxEditableTable.refreshStructureWithOutSort();
	}
	else
	{
		window.refreshTablePage();
	}
	        		
	</script>
<%  
    //to refresh the create dialog page
    if(strMode.equalsIgnoreCase("Create"))
{
  %>
     <script language="JavaScript">
     if ( typeof getTopWindow().closeSlideInDialog == 'function' )
     {
         getTopWindow().closeSlideInDialog();
         refreshStructureTree();
     }
     else
     {
    	 getTopWindow().closeWindow();
    	 var topWindow = getTopWindow().getWindowOpener();
    	 // refreshSBTable method expects emxIndentedTable
    	 topWindow.refreshSBTable(topWindow.configuredTableName);
     }
     </script>
  <%
}
    if (strMode.equalsIgnoreCase("CreateAnother"))
    {
%>

   <script language="javascript" type="text/javaScript">
   // ZUD IR-232722V6R2014x Fix for refreshing Structure tree
      refreshStructureTree();
    <!-- hide JavaScript from non-JavaScript browsers -->
    //<![CDATA[
         var pc =findFrame(parent,"pagecontent");
         pc.clicked = false;
         parent.turnOffProgress();   
    
         //Added:oep:03-July-09:RMT Bug 373927  
			/*if(tableWindowToRefresh!=null)
         	{
				if (tableWindowToRefresh) 
				{
					tableWindowToRefresh.location = tableWindowToRefresh.location;
				}
         	}*/
  		//End:oep: Bug 373927
  
      //]]>
    </script>

<%
    }
    else
    {
      /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/
              String strObjId = emxGetParameter(request, "objectId");
              String strRelName = testcaseBean.getRelName(context,strObjId);
              String strSelectRelId = "to["+strRelName+"].id";
              DomainObject domObjTC = DomainObject.newInstance(context,objId);
              String strRelId = domObjTC.getInfo(context,strSelectRelId);
	      // ZUD changes for TreeOrder
	      
	      // KIE1 IR-340217-3DEXPERIENCER2015x  Unwanted error message is displayed when user create Testcase under EC
	         if(!DomainRelationship.getAttributeValue(context,strRelId, ProductLineUtil.getTreeOrderAttribute(context)).equals(""))
	         {
              DomainRelationship.setAttributeValue(context,strRelId,ProductLineUtil.getTreeOrderAttribute(context),""+TreeOrderUtil.getNextTreeOrderValue());
	         }
      /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/

		if("structureBrowser".equalsIgnoreCase(strUiType))
		   {
 %>
    <script language="javascript" type="text/javaScript">

            if (parent != null && parent.window.getWindowOpener().parent != null)
			{
                if(parent.window.getWindowOpener().parent.reloadTableEditPage != null && parent.window.getWindowOpener().parent.reloadTableEditPage != 'undefined') {
                    parent.window.getWindowOpener().parent.reloadTableEditPage();
                } else {
                    parent.window.getWindowOpener().parent.location = parent.window.getWindowOpener().parent.location;
            }
            getTopWindow().closeWindow();
            }
    </script>
 <%
           }
		 else
		   {
    //to refresh the tree after create
    //create Functionality
%>
<script language="javascript" type="text/javaScript">
<!--Javascript to reload the tree-->
//<![CDATA[
//Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005
/* parent.window.getWindowOpener().parent.parent.document.location = "../common/emxTree.jsp?objectId=<%=objId%>&mode=insert&jsTreeID=<%=jsTreeID%>&relId=<%=strRelId%>";
 parent.window.closeWindow();
 parent.window.getWindowOpener().parent.parent.window.focus();
 parent.window.focus(); */
 //Added:03-July-09:oep:Bug 373927  
			if (contentFrameToRefresh) 
			{
				contentFrameToRefresh.location.href="../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,objId)%>&mode=insert&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>";
				contentFrameToRefresh.focus();
				getTopWindow().closeWindow();
			}
  //End:oep:Bug 373927
  
//]]>
</script>
<%
	    }
	}
  }
  //IR-016104V6R2011 : Verifying if the estimated completion date is current or future date 
  if(strMode.equalsIgnoreCase("dateValidation"))
   {
      //Date dtNewCompletionDate = eMatrixDateFormat.getJavaDate(strFormattedCompletionDate);
      Date dCompletionDate = new Date(Long.valueOf(estCompletionDate));
      DateFormat df = new SimpleDateFormat();
      Calendar calendar =  Calendar.getInstance();
      calendar.setTime(dCompletionDate);
      Date newCompletionDate = calendar.getTime();
      int day_of_month = calendar.get(Calendar.DAY_OF_MONTH);
     
      Date dtTodaysDate = df.parse(df.format(new Date()));
      calendar.setTime(dtTodaysDate);
      int tday_of_month = calendar.get(Calendar.DAY_OF_MONTH);
      
      if(newCompletionDate.before(dtTodaysDate) && day_of_month != tday_of_month)
      {
    	  out.clear();
    	  out.write("EstDateInvalid"); 
      }
	}
  
  %>



  <%
  
  // KIE1 Fix for IR-331850
  
  if(strMode.equalsIgnoreCase("TestCaseCreate"))
  {
	    
	    String strObjId = emxGetParameter(request, "objectId");
	 	String openerFrame = emxGetParameter(request, "openerFrame");
	 	String relationship = "";
	 	
	 	
	 	DomainObject dmObj = DomainObject.newInstance(context, strObjId);
	 	  // KIE1 Fix for IR-331850 Adding types (Logical Feature, Manufacturing Feature, Configuration Feature)
	 	if((dmObj.isKindOf(context, PropertyUtil.getSchemaProperty(context, "type_CONFIGURATIONFEATURES"))) ||
	 			(dmObj.isKindOf(context, PropertyUtil.getSchemaProperty(context, "type_LOGICALSTRUCTURES")))
	 		)
	 	{
	 		relationship = "relationship_FeatureTestCase";
	 	}
	 	else if(dmObj.isKindOf(context, PropertyUtil.getSchemaProperty(context, "type_Requirement")))
	 	{
	 		relationship = "relationship_RequirementValidation";
	 	}
	 	else if(dmObj.isKindOf(context, PropertyUtil.getSchemaProperty(context, "type_UseCase")))
	 	{
	 		relationship = "relationship_UseCaseValidation";
	 	}
	 	else if(dmObj.isKindOf(context, PropertyUtil.getSchemaProperty(context, "type_EngineeringChange"))){
	 		relationship = FrameworkUtil.getAliasForAdmin(context, "relationship", "EC Test Case", true);
	 	}
	 	  
    	String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxProduct.form.create.autonamechecked");
    	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
    		autonameChecked = "true";
    	}
	    
	    %>
	      <script language="javascript" type="text/javaScript">
    	var url= "../common/emxCreate.jsp?submitAction=xmlMessage&postProcessURL=../productline/CreateProcess.jsp?Mode=refreshTopWindow";      	// HAT1 ZUD: Populating title as per autoName of Name in Web form. -->nameField=autoName 
    	url += "&direction=from&type=type_TestCase&policy=policy_TestCase&typeChooser=true&nameField=program&form=PLCCreateTestCase&showApply=true&suiteKey=ProductLine&windowMode=slidein&targetLocation=slidein"; 
    	url += "&objectId="+"<%=strObjId%>";
    	url += "&openerFrame="+"<%=openerFrame%>";
    	url += "&relationship="+"<%=relationship%>";
    	
    	getTopWindow().showSlideInDialog(url, true, window.name,"", 550);    			
    	</script>
	    
	<%
		}
  if(strMode.equalsIgnoreCase("reviseSubTestCase"))
  {
	  String strObjId = emxGetParameter(request, "objectId");
	  String TableRowId = emxGetParameter(request, "emxTableRowId");
      String[] arrTableRowId={TableRowId};
      try{
    	  ContextUtil.startTransaction(context, true);
	      for(int i=0;i<arrTableRowId.length;i++){
	    	  DomainObject revisedObj = null;
	    	  String obj = arrTableRowId[i].split("[|]")[1]; 
	    	  String relId = arrTableRowId[i].split("[|]")[0];
	    	  revisedObj = TestCase.createRevision(context, obj);
	    	  DomainRelationship.setToObject(context, relId, revisedObj);
	      }
	      ContextUtil.commitTransaction(context);
	      %>
    	  <script type="text/javascript">
    	  	refresh();
    	  </script>
    	  <%
      }catch(Exception e){
    	  ContextUtil.abortTransaction(context);
    	  session.putValue("error.message", e.toString()); 
      }
	      
  }
  if(strMode.equalsIgnoreCase("attachLatestSubTestCaseRevision"))
  {
	  String strObjId = emxGetParameter(request, "objectId");
	  String TableRowId = emxGetParameter(request, "emxTableRowId");
      String[] arrTableRowId={TableRowId};
      try{
    	  ContextUtil.startTransaction(context, true);
    	  for(int i=0;i<arrTableRowId.length;i++){
        	  String obj = arrTableRowId[i].split("[|]")[1]; 
        	  String relId = arrTableRowId[i].split("[|]")[0];
        	  DomainObject lastRev = TestCase.getLastRevision(context, obj);
        	  DomainRelationship.setToObject(context, relId, lastRev);
          }
    	  ContextUtil.commitTransaction(context);
    	  %>
    	  <script type="text/javascript">
    	  	refresh();
    	  </script>
    	  <%
      }catch(Exception e){
    	  ContextUtil.abortTransaction(context);
    	  throw e;
      }
  }
  
  // KIE1 Fix for IR-331850
	%>

<%  
}
catch(Exception e)
{
  // ++ IR-234830V6R2014x ZUD FIX FOR NLS message ++
  String ExceptionMsg = e.getMessage();
  String CompareNoDeleteAccess = "No delete access to business object";
  String CompareTNRNotUnique = "Business object 'type name revision' not unique";
  String NoDeleteAccess = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Alert.NoDeleteAccess");
  String TNRNotUnique = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Alert.TNRNotUnique");
  
  if(ExceptionMsg.contains(CompareTNRNotUnique))
  {
	  String TranslatedMessage = "\n" + EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Alert.CannotCommitTransaction");
	  TranslatedMessage += "\n" + TNRNotUnique;
	  
	  session.putValue("error.message", TranslatedMessage);
  }
  else if(ExceptionMsg.contains(CompareNoDeleteAccess))
  {
	  String TranslatedMessage = e.toString();
	  NoDeleteAccess += TranslatedMessage.substring(35,TranslatedMessage.length());
	  session.putValue("error.message", NoDeleteAccess);	 
  }
  // -- ZUD FIX FOR NLS message --
  else
	  session.putValue("error.message", e.getMessage());
  
  bExceptionVal = true;
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
//Closing the window if mode is create
  if (bExceptionVal == true)
  {
    %>
    <script language="javascript" type="text/javaScript">
	    var pc =findFrame(parent,"pagecontent");
	    pc.clicked = false;
	    parent.turnOffProgress();   
        history.back();
    </script>
    <%
      }
    %>
</html>


