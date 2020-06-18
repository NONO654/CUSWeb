<%-- emxEngrBOMPartSearchWithinProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
are added under respective scriplet--%>
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">
 //KIE1 ZUD TSK447636 
	var dupemxUICore   = getTopWindow().getWindowOpener().emxUICore;
	var dupTimeStamp   = getTopWindow().getWindowOpener().timeStamp;
	var mxRoot         = getTopWindow().getWindowOpener().oXML.documentElement;
	var selectedObject = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows//r[@checked = 'checked']");
	if (selectedObject == null  || selectedObject == undefined)
	{
		selectedObject = dupemxUICore.selectSingleNode(mxRoot, "/mxRoot/rows/r");
	}
	var arrSelect = new Array();

</script>
<%

Map mapKeyObjId = (Map)session.getAttribute("mapKeyObjId");

String[] selectedItems = emxGetParameterValues(request, "emxTableRowId");
for (int i=0; i < selectedItems.length ;i++){
	StringList slTokens = FrameworkUtil.split(" "+selectedItems[i], "|");
	String strSelected = (String)slTokens.get(1);
	StringList slParentStructure = (StringList)mapKeyObjId.get(strSelected);

	if(slParentStructure != null){
		for(int j=0;j<slParentStructure.size();j++){
			String strHierarchy = (String)slParentStructure.get(j);
			%>
			<script language="javascript">
				var vHierarchy = "<xss:encodeForJavaScript><%=strHierarchy%></xss:encodeForJavaScript>";
				var vSelected  = "<xss:encodeForJavaScript><%=strSelected%></xss:encodeForJavaScript>";
				var arrHierarchy = vHierarchy.split("|");
				var countHierarchy = arrHierarchy.length - 1;
				var checkObject = selectedObject;
			</script>
			<script language="javascript">
			</script>
			<script language="javascript">
				var expand = checkObject.getAttribute("expand");
				if(expand == null || (typeof expand == 'undefined')){
					var pLevel = checkObject.getAttribute("level");
					var pRowIdArr = new Array();
					pRowIdArr[0] = checkObject.getAttribute("id");
					 //KIE1 ZUD TSK447636 
					getTopWindow().getWindowOpener().emxEditableTable.expand(pRowIdArr, pLevel);
				}
				// Start: Bug 370797
				else if(expand == 'true')
				{
					selectedObject.setAttribute("display","block");
				}
				// End: Bug 370797
				//expand(checkObject);				
				do{
					var selectRows = dupemxUICore.selectNodes(checkObject, "r[@o='"+vSelected+"']");
					if(selectRows.length >0 && countHierarchy == -1){
						for(var i=0;i<selectRows.length;i++){
							//selectRows[i].setAttribute("checked", "checked");
							arrSelect.push(selectRows[i].getAttribute("id"));
						}
					}
					else{
						var expandRow = dupemxUICore.selectSingleNode(checkObject, "r[@o='"+arrHierarchy[countHierarchy]+"']");
						if(expandRow != null){
							var expandC = expandRow.getAttribute("expand");
							if(expandC == null || (typeof expandC == 'undefined')){
								var parentLevel = expandRow.getAttribute("level");
								var parentRowIdArr = new Array();
								parentRowIdArr[0] = expandRow.getAttribute("id");
								 //KIE1 ZUD TSK447636 
								getTopWindow().getWindowOpener().emxEditableTable.expand(parentRowIdArr, parentLevel);
							}
							// Start: Bug 370797
							else if(expandC == 'true')
							{
								expandRow.setAttribute("display","block");
							}
							// End: Bug 370797
							//expand(expandRow);
							checkObject = expandRow;
						}
					}
					countHierarchy--;
				}while(countHierarchy >= -1);

			</script>
			<%
		}
	}
}
%>
<script language="javascript">
 //KIE1 ZUD TSK447636 
getTopWindow().getWindowOpener().parent.emxEditableTable.select(arrSelect);
arrSelect = new Array();

// IR IR-346884-3DEXPERIENCER2016x to expand the tree
if (getTopWindow().getWindowOpener().parent.expandAllDynaTreeRMT)
	getTopWindow().getWindowOpener().parent.expandAllDynaTreeRMT();

getTopWindow().closeWindow();
</script>
