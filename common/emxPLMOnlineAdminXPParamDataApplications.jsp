<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="java.util.*"%>
<%@ page import="com.matrixone.vplm.parameterizationUtilities.MatrixUtilities" %>
<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
<%@ page import ="com.matrixone.vplm.applicationsIntegrationInfra.AppIntUIConnector"%>
<%@ page import ="com.matrixone.vplm.parameterizationUtilities.NLSUtilities.ParameterizationNLSCatalog"%>
<html>
	<head>
		<link rel=stylesheet type="text/css" href="../common/styles/emxUIDOMLayout.css">
		<link rel=stylesheet type="text/css" href="../common/styles/emxUIDefault.css">
		<link rel=stylesheet type="text/css" href="../common/styles/emxUIPlmOnline.css">
		<link rel=stylesheet type="text/css" href="../common/styles/emxUIMenu.css">
		<%-- DATE_FLAG
		<link rel=stylesheet type="text/css" href="../common/styles/emxUICalendar.css">
		--%><script type="text/javascript" src="../common/scripts/emxPLMOnlineAdminJS.js" language="javascript"></script>
		<script type="text/javascript" src="../common/scripts/emxUIAdminConsoleUtil.js"></script>
		<script type="text/javascript" src="../common/scripts/expand.js"></script>
		<%-- DATE_FLAG
		<script type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
		<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
		<script type="text/javascript" src="../common/scripts/emxUICoreMenu.js"></script>
		<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
		--%><%@include file = "../common/emxUIConstantsInclude.inc"%>

<%		Locale currentLocale = request.getLocale();
		ParameterizationNLSCatalog myNLS = new ParameterizationNLSCatalog(context, currentLocale, "myMenu");
		
		String domainID = emxGetParameter(request, "domain");
		AppIntUIConnector appIntUIConnector = new AppIntUIConnector(context);
		AppIntUIConnector.IExchangeDomain domain = appIntUIConnector.getDomain(domainID);
		
		String currentUISolution = MatrixUtilities.getCurrentSolution(context);
		
		AppIntUIConnector.IExchangeUIValueCheck[] uiValueChecks = new AppIntUIConnector.IExchangeUIValueCheck[0];
		
		boolean currentUISolutionIsInDomainSolution = false;
		if (domain != null)
		{
			uiValueChecks = domain.getUIValueChecks();
			String[] checkJSFiles = domain.getCheckJSFiles();
			for (String checkJSFile : checkJSFiles)
			{
%>		<script src="<%=checkJSFile%>" type="text/javascript"></script>
<%			}
			String[] domainSolutions = domain.getSolutions();
			currentUISolutionIsInDomainSolution = (domainSolutions.length == 0);
			for (String domainSolution : domainSolutions)
				if (domainSolution.equalsIgnoreCase(currentUISolution))
				{
					currentUISolutionIsInDomainSolution = true;
					break;
				}
		}
		String currentcontext = context.getRole();
		String admincontext = "VPLMAdmin";
		String displayhidediv = "block";
		String displayhidecontrol = "none";
		String NonAppropriateContext   = myNLS.getMessage("NonAppropriateContext");
		String NonAppropriateLicenseMsg = myNLS.getMessage("NonAppropriateLicenseMsg"); 
		
		if (!currentUISolutionIsInDomainSolution)
			NonAppropriateContext = myNLS.getMessage("NonAppropriateSolution");
		else if (currentcontext.indexOf(admincontext) >= 0)
		{
			displayhidediv = "none";
			displayhidecontrol= "block";
		}
		
		String commandName = appIntUIConnector.getCommandName(domainID);
		FreezeServerParamsSMB frz = new FreezeServerParamsSMB();
		boolean tabIsFrozen = (frz.GetServerFreezeStatusDB(context, commandName) == FreezeServerParamsSMB.S_FROZEN);
		
		// HEIGHT WIDTH
		int basicFamilyHeight = 10; //px
		int tableTitlesHeight = 16; //px
		int basicRowHeight = 30; //px
		int checkboxOffSetHeight = 0; //px
		int textfieldOffSetHeight = 0; //px
		int comboboxOffSetHeight = 0; //px
		int defaultWidthParameterName = 5; //percentage
		int defaultWidthArgumentName = 40; //percentage
		int defaultWidthColumn = 15; //percentage
		int defaultWidthStatus = 35; //percentage
		if ("DataAccessRight".equals(domainID))
		{
			defaultWidthParameterName = 5;
			defaultWidthArgumentName = 70;
			//defaultWidthColumn = 5; //IR-440194-3DEXPERIENCER2017x
			defaultWidthStatus = 8;
		}
		
		// COLORS
		String colorFamilyTitle = "#6691AA";
		String colorColumnTitles = "#B8CCD8";
		String color1 = "#F3F3F3";//EEEEEE
		String color2 = "#EFEFEF";//EAEAEA
		String colorNotEditable = color2;
		String colorOK = "#FFFFFF";
		String colorERROR = "#F08080";
		
%>		<script>
			var CELL_PARAM  = 0;
			var CELL_ARG    = 1;
			var CELL_WIDGET = 2;
			var CELL_EMPTY  = 3;
			var CELL_STATUS = 4;
			
			var INPUT_COMBOBOX  = "<%=AppIntUIConnector.INPUT_COMBOBOX%>";
			var INPUT_TEXTFIELD = "<%=AppIntUIConnector.INPUT_TEXTFIELD%>";
			var INPUT_CHECKBOX  = "<%=AppIntUIConnector.INPUT_CHECKBOX%>";
			var INPUT_CALENDAR  = "<%=AppIntUIConnector.INPUT_CALENDAR%>";
			var INPUT_CLEARCAL  = "<%=AppIntUIConnector.INPUT_CLEARCAL%>";
			
			var CHECKED   = "<%=AppIntUIConnector.CHECKED%>";
			var UNCHECKED = "<%=AppIntUIConnector.UNCHECKED%>";
			
			var TYPE_STRING    = "<%=AppIntUIConnector.TYPE_STRING%>";
			var TYPE_INTEGER   = "<%=AppIntUIConnector.TYPE_INTEGER%>";
			var TYPE_NATURAL   = "<%=AppIntUIConnector.TYPE_NATURAL%>";
			var TYPE_REAL      = "<%=AppIntUIConnector.TYPE_REAL%>";
			var TYPE_BOOLEAN   = "<%=AppIntUIConnector.TYPE_BOOLEAN%>";
			var TYPE_DATE      = "<%=AppIntUIConnector.TYPE_DATE%>";
			var TYPE_TIMESTAMP = "<%=AppIntUIConnector.TYPE_TIMESTAMP%>";
			
			var STATUS_DEPLOYED = 0;
			var STATUS_STORED   = 1;
			var STATUS_MODIFIED = 2;
			
			var parameterList    = new Array();
			var argumentIDs      = new Array();
			var argumentNLSNames = new Array();
			var argumentTypes    = new Array();
			var argumentLengths  = new Array();
			var argumentDefault  = new Array();
			
			var xmlreqs = new Array();
			
			var tabIsFrozen = false;
			function updateFreeze(iIsFrozen)
			{
				tabIsFrozen = iIsFrozen;
				for (var i=0 ; i<parameterList.length ; i++)
					for (var j=0 ; j<argumentIDs[i].length ; j++)
						setEditable(parameterList[i], argumentIDs[i][j], !iIsFrozen)
			}
			function isFrozen()
			{
				return tabIsFrozen;
			}
			
			function getFamilyDivID(iFamilyID)
			{
				return "familyDiv_" + iFamilyID;
			}
			function getWidgetID(iParameterID, iArgumentID)
			{
				return iParameterID + "_" + iArgumentID;
			}
			
			function getArgumentType(iParameterID, iArgumentID)
			{
				for (var i=0 ; i<parameterList.length ; i++)
					if (parameterList[i] == iParameterID)
						for (var j=0 ; j<argumentIDs[i].length ; j++)
							if (argumentIDs[i][j] == iArgumentID)
								return argumentTypes[i][j];
				return TYPE_STRING;
			}
			
			function increaseDivHeight(iFamilyID, iPx)
			{
				var familyDiv = document.getElementById(getFamilyDivID(iFamilyID));
				var divHeightStr = familyDiv.style.height;
				var divHeight = parseInt(divHeightStr) + iPx;
				familyDiv.style.height = divHeight + "px";
			}
			
			function addFamily(iFamilyID, iFamilyNLSName, iTooltip, iIcon, iColumns, iColumnsNLS, iColumnsTooltip, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizesColumns, iSizeStatus)
			{
				document.write('<table border="0" width="100%" >');
				document.write('<tr bgcolor="<%=colorFamilyTitle%>" align="left">');
				document.write('<td class="pic" style="border:0"><img src="../common/images/' + iIcon + '" title="' + iTooltip + '"/></td>');
				document.write('<td><b><font color="white">' + iFamilyNLSName + '</font></b></td>');
				document.write('<td class="pic" style="border:0" align="center"><img src="images/xpcollapse1_s.gif" onclick="SwitchMenuParams(\'' + getFamilyDivID(iFamilyID) + '\', this);"/></td>');
				document.write('</tr>')
				document.write('</table>');
				document.write('<div id="' + getFamilyDivID(iFamilyID) + '" style="width: 98%; height:<%=basicFamilyHeight%>px; min-height:<%=basicFamilyHeight%>px; background-color:<%=color1%>; overflow-x:hidden; overflow-y:auto;">');
				document.write('<table id ="' + iFamilyID + '" border="0" width="100%" height="100%"></table>');
				document.write('</div>');
				document.write('<br>');
				if (iColumns.length > 0)
					addParameter(iFamilyID, "", "", "", false, "<%=colorColumnTitles%>", iColumns, iColumnsNLS, iColumnsTooltip, false, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizesColumns, iSizeStatus);
			}
			
			function addParameter(iFamilyID, iParameterID, iParameterNLSName, iParameterTooltip, iIsDeployed, iColor, iColumns, iColumnsNLS, iColumnsTooltip, iHasOnlyOneArgument, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizesColumns, iSizeStatus)
			{
				if (iColumns.length > 0)
					addParameterTableLayout(iFamilyID, iParameterID, iParameterNLSName, iParameterTooltip, iIsDeployed, iColor, iColumns, iColumnsNLS, iColumnsTooltip, iSizeParameterName, iSizesColumns, iSizeStatus);
				else
					addParameterRegularLayout(iFamilyID, iParameterID, iParameterNLSName, iParameterTooltip, iIsDeployed, iColor, iHasOnlyOneArgument, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus);
			}
			function addArgument(iFamilyID, iParameterID, iArgumentID, iArgumentNLSName, iCompleteArgumentNLSName, iArgumentTooltip, iInputType, iMaxLength, iEditable, iValueList, iValueListNLS, iColor, iIsOnlyArgument, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus, iColumns)
			{
				if (iColumns.length > 0)
					addArgumentTableLayout(iFamilyID, iParameterID, iArgumentID, iCompleteArgumentNLSName, iInputType, iMaxLength, iEditable, iValueList, iValueListNLS, iColor, iColumns);
				else
					addArgumentRegularLayout(iFamilyID, iParameterID, iArgumentID, iArgumentNLSName, iArgumentTooltip, iInputType, iMaxLength, iEditable, iValueList, iValueListNLS, iColor, iIsOnlyArgument, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus);
			}
			
			function addParameterTableLayout(iFamilyID, iParameterID, iParameterNLSName, iParameterTooltip, iIsDeployed, iColor, iColumns, iColumnsNLS, iColumnsTooltip, iSizeParameterName, iSizesColumns, iSizeStatus)
			{
//				var className = "MatrixFeelNxG";
				var rowHeight = <%=basicRowHeight%>;
				if (iParameterID == "")
				{
//					className = "matrixFeel";
					rowHeight = <%=tableTitlesHeight%>;
				}
				increaseDivHeight(iFamilyID, rowHeight);
				var newRow = document.getElementById(iFamilyID).insertRow(-1);
				newRow.style.height = rowHeight + "px";
				
				if (iColor == "")
					newRow.style.backgroundColor = "<%=color1%>";
				else
					newRow.style.backgroundColor = iColor;
				if (iParameterID != "")
					newRow.id = iParameterID;
				//Status Columns index
				newRow.value = iColumns.length + 1;
				
				var newCell = newRow.insertCell(-1);
				newCell.align = "left";
//				newCell.className = className;
				newCell.style.width = (iSizeParameterName+"%");
				if (iParameterID != "")
				{
					newCell.innerHTML = iParameterNLSName;
					newCell.title = iParameterTooltip;
				}
				
				for (var i=0 ; i<iColumns.length ; i++)
				{
					newCell = newRow.insertCell(-1);
					newCell.align = "center";
//					newCell.className = className;
					newCell.style.width = (iSizesColumns[i]+"%");
					if (iParameterID == "")
					{
						newCell.innerHTML = iColumnsNLS[i];
						newCell.title = iColumnsTooltip[i];
					}
				}
				
				newCell = newRow.insertCell(-1);
				newCell.align = "center";
//				newCell.className = className;
				newCell.style.width = (iSizeStatus+"%");
				
				if (iParameterID != "")
				{
					if (iIsDeployed)
						setParameterStatus(iParameterID, STATUS_DEPLOYED);
					else
						setParameterStatus(iParameterID, STATUS_STORED);
				}
			}
			
			function addArgumentTableLayout(iFamilyID, iParameterID, iArgumentID, iCompleteArgumentNLSName, iInputType, iMaxLength, iEditable, iValueList, iValueListNLS, iColor, iColumns)
			{
				var lineOffSet = 0;
				if (iInputType == INPUT_CHECKBOX)
					lineOffSet = <%=checkboxOffSetHeight%>;
				else if (iInputType == INPUT_COMBOBOX)
					lineOffSet = <%=comboboxOffSetHeight%>;
				else if (iInputType == INPUT_TEXTFIELD || iInputType == INPUT_CALENDAR || iInputType == INPUT_CLEARCAL)
					lineOffSet = <%=textfieldOffSetHeight%>;
				
				if (lineOffSet > 0)
				{
					var row = document.getElementById(iParameterID);
					var currentRowHeight = parseInt(row.style.height);
					var supposedRowHeight = <%=basicRowHeight%> + lineOffSet;
					if (supposedRowHeight > currentRowHeight)
					{
						var offset = supposedRowHeight - currentRowHeight;
						increaseDivHeight(iFamilyID, offset);
						var newHeight = currentRowHeight + offset;
						row.style.height = newHeight + "px";						
					}
				}
				
				var widget = getInputWidget(iParameterID, iArgumentID, iInputType, iMaxLength, iEditable, iCompleteArgumentNLSName, iValueList, iValueListNLS, iColor);
				for (i=0 ; i<iColumns.length ; i++)
					if (iColumns[i] == iArgumentID)
					{
						document.getElementById(iParameterID).cells[i+1].appendChild(widget);
						return;
					}
				widget.style.display = "none";
				document.getElementById(iFamilyID).rows[0].cells[0].appendChild(widget);
			}
			
			function addParameterRegularLayout(iFamilyID, iParameterID, iParameterNLSName, iParameterTooltip, iIsDeployed, iColor, iHasOnlyOneArgument, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus)
			{
				var newRow = addLineRegularLayout(iFamilyID, iColor, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus);
				newRow.cells[CELL_PARAM].innerHTML = iParameterNLSName;
				newRow.cells[CELL_PARAM].title = iParameterTooltip;
				if (!iHasOnlyOneArgument)
				{
					newRow.deleteCell(CELL_STATUS);
					newRow.deleteCell(CELL_WIDGET);
					newRow.deleteCell(CELL_ARG);
					newRow.cells[CELL_PARAM].colSpan = 4;
					newRow.cells[CELL_PARAM].style.width = (100 - iSizeStatus) + "%";
					newRow.value = newRow.value - 3;
				}
				newRow.id = iParameterID;
				if (iIsDeployed)
					setParameterStatus(iParameterID, STATUS_DEPLOYED);
				else
					setParameterStatus(iParameterID, STATUS_STORED);
			}
			
			function addArgumentRegularLayout(iFamilyID, iParameterID, iArgumentID, iArgumentNLSName, iArgumentTooltip, iInputType, iMaxLength, iEditable, iValueList, iValueListNLS, iColor, iIsOnlyArgument, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus)
			{
				var cellArgument;
				var cellWidget;
				
				var row;
				
				if (iIsOnlyArgument)
				{
					row = document.getElementById(iParameterID);
					
					row.deleteCell(CELL_ARG);
					row.value = row.value - 1;
					
					cellArgument = row.cells[CELL_PARAM];
					cellArgument.colSpan = 2;
					cellArgument.style.width = (iSizeParameterName + iSizeArgumentName) + "%";
					cellWidget = row.cells[CELL_WIDGET - 1];
				}
				else
				{
					row = addLineRegularLayout(iFamilyID, iColor, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus);
					cellArgument = row.cells[CELL_ARG];
					cellWidget = row.cells[CELL_WIDGET];
				}
				
				var lineOffSet = 0;
				if (iInputType == INPUT_CHECKBOX)
					lineOffSet = <%=checkboxOffSetHeight%>;
				else if (iInputType == INPUT_COMBOBOX)
					lineOffSet = <%=comboboxOffSetHeight%>;
				else if (iInputType == INPUT_TEXTFIELD || iInputType == INPUT_CALENDAR || iInputType == INPUT_CLEARCAL)
					lineOffSet = <%=textfieldOffSetHeight%>;
				
				if (lineOffSet > 0)
				{
					increaseDivHeight(iFamilyID, lineOffSet);
					var rowHeight = row.style.height;
					var newHeight = parseInt(rowHeight) + lineOffSet;
					row.style.height = newHeight + "px";
				}
				
				cellArgument.innerHTML = iArgumentNLSName;
				cellArgument.title = iArgumentTooltip;
				cellWidget.appendChild(getInputWidget(iParameterID, iArgumentID, iInputType, iMaxLength, iEditable, iArgumentNLSName, iValueList, iValueListNLS, iColor));
			}
			
			function addLineRegularLayout(iFamilyID, iColor, iSizeParameterName, iSizeArgumentName, iSizeColumn, iSizeStatus)
			{
				increaseDivHeight(iFamilyID, <%=basicRowHeight%>);
				var newRow = document.getElementById(iFamilyID).insertRow(-1);
				newRow.style.height = "<%=basicRowHeight%>px";
				if (iColor == "")
					newRow.style.backgroundColor = "<%=color1%>";
				else
					newRow.style.backgroundColor = iColor;
				
				// CELL_PARAM
				var newCell = newRow.insertCell(-1);
				newCell.align = "left";
//				newCell.className = "MatrixFeelNxG";
				newCell.style.width = iSizeParameterName + "%";
				
				// CELL_ARG
				newCell = newRow.insertCell(-1);
				newCell.align = "left";
//				newCell.className = "MatrixFeelNxG";
				newCell.style.width = iSizeArgumentName + "%";
				
				// CELL_WIDGET
				newCell = newRow.insertCell(-1);
				newCell.align = "left";
//				newCell.className = "MatrixFeelNxG";
				newCell.style.width = iSizeColumn + "%";
				
				// CELL_EMPTY
				newCell = newRow.insertCell(-1);
				newCell.align = "left";
//				newCell.className = "MatrixFeelNxG";
				newCell.style.width = (100 - iSizeParameterName - iSizeArgumentName - iSizeColumn - iSizeStatus) + "%";
				
				// CELL_STATUS
				newCell = newRow.insertCell(-1);
				newCell.align = "left";
//				newCell.className = "MatrixFeelNxG";
				newCell.style.width = iSizeStatus + "%";
				
				//Status Columns index
				newRow.value = CELL_STATUS;
				
				return newRow;
			}
			
			function getInputWidget(iParameterID, iArgumentID, iInputType, iMaxLength, iEditable, iArgumentNLSName, iValueList, iValueListNLS, iColor)
			{
				if (iEditable && iInputType == INPUT_COMBOBOX)
				{
					var combobox = document.createElement("select");
					combobox.id = getWidgetID(iParameterID, iArgumentID);
					combobox.setAttribute("style", "width:100%");
					if (document.all) //IE
					{
						combobox.style.setAttribute("cssText", "width:100%;");
					}
					combobox.onchange = function() { setParameterStatus(iParameterID, STATUS_MODIFIED); };
					for (var i=0 ; i<iValueList.length ; i++)
						combobox.options[i] = new Option(iValueListNLS[i], iValueList[i]);
					combobox.title = iArgumentNLSName;
					return combobox;
				}
				else if (iInputType == INPUT_CHECKBOX)
				{
					var checkbox = document.createElement("input");
					checkbox.type = "checkbox";
					checkbox.id = getWidgetID(iParameterID, iArgumentID);
					checkbox.onclick = function() { setParameterStatus(iParameterID, STATUS_MODIFIED); };
					checkbox.title = iArgumentNLSName;
					checkbox.disabled = !iEditable;
					return checkbox;
				}
				else if (iInputType == INPUT_CALENDAR || iInputType == INPUT_CLEARCAL)
				{
					var widgetID = getWidgetID(iParameterID, iArgumentID);
					var innerTable = document.createElement("table");
					innerTable.setAttribute("style", "width:100%");
					var innerRow = innerTable.insertRow(-1);
					
					var dateField = document.createElement("input");
					dateField.type = "text";
					dateField.id = widgetID;
					dateField.name = dateField.id;
					dateField.setAttribute("style", "width:88%; min-height:18px");
					dateField.title = iArgumentNLSName;
					dateField.setAttribute('readonly', 'readonly');
					innerRow.insertCell(-1).appendChild(dateField);
					
					var msDateField = document.createElement("input");
					msDateField.type = "hidden";
					msDateField.id = widgetID + "_msvalue";
					msDateField.name = msDateField.id;
					//msDateField.setAttribute("style", "width:100%");
					msDateField.title = iArgumentNLSName;
					msDateField.setAttribute('readonly', 'readonly');
					var rowStamp = innerRow.insertCell(-1);
					rowStamp.appendChild(msDateField);
					rowStamp.style.display = 'none';
					
					if (iInputType == INPUT_CLEARCAL)
					{
						var imageClear = document.createElement("img");
						imageClear.src = "../common/images/iconParameterizationClearCalendar.gif";
						var clearLink = document.createElement("a");
						clearLink.href = "javascript:setArgumentValue(\"" + iParameterID + "\", \"" + iArgumentID + "\", \"\")";
						clearLink.appendChild(imageClear);
						clearLink.onclick = function() { setParameterStatus(iParameterID, STATUS_MODIFIED) };
						var cellClearLink = innerRow.insertCell(-1);
						cellClearLink.id = "CellClearDate_" + widgetID;
						cellClearLink.name = cellClearLink.id;
						cellClearLink.appendChild(clearLink);
						if (!iEditable)
							cellClearLink.style.display = 'none';
					}
					
					var imageCalendar = document.createElement("img");
					imageCalendar.style.marginLeft  = "2px";
					imageCalendar.src = "../common/images/iconSmallCalendar.gif";
					var calendarLink = document.createElement("a");
					calendarLink.id = "CalendarLink_" + widgetID;
					calendarLink.name = calendarLink.id;
					calendarLink.appendChild(imageCalendar);
					var cellCalendarLink = innerRow.insertCell(-1);
					cellCalendarLink.align = "right";
					cellCalendarLink.id = "CellCalendar_" + widgetID;
					cellCalendarLink.name = cellCalendarLink.id;
					cellCalendarLink.appendChild(calendarLink);
					if (!iEditable)
						cellCalendarLink.style.display = 'none';
					
					return innerTable;
				}
				else //if (iInputType == INPUT_TEXTFIELD)
				{
					var textField = document.createElement("input");
					textField.type = "text";
					textField.id = getWidgetID(iParameterID, iArgumentID);
					textField.setAttribute("style", "width:90%; min-height:18px");
					textField.onkeyup = function() { setWidgetColor(iParameterID, iArgumentID, true); setParameterStatus(iParameterID, STATUS_MODIFIED); };
					textField.oninput = function() { setWidgetColor(iParameterID, iArgumentID, true); setParameterStatus(iParameterID, STATUS_MODIFIED); };
					textField.onblur  = function() { checkNullValue(iParameterID, iArgumentID); };
					if (iMaxLength > 0)
						textField.maxLength = iMaxLength;
					textField.title = iArgumentNLSName;
					if (!iEditable)
					{
						textField.disabled = true;
						textField.style.background = iColor;
						textField.style.borderStyle = "none";
					}
					return textField;
				}
			}
			
			function getDateFromStamp(iStamp)
			{
				return "";
				/*
				<%-- DATE_FLAG : replace previous by next
				var objDate = new Date(parseInt(iStamp));
				var strURL = URL_GET_CALENDAR_SELECT;
				strURL = emxUICore.addURLParam(strURL, "day=" + objDate.getDate());
				strURL = emxUICore.addURLParam(strURL, "mon=" + (objDate.getMonth()+1));
				strURL = emxUICore.addURLParam(strURL, "year=" + objDate.getFullYear());
				return trim(emxUICore.getData(strURL));
				--%>
				*/
			}
			
			function setWidgetColor(iParameterID, iArgumentID, iOK)
			{
				var input = document.getElementById(getWidgetID(iParameterID, iArgumentID));
				if (input.type == "text")
				{
					if (iOK)
						input.style.background = "<%=colorOK%>";
					else
						input.style.background = "<%=colorERROR%>";
				}
			}
			
			function getParameterStatus(iParameterID)
			{
				var row = document.getElementById(iParameterID);
				if (row == null)
					return STATUS_DEPLOYED;
				return row.cells[row.value].value;
			}
			function setParameterStatus(iParameterID, iStatus)
			{
				var row = document.getElementById(iParameterID);
				var parameterLine = row.cells[row.value];
				parameterLine.value = iStatus;
				if (iStatus == STATUS_DEPLOYED)
				{
					parameterLine.innerHTML = "<img src=\"images/iconParameterizationParameterDeployed.gif\">";
					parameterLine.title = "<%=myNLS.getMessage("DeployedParameter")%>";
				}
				else if (iStatus == STATUS_STORED)
				{
					parameterLine.innerHTML = "<img src=\"images/iconParameterizationParameterSaved.gif\">";
					parameterLine.title = "<%=myNLS.getMessage("NotYetDeployedParameter")%>";
				}
				else if (iStatus == STATUS_MODIFIED)
				{
					parameterLine.innerHTML = "<img src=\"images/iconParameterizationParameterModified.gif\">";
					parameterLine.title = "<%=myNLS.getMessage("modifiedParameter")%> (<%=myNLS.getMessage("NotYetDeployedParameter")%>)";
				}
			}
			
			function checkNullValue(iParameterID, iArgumentID)
			{
				if (getArgumentValue(iParameterID, iArgumentID) != "")
					return;
				var argumentType = getArgumentType(iParameterID, iArgumentID);
				if (argumentType == TYPE_INTEGER)
					setArgumentValue(iParameterID, iArgumentID, "0");
				else if (argumentType == TYPE_NATURAL)
					setArgumentValue(iParameterID, iArgumentID, "0");
				else if (argumentType == TYPE_REAL)
					setArgumentValue(iParameterID, iArgumentID, "0.");
				else if (argumentType == TYPE_BOOLEAN)
					setArgumentValue(iParameterID, iArgumentID, UNCHECKED);
			}
			
			function getArgumentValue(iParameterID, iArgumentID)
			{
				var input;
				if (getArgumentType(iParameterID, iArgumentID) == TYPE_TIMESTAMP)
					input = document.getElementById(getWidgetID(iParameterID, iArgumentID) + "_msvalue");
				else
					input = document.getElementById(getWidgetID(iParameterID, iArgumentID));
				if (input == null)
					return "";
				if (input.type == "checkbox")
				{
					if (input.checked)
						return CHECKED;
					return UNCHECKED;
				}
				else if (input.type == "text")
					return input.value;
				else if (input.type == "hidden")
					return input.value;
				else if (input.type == "select-one")
					return input.value;
				else
					return input.value;
			}
			
			function setArgumentInitialValue(iParameterID, iArgumentID, iValue)
			{
				setArgumentValue(iParameterID, iArgumentID, iValue);
				var argumentType = getArgumentType(iParameterID, iArgumentID);
				if (argumentType == TYPE_TIMESTAMP || argumentType == TYPE_DATE)
				{
					var widgetID = getWidgetID(iParameterID, iArgumentID);
					var calendarLink = document.getElementById("CalendarLink_" + widgetID);
					var value = iValue;
					if (argumentType == TYPE_TIMESTAMP)
						value = getDateFromStamp(iValue);
					
					calendarLink.href = "javascript:setParameterStatus(\"" + iParameterID + "\", STATUS_MODIFIED);";
					/*
					<%-- DATE_FLAG : replace previous by next
					calendarLink.href = "javascript:showCalendar(" +
						"\"ParameterizationAppIntForm\"," +	//strFormName
						"\"" + widgetID + "\"," +	//strInputName
						"\"" + value + "\"," +	//strInitialDate
						"\"\"," +	//blnRemember
						"setParameterStatus(\"" + iParameterID + "\", STATUS_MODIFIED)," +	//fnCallback
						"\"\"," +	//objWindow
						"\"\"," +	//objTargetFrame
						"null);";	//requestMapObj
					--%>
					*/
				}
			}
			function setArgumentValue(iParameterID, iArgumentID, iValue)
			{
				if (isEditable(iParameterID, iArgumentID))
					setWidgetColor(iParameterID, iArgumentID, true);
				var input = document.getElementById(getWidgetID(iParameterID, iArgumentID));
				
				var argumentType = getArgumentType(iParameterID, iArgumentID);
				if (argumentType == TYPE_TIMESTAMP)
				{
					var inputDate = input;
					input = document.getElementById(getWidgetID(iParameterID, iArgumentID) + "_msvalue");
					
					if (iValue == "")
						inputDate.value = '';
					else
						inputDate.value = getDateFromStamp(iValue);
				}
				else if (argumentType == TYPE_DATE)
				{
					var inputStamp = document.getElementById(getWidgetID(iParameterID, iArgumentID) + "_msvalue");
					if (iValue == "")
						inputStamp.value = '';
					else
						inputStamp.value = (new Date(iValue)).getTime();
				}
				if (input.type == "checkbox")
				{
					if (iValue == CHECKED)
						input.checked = true;
					else
						input.checked = false;
				}
				else if (input.type == "text")
					input.value = iValue;
				else if (input.type == "hidden")
					input.value = iValue;
				else if (input.type == "select-one")
					input.value = iValue;
				else
					input.value = iValue;
			}
			
			function setEditable(iParameterID, iArgumentID, iEnabled)
			{
				var widgetID = getWidgetID(iParameterID, iArgumentID);
				var argumentType = getArgumentType(iParameterID, iArgumentID);
				if (argumentType == TYPE_TIMESTAMP || argumentType == TYPE_DATE)
				{
					var newStyle = '';
					if (!iEnabled)
						newStyle = 'none';
					var cellCalendarLink = document.getElementById("CellCalendar_"  + widgetID);
					var cellClearLink    = document.getElementById("CellClearDate_" + widgetID);
					cellCalendarLink.style.display = newStyle;
					if (cellClearLink != null)
						cellClearLink.style.display = newStyle;
					return;
				}
				var input = document.getElementById(widgetID);
				if (input.type == "checkbox")
				{
					input.disabled = !iEnabled;
					if (!iEnabled)
						input.style.background = "<%=colorNotEditable%>";
				}
				else if (input.type == "text")
				{
					input.disabled = !iEnabled;
					if (!iEnabled)
						input.style.background = "<%=colorNotEditable%>";
				}
				else if (input.type == "select-one")
				{
					input.disabled = !iEnabled;
					if (!iEnabled)
						input.style.background = "<%=colorNotEditable%>";
				}
				else
					input.disabled = !iEnabled;
			}
			function isEditable(iParameterID, iArgumentID)
			{
				var argumentType = getArgumentType(iParameterID, iArgumentID);
				if (argumentType == TYPE_TIMESTAMP || argumentType == TYPE_DATE)
				{
					var cellCalendarLink = document.getElementById("CellCalendar_"  + getWidgetID(iParameterID, iArgumentID));
					if (cellCalendarLink == null)
						return false;
					if (cellCalendarLink.style.display == 'none')
						return false;
					return true;
				}
				var input = document.getElementById(getWidgetID(iParameterID, iArgumentID));
				if (input == null)
					return false;
				if (input.type == "checkbox")
					return !input.disabled;
				else if (input.type == "text")
					return !input.disabled;
				else if (input.type == "select-one")
					return !input.disabled;
				else
					return !input.disabled;
				return true;
			}
			
			function containsChar(string, chars)
			{
				for (var i=0 ; i<string.length ; i++)
					if (chars.indexOf(string.charAt(i)) != -1)
						return true;
				return false;
			}
			function checkValue(iValue, iArgumentType, iArgumentLength)
			{
				if (iArgumentType == TYPE_STRING)
				{
					var forbiddenChars = "\n|<>";
					var foundForbiddenChars = "";
					for (var i=0 ; i<forbiddenChars.length ; i++)
						if (iValue.indexOf(forbiddenChars.charAt(i)) != -1)
							foundForbiddenChars = foundForbiddenChars + " " + forbiddenChars.charAt(i);
					if (foundForbiddenChars != "")
						return "<%=myNLS.getMessage("EntryContainsForbiddenChar")%> :" + foundForbiddenChars;
					
					if (iArgumentLength > 0 && iValue.length > iArgumentLength)
						return "<%=myNLS.getMessage("EntryTooLong")%>";
				}
				else if (iArgumentType == TYPE_INTEGER)
				{
					if (!(/^-{0,1}\d+$/.test(iValue)))
						return "<%=myNLS.getMessage("EntryMustBeInteger")%>";
				}
				else if (iArgumentType == TYPE_NATURAL)
				{
					if (!(/^\d+$/.test(iValue)))
						return "<%=myNLS.getMessage("EntryMustBeNatural")%>";
				}
				else if (iArgumentType == TYPE_REAL)
				{
					if ("." == iValue || "-" == iValue || "-." == iValue || !(/^-{0,1}\d*\.{0,1}\d*$/.test(iValue)))
						return "<%=myNLS.getMessage("EntryMustBeReal")%>";
				}
				else if (iArgumentType == TYPE_BOOLEAN)
				{
					if (iValue != CHECKED && iValue != UNCHECKED)
						return "<%=myNLS.getMessage("EntryMustBeBoolean")%>";
				}
				else if (iArgumentType == TYPE_DATE || iArgumentType == TYPE_TIMESTAMP)
				{
					return "";
				}
				else
				{
					return "?"
				}
				return "";
			}
			
			function DeployParams(iInput)
			{
				if (isFrozen())
				{
					alert("<%=myNLS.getMessage("Freezemessage")%>");
					return;
				}
				
				var deploymentString = "&frzStatus=false";
				if (iInput == "freezecmds" && confirm("<%=myNLS.getMessage("Confirmfreeze")%>"))
					deploymentString = "&frzStatus=true";
				
				var errorString = "";
				var nbParameters = 0;
				deploymentString = deploymentString + "&domainID=<%=domainID%>";
				for (var i=0 ; i<parameterList.length ; i++)
				{
					var parameterID = parameterList[i];
					
					// don t even try to send parameter that have not been modified
					if (getParameterStatus(parameterID) == STATUS_DEPLOYED)
						continue;
					
					var nbArguments = 0;
					for (var j=0 ; j<argumentIDs[i].length ; j++)
					{
						var argumentID = argumentIDs[i][j];
						var value = getArgumentValue(parameterID, argumentID)
						
						var valueCheck = checkValue(value, argumentTypes[i][j], argumentLengths[i][j]);
						if (valueCheck != "")
						{
							setWidgetColor(parameterID, argumentID, false);
							errorString = errorString + "\n    " + argumentNLSNames[i][j] + " : " + valueCheck;
							continue;
						}
						deploymentString = deploymentString + "&iArgumentID_"    + nbParameters + "_" + nbArguments + "=" + argumentID;
						deploymentString = deploymentString + "&iArgumentValue_" + nbParameters + "_" + nbArguments + "=" + value;
						nbArguments++;
					}
					deploymentString = deploymentString + "&nbOfArguments_" + nbParameters + "=" + nbArguments;
					deploymentString = deploymentString + "&iParamID_" + nbParameters + "=" + parameterID;
					nbParameters++;
				}
				deploymentString = deploymentString + "&numberbofSentParams=" + nbParameters;
				
				if (errorString != "")
				{
					alert("<%=myNLS.getMessage("EntryFormatError")%>" + errorString);
					return;
				}
<%				for (AppIntUIConnector.IExchangeUIValueCheck uiValueCheck : uiValueChecks)
				{
					String functionName = uiValueCheck.getID();
%>				var ret_<%=functionName%> = <%=functionName%>();
<%					String[] errorsList        = uiValueCheck.getErrorsList();
					String[] errorsNLSKeyList  = uiValueCheck.getErrorsNLSKeyList();
					String[] errorsNLSFileList = uiValueCheck.getErrorsNLSFileName();
					for (int i=0 ; i<errorsList.length ; i++)
					{
						ParameterizationNLSCatalog errorNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, errorsNLSFileList[i]);
						String nlsErrorName = errorNLSCatalog.getMessage(errorsNLSKeyList[i]);
%>				if (ret_<%=functionName%> == "<%=errorsList[i]%>")
				{
					alert("<%=nlsErrorName%>");
					return;
				}
<%					}
				}
%>				document.getElementById('LoadingDiv').style.display = 'block';
				document.getElementById('divPageFoot').style.display = 'none';

				xmlreq("emxPLMOnlineAdminXPApplicationsAjax.jsp", deploymentString, DeployParamsRet, 0);
			}

			function DeployParamsRet()
			{
				var xmlhttpfreeze = xmlreqs[0];
				if (xmlhttpfreeze.readyState == 4)
				{
					document.getElementById('LoadingDiv').style.display = 'none';
					document.getElementById('divPageFoot').style.display = 'block';

					var message = "";
					
					var deploymentRet = xmlhttpfreeze.responseXML.getElementsByTagName("ParamsAppsSet");
					if (deploymentRet.item(0) != null && deploymentRet.item(0).firstChild.data == "S_OK")
					{
						for (var i=0 ; i<parameterList.length ; i++)
							setParameterStatus(parameterList[i], STATUS_DEPLOYED);
						message = "<%=myNLS.getMessage("Deploysuccess")%>";
					}
					else
					{
						var paramStoredAndDeployed = xmlhttpfreeze.responseXML.getElementsByTagName("ParamsStoredAndDeployed");
						if (paramStoredAndDeployed.item(0) != null)
						{
							var paramStoredAndDeployedList = paramStoredAndDeployed.item(0).firstChild.data.split(',');
							for (var i=0 ; i<paramStoredAndDeployedList.length ; i++)
								setParameterStatus(paramStoredAndDeployedList[i], STATUS_DEPLOYED);
						}
						var paramStoredOnly = xmlhttpfreeze.responseXML.getElementsByTagName("ParamsStoredOnly");
						if (paramStoredOnly.item(0) != null)
						{
							var paramStoredOnlyList = paramStoredOnly.item(0).firstChild.data.split(',');
							for (var i=0 ; i<paramStoredOnlyList.length ; i++)
								setParameterStatus(paramStoredOnlyList[i], STATUS_STORED);
						}
						var paramNotStored = xmlhttpfreeze.responseXML.getElementsByTagName("ParamsNotStored");
						if (paramNotStored.item(0) != null)
						{
							var paramNotStoredList = paramNotStored.item(0).firstChild.data.split(',');
							for (var i=0 ; i<paramNotStoredList.length ; i++)
								setParameterStatus(paramNotStoredList[i], STATUS_MODIFIED);
						}
						message = "<%=myNLS.getMessage("Deployfail")%>";
					}
					
					var freezeRet = xmlhttpfreeze.responseXML.getElementsByTagName("Freezeret");
					if (freezeRet.item(0) != null)
					{
						if (freezeRet.item(0).firstChild.data == "S_OK")
						{
							updateFreeze(true);
							message = message + "\n<%=myNLS.getMessage("Freezesuccess")%>";
						}
						else
						{
							message = message + "\n<%=myNLS.getMessage("Freezefailure")%>";
						}
					}
					
					var reloadCacheRet = xmlhttpfreeze.responseXML.getElementsByTagName("ReloadCacheRet");
					if (reloadCacheRet.item(0) != null)
					{
						if (reloadCacheRet.item(0).firstChild.data == "S_OK")
							message = message + "\n<%=myNLS.getMessage("ReloadCacheSuccess")%>";
						else if (reloadCacheRet.item(0).firstChild.data == "E_Fail")
							message = message + "\n<%=myNLS.getMessage("ReloadCacheFailure")%>";
					}
					
					alert(message);
				}
			}

			function ResetInSession()
			{
				if (isFrozen())
				{
					alert("<%=myNLS.getMessage("Freezemessage")%>");
					return;
				}
				var allDefault = true;
				for (var i=0 ; i<parameterList.length ; i++)
				{
					var parameterID = parameterList[i];
					for (var j=0 ; j<argumentIDs[i].length ; j++)
					{
						var argumentID = argumentIDs[i][j];
						if (!isEditable(parameterID, argumentID))
							continue;
						var defaultValue = argumentDefault[i][j];
						var value = getArgumentValue(parameterID, argumentID);
						if (defaultValue != value)
						{
							setArgumentValue(parameterID, argumentID, defaultValue);
							setParameterStatus(parameterID, STATUS_MODIFIED);
							allDefault = false;
						}
					}
				}
				if (allDefault)
					for (var i=0 ; i<parameterList.length ; i++)
						setParameterStatus(parameterList[i], STATUS_MODIFIED);
			}		
		
		</script>
	</head>
	<body>
	<form name="ParameterizationAppIntForm">
		<div id="ParamDataIdDiv" style="width: 100%; height:100%; min-height: 80%; background-color:<%=color1%>;  overflow-x:hidden; overflow-y:auto;">
			<script type="text/javascript">
				addTransparentLoadingInSession("none","LoadingDiv");
				addDivForNonAppropriateContext("<%=displayhidediv%>","<%=NonAppropriateContext%>","100%","100%");
<%			AppIntUIConnector.IExchangeFamily[] families = new AppIntUIConnector.IExchangeFamily[0];
			if (domain != null)
				families = domain.getFamilies();
			int nbParameters = 0;
			for (AppIntUIConnector.IExchangeFamily family : families)
			{
%>				var columns        = new Array();
				var columnsNLS     = new Array();
				var columnsTooltip = new Array();
				var columnsSizes   = new Array();
<%				ParameterizationNLSCatalog familyNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, family.getNLSFileName());
				String familyNLSName = familyNLSCatalog.getMessage(family.getNLSKey());
				String familyTooltip = familyNLSCatalog.getMessage(family.getTooltipNLSKey());
				AppIntUIConnector.IExchangeColumn[] columns = family.getColumns();
				
				int sizeParameterName = defaultWidthParameterName;
				int sizeArgumentName = defaultWidthArgumentName;
				int sizeColumn = defaultWidthColumn;
				int sizeStatus = defaultWidthStatus;
				
				if (family.getParameterTextSize() >= 0 && family.getArgumentTextSize() >= 0 && family.getWidgetSize() >= 0 && family.getStatusSize() >= 0)
				{
					sizeParameterName = family.getParameterTextSize();
					sizeArgumentName = family.getArgumentTextSize();
					sizeColumn = family.getWidgetSize();
					sizeStatus = family.getStatusSize();
				}
				
				if (columns.length > 0)
				{
					int tableParameterNameWidthPercentage = 15;
					int tableStatusWidthPercentage = 5;
					if (family.getParameterTextSize() >= 0 && family.getStatusSize() >= 0)
					{
						tableParameterNameWidthPercentage = family.getParameterTextSize();
						tableStatusWidthPercentage = family.getStatusSize();
					}
					int[] columnWidthPercentage = new int[columns.length];
					int remainingSize = 100;
					int notSpecifiedColumnsNumber = 0;
					for (int i=0 ; i<columns.length ; i++)
						if (columns[i].getWidgetSize() < 0)
							notSpecifiedColumnsNumber++;
						else
						{
							remainingSize = remainingSize - columns[i].getWidgetSize();
							columnWidthPercentage[i] = columns[i].getWidgetSize();
						}
					if (notSpecifiedColumnsNumber > 0)
					{
						int defaultSize = (int)(remainingSize/notSpecifiedColumnsNumber);
						for (int i=0 ; i<columns.length ; i++)
							if (columns[i].getWidgetSize() < 0)
								columnWidthPercentage[i] = defaultSize;
					}
					sizeArgumentName = 0;
					sizeColumn = 0;
					int[] columnWidthSize = new int[columns.length];
					int allColumnsWidthTmp = 100 - (tableParameterNameWidthPercentage + tableStatusWidthPercentage);
					int allColumnsWidth = 0;
					for (int i=0 ; i<columns.length ; i++)
					{
						columnWidthSize[i] = (int)((columnWidthPercentage[i]*allColumnsWidthTmp)/100);
						allColumnsWidth = allColumnsWidth + columnWidthSize[i];
					}
					sizeStatus = tableStatusWidthPercentage;
					sizeParameterName = 100 - sizeStatus - allColumnsWidth;
					for (int i=0 ; i<columns.length ; i++)
					{
						ParameterizationNLSCatalog columnsNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, columns[i].getNLSFileName());
						String tmpColumnNLS     = columnsNLSCatalog.getMessage(columns[i].getNLSKey());
						String tmpColumnTooltip = columnsNLSCatalog.getMessage(columns[i].getTooltipNLSKey());
						if (columns[i].getTooltipNLSKey().equals(tmpColumnTooltip))
							tmpColumnTooltip = tmpColumnNLS;
%>				columns[<%=i%>]        = "<%=columns[i].getID()%>";
				columnsNLS[<%=i%>]     = "<%=tmpColumnNLS%>";
				columnsTooltip[<%=i%>] = "<%=tmpColumnTooltip%>";
				columnsSizes[<%=i%>]   = <%=columnWidthSize[i]%>;
<%					}
				}
%>				addFamily(
					"<%=family.getID()%>",
					"<%=familyNLSName%>",
					"<%=familyTooltip%>",
					"<%=family.getIcon()%>",
					columns,
					columnsNLS,
					columnsTooltip,
					<%=sizeParameterName%>,
					<%=sizeArgumentName%>,
					<%=sizeColumn%>,
					columnsSizes,
					<%=sizeStatus%>);
<%				String currentColor = color2;
				AppIntUIConnector.IExchangeParameter[] parameters = family.getParameters();
				for (AppIntUIConnector.IExchangeParameter parameter : parameters)
				{
					ParameterizationNLSCatalog parameterNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, parameter.getNLSFileName());
					String parameterNLSName = parameterNLSCatalog.getMessage(parameter.getNLSKey());
					String parameterTooltip = parameterNLSCatalog.getMessage(parameter.getTooltipNLSKey());
					if (color1.equals(currentColor))
						currentColor = color2;
					else
						currentColor = color1;
					AppIntUIConnector.IExchangeArgument[] argumentsWithHidden = parameter.getArguments();
					AppIntUIConnector.IExchangeArgument[] arguments = new AppIntUIConnector.IExchangeArgument[0];
					for (AppIntUIConnector.IExchangeArgument arg : argumentsWithHidden)
					{
						if (arg.getInactive())
							continue;
						AppIntUIConnector.IExchangeArgument[] tmp = arguments;
						arguments = new AppIntUIConnector.IExchangeArgument[tmp.length + 1];
						for (int j=0 ; j<tmp.length ; j++)
							arguments[j] = tmp[j];
						arguments[tmp.length] = arg;
					}
%>				addParameter(
					"<%=family.getID()%>",
					"<%=parameter.getID()%>",
					"<%=parameterNLSName%>",
					"<%=parameterTooltip%>",
					<%=parameter.isDeployed()%>,
					"<%=currentColor%>",
					columns,
					columnsNLS,
					columnsTooltip,
					<%=(arguments.length == 1)%>,
					<%=sizeParameterName%>,
					<%=sizeArgumentName%>,
					<%=sizeColumn%>,
					columnsSizes,
					<%=sizeStatus%>);
				parameterList[<%=nbParameters%>] = "<%=parameter.getID()%>";
				argumentIDs[<%=nbParameters%>]      = new Array();
				argumentNLSNames[<%=nbParameters%>] = new Array();
				argumentTypes[<%=nbParameters%>]    = new Array();
				argumentLengths[<%=nbParameters%>]  = new Array();
				argumentDefault[<%=nbParameters%>]  = new Array();
<%					int nbArguments = 0;
					for (int k=0 ; k<arguments.length ; k++)
					{
						ParameterizationNLSCatalog argumentNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, arguments[k].getNLSFileName());
						String argumentNLSName = argumentNLSCatalog.getMessage(arguments[k].getNLSKey());
						String argumentTooltip = argumentNLSCatalog.getMessage(arguments[k].getTooltipNLSKey());
						
						if (argumentTooltip.indexOf("<br>") >=0)
						{
							argumentTooltip = argumentTooltip.replaceAll("<br>", "\\\\n");
						}		
						
%>				var valueList    = new Array();
				var valueListNLS = new Array();
<%							String[] valueList = arguments[k].getValuesList();
							String[] valueListNLS = arguments[k].getValuesNLSKeyList();
							String[] valuesNLSFileName = arguments[k].getValuesNLSFileName();
							
							for (int l=0 ; l<valueList.length ; l++)
							{
								if (l >= valueListNLS.length || l >= valuesNLSFileName.length)
									continue;
								ParameterizationNLSCatalog valueNLSCatalog = new ParameterizationNLSCatalog(context, currentLocale, valuesNLSFileName[l]);
								String valueNLS = valueNLSCatalog.getMessage(valueListNLS[l]);
%>				valueList[<%=l%>]    = "<%=valueList[l]%>";
				valueListNLS[<%=l%>] = "<%=valueNLS%>";
<%							}
							if (columns.length > 0)
							{
%>				argumentNLSNames[<%=nbParameters%>][<%=nbArguments%>] = "<%=parameterNLSName%>";
				for (i=0 ; i<columns.length ; i++)
					if (columns[i] == "<%=arguments[k].getID()%>")
						argumentNLSNames[<%=nbParameters%>][<%=nbArguments%>] = "<%=parameterNLSName%> | " + columnsNLS[i];
<%							}
							else if (arguments.length == 1)
							{
%>				argumentNLSNames[<%=nbParameters%>][<%=nbArguments%>] = "<%=argumentNLSName%>";
<%							}
							else
							{
%>				argumentNLSNames[<%=nbParameters%>][<%=nbArguments%>] = "<%=parameterNLSName%> | <%=argumentNLSName%>";
<%							}
%>				addArgument(
					"<%=family.getID()%>",
					"<%=parameter.getID()%>",
					"<%=arguments[k].getID()%>",
					"<%=argumentNLSName%>",
					argumentNLSNames[<%=nbParameters%>][<%=nbArguments%>],
					"<%=argumentTooltip%>",
					"<%=arguments[k].getInput()%>",
					<%=arguments[k].getMaxLength()%>,
					<%=arguments[k].getEditable()%>,
					valueList,
					valueListNLS,
					"<%=currentColor%>",
					<%=(arguments.length == 1)%>,
					<%=sizeParameterName%>,
					<%=sizeArgumentName%>,
					<%=sizeColumn%>,
					<%=sizeStatus%>,
					columns);
				argumentIDs[<%=nbParameters%>][<%=nbArguments%>] = "<%=arguments[k].getID()%>";
				argumentTypes[<%=nbParameters%>][<%=nbArguments%>]    = "<%=arguments[k].getArgumentType()%>";
				argumentLengths[<%=nbParameters%>][<%=nbArguments%>]  = <%=arguments[k].getMaxLength()%>;
				argumentDefault[<%=nbParameters%>][<%=nbArguments%>]  = "<%=arguments[k].getDefault()%>";
				setArgumentInitialValue("<%=parameter.getID()%>", "<%=arguments[k].getID()%>", "<%=arguments[k].getValue()%>");
<%						nbArguments++;
					}
					nbParameters++;
				}
			}
			if (nbParameters == 0) {
				displayhidecontrol = "none";
				%>	               
                sendLicenseWarningMsg("<%=NonAppropriateLicenseMsg%>");
			    <%
			}
%>			</script>
			<br><br>
		</div>
	</form>
	<script>
		if (tabIsFrozen)
			updateFreeze(<%=tabIsFrozen%>);
		addFooter("javascript:DeployParams('nofreeze')","images/buttonParameterizationDeploy.gif","<%=myNLS.getMessage("Deploycmd")%>","<%=myNLS.getMessage("DeployTitle")%>",null,null,null,null,"javascript:ResetInSession()","images/buttonParameterizationReset.gif","<%=myNLS.getMessage("Resetcmd")%>","<%=myNLS.getMessage("ResetTitle")%>","<%=displayhidecontrol%>");
	</script>
	</body>
</html>
