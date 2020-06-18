<%--
  ProductVariantUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.domain.*" %>
<%@page import="com.matrixone.apps.productline.ProductLineConstants" %>
<%@page import="com.matrixone.apps.productline.ProductLineUtil" %>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import="com.matrixone.apps.configuration.ProductVariant" %>
<%@page import="com.matrixone.apps.domain.DomainObject" %>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Map"%>
<%@ page import="java.util.List"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="java.util.StringTokenizer"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>

<html>
    <body>
        <FORM name="ProductVariantUtil" method="post" id="ProductVariantUtil">
         <INPUT type="hidden" name="forNetscape" >
                &nbsp;
        </FORM>
    </body>

<%
    String strMode = "";
    boolean bIsError = false;
    
    String productId ="";

    //Get the mode called
    strMode = emxGetParameter(request, "mode");
    String jsTreeID = emxGetParameter(request, "jsTreeID");
    String objectId = emxGetParameter(request, "objectId");
    String productVariantId = "";
    String strRelId = emxGetParameter(request, "relId");
    String strIsClone = emxGetParameter(request, "clone");
    String strContext = emxGetParameter(request, "context");
    
    String strTimeStamp = emxGetParameter(request, "timeStamp");
    String strSelectedFeaturesFromSession = emxGetParameter(request, "selectedFeatures");
    String selectedData = emxGetParameter(request, "selectedData");
    HashMap attributeHolder = new HashMap();

    try{
    //ProductVariant productVariantBean = (ProductVariant) DomainObject.newInstance(context,ConfigurationConstants.TYPE_PRODUCT_VARIANT,"Configuration");
      ProductVariant productVariantBean = new com.matrixone.apps.configuration.ProductVariant();
  //edit functionality UNDER DEVELOPMENT
    if (strMode.equalsIgnoreCase("edit"))
    {
      try
      {
        String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        String arrObjectIds[] = null;
        if (arrTableRowIds[0].indexOf("|") > 0 )
        {
         arrObjectIds = ProductLineUtil.getObjectIds(arrTableRowIds);
         }
        else
        {
          arrObjectIds   = arrTableRowIds;
        }
       	  productId = arrObjectIds[0];
    	  DomainObject domProduct = new DomainObject(productId);
    	  StringList sl = new StringList(2);
    	  sl.addElement(DomainConstants.SELECT_CURRENT);
    	  sl.addElement("from["+ConfigurationConstants.RELATIONSHIP_PRODUCT_VERSION+"].to.id");
    	  List lstProductStates =  domProduct.getStates(context);
    	  Map prodInfo = domProduct.getInfo(context,sl);
    	  String productState =  (String)prodInfo.get(DomainConstants.SELECT_CURRENT);
    	  boolean bReleased = false;
  	      for(int iCnt = 0; iCnt < lstProductStates.size(); iCnt++)
  	      {
  	      	State prodLifecycleState = (State)lstProductStates.get(iCnt);
  	      	String strState =  prodLifecycleState.getName();
  	     	 if(strState.equals(ConfigurationConstants.STATE_RELEASE) )
  	    	 {
  	     	     bReleased = true;
  	    	 }
  	      	if(strState.equals(productState))
   	        {
  	      	  if(bReleased)
	          {
%>
	              <SCRIPT language="javascript" type="text/javaScript">
			   	      var AlertMsg = "<%=i18nNow.getI18nString("emxProduct.Alert.ProductInRelease",bundle,acceptLanguage)%>"
		    	      alert(AlertMsg);
	           	</SCRIPT>
	         <%
	         }
	         else
	         {%>
   <SCRIPT language="javascript" type="text/javaScript">
      var formName = document.getElementById("ProductVariantUtil");
      var strProductVariantId = '<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[0])%>';
      var strparentID = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
      var strMode = '<%=XSSUtil.encodeForJavaScript(context,strMode)%>';
    				 var url = "ProductVariantFS.jsp?PRCFSParam2=edit&objectId="+strProductVariantId+"&parentID="+strparentID+"&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&jsTreeID=<%=XSSUtil.encodeForURL(context,jsTreeID)%>&functionality=ProductVariantEditOptionsContentFSInstance&relId=<%=XSSUtil.encodeForURL(context,strRelId)%>&suiteKey=Configuration&mode="+strMode;
					getTopWindow().location.href = url;    				 
   				// showModalDialog(url,730,600);
   </script>
	         <%}
	         	break;
	          }
   	        }
	         %>
   				

<%
      }
      catch(Exception e)
      {
        session.putValue("error.message", e.getMessage());
      }
    }
  //end of edit functionality




    if (strMode.equalsIgnoreCase("viewEdit"))
    {
%>

   <SCRIPT language="javascript" type="text/javaScript">
      var formName = document.getElementById("ProductVariantUtil");
      var strMode = '<%=XSSUtil.encodeForJavaScript(context,strMode)%>';
      var strObjId = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
      formName.action="../configuration/ProductVariantFS.jsp?objectId="+strObjId+"&mode="+strMode;
      formName.submit();
   </script>
<%
   }

    //delete Functionality
    if (strMode.equalsIgnoreCase("delete")||strMode.equalsIgnoreCase("viewDelete"))
    {
      try
      {
    	PropertyUtil.setGlobalRPEValue(context,"ContextRemoveCheckForMCF","TRUE");
        String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
        String arrObjectIds[] = null;
        boolean bIsFromTree = false;
        if (arrTableRowIds[0].indexOf("|") > 0 )
        {
          arrObjectIds = ProductLineUtil.getObjectIds(arrTableRowIds);
          bIsFromTree = true;
        }
        else
        {
          arrObjectIds   = arrTableRowIds;
        }
        boolean bFlag = productVariantBean.delete(context,arrObjectIds);
        if(strMode.equalsIgnoreCase("viewDelete"))
        {
            %>
       <script language="javascript" type="text/javaScript">
         parent.getWindowOpener().location.reload();
         getTopWindow().window.closeWindow();
       </script>

<%      
        }
        
        else if (bIsFromTree)
        {
        %>
       <script language="javascript" type="text/javaScript">
       <%
       for(int i=0;i<arrObjectIds.length;i++)
       {
       %>
            <!-- hide JavaScript from non-JavaScript browsers -->
            var tree = window.getTopWindow().objDetailsTree;
            tree.deleteObject ("<%=XSSUtil.encodeForJavaScript(context,arrObjectIds[i])%>");
        <%
       }
       %>
      refreshTreeDetailsPage();
    //releasing mouse events after Deletion
     </script>
        <%
        }
        else
        {
        %>
            <script language="javascript" type="text/javaScript">
            refreshContentPage();
           //releasing mouse events after Deletion
          </script>
        <%
        }
      }
      catch(Exception e)
      {
   		if (e.toString()!=null && e.toString().indexOf("Check trigger blocked event")< 0) {
        session.putValue("error.message", e.getMessage());
		}
      }
    }
// End of Delete functionality

//Begin Create functionality
else if(strMode .equalsIgnoreCase("featureSelect")) 
{
    //get the field values
      String strObjId           = emxGetParameter(request, "objectId");
      String strName           = emxGetParameter(request, "txtName");
      //strName=hiddenStrName;
      String strDescription    = emxGetParameter(request, "txtDescription");
      String strPolicy         = emxGetParameter(request, "txtProductVariantPolicy");
      String strType         = emxGetParameter(request, "txtType");
      String strVault          = emxGetParameter(request, "txtProductVariantVault");
      String strOwner          = emxGetParameter(request, "txtProductVariantOwner");
      String strMarketingName    = emxGetParameter(request, "txtMarketingName");
      String hiddenTxtMarketingName =  emxGetParameter(request , "hiddenTxtMarketingName");
      strMarketingName = hiddenTxtMarketingName;
      String strMarketingText    = emxGetParameter(request, "txtProductMarketingText");
      String strProductVariantSEDate    = emxGetParameter(request, "txtProductVariantSEDate");
      String strProductVariantEEDate    = emxGetParameter(request, "txtProductVariantEEDate");
      
      String strProductVariantSEDateValue    = emxGetParameter(request, "txtProductVariantSEDate_msvalue");
      String strProductVariantEEDateValue    = emxGetParameter(request, "txtProductVariantEEDate_msvalue");

      String strradProductWebAvailability    = emxGetParameter(request, "radProductWebAvailability");
      String strDesResDisplay    = emxGetParameter(request, "txtProductVariantDesignResponsibility");
      String strDesRespName    = emxGetParameter(request, "txtProductVariantDesResp");
      String strRevision    = emxGetParameter(request, "revision");
      String strProductName    = emxGetParameter(request, "txtProductName");
      String hiddenProductName  = emxGetParameter(request,"hiddenProductName" );
      strProductName = hiddenProductName;
      //for Clone functionality
      String strProductVariantName    = emxGetParameter(request, "txtSourceProductVariant");
      session.setAttribute("productVariantName",strProductVariantName);
      String strProductVariantId    = emxGetParameter(request, "productVariantId");
      String  hasTechnical = emxGetParameter(request, "hasTechnicalFeatures");

	  DomainObject dom = new DomainObject(strObjId);
	  StringList strListProductVariantMarketingNames = dom.getInfoList(context,"from["+ProductLineConstants.RELATIONSHIP_PRODUCT_VERSION+"].to.attribute["+ProductLineConstants.ATTRIBUTE_MARKETING_NAME+"]");
	  boolean strDuplicateProductVariant = false;
      
      for(int i=0;i<strListProductVariantMarketingNames.size();i++){
          if(strMarketingName.equalsIgnoreCase(strListProductVariantMarketingNames.get(i).toString())){
              strDuplicateProductVariant =true;
          }
      }
      
      attributeHolder.put("parentObjId",strObjId);
      attributeHolder.put("strName",strName);
      attributeHolder.put("strDescription",strDescription);
      attributeHolder.put("strPolicy",strPolicy);
      attributeHolder.put("strType",strType);
      attributeHolder.put("strVault",strVault);
      attributeHolder.put("strOwner",strOwner);
      attributeHolder.put("strMarketingName",strMarketingName);
      attributeHolder.put("strMarketingText",strMarketingText);
      attributeHolder.put("strProductVariantDesResp",strDesResDisplay);
      attributeHolder.put("strProductVariantSEDate",strProductVariantSEDate);
      attributeHolder.put("strProductVariantEEDate",strProductVariantEEDate);
      attributeHolder.put("strProductVariantSEDateValue",strProductVariantSEDateValue);
      attributeHolder.put("strProductVariantEEDateValue",strProductVariantEEDateValue);
      attributeHolder.put("strradProductWebAvailability",strradProductWebAvailability);
      attributeHolder.put("strRevision",strRevision);
      attributeHolder.put("strProductName",strProductName);
      attributeHolder.put("strDesRespName",strDesRespName);
      attributeHolder.put("strProductVariantId",strProductVariantId);

      session.removeAttribute("productVariant");
      
      session.setAttribute("productVariant", attributeHolder);

      
        
     
%>

   <SCRIPT language="javascript" type="text/javaScript">
      var formName = document.getElementById("ProductVariantUtil");
      var strTreeId = '<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>';
      var strRelId = '<%=XSSUtil.encodeForJavaScript(context,strRelId)%>';
      var strObjectId = '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
      var strVariantName = "<%=XSSUtil.encodeForJavaScript(context,strName)%>";
      var strProductVariantId = '<%=XSSUtil.encodeForJavaScript(context,strProductVariantId)%>';
      var hasTechnical = '<%=XSSUtil.encodeForJavaScript(context,hasTechnical)%>';
      var strMode = '<%=XSSUtil.encodeForJavaScript(context,strMode)%>';
      var strContext = '<%=XSSUtil.encodeForJavaScript(context,strContext)%>';
      var selectedData = '<%=XSSUtil.encodeForJavaScript(context,selectedData)%>';      
      var timeStamp = '<%=XSSUtil.encodeForJavaScript(context,strTimeStamp)%>';
      //XSSOK
      var duplicateProductVariant = "<%=strDuplicateProductVariant%>";
      var duplicatealert = "<%=i18nNow.getI18nString("emxConfiguration.label.ProductVariant",bundle,acceptLanguage)%> "+"\""+strVariantName +"\""+
      						" <%=i18nNow.getI18nString("emxProduct.Alert.ProductVariant.DuplicateProductVariant",bundle,acceptLanguage)%>";
 				    
      if (duplicateProductVariant=="true")
      {
         var AlertMsg = null;
                 
         alert(duplicatealert);
         if(strContext=="clone")
         {
            formName.action="../components/emxCommonFS.jsp?mode=clone&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCloneFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+strTreeId+"&relId="+strRelId+"&objectId="+strObjectId+"&FTRParam=getFromSession&productVariantId="+strProductVariantId+"&timeStamp="+timeStamp+"&selectedData="+selectedData;
         }
         else if(strContext=="viewClone")
         {
            formName.action="../components/emxCommonFS.jsp?mode=viewClone&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCloneFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+strTreeId+"&relId="+strRelId+"&objectId="+strObjectId+"&FTRParam=getFromSession&timeStamp="+timeStamp+"&selectedData="+selectedData;
         }
         else
         {
            formName.action="../components/emxCommonFS.jsp?mode=create&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&functionality=ProductVariantCreateFSInstance&PRCFSParam1=ProductVariant&jsTreeID="+strTreeId+"&relId="+strRelId+"&objectId="+strObjectId+"&FTRParam=getFromSession&timeStamp="+timeStamp+"&selectedData="+selectedData;
         }
      formName.submit();
     }
     else{
      formName.action="../configuration/ProductVariantFS.jsp?jsTreeID="+strTreeId+"&relId="+strRelId+"&objectId="+strObjectId+"&variantName=encodeURIComponent(strVariantName)&productVariantId="+strProductVariantId+"&selectedData=<%=XSSUtil.encodeForURL(context,selectedData)%>&clone=<%=XSSUtil.encodeForURL(context,strIsClone)%>&mode=create&functionality=ProductVariantCreateFlatViewContentFSInstance&suiteKey=Configuration&FSmode=featureSelect&PRCFSParam2=createNewProductVariant&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&context=<%=XSSUtil.encodeForURL(context,strContext)%>&selectedFeatures=<%=XSSUtil.encodeForURL(context,strSelectedFeaturesFromSession)%>&timeStamp="+timeStamp;
      formName.submit();
     }
   </script>
<%
}
else if(strMode.equals("cleanupsession")) 
{
      session.removeAttribute("attributeHolder");
}
else if(strMode.equals("ViewProductVariant")) 
{
	String struiContext = emxGetParameter(request, "uiContext");
	
	String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  StringBuffer bn = new StringBuffer();
	  if(struiContext==null || !"LogicalFeatures".equalsIgnoreCase(struiContext)){
	  if(arrTableRowIds != null){
		  StringList strObjectIdList = new StringList();
	      StringTokenizer strTokenizer = null;
	      String strObjectID = "";
	      for(int i=0;i<arrTableRowIds.length;i++)
		    {
		      
		    	if(arrTableRowIds[i].indexOf("|") > 0){
		              strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
		              strTokenizer.nextToken();				              				              
		              strObjectID = strTokenizer.nextToken() ;				              
		              strObjectIdList.add(strObjectID);
		          }
		          else{
		        	  strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
		        	  strObjectID = strTokenizer.nextToken() ;
		        	  strObjectIdList.add(strObjectID);				        	  
		          }
		    }
	      for(int i=0;i<strObjectIdList.size();i++)
	      {   
	          bn.append((String)strObjectIdList.get(i));
	          if(i<(strObjectIdList.size()-1)){
	           bn.append(",");
	          }
	      }
	  }  
	}
    MapList productVariants = productVariantBean.getProductVariants(context,objectId);
    if (productVariants.size()==0)
    {
    %>
        <script language="Javascript">
          var AlertMsg = "<%=i18nNow.getI18nString("emxProduct.Alert.NoProductVariants",bundle,acceptLanguage)%>"
          alert(AlertMsg);
          window.closeWindow();
        </script>
<%    
    }
    else{
       // String strURL = "../common/emxIndentedTable.jsp?objectId="+objectId+"&expandProgram=LogicalFeature:getLogicalFeatureStructure&selectId="+bn.toString()+"&table=FTRViewProductVariants&header=emxProduct.Heading.ViewProductVariants&toolbar=FTRViewProductVariantToolBar&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&expandLevelFilterMenu=FTRExpandAllLevelFilter";
       String strURL = "../common/emxGridTable.jsp?expandLevelFilter=false&editLink=false&objectId="+objectId+"&freezePane=Display Name,Revision&rowJPO=emxProductVariant:getLogicalStrutcureForProductVariantGrid&colJPO=emxProductVariant:getProductVariantForGrid&selectId="+bn.toString()+"&table=FTRViewProductVariantsGridTable&HelpMarker=emxhelpviewproductvariants&header=emxProduct.Heading.ViewProductVariants&subHeader=&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&suiteKey=Configuration&expandLevelFilterMenu=FTRExpandAllLevelFilter";
%>      
        <script language="Javascript">
        var url = '<%=XSSUtil.encodeURLwithParsing(context,strURL)%>';
        showModalDialog(url,700,800,true,'Large');
        </script>
<%      
    }
}




//Create Functionality
else if(strMode .equalsIgnoreCase("createVariant")) 
{
    
      String strSelectedFeature = emxGetParameter(request, "logicalfeaturerels");
      HashMap prodVariant = (HashMap)session.getAttribute("productVariant");
      String strPFLUsage = emxGetParameter(request, "PFLUsage");
      prodVariant.put("FATUsage", strPFLUsage);
      prodVariant.put("strTimeStamp",strTimeStamp);
      strContext = emxGetParameter(request, "context");
      productVariantId = productVariantBean.create(context,prodVariant,strSelectedFeature);
      DomainObject domainobject = new DomainObject(productVariantId);
      String  strProductVariantRelId = domainobject.getInfo(context, "to["+ProductLineConstants.RELATIONSHIP_PRODUCT_VERSION+"].id");
     
%>
  <script language="javascript" type="text/javaScript">
     var strTreeId = '<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>';
     var strRelId = '<%=XSSUtil.encodeForJavaScript(context,strProductVariantRelId)%>';
     var productVariantId= '<%=XSSUtil.encodeForJavaScript(context,productVariantId)%>';
     var strContext = '<%=XSSUtil.encodeForJavaScript(context,strContext)%>';
     if(strContext=="viewCreate" ||strContext=="viewClone" )
     {
         parent.getWindowOpener().location.reload();
        
     }
     else
     {
    	   //For NextGen UI
	    var detailsDisplayFrame = findFrame(getTopWindow().getWindowOpener().parent.parent,'detailsDisplay');
	    getTopWindow().window.closeWindow();
    	detailsDisplayFrame.location.href = "../common/emxTree.jsp?objectId="+productVariantId+"&mode=insert&jsTreeID="+strTreeId+"&relId="+strRelId;
	 //top.getWindowOpener().parent.parent.location = "../common/emxTree.jsp?objectId="+productVariantId+"&mode=insert&jsTreeID="+strTreeId+"&relId="+strRelId;
         
     }
     
  //]]>
  </script>
<%
session.removeAttribute("productVariant");
}

else if(strMode .equalsIgnoreCase("editVariant")) 
{
     String strProductVariantId = emxGetParameter(request, "objectId");
     String strSelectedFeature = emxGetParameter(request, "logicalfeaturerels");
     String strUnSelectedFeature = emxGetParameter(request, "connectedrels");
     String strPFlIds = emxGetParameter(request, "PFLIds");
     String strPFLUsage = emxGetParameter(request, "PFLUsage");
     strContext = emxGetParameter(request, "context");
     productVariantBean.editvariant(context,strSelectedFeature,strUnSelectedFeature,strProductVariantId,strPFlIds,strPFLUsage);
     DomainObject domainobject = new DomainObject(strProductVariantId);
     String  strProductVariantRelId = domainobject.getInfo(context, "to["+ProductLineConstants.RELATIONSHIP_PRODUCT_VERSION+"].id");
     String isApply = emxGetParameter(request, "applyMode");

    
     
%>
  <script language="javascript" type="text/javaScript">
  var applyMode = '<%=XSSUtil.encodeForJavaScript(context,isApply)%>';
  var strTreeId = '<%=XSSUtil.encodeForJavaScript(context,jsTreeID)%>';
  var strRelId = '<%=XSSUtil.encodeForJavaScript(context,strProductVariantRelId)%>';
  var productVariantId= '<%=XSSUtil.encodeForJavaScript(context,objectId)%>';
  var strContext = '<%=XSSUtil.encodeForJavaScript(context,strContext)%>';
  if (applyMode == 'true')
  {
    getTopWindow().getTopWindow().location.href=getTopWindow().getTopWindow().location.href;      
  }
  else
  {
     var detailsDisplayFrame = findFrame(getTopWindow().getWindowOpener().parent.parent,'detailsDisplay');
     detailsDisplayFrame.location.href = "../common/emxTree.jsp?objectId="+productVariantId+"&mode=insert&jsTreeID="+strTreeId+"&relId="+strRelId;
  }   
  getTopWindow().window.closeWindow();
  </script>
<%
}

  }
  catch(Exception e)
  {
     session.putValue("error.message", e.getMessage());
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%
  if (bIsError==true)// && !(strMode.equalsIgnoreCase("delete") ||strMode.equalsIgnoreCase("Form")))

  {
%>
    <script language="javascript" type="text/javaScript">
 // NExtgenui
    var pc = findFrame(parent, 'pagecontent');
    pc.clicked = false;         
    parent.turnOffProgress();
      history.back();
    </script>
<%
  }
%>

</html>
