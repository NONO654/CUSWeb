<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
 
<%!
   private String getString(matrix.db.Context context, String key) throws Exception {
		try {
			String keyValue = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), key);
			return XSSUtil.encodeForJavaScript(context, keyValue);
		} catch (Exception e) {
			throw new Exception(e);
		}
	}
   
%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript" language="javascript">

function createModel(status, objectId) {
	if("TRUE"==(status)){
		var submitURL ="../common/emxCreate.jsp?type=type_Model&typeChooser=true&showApply=true&autoNameChecked=false&nameField=both&form=type_CreateModel&suiteKey=ProductLine&header=emxProduct.Heading.ModelCreate&HelpMarker=emxhelpmodelcreate&submitAction=refreshCaller&objectId="+objectId;
		getTopWindow().showSlideInDialog(submitURL, "true");
	}
	else{
		alert("<%=getString(context,"emxProduct.Alert.ParentShouldBePLForModel")%>");
		getTopWindow().closeSlideInDialog();
	}
}
function addModel(status,objectId) {
	if("TRUE"==(status)){
		//getTopWindow().location.href="../common/emxFullSearch.jsp?field=TYPES=type_Model&excludeOIDprogram=emxPLCCommon:excludeConnectedModels&table=PLCSearchModelsTable&suiteKey=ProductLine&selection=multiple&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp?mode=AddExisting&relName=relationship_ProductLineModels&from=false&objectId="+objectId;
		showModalDialog("../common/emxFullSearch.jsp?field=TYPES=type_Model&excludeOIDprogram=emxPLCCommon:excludeConnectedModels&table=PLCSearchModelsTable&suiteKey=ProductLine&selection=multiple&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../productline/SearchUtil.jsp?mode=AddExisting&relName=relationship_ProductLineModels&from=false&objectId="+objectId,575,575,"true","Large");
	}
	else{
		alert("<%=getString(context,"emxProduct.Alert.ParentShouldBePLForModel")%>");
		getTopWindow().close();
	}
}
function addProduct(status, objectId) {
	if("TRUE"==(status)){
		var submitURL ="../common/emxCreate.jsp?type=type_HardwareProduct&typeChooser=true&autoNameChecked=false&nameField=both&form=type_CreateProduct&suiteKey=ProductLine&header=emxProduct.Heading.ProductCreate&HelpMarker=emxhelpproductcreate&submitAction=refreshCaller&UIContext=ProductLine&postProcessJPO=emxProduct:createModelAndConnectToProductLine&objectId="+objectId;
		getTopWindow().showSlideInDialog(submitURL, "true");
	}
	else{
		alert("<%=getString(context,"emxProduct.Alert.ParentShouldBePLForNewProduct")%>");
		getTopWindow().closeSlideInDialog();
	}
}
</script>
