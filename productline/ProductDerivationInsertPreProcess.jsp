<%--
  ProductDerivationInsertPreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.productline.DerivationUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

                   
<%

boolean bIsError = false;
String action = "";
String msg = "";

try {   

    String strLanguage = context.getSession().getLanguage();      
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String strUIContext = emxGetParameter(request, "UIContext");
    String strHelpMarker = emxGetParameter(request, "HelpMarker");
    String strObjectID  = emxGetParameter(request, "objectId");
      
    // Booleans for checking context
    boolean isProductContext = strUIContext.equals("product");
    boolean isModelContext = strUIContext.equals("model");
    		
    String arrObjIds[] = null;
    String parentId = null;
     
    String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Derivation.InsertBefore.SelectSingleRow",strLanguage);
    String strRootProduct = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.InsertBefore.OnRoot", strLanguage);
    String strBeforeDerivation = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.InsertBefore.Derivation", strLanguage);
    String strFrozenProduct = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.InsertBefore.FrozenState", strLanguage);
    String strSelectProduct = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.InsertBefore.Product", strLanguage);
    
    String heading = "emxProduct.Derivation.InsertBefore.FormHeading";
    String formType = "PLCInsertProductDerivationForm";

    if(arrTableRowIds == null || (arrTableRowIds.length ==0 || arrTableRowIds.length > 1)) {
        %>
            <script language="javascript" type="text/javaScript">
                alert("<xss:encodeForJavaScript><%=strRowSelectSingle%></xss:encodeForJavaScript>");
            </script>
        <%       
    } else {
    	
    	// Have we selected from the root level?
        boolean isRootSelected=false;
        StringList slLevels = FrameworkUtil.split(arrTableRowIds[0] , "|");
        String strLevel = slLevels.get(slLevels.size()-1).toString();
        StringList slLevels2 = FrameworkUtil.split(strLevel , ",");
        if (slLevels2.size() == 2) {
            isRootSelected=true;
        }
             
        arrObjIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
        StringTokenizer st = new StringTokenizer(arrObjIds[0],"|");
        String strSelObjectID = st.nextToken();
        String strSelParentId = st.nextToken();
        
        StringList lstProductChildTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ProductLineConstants.TYPE_PRODUCTS);
		DomainObject domObject = DomainObject.newInstance(context, strSelObjectID);
		String strObjectType = domObject.getInfo(context, DomainConstants.SELECT_TYPE);
        if(lstProductChildTypes.contains(strObjectType))
        {
	        // Find out if we are the root node.
	        boolean isRoot = DerivationUtil.isRootNode(context, strSelObjectID);
	        boolean isFrozenProduct = Product.isFrozenState(context, strSelObjectID);
	        String strDerivationType = DerivationUtil.getDerivationType(context, strSelObjectID);
	        boolean isDerivation = strDerivationType.equals(DerivationUtil.DERIVATION_TYPE_DERIVATION);
	
	        if (isRoot) {
	            %>
	                <script language="javascript" type="text/javaScript">
	                    alert("<xss:encodeForJavaScript><%=strRootProduct%></xss:encodeForJavaScript>");
	                </script>
	            <%
	        } else if (isFrozenProduct) {
	            %>
	                <script language="javascript" type="text/javaScript">
	                    alert("<xss:encodeForJavaScript><%=strFrozenProduct%></xss:encodeForJavaScript>");
	                </script>
	            <%
	        } else if (!Product.isInsertBeforeDerivationEnabled(context) && isDerivation) {
	            %>
	                <script language="javascript" type="text/javaScript">
	                    alert("<xss:encodeForJavaScript><%=strBeforeDerivation%></xss:encodeForJavaScript>");
	                </script>
	            <%
	        } else {
	        	// Get the product Type
	            Product productBean = new Product(strSelObjectID);
	        	String strModelId = productBean.getModelId(context);
	            Map productDetails = productBean.getProductDetail(context);
	            String productType = (String)productDetails.get(DomainObject.SELECT_TYPE);
	            String strSymbolicName = FrameworkUtil.getAliasForAdmin(context,DomainConstants.SELECT_TYPE, productType, true);
	
	            // Get the product's parent information.              
	            Map parentProductDetails = productBean.getProductParent(context);
	            String parentProductId = (String)parentProductDetails.get(DomainObject.SELECT_ID);
	
	            %>
	            <body>   
	                <form name="ProductDerivationInsert" method="post">
	                    <script language="Javascript" type="text/javascript">
	                        var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strSymbolicName)%>&typeChooser=false&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&autoNameChecked=false&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,parentProductId)%>&derivedFromID=<%=XSSUtil.encodeForURL(context,parentProductId)%>&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&createJPO=emxProduct:insertProductDerivation&postProcessJPO=emxProduct:connectProductDerivationToModel&preProcessJavaScript=setNameValueOnLoad&isRootProduct=false&isRootSelected=<%=XSSUtil.encodeForURL(context,String.valueOf(isRootSelected))%>&modelID=<%=XSSUtil.encodeForURL(context,strModelId)%>&isFromProductContext=<%=XSSUtil.encodeForURL(context,String.valueOf(isProductContext))%>&submitAction=xmlMessage&postProcessURL=../productline/ProductDerivationInsertPostProcess.jsp&objectId=<%=strSelObjectID%>&Level=<%=strLevel%>&SelParentId=<%=strSelParentId%>";
	                        getTopWindow().showSlideInDialog(submitURL, "true");
	                    </script>
	                </form>
	            </body>
	            <%
	        }
        }
        else
        {
%>
             <script language="javascript" type="text/javaScript">
                 alert("<%=strSelectProduct%>");
             </script>
<%        	
        }
    }
} catch(Exception e) {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
