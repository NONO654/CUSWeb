<%--
  PLCHierarchyProductCreatePreProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%--Common Include File --%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties" %>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.productline.DerivationUtil"%>
<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  boolean bIsError=false;
  try
  {
	  String strLanguage      = context.getSession().getLanguage();
	  String strDefaultType   = EnoviaResourceBundle.getProperty(context,"ProductLine.ProductDerivation.DefaultType");    
	  String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProdutLine.RowSelect.Single", strLanguage); 
	  String strInactivePL      = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.InactiveProductLine", strLanguage);
	  String strInactiveModel   = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.InactiveModel", strLanguage);
	  String strInactiveProduct   = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.InactiveProduct", strLanguage);
      String strCreationType  = strDefaultType;
      String strHelpMarker    = emxGetParameter(request, "HelpMarker");
      String strMode          = emxGetParameter(request,"mode");
      String strTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
      StringList lstPLChildTypes      = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCT_LINE);
      StringList lstModelChildTypes   = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_MODEL);
      StringList lstProductChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTS);
      String strProductFrozenStates   = EnoviaResourceBundle.getProperty(context, "ProductLine.FrozenStates.type_Products");
      String[] arrProductFrozenStates = strProductFrozenStates.split(",");
      StringList lstProductFrozenStates = new StringList();
      ArrayList<String> arrList         = new ArrayList<String>(Arrays.asList(arrProductFrozenStates));
      String strContextParentOID        = emxGetParameter(request, "parentOID");
      
      for(String strSymbName : arrList)
      {
    	  lstProductFrozenStates.add(strSymbName.substring(strSymbName.lastIndexOf("_")+1));
      }
      
      if(strTableRowIds.length == 1)
	  {
	      StringList strTableIdArr = FrameworkUtil.split(strTableRowIds[0].toString(), "|");
	      String     strObjectId   = "";
	      
	      if(strTableIdArr.size() >= 4){
	        strObjectId = (String)strTableIdArr.get(1);
	      }else{
	        strObjectId = (String)strTableIdArr.get(0);
	      }
	      DomainObject domObject = new DomainObject(strObjectId);
	      StringList      lstSelect    = new StringList();
		  lstSelect.add(DomainObject.SELECT_TYPE);
		  lstSelect.add(DomainObject.SELECT_CURRENT);
		  Map map = (Map) domObject.getInfo(context, lstSelect);
	      String strType = (String)map.get(DomainObject.SELECT_TYPE);
	      String strState = (String)map.get(DomainObject.SELECT_CURRENT);
	      
	      if("CreateProduct".equals(strMode))
	      {
	    	  String strAlertMessage = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBePLForNewProduct", strLanguage);
	    	  if(lstPLChildTypes.contains(strType))
	    	  {
	    		  if(!ProductLineConstants.STATE_INACTIVE.equals(strState)){
%>   	 
		           <Script language="javascript" type="text/javaScript">
		           var submitURL = "../common/emxCreate.jsp?type=type_Products&typeChooser=true&autoNameChecked=false&nameField=both&ContextParentOID=<%=XSSUtil.encodeForURL(context, strContextParentOID)%>&form=type_CreateProduct&suiteKey=ProductLine&header=emxProduct.Heading.ProductCreate&HelpMarker=emxhelpproductcreate&submitAction=none&postProcessJPO=emxProduct:createModelAndConnectToProductLine&UIContext=ProductLine&objectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&postProcessURL=../productline/PLCHierarchyProductCreatePostProcess.jsp?mode=<%=XSSUtil.encodeForURL(context, strMode)%>";
		           getTopWindow().showSlideInDialog(submitURL, "false");
		           </Script>  	  
<%    	  
	    	  
	    		  }else{
%>
	    		   <script language="javascript" type="text/javaScript">
	    		   alert("<%=strInactivePL%>");
	    		   </script>
<%		    			  
	    		  }
	    	  }
	    	  else
	    	  {
%>   	 
	  	       <Script language="javascript" type="text/javaScript">
	  	       alert("<%=strAlertMessage%>");
	  	       </Script>  	  
<%     		  
	    	  }
	      }
	      else if("CreateDerivation".equals(strMode))
	      {
	    	  String heading         = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Derivation.CreateDerivation.FormHeading",strLanguage);
	    	  String strAlertMessage = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBeProductForDerivation", strLanguage);
	    	  String DerivationType  = "Derivation";
	    	  String strParentOID    = (String)strTableIdArr.get(1);
	    	  String strLevel        = (String)strTableIdArr.get(2);
	    	  Product pbean     = new Product(strObjectId);
	          String strModelId = pbean.getModelId(context);
	          
              if(lstProductChildTypes.contains(strType))
	    	  {
	          // To check user has modify and fromconnect Access to Model
	          String errCreateProduct = EnoviaResourceBundle.getProperty(context,"ProductLine",
	          		"emxProduct.Error.CreateProduct", strLanguage);
	          BusinessObject boModel = new BusinessObject(strModelId);
	          Access  accessObject   = boModel.getAccessMask(context);
	          boolean isModifyAccess = accessObject.hasModifyAccess();
	          boolean isFromConnectAccess = accessObject.hasFromConnectAccess();
	          
    	          if(!isModifyAccess || !isFromConnectAccess) {
	          	%>
	              <script language="javascript" type="text/javaScript">
	                   alert("<xss:encodeForJavaScript><%=errCreateProduct%></xss:encodeForJavaScript>");
	              </script>
	              <%
    	          }else{
%>    		  
		           <script language="javascript" type="text/javaScript">
		           var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=true&autoNameChecked=false&ContextParentOID=<%=XSSUtil.encodeForURL(context, strContextParentOID)%>&nameField=both&vaultChooser=false&copyObjectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&form=PLCCreateProductDerivationForm&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&parentOID=<%=XSSUtil.encodeForURL(context,strParentOID)%>&objectID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&modelID=<%=XSSUtil.encodeForURL(context,strModelId)%>&isRootProduct=false&UIContext=product&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&Level=<%=XSSUtil.encodeForURL(context,strLevel)%>&preProcessJavaScript=setNameValueOnLoad&createJPO=emxProduct:createProductDerivation&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&postProcessURL=../productline/PLCHierarchyProductCreatePostProcess.jsp?mode=<%=XSSUtil.encodeForURL(context, strMode)%>&submitAction=xmlMessage"; 
		           getTopWindow().showSlideInDialog(submitURL, "false");
		           </script>
<% 		
				  }
	    	  }
	    	  else
	    	  {
%>   	 
	    	   <Script language="javascript" type="text/javaScript">
	    	   alert("<%=strAlertMessage%>");
	    	   </Script>  	  
<%      		  
	    	  }
	      }
	      else if("CreateRevision".equals(strMode))
	      {
	    	  String heading         = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Derivation.CreateRevision.FormHeading",strLanguage);
	    	  String strAlertMessage = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBeModelForRevision", strLanguage);
	    	  String DerivationType  = "Revision";
	    	  String strParentOID    = (String)strTableIdArr.get(strTableIdArr.size() - 3);
	    	  String strLevel        = (String)strTableIdArr.get(strTableIdArr.size() - 1);
	    	  String strCannotCreateRevision  = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Derivation.Create.CannotCreateRevision", strLanguage);
	    	  String strModelId        = "";
	    	  String strLastRevisionId = "";	
	    	  boolean isRootProduct    = true;
	          boolean isModelContext   = lstModelChildTypes.contains(strType);
	          String strCopyObjectId   = "";
	          String strModelBO        = "";
	          
	          if(lstPLChildTypes.contains(strType))
	          {
	        	  %>
	              <script language="javascript" type="text/javaScript">
	                   alert("<xss:encodeForJavaScript><%=strAlertMessage%></xss:encodeForJavaScript>");
	              </script>
	              <%
	          }
	          else
	          {
		          if(isModelContext)
		          {
		        	  DomainObject domObj = new DomainObject(strObjectId);
		        	  String    strRootId = domObj.getInfo(context, "from[" + ProductLineConstants.RELATIONSHIP_MAIN_PRODUCT + "].to.id");
		        	  
		        	  if(ProductLineCommon.isNotNull(strRootId)){
		        	  isRootProduct     = false;	  
		        	  strLastRevisionId = DerivationUtil.getLastRevision(context, strRootId);
		        	  strCopyObjectId   = strLastRevisionId;
		        	  }
		        	  strModelBO = strObjectId;
		          }
		          else
		          {
		        	  Product pbean = new Product(strObjectId);
		              strModelId    = pbean.getModelId(context);
		              strModelBO    = strModelId;
		          }
		          
		          // To check user has modify and fromconnect Access to Model
		          String errCreateProduct = EnoviaResourceBundle.getProperty(context,"ProductLine",
		          		"emxProduct.Error.CreateProduct", strLanguage);
		          BusinessObject boModel = new BusinessObject(strModelBO);
		          Access  accessObject   = boModel.getAccessMask(context);
		          boolean isModifyAccess = accessObject.hasModifyAccess();
		          boolean isFromConnectAccess = accessObject.hasFromConnectAccess();
		          
		          if(!isModifyAccess || !isFromConnectAccess)
		          {
		          	%>
		              <script language="javascript" type="text/javaScript">
		                   alert("<xss:encodeForJavaScript><%=errCreateProduct%></xss:encodeForJavaScript>");
		              </script>
		            <%
		          }
		          else if(lstProductChildTypes.contains(strType) || lstModelChildTypes.contains(strType))
		    	  {
		    		  if(DerivationUtil.isLastNodeInRevisionChain(context, strObjectId))
		    		  {
		    			  if(lstProductChildTypes.contains(strType)){
%>
			                  <script language="javscript" type="text/javaScript">
			                  var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=true&ContextParentOID=<%=XSSUtil.encodeForURL(context,strContextParentOID)%>&autoNameChecked=false&nameField=both&vaultChooser=false&form=PLCCreateProductDerivationForm&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strObjectId)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&parentOID=<%=XSSUtil.encodeForURL(context,strParentOID)%>&objectID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&modelID=<%=XSSUtil.encodeForURL(context,strModelId)%>&isRootProduct=false&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&UIContext=product&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&Level=<%=XSSUtil.encodeForURL(context,strLevel)%>&preProcessJavaScript=setNameValueOnLoad&createJPO=emxProduct:createProductDerivation&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&postProcessURL=../productline/PLCHierarchyProductCreatePostProcess.jsp?mode=<%=XSSUtil.encodeForURL(context,strMode)%>&submitAction=xmlMessage";
			                  getTopWindow().showSlideInDialog(submitURL, "false");
			                  </script>
<%    	              
						  } 
		    			  else
		    			  {
		    				  if(!ProductLineConstants.STATE_INACTIVE.equals(strState)){
%>
							  <Script language="javascript" type="text/javaScript">
							  var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=false&autoNameChecked=false&ContextParentOID=<%=XSSUtil.encodeForURL(context, strContextParentOID)%>&nameField=both&vaultChooser=false&form=PLCCreateProductDerivationForm&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&copyObjectId=<%=XSSUtil.encodeForURL(context,strCopyObjectId)%>&parentOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&HelpMarker=emxhelpproductrevise&submitAction=none&modelID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&isRootProduct=<%=isRootProduct%>&UIContext=model&DerivationType=<%=DerivationType%>&createJPO=emxProduct:createProductDerivation&Level=<%=XSSUtil.encodeForURL(context,strLevel)%>&objectID=<%=XSSUtil.encodeForURL(context,strLastRevisionId)%>&preProcessJavaScript=setNameValueOnLoad&postProcessURL=../productline/PLCHierarchyProductCreatePostProcess.jsp?mode=<%=XSSUtil.encodeForURL(context, strMode)%>";
							  getTopWindow().showSlideInDialog(submitURL, "false");
							  </Script>  	
<%  
		    				  }else{
%>
		    				  <script language="javascript" type="text/javaScript">
		    				  alert("<%=strInactiveModel%>");
		    				  </script>
<%	    					  
		    				  }  
		                  }
		    		  }
		    		  else
		    		  {
%>
		                  <script language="javascript" type="text/javaScript">
		                  alert("<%=strCannotCreateRevision%>");    
		                  </script>
<%
		    		  }
		    	  }
		    	  else
		    	  {
%>   	 
		    	        <Script language="javascript" type="text/javaScript">
		    	        alert("<%=strAlertMessage%>");
		    	        </Script>  	  
<%      		  
		    	  }
		       }
	      }
	    }
       else
       {
%>
         <script language="javascript" type="text/javaScript">
         alert("<%=strRowSelectSingle%>");
         </script>
<%		   
       }
  }
  catch(Exception e)
  {
	  bIsError=true;
	  session.putValue("error.message", e.getMessage());	  
  }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
