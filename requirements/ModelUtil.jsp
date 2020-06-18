<%--
  ModelUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENORequirementsManagementBase/CNext/webroot/requirements/ModelUtil.jsp 1.3.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$";

 --%>
 <%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
       respective scriplet
      @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
      @quickreview T25 DJH 16 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
      @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
      @quickreview JX5		15:07:20 : IR-374908-3DEXPERIENCER2016x : Refresh issue after commiting requirement from model to product 
    
 --%>
<%--Importing package com.matrixone.apps.domain --%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>

<%--Importing package com.matrixone.apps.product --%>
<%@page import = "com.matrixone.apps.productline.Model"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.CandidateProductHolder"%>
<%@page import = "com.matrixone.apps.requirements.Requirement"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>


<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>

<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>


<%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%


boolean bExceptionVal = false;
//initializing the mode
String strMode = null;
boolean bIsError = false;
try
{
  //Get the mode called
  strMode = emxGetParameter(request, "mode");
  //get the tree id passed from Dialog jsp
  String strTreeID = emxGetParameter(request, "jsTreeId");

  //Instantiate the common and util beans
  ProductLineCommon commonBean = new ProductLineCommon();

  if (strMode.equalsIgnoreCase("selectedProduct"))
  {

    String strSelectedProduct = emxGetParameter(request, "Product");

    //Getting the Selected Products from the Session
    CandidateProductHolder[] cph = (CandidateProductHolder[])session.getAttribute(ProductLineConstants.SESSION_CANDIDATE_PRODUCT_HOLDER);

    //Clearing the selected flag if routed through previous
    for(int i=0; i<cph.length; i++)
    {
      cph[i].setIsSelected(false);
    }

    //setting the selected flag for the selected CandidateProductHolder objecte
    for(int i=0; i<cph.length; i++)
    {
      if(cph[i].getId().equals(strSelectedProduct))
      cph[i].setIsSelected(true);
    }
    //Replacing the CandidateProductHolder[] in the session
    session.putValue(ProductLineConstants.SESSION_CANDIDATE_PRODUCT_HOLDER, cph);

%>

<form name="selectedProduct"   method="post" >
  <input type="hidden" name="forNetscape" value ="" />
</form>
<script language="javascript" type="text/javaScript">
//<![CDATA[
  var f= document.selectedProduct;
  f.target="_top";
  f.action = "../components/emxCommonFS.jsp?SuiteDirectory=requirements&functionality=modelSelectFeatures&suiteKey=Requirements&objectId=<xss:encodeForJavaScript><%=strSelectedProduct%></xss:encodeForJavaScript>";
  f.submit();
//]]>
</script>

<%
  }

  //commitCandidateRequirement Functionality
  else if (strMode.equalsIgnoreCase("commitCandidateRequirement"))
  {
    boolean berror = false;
    try
     {
    try
    {
    //Removing RequirementIds from the session
    session.removeValue(ProductLineConstants.SESSION_REQUIREMENTIDS);
    }
    catch(Exception e)
    {
    }
    String strModelId = emxGetParameter(request,"objectId");
    //Getting an array of related Products
    CandidateProductHolder[] cph = CandidateProductHolder.getRelatedProducts(context, strModelId);

    if (cph == null || cph.length == 0) {
%>
<script language="javascript" type="text/javaScript">
  msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.NoProductsUnderModel")%>";
  alert(msg);
  

</script>
<%    
    }
else
    {

    //Getting the Parameters to build the SubmitURL
    String strSuiteDir = emxGetParameter(request,"SuiteDirectory");
    String strJsTreeID = emxGetParameter(request,"jsTreeID");
    String strParentObjectId = emxGetParameter(request,"objectId");

    //extract Table Row ids of the checkboxes selected.
    String arrRowIds[] = emxGetParameterValues(request,"emxTableRowId");

    //extracts Object id of the Objects to be disconnected.
    String[] arrObjIds=(String[])(ProductLineUtil.getObjectIdsRelIdsR213(arrRowIds)).get("ObjId");

    //putting the RequirementIds into the session to access it in "commitToProduct"
    session.putValue(ProductLineConstants.SESSION_REQUIREMENTIDS, arrObjIds);

%>

<form name="CommitCandidateRequirement"   method="post" >
  <input type="hidden" name="forNetscape" value ="" />
</form>
<script language="javascript" type="text/javaScript">
//<![CDATA[
//  var f= document.CommitCandidateRequirement;

  showModalDialog( "../common/emxTable.jsp?program=emxModel:getRelatedProducts&table=PLCRelatedProductList&Submit=true&SuiteDirectory=<xss:encodeForJavaScript><%=strSuiteDir%></xss:encodeForJavaScript>&parentOID=<xss:encodeForJavaScript><%=strParentObjectId%></xss:encodeForJavaScript>&objectId=<xss:encodeForJavaScript><%=strParentObjectId%></xss:encodeForJavaScript>&jsTreeID=<xss:encodeForJavaScript><%=strJsTreeID%></xss:encodeForJavaScript>&suiteKey=Requirements&header=emxRequirements.Heading.SelectProductRevision&selection=single&CancelButton=true&SubmitLabel=emxRequirements.Button.Done&CancelLabel=emxRequirements.Button.Cancel&SubmitURL=../requirements/ModelUtil.jsp?mode=commitToProduct&Export=false&PrinterFriendly=false&ConfirmMessage=emxRequirements.Alert.CommitSelected&HelpMarker=emxhelpmodreqmts",700,700);

//]]>
</script>


<%
}
  
  }

catch(Exception ex)
 {
    berror = true;
}

if(berror == true)
  {
    %>

<script language="javascript" type="text/javaScript">
  msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.RequirementNotCommited")%>";
  alert(msg);
  //KIE1 ZUD TSK447636 
  parent.closeWindow();
</script>

<%
  }

 }
  //commitCandidateRequirement Functionality
else if (strMode.equalsIgnoreCase("commitToProduct"))
 {
     //Getting the Parameters object id
     String strModelObjId = emxGetParameter(request, "objectId");
     //Getting the Product Table row ids
     String[] strProductRowId = emxGetParameterValues(request, "emxTableRowId");

     //Checking if any product has been selected
     if(strProductRowId == null)
     {
       String strAlertMessage = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.NoProductChosen");

%>
       <script language="javascript" type="text/javaScript">
       alert("<xss:encodeForJavaScript><%=strAlertMessage%></xss:encodeForJavaScript>");
       history.back();
       </script>
<%

     }

     //Getting the Product object id
     String[] strProductObjId=(String[])(ProductLineUtil.getObjectIdsRelIdsR213(strProductRowId)).get("ObjId");


     //Getting the RequirementIds
     String[] arrRequirementIds = (String[])session.getAttribute(ProductLineConstants.SESSION_REQUIREMENTIDS);

     //Instantiating the Requirement bean
     Requirement requirementBean = (Requirement)DomainObject.newInstance(context,ReqSchemaUtil.getRequirementType(context),"Requirements");
     //Calling the commitSelectedRequirements method of the bean
     requirementBean.commitSelectedRequirements(context, strModelObjId, strProductObjId[0], arrRequirementIds);

%>
     <script language="javascript" type="text/javaScript">
<%
     for(int i=0;i<arrRequirementIds.length;i++) {
%>
 //KIE1 ZUD TSK447636 
    	var tempTree = getTopWindow().getWindowOpener().parent.window.getTopWindow().objDetailsTree;
     	tempTree.deleteObject ("<xss:encodeForJavaScript><%=arrRequirementIds[i]%></xss:encodeForJavaScript>");   
    
<%
     }
%>   
 //KIE1 ZUD TSK447636 
     try {   
    	 getTopWindow().getWindowOpener().parent.window.getTopWindow().refreshTreeDetailsPage();
     } catch(e) {
     	//alert if anything other than permission denied
        if (-2146828218 != e.number) {
        	alert(e.description);
        }
     }     
     
     //Pops the Commit Complete Message
    msg = "<%=EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), "emxRequirements.Alert.RequirementCommited")%>";
    alert(msg);   
       //KIE1 ZUD TSK447636 
    window.getTopWindow().closeWindow();
    </script>
<%

     //Removing RequirementIds from the session
     session.removeValue(ProductLineConstants.SESSION_REQUIREMENTIDS);
  } 
} catch(Exception e)
{
   
   bIsError=true;
   session.removeValue(ProductLineConstants.SESSION_MODELID);
   session.removeValue(ProductLineConstants.SESSION_CANDIDATE_FEATURE_HOLDER);
   session.removeValue(ProductLineConstants.SESSION_CANDIDATE_PRODUCT_HOLDER);
   session.removeValue(ProductLineConstants.SESSION_REQUIREMENTIDS);
   String alertString = "emxRequirements.Alert." + e.getMessage();
   String i18nErrorMessage = EnoviaResourceBundle.getProperty(context, bundle, context.getLocale(), alertString);
   if ("".equals(i18nErrorMessage))
     i18nErrorMessage = e.getMessage();
   i18nErrorMessage = i18nErrorMessage.trim();
   %>

   <script language="javascript" type="text/javaScript"></script>
   <script>
    
   if(("<%=i18nErrorMessage%>")!= "")
    {
     
     alert("<%=i18nErrorMessage%>");
    }
    <%
  if (!strMode.equalsIgnoreCase("create") )
    {
      session.putValue("error.message", i18nErrorMessage);
   %>
    //KIE1 ZUD TSK447636 
     getTopWindow().closeWindow();
    <%
     }
    %>
    </script>
<%
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%
  if (bIsError==true && strMode.equalsIgnoreCase("create") )
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


<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
