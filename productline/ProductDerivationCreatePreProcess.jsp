<%--
  ProductDerivationCreatePreProcess.jsp
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

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

                 
<%
boolean bIsError = false;

    try
    {	  
	    String strLanguage = context.getSession().getLanguage();      
        String strObjIdContext = emxGetParameter(request, "objectId");
        String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
        String strUIContext = emxGetParameter(request, "UIContext");
        String strHelpMarker = emxGetParameter(request, "HelpMarker");
        String strWrongParentType = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBeProductForDerivation", strLanguage);

        // Ids to be used later.
        String strObjectID = null;
        
        // Booleans for checking context
        boolean isProductContext = strUIContext.equals("product");
        boolean isModelContext = strUIContext.equals("model");
        boolean isProductLineContext = strUIContext.equals("ProductLine");
        		
        // Pass the Model along...
        String strModelId = "";
        if (isModelContext) {
            strModelId = strObjIdContext;
        } else if(isProductContext) {
        	String strProductId = strObjIdContext;
        	Product pbean = new Product(strProductId);
        	strModelId = pbean.getModelId(context);
        } else if(isProductLineContext){
        	StringList emxTableRowIds = FrameworkUtil.split(strTableRowIds[0], "|");
        	switch (emxTableRowIds.size()) {
    		case 3:
    			strModelId = (String)emxTableRowIds.get(0);
                strObjIdContext = strModelId;
    			break;
    			
    		case 4:
    			strModelId = (String)emxTableRowIds.get(0);
    			strObjIdContext = strModelId;
    			// the if condition on line 136 check for strTableRowIds to be null,
    			//thus there the strTableRowIds is assigned null, so that the same logic executes as if from a model context. 
                strTableRowIds = null;
    			break;
    		
    		default:
    			throw new Exception("Invalid emxTableRowId '" + emxTableRowIds + "'");
    		}
             if(strModelId != null && !(strModelId.isEmpty())) {
	             DomainObject parentObj =  new DomainObject(strModelId);
	             StringList objectSelectList = new StringList();
	               
	             StringBuilder typeKindProduct = new StringBuilder(50);
	             typeKindProduct.append("type.kindof[");
	             typeKindProduct.append(ProductLineConstants.TYPE_PRODUCTS);
	             typeKindProduct.append("]");
	             
	             StringBuilder typeKindModel = new StringBuilder(50);
	             typeKindModel.append("type.kindof[");
	             typeKindModel.append(ProductLineConstants.TYPE_MODEL);
	             typeKindModel.append("]");
	             
				 objectSelectList.addElement(typeKindProduct.toString());
				 objectSelectList.addElement(typeKindModel.toString());
	             Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
	             String typeProd = (String) parentInfoTable.get(typeKindProduct.toString());        
	             String typeModel = (String) parentInfoTable.get(typeKindProduct.toString());
	             if(!Boolean.valueOf(typeProd)){
	             %>
				<script language="javascript" type="text/javaScript">
	                   alert("<xss:encodeForJavaScript><%=strWrongParentType%></xss:encodeForJavaScript>");
	             </script>
<%
	                   return;
	             }
	              else {
	              	Product pbean = new Product(strModelId);
	              	strModelId = pbean.getModelId(context);
	              }
             }
        }
        		
        // Internationalized Strings
        String strCannotCreateRoot = EnoviaResourceBundle.getProperty(context,"ProductLine",
                "emxProduct.Derivation.Create.CannotCreateRoot", strLanguage);
        String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"ProductLine",
        		"emxProduct.Derivation.Create.SelectSingleRow", strLanguage);
        String heading = EnoviaResourceBundle.getProperty(context,"ProductLine",
        		"emxProduct.Derivation.CreateDerivation.FormHeading",strLanguage);
                
        // Relationships and selectables for queries
        String DerivationType = "Derivation";
        String RELATIONSHIP_MAIN_PRODUCT = PropertyUtil.getSchemaProperty(context, "relationship_MainProduct");
        String strMainProductSelectable = "from[" + RELATIONSHIP_MAIN_PRODUCT + "].id";
        String strDefaultType = EnoviaResourceBundle.getProperty(context,"ProductLine.ProductDerivation.DefaultType");        		
        String strCreationType = strDefaultType;
            
        // To check user has modify and fromconnect Access to Model
        String errCreateProduct = EnoviaResourceBundle.getProperty(context,"ProductLine",
        		"emxProduct.Error.CreateProduct", strLanguage);
        BusinessObject boModel = new BusinessObject(strModelId);
        Access  accessObject   = boModel.getAccessMask(context);
        boolean isModifyAccess = accessObject.hasModifyAccess();
        boolean isFromConnectAccess = accessObject.hasFromConnectAccess();
        
        // We do not allow multiple selections here.
        if (strTableRowIds != null && strTableRowIds.length > 1) {
            %>
            <script language="javascript" type="text/javaScript">
                  alert("<xss:encodeForJavaScript><%=strRowSelectSingle%></xss:encodeForJavaScript>");                
            </script>
           <%
        }
        else if(!isModifyAccess || !isFromConnectAccess)
        {
        	%>
            <script language="javascript" type="text/javaScript">
                 alert("<xss:encodeForJavaScript><%=errCreateProduct%></xss:encodeForJavaScript>");
            </script>
            <%
        }else if (strTableRowIds == null || strTableRowIds.length == 0) {

        	if (isModelContext || isProductLineContext) {

	        	// Check the Context object and find out whether there are any products attached
	            // to the Model.  If not, we are allowing the user to create the Root Product.
	            // Otherwise, we will be throwing an error.
	                    
	            DomainObject modelObj =  new DomainObject(strObjIdContext);
	            StringList objectSelectList = new StringList();
	            objectSelectList.addElement(DomainObject.SELECT_ID);      
	            objectSelectList.addElement(strMainProductSelectable);
	            Hashtable modelTable = (Hashtable) modelObj.getInfo(context, objectSelectList);
	            String strReturnId = (String)modelTable.get(strMainProductSelectable);   
	                          
	        	if (strReturnId == null || strReturnId.isEmpty()) {
                    // A return ID of null or empty means there is NO Product attached to the Model with the
                    // Main Product relationship.  The user must use Create Revision to create the Root Product.
                    %>
                    <script language="javascript" type="text/javaScript">
                        alert("<xss:encodeForJavaScript><%=strCannotCreateRoot%></xss:encodeForJavaScript>");                
                    </script>
                    <%
	        	} else {
                    %>
                    <script language="javascript" type="text/javaScript">
                        alert("<xss:encodeForJavaScript><%=strRowSelectSingle%></xss:encodeForJavaScript>");                
                    </script>
                    <%
         	    }
        	} else {
                %>
                <script language="javascript" type="text/javaScript">
                    alert("<xss:encodeForJavaScript><%=strRowSelectSingle%></xss:encodeForJavaScript>");                
                </script>
                <%
            }
        } else {

            // Have we selected from the root level?
            boolean isRootSelected=false;
            StringList slLevels = FrameworkUtil.split(strTableRowIds[0] , "|");
            String strLevel = slLevels.get(slLevels.size()-1).toString();
            StringList slLevels2 = FrameworkUtil.split(strLevel , ",");
            if (slLevels2.size() == 2) {
                isRootSelected=true;
            }
                 
            // Single Selection for either Model or Product Context.
            StringTokenizer strTokenizer = new StringTokenizer(strTableRowIds[0] , "|"); 
            if (strTableRowIds[0].indexOf("|") > 0) {                       
                String temp = strTokenizer.nextToken();
            }
            strObjectID = strTokenizer.nextToken();
            
            // Get the type of the Selection
            DomainObject selectionObj =  new DomainObject(strObjectID);
            StringList selectList = new StringList();
            selectList.addElement(DomainObject.SELECT_TYPE);
            Hashtable objTable = (Hashtable) selectionObj.getInfo(context, selectList);
            String strType = (String)objTable.get(DomainObject.SELECT_TYPE);   
        	
            // TO CREATE DERIVATION
	        %>
	        <body>   
	            <form name="ProductDerivationCreate" method="post">
	                <script language="Javascript" type="text/javaScript">
	                    var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=true&autoNameChecked=false&nameField=both&vaultChooser=false&form=PLCCreateProductDerivationForm&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&modelID=<%=XSSUtil.encodeForURL(context,strModelId)%>&isRootProduct=false&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&isRootSelected=<%=XSSUtil.encodeForURL(context,String.valueOf(isRootSelected))%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&preProcessJavaScript=setNameValueOnLoad&createJPO=emxProduct:createProductDerivation&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&postProcessURL=../productline/ProductDerivationCreatePostProcess.jsp&submitAction=xmlMessage";
                        getTopWindow().showSlideInDialog(submitURL, "true");
	                </script>
	            </form>
	        </body>
	        <%
        }
        
    } catch(Exception e) {
        bIsError=true;
    	session.putValue("error.message", e.getMessage());
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
