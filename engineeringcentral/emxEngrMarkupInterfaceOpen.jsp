<%--  emxEngrMarkupInterfaceOpen.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@ page import="java.util.*"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.partmanagement.modeler.interfaces.parameterization.*"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<%

String commandType=emxGetParameter(request,"commandType");

StringList OpenedMarkupIds=(StringList)session.getAttribute("OpenedMarkupIds");


Hashtable htConflictBOMs = (Hashtable)session.getAttribute("ConflictList");

String timeStamp = emxGetParameter(request, "timeStamp");

HashMap requestMap = indentedTableBean.getRequestMap(timeStamp);


String strMarkupIds = (String) requestMap.get("markupIds");
String strPartId = (String) requestMap.get("objectId");
String strChangeObjectId=(String)requestMap.get("sChangeOID");

StringList strlMarkupIds = FrameworkUtil.split(strMarkupIds, ",");

IParameterization iParameterization = new com.dassault_systemes.enovia.partmanagement.modeler.impl.parameterization.Parameterization();
boolean isInstaceMode = iParameterization.isUnConfiguredBOMMode_Instance(context);
String strInstanceModeErrorMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
		context.getLocale(),"emxEngineeringCentral.InstanceMode.NoModifyAccessOnLegacyComponents"); 

String rangeEAeach = EnoviaResourceBundle.getProperty(context,"emxFrameworkStringResource", new Locale("en"), "emxFramework.Range.Unit_of_Measure.EA_(each)");

boolean hasAccess = true;
for(int i=0; i < strlMarkupIds.size(); i++) {
	String sMarkupId = (String)strlMarkupIds.get(i);
	DomainObject domMarkup = new DomainObject(sMarkupId);
	String sHasMarkupCheckinAcc = domMarkup.getInfo(context,"current.access[checkin]");
	String sMarkupName = domMarkup.getInfo(context,"name");    
    if (UIUtil.isNotNullAndNotEmpty(sHasMarkupCheckinAcc) && "FALSE".equals(sHasMarkupCheckinAcc)) {                     
        %>
        <script language="JavaScript" type="text/javascript">        
        //XSSOK
        alert("<%=EnoviaResourceBundle.getProperty(Framework.getContext(session), "emxEngineeringCentralStringResource", Framework.getContext(session).getLocale(),"emxEngineeringCentral.EBOM.MarkupSaveCheckinAccess")%>");
        </script>
        <%
        hasAccess = false;
        break;
    }
}

// Added for V6R2009.HF0.2 - Starts
String accLanguage  = request.getHeader("Accept-Language");
// Added for V6R2009.HF0.2 - Ends

String contentURL = "";

StringTokenizer st=null;
String chkbo=emxGetParameter(request,"emxTableRowId");


boolean sflag=false;

String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");


int intLength = 0;
int intMinLength = 0;

String sRelId="";
String sObjId="";
 if(checkBoxId != null )
    {
        try
        {

            for(int i=0;i<checkBoxId.length;i++)
            {

                if(checkBoxId[i].indexOf("|") != -1)
                {
                    st = new StringTokenizer(checkBoxId[i], "|");

					int intNumTokens = st.countTokens();


					if (intNumTokens > 2)
					{
						sRelId = st.nextToken();
					}
                    String sTempObjId = st.nextToken();
					String sParentId = null;
					if (intNumTokens > 2)
					{
					sParentId = st.nextToken();
					}
					String sLevelId = st.nextToken();



					StringTokenizer strLevel = new StringTokenizer(sLevelId, ",");

					int intDepth = 0;
					if (sLevelId.indexOf(",") != -1)
					{
						intDepth = strLevel.countTokens();
					}


					if (i == 0)
					{
						intMinLength = intDepth;
					}


					if(intDepth <= intMinLength)
					{

						sObjId=	sTempObjId;
						intMinLength = intDepth;

					}

               }
                else
                {
                    sObjId = checkBoxId[i];

                }


            }
        }
        catch (Exception e)
        {
            session.setAttribute("error.message", e.getMessage());
        }

    }

if (sObjId == null || sObjId.length() == 0)
{
	sObjId = strPartId;
}


		DomainObject sdomobj=new DomainObject();
		sdomobj.setId(sObjId);

		if(hasAccess) {
			if("Save".equalsIgnoreCase(commandType))
			{
				contentURL="../engineeringcentral/emxEngrMarkupPreInterface.jsp?form=ENCOpenSaveMarkupChangeProcess&formHeader=emxEngineeringCentral.Markup.Create&suiteKey=EngineeringCentral&mode=edit&commandType=Save&sSelPart=ECPart&sChangeObjId="+strChangeObjectId+"&sObjId="+sObjId+"&strMarkupIds="+strMarkupIds+"&postProcessURL=../engineeringcentral/emxEngrMarkupSavePostProcess.jsp&Action=SaveOpen";
	
				sflag=true;
			}
	
			else
			{
				contentURL="../engineeringcentral/emxEngrMarkupPreInterface.jsp?form=ENCOpenSaveMarkupChangeProcess&formHeader=emxEngineeringCentral.Markup.Create&suiteKey=EngineeringCentral&mode=edit&commandType=SaveAs&sSelPart=ECPart&sChangeObjId="+strChangeObjectId+"&sObjId="+sObjId+"&strMarkupIds="+strMarkupIds+"&postProcessURL=../engineeringcentral/emxEngrMarkupSavePostProcess.jsp&Action=SaveAsOpen";
	
				sflag=true;
	
			}
		}

%>

<%
if(sflag)
{%>
 <html>
	<head>
	</head>
	<body>
		<form name="form" method="post">
			<input type="hidden" name="markupXML" value = "" />
			<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
			<script language="javascript" src="../common/scripts/emxUICore.js"></script>
			<script language="JavaScript" type="text/javascript">
		        var contentFrame   = findFrame(getTopWindow(),"listHidden");
				var warningMessage = "";
      			
      			var isInstaceMode = "<%=isInstaceMode%>";
      			if(isInstaceMode && isInstaceMode=="true"){
      				var xPath     =  "/mxRoot/rows//r[@status = 'changed']";	
      				contentFrame = (contentFrame != null && contentFrame != undefined)? contentFrame : findFrame(getTopWindow().getWindowOpener(),"listHidden");
      				var modifiedRow = emxUICore.selectNodes(contentFrame.parent.oXML, xPath);
      				if(modifiedRow == null || modifiedRow.length==0){
      					modifiedRow = emxUICore.selectSingleNode(contentFrame.parent.oXML, "/mxRoot/rows//r[@id='0']");
      				}
      				for(var i=0;i<modifiedRow.length;i++){
       					var newQty = contentFrame.parent.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"Quantity").value.current.actual;
       					var newUOM = contentFrame.parent.emxEditableTable.getCellValueByRowId(modifiedRow[i].getAttribute("id"),"UOM").value.current.actual;
       					//XSSOK
       					if(!("1.0" == newQty) && (newUOM == "<%=rangeEAeach%>")){
       						//XSSOK
       						warningMessage = "<%=strInstanceModeErrorMessage%>";
       					}
      				}
      			}
      			if(warningMessage != ""){
      				alert(warningMessage);
      			}else{
        		var validateSuccess = true;
        		try {
            		validateSuccess = contentFrame.parent.validateAddedRowsOnApply();
            		if(validateSuccess){
                		validateSuccess = contentFrame.parent.validateOnApply();
            		}
        		} catch(e) {
        			
        			<%--Multitenant--%>
        			<%--validateSuccess = confirm("<%=i18nNow.getI18nString("emxEngineeringCentral.CommonView.ValidationFailed_1","emxEngineeringCentralStringResource",accLanguage)%>");--%>
        			//XSSOK
        			validateSuccess = confirm("<%=EnoviaResourceBundle.getProperty(Framework.getContext(session), "emxEngineeringCentralStringResource", Framework.getContext(session).getLocale(),"emxEngineeringCentral.CommonView.ValidationFailed_1")%>");
        		}
        		
        		try {
            		if(validateSuccess) {
            			var reference     = findFrame(getTopWindow(), "portalDisplay") == null ? findFrame(getTopWindow(), "content") : findFrame(getTopWindow(), "portalDisplay").frames[0];
            			if(reference == null) {
            				reference = getTopWindow();
            			}
				var callback      = eval(reference.emxEditableTable.prototype.getMarkUpXML);
				var oxmlstatus        = callback();
				var oXMLCallBack  = reference.oXML;
				var dupemxUICore  = reference.emxUICore;
				var inputXML = oxmlstatus.xml;
				document.form.markupXML.value = inputXML;
        		//XSSOK		
				document.form.action='<%=XSSUtil.encodeForJavaScript(context,contentURL)%>';
				document.form.submit();
            		}
        		} catch(e) {
        			
        			<%--Multitenant--%>
        			<%--alert("<%=i18nNow.getI18nString("emxEngineeringCentral.Markup.Error_1","emxEngineeringCentralStringResource",accLanguage)%>"+e.message);--%>
        			//XSSOK
        			alert("<%=EnoviaResourceBundle.getProperty(Framework.getContext(session), "emxEngineeringCentralStringResource", Framework.getContext(session).getLocale(),"emxEngineeringCentral.Markup.Error_1")%>");
        		}
      			}
      			
			</script>

		</form>
	</body>
</html>

<%
}
%>

