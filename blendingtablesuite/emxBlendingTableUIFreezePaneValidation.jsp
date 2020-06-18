<%@include file = "emxBlendingTableInclude.inc"%>

var isValidForModification = false; 
var isValidForDateModification = false;

function isNumeric(varValue)
{
    if (isNaN(varValue))
    {
        return false;
    } else {
        return true;
    }
}

function isEmpty( StrToCheck ) 
{
	if( StrToCheck != null)
	{
		StrToCheck= StrToCheck.replace(/^\s+|\s+$/, '');
		if( StrToCheck.length>0)
			return false;
	}
	return true;
}

function isNegative(varValue)
{
	if( parseFloat(varValue) < 0.0 )
	 return true;
	 
	return false;
}

function ValidateMinimumValue( minValue )
{
	if( isValidForModification == false && isEmpty(minValue) )
		return true;
	
	if( isValidForModification == true )
	{
 		isValidForModification = false;
 		return true;
 	}
	if( isNumeric( minValue) && !isNegative(minValue))
	{
		var decimalNum = minValue / 100.0;
		if( decimalNum >= 0.0 && decimalNum <= 1.0 )
		{
			var columnName = getColumn();
  			var colIndex = columnName.index;
  			var colName = columnName.name;
  			
  			var rowId = currentRow.getAttribute("id");
  			var MaxColumnName = colMap.getColumnByIndex(colIndex).name;
  			var cellValue = getValueForColumn(MaxColumnName);
  			
  			if( isEmpty(cellValue))
 			{
 				if( isValidForModification == true )
 				{
 					isValidForModification = false;
 				}
 				else
 				{
 					isValidForModification = true;
 					emxEditableTable.setCellValueByRowId(rowId,colName,minValue,minValue); //id,colName,actualVal,DisplayVal
 					emxEditableTable.setCellValueByRowId(rowId,MaxColumnName,minValue,minValue);
 				}
 				return true;
 			}
 			else
 			{
 				
 				var MaxColumnCellValue = parseFloat(cellValue);
 				if( minValue <= MaxColumnCellValue)
 				{
 					isValidForModification = true;
 					emxEditableTable.setCellValueByRowId(rowId,colName,minValue,minValue); //id,colName,actualVal,DisplayVal
 					return true;
	 			}
 				else
 				{
 					var msg= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Msg.MinLesserThanMax","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
					alert(msg);
 					return false;
 				}
 			}
 			return true;
		}
	}
	var msg= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Msg.InvalidMinNumber","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
	alert(msg);
	return false;
}


function ValidateMaximumValue( maxValue )
{
	if( isValidForModification == false && isEmpty(maxValue) )
		return true;
	
	if( isValidForModification == true )
	{
 		isValidForModification = false;
 		return true;
 	}
 	
	if( isNumeric( maxValue) && !isNegative(maxValue) )
	{
		var decimalNum = maxValue / 100.0;
		if( decimalNum >= 0.0 && decimalNum <= 1.0 )
		{
			var columnName = getColumn();
  			var colIndex = columnName.index;
  			var colName = columnName.name;
  			
  			var rowId = currentRow.getAttribute("id");
  			var MinColumnName = colMap.getColumnByIndex(colIndex-2).name;
  			var minCellValue = getValueForColumn(MinColumnName);
  			
  			if( isEmpty(minCellValue))
 			{
 				if( isValidForModification == true )
 				{
 					isValidForModification = false;
 				}
 				else
 				{
 					isValidForModification = true;
 					var defaultValueForMin = "0";
 					emxEditableTable.setCellValueByRowId(rowId,colName,maxValue,maxValue); //id,colName,actualVal,DisplayVal
 					emxEditableTable.setCellValueByRowId(rowId,MinColumnName,defaultValueForMin,defaultValueForMin);
 				}
 				return true;
 			}
 			else
 			{
 				
 				var MinColumnCellValue = parseFloat(minCellValue);
 				if( maxValue >= MinColumnCellValue || isNaN(MinColumnCellValue))
 				{
 					isValidForModification = true;
 					emxEditableTable.setCellValueByRowId(rowId,colName,maxValue,maxValue); //id,colName,actualVal,DisplayVal
 					return true;
	 			}
 				else
 				{
 					var msg= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Msg.MaxGreaterThanMin","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
					alert(msg);
 					return false;
 				}
 			}
 			return true;
 		}
 	}
	var msg= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Msg.InvalidMaxNumber","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
	alert(msg);
	return false;
}

function ResetBRPlugFilterField()
{
	var defaultValue= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Command.BRFilterDefaultValue","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
	document.getElementById("DELBT_BRPlugsFilter").value =defaultValue;
}

function ResetBRSupplierFilterField()
{
	var defaultValue= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Command.BRFilterDefaultValue","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
	document.getElementById("DELBT_BRSuppliersFilter").value =defaultValue;
}

function ResetBRSuppliedMaterialFilterField()
{
	var defaultValue= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Command.BRFilterDefaultValue","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
	document.getElementById("DELBT_BRSuppliedMaterialsFilter").value=defaultValue;
}

function ResetBRStartDateFilterField()
{
	document.getElementById("DELBT_BRStartDateFilter").value ="";
}

function ResetBREndDateFilterField()
{
	document.getElementById("DELBT_BREndDateFilter").value ="";
}
	
function ResetBRDateFilterFields()
{
	document.getElementById("DELBT_BRStartDateFilter").value ="";
	document.getElementById("DELBT_BREndDateFilter").value ="";
}

function ResetBRMinFilterFields()
{
	document.getElementById("DELBT_BRMin1TextBox").value ="";
	document.getElementById("DELBT_BRMin2TextBox").value ="";
}

function ResetBRMaxFilterFields()
{
	document.getElementById("DELBT_BRMax1TextBox").value ="";
	document.getElementById("DELBT_BRMax2TextBox").value ="";
}


function ResetBRAllFilterFields()
{
	var defaultValue= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Command.BRFilterDefaultValue","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
	document.getElementById("DELBT_BRPlugsFilter").value =defaultValue;
	document.getElementById("DELBT_BRSuppliersFilter").value =defaultValue;
	document.getElementById("DELBT_BRSuppliedMaterialsFilter").value =defaultValue;
	document.getElementById("DELBT_BRStartDateFilter").value ="";
	document.getElementById("DELBT_BREndDateFilter").value ="";
	document.getElementById("DELBT_BRStartDateFilter").value ="";
	document.getElementById("DELBT_BREndDateFilter").value ="";
	document.getElementById("DELBT_BRMin1TextBox").value ="";
	document.getElementById("DELBT_BRMin2TextBox").value ="";
	document.getElementById("DELBT_BRMax1TextBox").value ="";
	document.getElementById("DELBT_BRMax2TextBox").value ="";
}

function ValidateStartDate( startDate )
{

	if( isValidForDateModification == true )
	{
 		isValidForDateModification = false;
 		return true;
 	}

	var sDate = (startDate.indexOf(" ") > 0 ||startDate.indexOf(",") > 0)? parseInt(hiddenVal) : parseInt(startDate);
	var vStartDate = new Date(sDate);
	
	
	var columnName = getColumn();
  	var colIndex = columnName.index;
  	var colName = columnName.name;
  			
  	var rowId = currentRow.getAttribute("id");
  	
  	var EndDateColumnName = colMap.getColumnByIndex(colIndex).name;
  	var endDateCellValue = getValueForColumn(EndDateColumnName);
	
	var eDate = (endDateCellValue.indexOf(" ") > 0 ||endDateCellValue.indexOf(",") > 0)? endDateCellValue : parseInt(endDateCellValue);
	var vEndDate = new Date ( eDate );
	
	
	if( vStartDate > vEndDate )
	{
		var msg= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Msg.StartDateGreaterThanEndDate","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
		alert(msg);			
		return false;
	}
	isValidForDateModification = true;
	emxEditableTable.setCellValueByRowId(rowId,colName,startDate,startDate);
	return true;
}


function ValidateEndDate( endDate )
{
	if( isValidForDateModification == true )
	{
 		isValidForDateModification = false;
 		return true;
 	}

	var eDate = (endDate.indexOf(" ") > 0 ||endDate.indexOf(",") > 0)? parseInt(hiddenVal) : parseInt(endDate);
	var vEndDate = new Date(eDate);
	
	
	var columnName = getColumn();
  	var colIndex = columnName.index;
  	var colName = columnName.name;
  			
  	var rowId = currentRow.getAttribute("id");
  	
  	var startDateColumnName = colMap.getColumnByIndex(colIndex-2).name;
  	var startDateCellValue = getValueForColumn(startDateColumnName);
	
	var sDate = (startDateCellValue.indexOf(" ") > 0 ||startDateCellValue.indexOf(",") > 0)? startDateCellValue : parseInt(startDateCellValue);
	var vStartDate = new Date ( sDate );
	
	
	if( vEndDate < vStartDate )
	{
		var msg= "<%=i18nNow.getI18nString("emxBlendingTableCentral.Msg.EndDateLesserThanStartDate","emxBlendingTableSuiteStringResource",context.getSession().getLanguage())%>";
		alert(msg);	
		return false;
	}
	isValidForDateModification = true;
	emxEditableTable.setCellValueByRowId(rowId,colName, endDate,endDate);
	return true;
}
