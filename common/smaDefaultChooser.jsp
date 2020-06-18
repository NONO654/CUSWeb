<%--  smaDefaultChooser.jsp - Display the Choice options for an attribute

   Copyright (c) 1992-2014 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxForm.jsp.rca 1.28 Wed Oct 22 15:48:22 2008 przemek Experimental przemek $
--%>

<%@include file="emxNavigatorInclude.inc"%>

<html>
<head>

<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page	import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page	import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page	import="com.dassault_systemes.smaslm.matrix.server.AttributeGroupsUtil"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="matrix.db.AttributeType"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.StringResource"%>
<%@page import="java.util.*"%>

<%
    HashMap requestMap = UINavigatorUtil
					.getRequestParameterMap(pageContext);
			String querystring = request.getQueryString();
			int pos = querystring.indexOf("objectName=");
			if (pos != -1) {
				StringBuffer sb = new StringBuffer(querystring);
				sb.append('&');
				sb.delete(pos, sb.indexOf("&", pos) + 1);
				querystring = sb.toString();
			}

			final String locale = context.getSession().getLanguage();

			String Export = emxGetParameter(request, "Export");
			String mode = emxGetParameter(request, "mode");
			String form = emxGetParameter(request, "form");
			String formHeader = emxGetParameter(request, "formHeader");
			String objectBased = emxGetParameter(request, "objectBased");
			String suiteKey = emxGetParameter(request, "suiteKey");
			String SuiteDirectory = emxGetParameter(request, "SuiteDirectory");
			String rowId = emxGetParameter(request, "rowId");
			String postProcessURL = emxGetParameter(request, "postProcessURL");
			String submitAction = emxGetParameter(request, "submitAction");
			String fName = emxGetParameter(request, "fName");
			String slmmode = emxGetParameter(request, "slmmode");
			String cellValue = emxGetParameter(request, "cellValue");
			String attributeGroupId = emxGetParameter(request,
					"attributeGroupId");

			Map currentAttribute = null;
			String fieldValue = null;
			StringList listFieldValue = null;
			boolean isAttrGrpCall = true;

			if (cellValue.startsWith("Value")) {
				isAttrGrpCall = false;
			}

			// Get the attribute info if this is the first field.
			if (currentAttribute == null)
				currentAttribute = AttributeGroupsUtil.getAttributeInfo(
						context, rowId);

			if (isAttrGrpCall) {
				listFieldValue = (StringList) currentAttribute
						.get("choicesList");
				fieldValue = (String) currentAttribute.get("choices");
			} else {
				if (attributeGroupId != null) {

					DomainObject domainObject = new DomainObject(
							attributeGroupId);
					//    domainObject.open(context);
					// determine whether the object is an attribute group
					final String TYPE_ATTR_GROUP = SimulationConstants.SYMBOLIC_type_SimulationAttributeGroup;
					final String ATTRIBUTE_MXSYSINTERFACE = SimulationUtil
							.getSchemaProperty(TYPE_ATTR_GROUP);

					domainObject.getTypeName();
					if (domainObject
							.isKindOf(context, ATTRIBUTE_MXSYSINTERFACE)) {
						MapList attrList = AttributeGroupsUtil
								.getAttributesTable(context, attributeGroupId);
						Map curAttribute = AttributeGroupsUtil
								.getAttributeInfoInGroup(context, domainObject,
										rowId, currentAttribute);
						listFieldValue = (StringList) curAttribute
								.get("choicesList");
					}
				} else {
					if (rowId != null) {
						listFieldValue = (StringList) currentAttribute
								.get("choicesList");
					}
				}

			}
			StringList choicesDisplay = UINavigatorUtil.getAdminI18NStringList(
					"choices", listFieldValue, locale);
%>

</head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css"
	type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css"
	type="text/css">

<script type="text/javascript" language="javascript">

</script>
<body>

	<br>
	<div>
		<form name="chooseDefaultFormHeader" id="chooseDefaultFormHeader">

			<table border="0.5" width="100%" class="list" cellpadding="1"
				cellspacing="0.5">
				<tbody>

					<tr align="center">
						<th width="4" style="text-align: center"><input
							type="checkbox" name="headerCheck" id="headerCheck"
							onclick="doCheckHeader()">
						</th>
						<th><a>Choices</a>
						</th>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	<br>
	<div style="overflow: auto; height: 400px;">
		<form name="chooseDefaultForm" id="chooseDefaultForm" method="post"
			onsubmit="doAdd();return false">

			<table border="0.5" width="100%" class="list" cellpadding="1"
				cellspacing="0.5">
				<tbody>
					<%
					    try {
									if (choicesDisplay.size() == 0) {
										String msg = UINavigatorUtil
												.getI18nString(
														"smaSimulationCentral.Content.ErrMsg.nomorecategories",
														"smaSimulationCentralStringResource",
														locale);
					%>
					<p class="error"><%=msg%></p>
					<%
					    } else {
										String[] sChoices = new String[choicesDisplay.size()];
										sChoices = (String[]) choicesDisplay.toArray(sChoices);

										for (int ii = 0; ii < sChoices.length; ii++) {
											if ((ii % 2) == 0) {
					%>

					<tr class="even">
						<td width="6" style="text-align: center"><input
							type="checkbox" name="Choices" id="Choices"
							onclick="doCheckAll()" value="<%=sChoices[ii].trim()%>" />
						</td>
						<td><%=sChoices[ii]%></td>
					</tr>

					<%
					    } else {
					%>

					<tr class="odd">
						<td width="6" style="text-align: center"><input
							type="checkbox" name="Choices" id="Choices"
							onclick="doCheckAll()" value="<%=sChoices[ii].trim()%>" />
						</td>
						<td><%=sChoices[ii]%></td>
					</tr>

					<%
					    }
										}
									}
								} catch (Exception e) {
									System.out.println("error: " + e.toString());
								}
					%>
				</tbody>
			</table>
	
		</form>
	</div>
	<script type="text/javascript"
		src="../simulationcentral/smaStructureBrowser.js"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" src="../common/scripts/jquery-latest.js"></script>

	<script type="text/javascript">
 // This script checks the already selected choices in the UI
 
     var frame2 = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"formEditDisplay");
     var sExistDefVal = frame2.document.editDataForm.<%=cellValue%>.value; // Extracting the existing selected values
 
     if (sExistDefVal!= null) 
     {
         var SplitChars = "\n";
         existValArray = sExistDefVal.split(SplitChars);
 
     }
      var checkboxList = document.getElementsByTagName("input");
     if(checkboxList.length > 0)
     {
     var checkboxLength = checkboxList.length;
     var rowstoCheckLength = existValArray.length;
     var editedExistVal = null;
      for(var i = 0; i < checkboxLength; i++)
      {
         if(checkboxList[i].type == "checkbox")
             {
     
                for(var ij = 0; ij < rowstoCheckLength; ij++)
                   {
              //Replacing the newline to make it compatible to IE8
                 editedExistVal = existValArray[ij].replace(/[\r\n|\n]/g, '');
                if (editedExistVal == null || editedExistVal == '')
                    {
                    editedExistVal = existValArray[ij];
                    }
                
                    if(checkboxList[i].value == editedExistVal) // Comparing the already selected values with the list of choices 
                           {
                           checkboxList[i].checked = true; // Checking the already selected choices
                           }
                     
                   }
           
             }
        }
      }
           
</script>
	<form name="chooseDefaultFooter" method="post"
		onsubmit="doAdd(); return false">
		<table width="100%" border="0" margin="0" align="center"
			cellspacing="0" cellpadding="0">
			<tr>
				<td align="right">
					<table border="0" cellspacing="0" cellpadding="0">
						<tr>
							<td>&nbsp;&nbsp;</td>
							<td><a class="footericon" href="javascript:doAdd()"><img border="0"
									" src="../common/images/buttonDialogDone.gif">
							</a>
							</td>
							<td nowrap>&nbsp;<a href="javascript:doAdd()" class="button"><button class="default" type="button"><emxUtil:i18n
										localize="i18nId">emxFramework.Common.Done</emxUtil:i18n></button>
							</a>
							</td>
							<td>&nbsp;&nbsp;</td>
							<td><a class="footericon" href="javascript:getTopWindow().closeWindow();"><img border="0"
									src="../common/images/buttonDialogCancel.gif">
							</a>
							</td>
							<td nowrap>&nbsp;<a class="button"
								href="javascript:getTopWindow().closeWindow();"><button class="default" type="button"><emxUtil:i18n
										localize="i18nId">emxFramework.Button.Cancel</emxUtil:i18n></button>
							</a>
							</td>
						</tr>
					</table></td>
			</tr>
		</table>
	</form>

	<script language="javascript">
   
	//This function adds the selected choices to 
	//the default feild in the parent window 
        function doAdd()
        {
                        
            var elems = document.getElementsByTagName("input");
            var params = "";
            for ( var ii=0; ii<elems.length; ii++ )
            {
                if ( elems[ii].checked && elems[ii].id != "headerCheck")
                   params += elems[ii].value + "\n";
            }
 
            var frame2 = sbFindFrame(getTopWindow().getWindowOpener().getTopWindow(),"formEditDisplay");
           frame2.document.editDataForm.<%=cellValue%>.value = params; 
            getTopWindow().closeWindow();
        }
	
       //This function sets the all the checkboxes based on the header checkbox value 
        function doCheckHeader()
        {
         //   alert('Insise DC');
             var elems = document.getElementById("headerCheck");
             var allElems = document.getElementsByTagName("input");
             if (elems.checked)
                 {
                 for ( var ii=0; ii<allElems.length; ii++ )
                 {
                         allElems[ii].checked = true;
                 }
                 }
             else
                 {
                 for ( var ii=0; ii<allElems.length; ii++ )
                 {
                         allElems[ii].checked = false;
                 }
                 
                 }
        }   
       
       //If all the checkboxes are checked then this function checks the header checkbox.
        function doCheckAll()
        {
        //  alert('Inside dca');
            var elems = document.getElementById("headerCheck");
            var allElems = document.getElementsByTagName("input");
            var allChecked = true;
            for ( var ii=0; ii<allElems.length; ii++ )
            {
                if ( allElems[ii].checked && allElems[ii].id != "headerCheck")
                    {
                    
                    }
                else
                    {
                    if(allElems[ii].id != "headerCheck")
                    {
                    allChecked = false;
                    break;
                    }
                    }
                    
            }
            if (allChecked)
                {
                elems.checked = true;
                }
            else
                {
                elems.checked = false;
                }
            
        }
    </script>
</body>
</html>
<%
    UIUtil.logConfigurations(context, request, requestMap);
%>
