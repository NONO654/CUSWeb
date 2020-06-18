//<script language="Javascript">

<%@ page import = "java.util.Map"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import="java.net.URLEncoder" %>

function transformValue()
{
	var url = window.location.href;
	
	var currCell = emxEditableTable.getCurrentCell();
	
	if(currCell != null)
	{
		var objectId = currCell.objectid;
		var cCellValue = currCell.value.current.display;
		var oCellValue = currCell.value.old.display;
		var rowId = currCell.rowID;
		var columnName = getColumn();
		var colName = columnName.name;
	
		var xmlhttp;
	
		if(cCellValue != "")
		{
			//if cell value is a number ; if cell value is "", it will be read at 0; must treat case separetly
			if(!isNaN(cCellValue))
			{
				// code for IE7+, Firefox, Chrome, Opera, Safari
       			if (window.XMLHttpRequest) {
               		xmlhttp=new XMLHttpRequest();       
     			}
       			else if (window.ActiveXObject) {// code for IE6, IE5
             		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
      			}
     			else {
              		alert("Your browser does not support XMLHTTP!");
      			}
 
       			xmlhttp.onreadystatechange=function()
       			{
					if(xmlhttp.readyState==4)
					{
						var response = xmlhttp.responseText;
						if (response != null)
						{
							var responseUnits = xmlhttp.responseXML.getElementsByTagName("DefaultUnit");
							if (responseUnits.length >0)
							{
								var defaultUnit = responseUnits[0].firstChild.data;
								if (defaultUnit != "null")
									emxEditableTable.setCellValueByRowId(rowId, colName, cCellValue, cCellValue+" "+defaultUnit);
							}
						}
					}
				}

				xmlhttp.open("GET","../parameter/emxParameterGetUnitAjaxResponse.jsp?objectId="+objectId+"&columnName="+colName,true);
				xmlhttp.send(null);
			}
		}
	}
	
	return true;
}

//</SCRIPT>
