<%--
  ModelUtil.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: /ENOProductLine/CNext/webroot/productline/ModelUtil.jsp 1.4.2.2.1.1 Wed Oct 29 22:17:06 2008 GMT przemek Experimental$";

 --%>
<%--Importing package com.matrixone.apps.domain --%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>

<%--Importing package com.matrixone.apps.product --%>
<%@page import = "com.matrixone.apps.productline.Model"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>

<%-- Top error page in emxNavigator --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%--Common Include File --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>


<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="javascript" src="emxUIMouseEvents.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITreeUtil.js"></script>


<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<%
boolean result = true;

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


  // Functionality to remove a Model object
  if (strMode.equalsIgnoreCase("disconnect"))
  {

     //get the table row ids of the Model objects selected
     String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");


     //get the relationship ids of the table row ids passed
     Map relIdMap=ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);

     String[] arrRelIds = (String[]) relIdMap.get("RelId");
     String[] strObjectIds = (String[]) relIdMap.get("ObjId");

     //Call the removeObjects method of ProductLineCommon to remove the selected object
     boolean bFlag = commonBean.removeObjects(context,arrRelIds);
%>
  <script language="javascript" type="text/javaScript">
  //<![CDATA[

<%
      //refresh the tree after disconnect
      for(int i=0;i<strObjectIds.length;i++)
      {
%>
  
  getTopWindow().deleteObjectFromTrees('<%=XSSUtil.encodeForJavaScript(context,strObjectIds[i])%>',true);
<%
      }
%>
   
    getTopWindow().refreshTablePage();
  //]]>
  </script>
<%

    }
  //Functionality to delete a Model object
  else if (strMode.equalsIgnoreCase("Delete"))
  {
    try
    {
      PropertyUtil.setGlobalRPEValue(context,"ContextRemoveCheckForMCF","TRUE");
      //Getting the table row ids of the selected objects from the request
      String arrRowIds[] = emxGetParameterValues(request, "emxTableRowId");
      String parentObjectID= emxGetParameter(request,"objectId");
      //Instantiating ProductLineUtil.java bean
      com.matrixone.apps.productline.ProductLineUtil productlineUtil = new com.matrixone.apps.productline.ProductLineUtil();
      com.matrixone.apps.productline.Model modelBean = (com.matrixone.apps.productline.Model)DomainObject.newInstance(context,ProductLineConstants.TYPE_MODEL,"ProductLine");
      //Getting the object ids from the table row ids
      String arrObjectIds[] = null;
      arrObjectIds = productlineUtil.getObjectIds(arrRowIds);


      // Calling the delete method of the Model bean
      boolean bReturnVal= modelBean.delete(context,arrObjectIds,parentObjectID);
%>
      <script language="javascript" type="text/javaScript">
     
<%
      for(int i=0;i<arrObjectIds.length;i++)
      {
%>
        <!-- hide JavaScript from non-JavaScript browsers -->
  
        getTopWindow().deleteObjectFromTrees('<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>',true);
<%
      }
%>
getTopWindow().refreshTablePage();
      </script>
<%
    }catch(Exception e){
      session.putValue("error.message", e.getMessage());
    }
  }
  //End of Delete Functionality


  //create   functionality to create new model objects
  else if (strMode.equalsIgnoreCase("Create"))
  {
     Model modelBean = new Model();
     String objId = null;
     
     String strPrefix = emxGetParameter(request, "txtModelPrefix");
     //Modifications for BUG: 376215 - Start
     //If is UNT Installed and property setting(ModelPrefixMandatoryAndUnique) is true
	 if( com.matrixone.apps.domain.util.FrameworkUtil.isSuiteRegistered(context,"appInstallTypeUnitTracking",false,null,null) ){
		try{     
			 String propVal =EnoviaResourceBundle.getProperty(context,"emxUnitTracking.Model.ModelPrefixMandatoryAndUnique");
	    	 if(propVal!= null && propVal.equalsIgnoreCase("true")) {
	       		result =  modelBean.checkModelPrefix(context, strPrefix);
		     }
		}catch(Exception e){}
	 }
	 //End of modifications - 376215
     if(!result)
     {
         %>
         <script language="javascript" type="text/javaScript">
          alert("<%=i18nStringNowUtil("emxProductLine.Model.ObjectCannotBeCreated",bundle,acceptLanguage)%>");
          parent.window.closeWindow();          
        
         </script>
         <%
     }
     else
     {
         com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean();
         formBean.processForm(session,request);

         //Calling the create Model  Method of Model.java
         objId = modelBean.createModel(context,formBean);

    	  /* Start-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility on 11th july 2007*/

    	 ProductLineCommon plcBean = new ProductLineCommon();
    	 String strDesResID = emxGetParameter(request, "txtDRId");
    	  if (strDesResID != null && !"".equals(strDesResID) )
    		{
    	  		plcBean.connectRDO(context,objId,strDesResID);
    			/*Start : Added by 3dPLM to connect product with Design Responsibility*/
    			DomainObject objModel = new DomainObject(objId.toString());
    	  		
	   			 final String SELECT_PARENT_PRODUCT = ("from["+ ProductLineConstants.RELATIONSHIP_PRODUCTS+"].to.id");
				 final String SELECT_PARENT_MAIN_PRODUCT = ("from["+ ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT+"].to.id");
				 String objProductId="";
				 java.util.Map  mapContext = objModel.getInfo(context, new StringList(SELECT_PARENT_PRODUCT));
				 if(mapContext.containsKey(SELECT_PARENT_PRODUCT))
					 objProductId = (String)mapContext.get(SELECT_PARENT_PRODUCT);
				 else if(mapContext.containsKey(SELECT_PARENT_MAIN_PRODUCT))
					 objProductId = (String)mapContext.get(SELECT_PARENT_MAIN_PRODUCT);


    			 plcBean.connectRDO(context,objProductId,strDesResID);
    			/*End : Added by 3dPLM to connect product with Design Responsibility*/			
    		}
          /* End-Added by Amarpreet Singh 3dPLM for addition of Design Responsibility*/
          
          String strAction = emxGetParameter(request,"PRCFSParam2");
     
     String strActionParentOId = (String)formBean.getElementValue("txtPLId");
     //if the call is made from actions tab
     if (strAction.equalsIgnoreCase("actions"))
     {
%>
        <!--Javascript for opening the tree with the object Id of the object that has been created-->
    <script language="javascript" type="text/javaScript">

    //nextgenUi Changes need to take out "mode=insert" as this independent of context
        var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
        contentFrameObj.document.location.href = "../common/emxTree.jsp?objectId=<%=XSSUtil.encodeForURL(context,objId)%>&jsTreeID=<%=XSSUtil.encodeForURL(context,strTreeID)%>";
        parent.window.closeWindow();
        </script>
<%
     }
     else
     {
          /*Begin of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/
              String strObjId = emxGetParameter(request, "objectId");
              String strRelName = modelBean.getRelName(context,strObjId);
              String strSelectRelId = "to["+strRelName+"].id";
              
              DomainObject domObjModel = DomainObject.newInstance(context,objId);
              String strRelId = domObjModel.getInfo(context,strSelectRelId);
           /*End of add by:Raman,Enovia MatrixOne for Bug # 298000 on 5/12/2005*/
 

     
%>
          <!--Opening the tree when creating from under a context-->
    <script language="javascript" type="text/javaScript">
         var contentFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");
        if(contentFrameObj.addStructureTreeNode)
        contentFrameObj.addStructureTreeNode("<%=objId%>","<%=XSSUtil.encodeForURL(context,strObjId)%>","<%=XSSUtil.encodeForURL(context,strTreeID)%>","Productline");
        try
        {        
            var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"_top");
            topFrameObj.window.focus();
        }catch(e){
            //alert if anything other than permission denied
            if(-2146828218 != e.number){
               alert(e.description)
            }
        }        
        parent.window.closeWindow();
          </script>
<%
      
      }
    }
    
     
  }

  else if(strMode.equalsIgnoreCase("Form"))
  {
  try
  {
%>
      <%@include file = "PrimaryImageInclude.inc"%>
<%
  }catch(Exception e){
        session.putValue("error.message", e.getMessage());
  }
  }

}catch(Exception e)
{
   
   bIsError=true;
   String alertString = "emxProduct.Alert." + e.getMessage();
   String i18nErrorMessage = i18nStringNowUtil(alertString,bundle,acceptLanguage);
   //Fix for IR-066633V6R2011x STARTS
  if ("".equals(i18nErrorMessage)){
	   
     i18nErrorMessage = e.getMessage();
   }
   i18nErrorMessage = i18nErrorMessage.trim();   
   if(i18nErrorMessage.contains("1500789")){;
	  // String strModelName = emxGetParameter(request, "txtName");
	   String[] strModelName = new String[1];
	   strModelName[0]=emxGetParameter(request, "txtName");;               
	   i18nErrorMessage= MessageUtil.getMessage(context, null,
    		 "emxProductLine.Model.BusinessObjMsg",
    		 strModelName, null,  context.getLocale(),
               "emxProductLineStringResource");	   
   }
   emxNavErrorObject.addMessage(i18nErrorMessage); 
   //Fix for IR-066633V6R2011x ENDS
   //emxNavErrorObject.addMessage(e.getMessage()); 
   %>

   <script language="javascript" type="text/javaScript"></script>
   <script>
  
   
    <%
  if (!strMode.equalsIgnoreCase("create") )
    {
      session.putValue("error.message", i18nErrorMessage);
   %>
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
  //IR-037303V6R2011 in case of create Model return error, need to reload the URL for next create model to work
  if (bIsError==true && strMode.equalsIgnoreCase("create") && result )
  {
%>
    <script language="javascript" type="text/javaScript">
    var pc = findFrame(parent, 'pagecontent');
    pc.clicked = false;   
    parent.turnOffProgress();
      history.back();
    </script>
<%
  }
%>


<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
