<%--
  ProductRevisionCreatePreProcess.jsp
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
<%@page import="com.matrixone.apps.productline.DerivationUtil"%>
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
        String strWrongParentType = EnoviaResourceBundle.getProperty(context,"ProductLine","emxProduct.Alert.ParentShouldBeModelForRevision", strLanguage);

        // Ids to be used later.
        String strObjectID = null;
        
        // Booleans for checking context
        boolean isProductContext = strUIContext.equals("product");
        boolean isModelContext = strUIContext.equals("model");
        		
        // Pass the Model along...
        String strModelId = "";
        String strProductId = "";
        if (isModelContext) {
            strModelId = strObjIdContext;
        } else if(isProductContext) {
        	strProductId = strObjIdContext;
        	Product pbean = new Product(strProductId);
        	strModelId = pbean.getModelId(context);
        } else {
        	StringList emxTableRowIds = FrameworkUtil.split(strTableRowIds[0], "|");
        	switch (emxTableRowIds.size()) {
    		case 3:
    			strModelId = (String)emxTableRowIds.get(0);
                strObjIdContext = strModelId;
                isModelContext = true;
                strTableRowIds = null;
    			break;
    			
    		case 4:
    			strModelId = (String)emxTableRowIds.get(0);
    			strObjIdContext = strModelId;
                isModelContext = true;
                strTableRowIds = null;
    			break;
    		
    		default:
    			throw new Exception("Invalid emxTableRowId '" + emxTableRowIds + "'");
    		}
        	
             if(strModelId != null && !("".equals(strModelId))) {
	             DomainObject parentObj =  new DomainObject(strModelId);
	             StringList objectSelectList = new StringList();
	             
	             StringBuilder typeKindPL = new StringBuilder(50);
	             typeKindPL.append("type.kindof[");
	             typeKindPL.append(ProductLineConstants.TYPE_PRODUCT_LINE);
				 typeKindPL.append("]");
				 
	             StringBuilder typeKindProduct = new StringBuilder(50);
	             typeKindProduct.append("type.kindof[");
	             typeKindProduct.append(ProductLineConstants.TYPE_PRODUCTS);
	             typeKindProduct.append("]");
				 
				 objectSelectList.addElement(typeKindPL.toString());
				 objectSelectList.addElement(typeKindProduct.toString());
				 
	             Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
	              String typePL = (String) parentInfoTable.get(typeKindPL.toString());
	              String typeProd = (String) parentInfoTable.get(typeKindProduct.toString());
	              if(Boolean.valueOf(typePL)){
	             %>
	             <script language="javascript" type="text/javaScript">
	                   alert("<xss:encodeForJavaScript><%=strWrongParentType%></xss:encodeForJavaScript>");
	             </script>
	            <%
	                   return;
   	  				}
	              else if(Boolean.valueOf(typeProd)){
	              	Product pbean = new Product(strModelId);
	              	strModelId = pbean.getModelId(context);
	              }
             	}
        }
        		
        // Internationalized Strings
        String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,"ProductLine",
        		"emxProduct.Derivation.Create.SelectSingleRow", strLanguage);
        String heading = EnoviaResourceBundle.getProperty(context,"ProductLine",
        		"emxProduct.Derivation.CreateRevision.FormHeading", strLanguage);
        
        String strCannotCreateRevision = "";
        if (Product.isProductEvolutionsEnabled(context)) {
            strCannotCreateRevision = EnoviaResourceBundle.getProperty(context,"ProductLine",
        		"emxProduct.Derivation.Create.CannotCreateRevision", strLanguage);
        } else {
            strCannotCreateRevision = EnoviaResourceBundle.getProperty(context,"ProductLine",
                "emxProduct.Derivation.Create.CannotCreateRevisionNoEvolutions", strLanguage);
        }
        
        String DerivationType = "Revision";
        String RELATIONSHIP_MAIN_PRODUCT = PropertyUtil.getSchemaProperty(context, "relationship_MainProduct");
        String RELATIONSHIP_MAIN_DERIVED = PropertyUtil.getSchemaProperty(context, "relationship_MainDerived");
        String strMainProductSelectable = "from[" + RELATIONSHIP_MAIN_PRODUCT + "].to.id";
        String strMainDerivedSelectable = "from[" + RELATIONSHIP_MAIN_DERIVED + "].id";
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
            
        	// Check the Context object and find out whether there are any products attached
            // to the Model.  If not, we are allowing the user to create the Root Product.
            // Otherwise, we will be throwing an error.
            DomainObject modelObj =  new DomainObject(strModelId);
            StringList objectSelectList = new StringList();
            objectSelectList.addElement(DomainObject.SELECT_ID);      
            objectSelectList.addElement(strMainProductSelectable);
            Hashtable modelTable = (Hashtable) modelObj.getInfo(context, objectSelectList);
            String strRootId = (String)modelTable.get(strMainProductSelectable);   

            if (isModelContext && (strRootId == null || strRootId.isEmpty())) {

                // A strRootId of null or empty means there is NO Product attached to the Model with the
                // Main Product relationship.  It is this scenario where we let the user create the root product.
                
                //modified for IR-324015-3DEXPERIENCER2016 - all ?create? new revisions the field Name should default to the same name as the Model name

                DerivationType = "Derivation";
                %>
                <body>   
                    <form name="ProductDerivationCreate" method="post">
                    <script language="Javascript" type="text/javaScript">
                        var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=false&form=PLCCreateProductDerivationForm&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectID=null&modelID=<%=XSSUtil.encodeForURL(context,strModelId)%>&isRootProduct=true&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&createJPO=emxProduct:createProductDerivation&submitAction=refreshCaller&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&preProcessJavaScript=setNameValueOnLoad&postProcessURL=../productline/ProductRevisionCreatePostProcess.jsp";

                        getTopWindow().showSlideInDialog(submitURL, "true");
                    </script>
                    </form>
                </body>
                <%
                    
            } else {
            	
                // We have no selection, and at least one Product Revision, so create the Revision from the
                // last Product in the main Revision Chain.  First of all, we have to find out what that Revision is!
                String strLastRevisionId = null;
            	if (isModelContext) {
                    strLastRevisionId = DerivationUtil.getLastRevision(context, strRootId);
            	} else {
                    strLastRevisionId = DerivationUtil.getLastRevision(context, strProductId);
            	}
            	
            	String strLevel = "0,0";
            	if (strLastRevisionId != null) {
	                %>
	                <body>   
	                    <form name="ProductRevisionCreate" method="post">
	                        <script language="Javascript" type="text/javaScript">
	                            var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=true&autoNameChecked=false&nameField=both&vaultChooser=false&form=PLCCreateProductDerivationForm&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strLastRevisionId)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&parentOID=<%=XSSUtil.encodeForURL(context,strModelId)%>&objectID=<%=XSSUtil.encodeForURL(context,strLastRevisionId)%>&modelID=<%=XSSUtil.encodeForURL(context,strModelId)%>&isRootProduct=false&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&isRootSelected=true&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&preProcessJavaScript=setNameValueOnLoad&createJPO=emxProduct:createProductDerivation&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&postProcessURL=../productline/ProductRevisionCreatePostProcess.jsp&submitAction=xmlMessage";
	                            getTopWindow().showSlideInDialog(submitURL, "true");
	                        </script>
	                    </form>
	                </body>
	                <%
            	} else {
                    %>
                    <script language="javascript" type="text/javaScript">
                        alert("<xss:encodeForJavaScript><%=strCannotCreateRevision%></xss:encodeForJavaScript>");                
                    </script>
                    <%
            	}
            }
        } else {
        	
            // We have a single selection.
            // Create the Revision from this selected object, if possible.

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
            
            // Find out of the strObjectID already has a child Revision
            if (DerivationUtil.isLastNodeInRevisionChain(context, strObjectID)) {
                %>
                <body>   
                    <form name="ProductRevisionCreate" method="post">
                        <script language="Javascript" type="text/javaScript">
                            var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strCreationType)%>&typeChooser=true&autoNameChecked=false&nameField=both&vaultChooser=false&form=PLCCreateProductDerivationForm&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strObjectID)%>&suiteKey=ProductLine&StringResourceFileId=emxProductLineStringResource&SuiteDirectory=productline&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&modelID=<%=XSSUtil.encodeForURL(context,strModelId)%>&isRootProduct=false&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&isRootSelected=<%=XSSUtil.encodeForURL(context,String.valueOf(isRootSelected))%>&UIContext=<%=XSSUtil.encodeForURL(context,strUIContext)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&preProcessJavaScript=setNameValueOnLoad&createJPO=emxProduct:createProductDerivation&HelpMarker=<%=XSSUtil.encodeForURL(context,strHelpMarker)%>&postProcessURL=../productline/ProductRevisionCreatePostProcess.jsp&submitAction=xmlMessage";
                            getTopWindow().showSlideInDialog(submitURL, "true");
                        </script>
                    </form>
                </body>
                <%
            } else {
                %>
                <script language="javascript" type="text/javaScript">
                    alert("<xss:encodeForJavaScript><%=strCannotCreateRevision%></xss:encodeForJavaScript>");                
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
