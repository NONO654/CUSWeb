
<%--
UseCaseUtil.jsp

Copyright (c) 1999-2018 Dassault Systemes.
All Rights Reserved.
This program contains proprietary and trade secret information of MatrixOne,
Inc.  Copyright notice is precautionary only
and does not evidence any actual or intended publication of such program
static const char RCSID[] = "$Id: /ENORequirementsManagementBase/CNext/webroot/requirements/UseCaseUtil.jsp 1.2.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$";
--%>
<%-- 
	 @quickreview XXXX	XXXX 	YY:MM:DD : COMMENT
	 @quickreview T25  	OEP 	12:12:10 : HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet
     @quickreview T25 	OEP 	12:12:18 : HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview LX6 	QYG 	13:02:28 : Manage refresh when Portals are used
     @quickreview T25 	DJH 	13:10:18 : HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview ZUD 	DJH 	14:06:26 : HL Sequence Order to Tree Order Migration
     @quickreview KIE1 	ZUD 	14:11:15 : Corection IR-331850 FTR_VariantConfigurationFullATP_TC66_TestCase creation KO under Logical Features and Configuration Features
     @quickreview JX5  	QYG 	15:02:13 : HL Widgetization - mode createUseCase
     @quickreview KIE1 	ZUD 	15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
     @quickreview JX5      		15:06:11 : Autoname checked by default
     @quickreview JX5			15:07:07 : IR-379991-3DEXPERIENCER2016x : R2016x-3DEX4ALLOP_Config_FTR_CF_Use Cases : Creating Use Cases is KO
     @quickreview JX5			15:07:20 : IR-387611-3DEXPERIENCER2016x : R2016x-3DEX4ALLOP_Config_FTR_CF_Use Cases_OCDX_User : On Create Use Case Page slide in panel name having string name instead of Create New Use Case 
	 @quickreview JX5	T94		15:08:18 : IR-367209-3DEXPERIENCER2016x Newly created sub test case and sub use case are not displayed  in tree structure.
	 @quickreview JX5   		15:10:26 : IR-403889-3DEXPERIENCER2017x Variant Management_LF:Use case creation KO in context of LF 
     @quickreview HAT1 ZUD      16:02:16  HL - ( xHTML editor for Use case) To enable Content column for Test Cases.
     @quickreview HAT1 ZUD      16:05:06  Populating title as per autoName of Name in Web form. & Refreshing slide in frame.
     @quickreview HAT1 ZUD      16:05:17  IR-433769-3DEXPERIENCER2017x:R419-FUN058646:NLS: On TRM object default value in Title attribute is not getting translated.
     @quickreview KIE1 ZUD 16:11:04 : IR-475850-3DEXPERIENCER2018x: R419-FUN055837: Unnecessary Requirement object is getting created, after error message object type name revision not unique on creation form.
     @quickreview KIE1 ZUD 16:12:14 : R419-UX: Improper header for Create Requirement Specification, Requirement, Chapter, comment slideIn
--%>

<%--Importing package com.matrixone.apps.domain --%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.TreeOrderUtil"%>

<%--Importing package com.matrixone.apps.productline --%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>

<%--Importing package com.matrixone.apps.requirements --%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import = "com.matrixone.apps.requirements.UseCase"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<html>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITreeUtil.js"></script>

<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
String strMode = null;
boolean bExceptionVal = false;

try
{
  //get the tree id passed from Dialog jsp
  String jsTreeID = emxGetParameter(request, "jsTreeId");
  String strUiType = emxGetParameter(request, "uiType");
  //get the mode called
  strMode = emxGetParameter(request, "Mode");

  //Instantiate the common and util beans
  ProductLineCommon commonBean = new ProductLineCommon();

  //remove Functionality
  if (strMode.equalsIgnoreCase("disconnect"))
  {
    //get the table row ids of the use case objects selected
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    //START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    String portalCmdName = emxGetParameter(request, "portalCmdName");
    //END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    Map relIdMap=ProductLineUtil.getObjectIdsRelIdsR213(arrTableRowIds);
    String[] arrRelIds = (String[]) relIdMap.get("RelId");
    String[] strObjectIds = (String[]) relIdMap.get("ObjId");

    //Call the removeObjects method of ProductLineCommon to remove the selected object
    boolean bFlag = commonBean.removeObjects(context,arrRelIds);

// Begin of Modify by Enovia MatrixOne for Bug # 301879 Date 04/07/2005
%>
<script language="javascript" type="text/javaScript">
//<![CDATA[
    //START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
   	parent.editableTable.loadData();
    parent.emxEditableTable.refreshStructureWithOutSort();
  //END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
   refreshStructureTree();
   
//]]>
</script>
<%
// End of Modify by Enovia MatrixOne for Bug # 301879 Date 04/07/2005
  }

  //Functionality to delete a Use Case object
  if (strMode.equalsIgnoreCase("Delete"))
  {
    //get the table row ids of the use case objects selected
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    //START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    String portalCmdName = emxGetParameter(request, "portalCmdName");
    //END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    String strObjectIds[] = null;

    //get the object ids of the tablerow ids passed
    strObjectIds = ProductLineUtil.getObjectIds(arrTableRowIds);

    //Call the deleteObjects method of ProductLineCommon to delete the selected object
    boolean bFlag = commonBean.deleteObjects(context,strObjectIds,false);

// Begin of Modify by Enovia MatrixOne for Bug # 301879 Date 04/07/2005
%>
<script language="javascript" type="text/javaScript">
<!-- hide JavaScript from non-JavaScript browsers -->
//<![CDATA[
  //START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
      parent.editableTable.loadData();
      parent.emxEditableTable.refreshStructureWithOutSort();
   //END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
   refreshStructureTree();
//]]>
</script>
<%
// End of Modify by Enovia MatrixOne for Bug # 301879 Date 04/07/2005
  }
  if (strMode.equalsIgnoreCase("refresh")){
	  String openerFrame = emxGetParameter(request, "openerFrame");
	  String strObjId = emxGetParameter(request, "objectId");
	  String objId = emxGetParameter(request, "newObjectId");

	  %>
	   <script language="JavaScript">
	   var openerFrame = "<%=openerFrame%>";
	   var frame=findFrame(getTopWindow(),openerFrame);
	   frame.editableTable.loadData();
	   frame.emxEditableTable.refreshStructureWithOutSort();
	   
	   //Update BPS fancytree
	   var isTreeActive = getTopWindow().objStructureFancyTree.isActive;
  	   if(isTreeActive == false)
  		 getTopWindow().objStructureFancyTree.isActive = true;//False for SB. Temporaraly set to true here
	    getTopWindow().objStructureFancyTree.addChild("<%=XSSUtil.encodeForURL(context,strObjId)%>","<%=objId%>");//addChild(parentId, objectId)
	    if(isTreeActive == false)
	    	getTopWindow().objStructureFancyTree.isActive = false; //False for SB = No tree from BPS point of view
	    //

	   </script>
	<%
  }
  if(strMode.equalsIgnoreCase("createUseCase")){
	    String openerFrame = emxGetParameter(request, "openerFrame");
		String strObjectId 	= emxGetParameter(request, "objectId");
		String relationship = "";
		String direction 	= "from";
		DomainObject obj 	= DomainObject.newInstance(context, strObjectId);
		
		if(obj.isKindOf(context, PropertyUtil.getSchemaProperty(context, "type_Requirement"))){
			relationship = FrameworkUtil.getAliasForAdmin(context, "relationship", "Requirement Use Case", true);
		}
		else if(obj.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_UseCase"))){
			relationship = FrameworkUtil.getAliasForAdmin(context, "relationship", "Sub Use Case", true);
		}
		else if(obj.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_LOGICALSTRUCTURES"))||
				obj.isKindOf(context, PropertyUtil.getSchemaProperty(context,"type_CONFIGURATIONFEATURES"))){
			relationship = FrameworkUtil.getAliasForAdmin(context, "relationship", "Feature Use Case", true);
		}
		
		String autonameChecked = EnoviaResourceBundle.getProperty(context, "emxRequirements.form.create.autonamechecked");
      	if(autonameChecked == null || autonameChecked.equalsIgnoreCase("")){
      		autonameChecked = "true";
      	}
		
	%>
	    <script language="javascript" type="text/javaScript">   //HAT1 ZUD: xHTML editor for Use case   // HAT1 ZUD: Populating title as per autoName of Name in Web form. -->nameField=autoName
		var url= "../common/emxCreate.jsp?submitAction=xmlMessage&postProcessURL=../productline/CreateProcess.jsp?Mode=refresh&type=type_UseCase&policy=policy_SoftwareUseCase&typeChooser=true&nameField=program&form=RMTCreateUseCase&header=emxRequirements.Heading.UseCaseCreate&showApply=true&suiteKey=Requirements&windowMode=slidein&targetLocation=slidein";
		url += "&objectId="+"<%=strObjectId%>";
		url += "&openerFrame="+"<%=openerFrame%>";
		url += "&relationship="+"<%=relationship%>";
		url += "&direction="+"<%=direction%>";
		url += "&policy=policy_SoftwareUseCase";
		
		getTopWindow().showSlideInDialog(url, true, window.name,"",550);    			
		</script>
	  
	<%
		
	}
  //create and create another  functionality to create new usecase objects
  if ((strMode.equalsIgnoreCase("CreateAnother"))||strMode.equalsIgnoreCase("Create"))
  {
    //instantiate and process the form bean
    com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();

    //Processing the form using FormBean.processForm
    formBean.processForm(session,request);

    //Instantiating the Use Case bean
    UseCase usecaseBean = (UseCase)DomainObject.newInstance(context,ReqSchemaUtil.getUseCaseType(context),"Requirements");

    String objId = null;

    //Calling the create Use Case Method of UseCase.java
    objId = usecaseBean.create(context,formBean);

    String strParentOId = (String)formBean.getElementValue("objectId");
    String strCreateStatus = "done" ;
    //START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    String openerFrame      = emxGetParameter(request,"openerFrame");
    //END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
%>

	<script language="JavaScript">
	//START:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
    parent.openerFrame.editableTable.loadData();
    parent.openerFrame.emxEditableTable.refreshStructureWithOutSort();
    //END:LX6 QYG 28 Feb 2013  Manage refresh when Portals are used
 	</script>
<%    
if(strMode.equalsIgnoreCase("Create"))
{
	%>
	   <script language="JavaScript">
	   getTopWindow().closeSlideInDialog();
	   refreshStructureTree();
	   </script>
	<%
}
    
    //to refresh the create dialog page
    if (strMode.equalsIgnoreCase("CreateAnother"))
    {
%>
  <script language="JavaScript">
     refreshStructureTree();
  </script>
   <body class="white">
<form name="DummyForm"   method="post" >
<input type="hidden" name="forNetscape" value ="" />
</form>
<script language="javascript" type="text/javaScript">
    <!-- hide JavaScript from non-JavaScript browsers -->
        findFrame(parent, 'pagecontent').clicked = false;
        parent.turnOffProgress();
</script>
<%
    }
    else
    {
        /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/
              String strObjId = emxGetParameter(request, "objectId");
              String strRelName = usecaseBean.getRelName(context,strObjId);
              String strSelectRelId = "to["+strRelName+"].id";
              DomainObject domObjUC = DomainObject.newInstance(context,objId);
              String strRelId = domObjUC.getInfo(context,strSelectRelId);
	      // ZUD change for TreeOrder
	      
	      if(!DomainRelationship.getAttributeValue(context,strRelId, ReqSchemaUtil.getTreeOrderAttribute(context)).equals(""))
	      {
              DomainRelationship.setAttributeValue(context,strRelId,ReqSchemaUtil.getTreeOrderAttribute(context),""+TreeOrderUtil.getNextTreeOrderValue());
	      }
	      
	      
      /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/
		if("structureBrowser".equalsIgnoreCase(strUiType))
		   {
 %>
  //KIE1 ZUD TSK447636 
    <script language="javascript" type="text/javaScript">
            if (parent!=null && parent.window.getWindowOpener().parent != null)
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
<!--Javascript to reload the tree-->
<script language="javascript" type="text/javaScript">
<!-- hide JavaScript from non-JavaScript browsers -->


//MODIFICATION LOG
/* Modified by <Tanmoy Chatterjee> On <22nd MAY 2003>
   For the following Bug
   <the dialog wasnt closing after creation:>
   Fixed as Follows:
   <commented out the releaseMouseEvents();>
*/
//<![CDATA[
  //Modified by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005
  /*parent.window.getWindowOpener().parent.parent.document.location = "../common/emxTree.jsp?objectId=<%=objId%>&mode=insert&jsTreeID=<%=jsTreeID%>&relId=<%=strRelId%>";
  parent.window.closeWindow();
  parent.window.getWindowOpener().parent.parent.window.focus();
  parent.window.focus();*/
  
  //Added:28-Apr-09:kyp:R207:RMT Bug 370643             
			if (contentFrameToRefresh) 
			{
				contentFrameToRefresh.location.href="../common/emxTree.jsp?objectId=<xss:encodeForJavaScript><%=objId%></xss:encodeForJavaScript>&mode=insert&jsTreeID=<xss:encodeForJavaScript><%=jsTreeID%></xss:encodeForJavaScript>&relId=<xss:encodeForJavaScript><%=strRelId%></xss:encodeForJavaScript>";
				contentFrameToRefresh.focus();
				 //KIE1 ZUD TSK447636 
				getTopWindow().closeWindow();
			}
  //End:R207:RMT Bug 370643
  
  
//]]>
</script>
<%
	    }
	}
  }
}
catch(Exception e) {
  if (e.toString() != null && (e.toString().trim()).length() > 0) {
    String msg = e.getMessage();
    String errorMessage = "";
    if (msg.indexOf("1500789") > 1) { // Object not unique 
      errorMessage = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.NotUniqueMsg");
      session.putValue("error.message", errorMessage);
    } else {
      session.putValue("error.message", e.getMessage());
    }
  }
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
	findFrame(parent, 'pagecontent').clicked = false;
    parent.turnOffProgress();
    history.back();
</script>
<%
  }
%>
</html>


