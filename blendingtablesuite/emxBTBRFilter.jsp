<html>
<%@page
	import="com.matrixone.apps.domain.*,
	com.matrixone.apps.domain.util.*" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>

<%
	String strBTObjectId = emxGetParameter(request,"objectId");
	String strIsFromSupplier = emxGetParameter(request,"IsFromSupplier");
	String strIsFromPlug= emxGetParameter(request,"IsFromPlug");
	String strIsFromSuppliedMaterial = emxGetParameter(request,"IsFromSuppliedMaterial");
	String timeStamp = emxGetParameter(request, "timeStamp");
    String[] selectedIds = emxGetParameterValues(request, "emxTableRowId");
    
    String languageStr = request.getHeader("Accept-Language");

    String strFilterDefaultValue = UINavigatorUtil.getI18nString("emxBlendingTableCentral.Command.BRFilterDefaultValue", "emxBlendingTableSuiteStringResource", languageStr);  
	
    String SupplierIds="";
    if(selectedIds!=null&&selectedIds.length>0)
    {
		MapList mlUserData = new MapList();
		for(int i=0; i<selectedIds.length; i++)
		{
			String tmpStr = selectedIds[i];
			
			String delims = "[|]+";
			String[] Nametokens = tmpStr.split(delims);
			if( Nametokens.length > 0 )
			{
				String plugObjId = Nametokens[1];
				DomainObject dobFeature =  new DomainObject();
				
				if(plugObjId!= null || !plugObjId.equals(""))
					dobFeature.setId(plugObjId);

				String Name = dobFeature.getInfo(context,DomainConstants.SELECT_NAME);
				
				SupplierIds += Name.trim() + ",";
			}
		}
    }
    if( SupplierIds.equalsIgnoreCase(""))
    	SupplierIds = strFilterDefaultValue;
    
    SupplierIds = "\"" + SupplierIds +"\"";
    strIsFromSupplier = "\'" + strIsFromSupplier +"\'";
    strIsFromPlug = "\'" + strIsFromPlug +"\'";
    strIsFromSuppliedMaterial = "\'" + strIsFromSuppliedMaterial +"\'";
%>
<script language="javascript">
//var objSel = top.opener.document.getElementById("DELBT_BRPlugsFilter");
var objSel = "";
var isFromPlug = <%=strIsFromPlug%>;
var isFromSupplier = <%=strIsFromSupplier%>;
var isFromSuppliedMaterial = <%=strIsFromSuppliedMaterial%>;

if( isFromPlug == 'TRUE')
	objSel = top.opener.document.getElementById("DELBT_BRPlugsFilter");
else if( isFromSupplier == 'TRUE')
	objSel = top.opener.document.getElementById("DELBT_BRSuppliersFilter");
else if ( isFromSuppliedMaterial == 'TRUE')	
	objSel = top.opener.document.getElementById("DELBT_BRSuppliedMaterialsFilter");

objSel.value =<%=SupplierIds%>
top.close();
</script>
</html>
