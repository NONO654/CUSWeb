<%--
  PLCRemoveDeleteProductHierarchy.jsp

--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.ArrayList"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import = "com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLine"%>
<%@page import = "com.matrixone.apps.productline.Product"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%!
boolean bIsError = false;
String action = "";
String msg = "";
%>
<%
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	String strMode = emxGetParameter(request,"mode");
    String strParentID = emxGetParameter(request,"objectId"); 
    String strLanguage = context.getSession().getLanguage();
    StringList strObjectIdList = new StringList();
    StringList relidList = new StringList();
    
    boolean bInvalidState = false;

    String tempRelID = "";
    String strObjectID = "";
    StringTokenizer strTokenizer = null;
    
    boolean bIsError = false;
    // if the root is sleected then it cann't be deleted/removed.
        if(arrTableRowIds[0].endsWith("|0")){
            %>
               <script language="javascript" type="text/javaScript">
                     alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
               </script>
            <%
            return;
        }
        
    try
	{    
		if("delete".equalsIgnoreCase(strMode)) {
			
			 for(int i=0;i<arrTableRowIds.length;i++)
			    {
				 StringList emxTableRowIds = FrameworkUtil.split(arrTableRowIds[i], "|");
				 switch (emxTableRowIds.size()) {
					case 3:
						strObjectID = (String)emxTableRowIds.get(0);
					    strObjectIdList.add(strObjectID);					
						break;
						
					case 4:
						strObjectID = (String)emxTableRowIds.get(1);
						strObjectIdList.add(strObjectID);
						break;
					
					default:
						break;
				    } 
				}
			StringList newSelectables = new StringList();
			
			StringBuilder typeKindProd = new StringBuilder(50);
			typeKindProd.append("type.kindof[");
			typeKindProd.append(ProductLineConstants.TYPE_PRODUCTS);
			typeKindProd.append("]");
			
			StringBuilder typeKindModel = new StringBuilder(50);
			typeKindModel.append("type.kindof[");
			typeKindModel.append(ProductLineConstants.TYPE_MODEL);
			typeKindModel.append("]");

			StringBuilder typeKindPL = new StringBuilder(50);
			typeKindPL.append("type.kindof[");
			typeKindPL.append(ProductLineConstants.TYPE_PRODUCTLINE);
			typeKindPL.append("]");
			
			newSelectables.add(typeKindProd.toString());
			newSelectables.add(typeKindModel.toString());
			newSelectables.add(typeKindPL.toString());
			newSelectables.add(DomainConstants.SELECT_NAME);
			newSelectables.add(DomainConstants.SELECT_CURRENT);
			newSelectables.add(DomainConstants.SELECT_POLICY);
			newSelectables.add(DomainConstants.SELECT_ID);
			MapList resultMaps = DomainObject.getInfo(context, (String[])strObjectIdList.toArray(new String[strObjectIdList.size()]), newSelectables);
			List<String> illegalObjs = new ArrayList<String>();
			List<String> modelObjIds = new ArrayList<String>();
			StringList plObjIds = new StringList();
			for(Object oMap : resultMaps) {
				Map rMap = (Map)oMap;
				String name = (String) rMap.get(DomainConstants.SELECT_NAME);
				String current = (String) rMap.get(DomainConstants.SELECT_CURRENT);
				String typeProd = (String) rMap.get(typeKindProd.toString());
				String typeModel = (String) rMap.get(typeKindModel.toString());
				String typePL = (String) rMap.get(typeKindPL.toString());
				String state = PropertyUtil.getSchemaProperty(context, "Policy", (String) rMap.get(DomainConstants.SELECT_POLICY), "state_Preliminary");
				if(Boolean.valueOf(typeProd)){
					if(!current.equalsIgnoreCase(state)){
						illegalObjs.add((String)rMap.get(DomainConstants.SELECT_NAME));
						strObjectIdList.remove((String)rMap.get(DomainConstants.SELECT_NAME));
						
					}
				}
				else if(Boolean.valueOf(typeModel)){
						modelObjIds.add((String)rMap.get(DomainConstants.SELECT_ID));
						strObjectIdList.remove((String)rMap.get(DomainConstants.SELECT_ID));
						
				}
				else if(Boolean.valueOf(typePL)){
					plObjIds.add((String)rMap.get(DomainConstants.SELECT_ID));
					strObjectIdList.remove((String)rMap.get(DomainConstants.SELECT_ID));
					
			    }				
				}
				if(illegalObjs.size() > 0){
					 %>
				       <script language="javascript" type="text/javaScript">
				             alert("<emxUtil:i18n localize='i18nId'>emxProduct.Error.ProductConfigurationNotPreliminary</emxUtil:i18n>"+"\n"+illegalObjs.toString());
				       </script>
				    <%
				    return;
				}
				try {
					if(strObjectIdList.size()>0){
						//ProductLine.delete(context, strObjectIdList);
						String[] productIds = new String[strObjectIdList.size()];
						
						Product.deleteObjects(context, (String[]) strObjectIdList.toArray(productIds));
					}
					if(modelObjIds.size()>0){
						com.matrixone.apps.productline.Model modelBean = (com.matrixone.apps.productline.Model)DomainObject.newInstance(context,ProductLineConstants.TYPE_MODEL,"ProductLine");
						modelBean.delete(context,modelObjIds.toArray(new String[modelObjIds.size()]),strParentID);
					}
					if(plObjIds.size()>0){
						ProductLine.delete(context, plObjIds);
					}					
				} catch(Exception e){
					throw new Exception(e.getMessage());
			        //bIsError=true;
			        //msg = e.getMessage();
			        //session.putValue("error.message", e.getMessage());
			       // return;
				}
		}			
   
		if("remove".equalsIgnoreCase(strMode)) {
            String[] arrObjectToRemove = ProductLineUtil.getObjectIds(arrTableRowIds);
		    boolean isProductSelected= ProductLineUtil.isListContainProduct(context, arrObjectToRemove);
		    if(isProductSelected){
			 %>
		       <script language="javascript" type="text/javaScript">
		             alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.RemoveOperationFailure</emxUtil:i18n>");
		       </script>
		    <%
		    return;
		    }
			for(int i=0;i<arrTableRowIds.length;i++)
		    {
			 StringList emxTableRowIds = FrameworkUtil.split(arrTableRowIds[i], "|");
			 switch (emxTableRowIds.size()) {
				case 3:
					String objectId = (String)emxTableRowIds.get(0);
					String parentObjectId = (String)emxTableRowIds.get(1);
					StringBuilder objectWhere = new StringBuilder(50);
					objectWhere.append(DomainObject.SELECT_ID);
					objectWhere.append("==");
					objectWhere.append(objectId);
					
					DomainObject parentObject = DomainObject.newInstance(context, parentObjectId);
					 List<Map<?, ?>> resultMaps = parentObject.getRelatedObjects(context,  DomainObject.QUERY_WILDCARD,  DomainObject.QUERY_WILDCARD, new StringList(),
							 new StringList(DomainRelationship.SELECT_ID), false, true, (short) 0, objectWhere.toString(), null, (short) 0, false, false, (short) 1, null, null, null, DomainConstants.EMPTY_STRING, null);
					Map rMap = resultMaps.get(0);
					tempRelID  = (String)rMap.get(DomainRelationship.SELECT_ID);
					relidList.add(tempRelID);
					break;
					
				case 4:
					tempRelID  = (String)emxTableRowIds.get(0);
		            relidList.add(tempRelID);
					break;
				
				default:
					break;
			    } 
			}
			DomainRelationship.disconnect(context, (String[])relidList.toArray(new String[relidList.size()]));

		}
		%>
		<html>
		  <script language="javascript" type="text/javaScript">//<![CDATA[
		    parent.document.location.href = parent.document.location.href;
		  </script>
		</html>
		<% 
	    
    } catch(Exception e) {
        bIsError=true;
    	// PL->PLs->Delete Product
    	// exclude Check trigger blocked event- message being put in to session so that it will be not dispayed
		if (e.toString()!=null && e.toString().indexOf("Check trigger blocked event")< 0) {
			session.putValue("error.message", e.getMessage());
		}
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

