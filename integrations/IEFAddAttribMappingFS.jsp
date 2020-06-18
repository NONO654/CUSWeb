
<%--  IEFAddAttribMappingFS.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<html>
<head>
<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="java.util.*"%>
<%@ page import="java.lang.Integer"%>
<%@ page import="com.matrixone.MCADIntegration.server.beans.IEFAttrMapping" %>
<%@ page import="com.matrixone.MCADIntegration.utils.*" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>


<%
	String sError = "";
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								= integSessionData.getClonedContext(session);

	IEFAttrMappingBase objIEFAttrMappingBase = (IEFAttrMappingBase)session.getAttribute("IEFAttrMapping");
	
	String sEVOVIATYPE_BASIC 							= IEFAttrMapping.EVOVIATYPE_BASIC;
	String sEVOVIATYPE_ATTRIBUTE 						= IEFAttrMapping.EVOVIATYPE_ATTRIBUTE;
	String sEVOVIATYPE_EXPRESSION 						= IEFAttrMapping.EVOVIATYPE_EXPRESSION;
	int EVOVIATYPEBASIC_INDEX 							= IEFAttrMapping.EVOVIATYPE_BASIC_INDEX;
	int EVOVIATYPEATTRIBUTE_INDEX 						= IEFAttrMapping.EVOVIATYPE_ATTRIBUTE_INDEX;
	int EVOVIATYPEEXPRESSION_INDEX 						= IEFAttrMapping.EVOVIATYPE_EXPRESSION_INDEX;
	String sMAPPINGTYPE_ENOVIATOCAD 					= IEFAttrMapping.MAPPINGTYPE_ENOVIATOCAD;
	String sMAPPINGTYPE_CADTOENOVIA 					= IEFAttrMapping.MAPPINGTYPE_CADTOENOVIA;
	String sEVENT_TYPECHANGE 							= IEFAttrMapping.EVENT_TYPECHANGE;
	String sEVENT_ENOVIATYPEATTRIBUTECHANGE 			= IEFAttrMapping.EVENT_ENOVIATYPEATTRIBUTECHANGE;
	String sACTION_ADD 									= objIEFAttrMappingBase.ACTION_ADD;
	String sACTION_ERROR 								= objIEFAttrMappingBase.ACTION_ERROR;
	
	String sMappingType = objIEFAttrMappingBase.getsMappingType();
	String sillegalChar = integSessionData.getStringResource("mcadIntegration.Server.Message.IEF0341100330");
	String sBlankChar = integSessionData.getStringResource("mcadIntegration.Server.Message.IEF0341100336");

	String sIntegrationName	=objIEFAttrMappingBase.getsIntegrationName();
	String sDirPath = request.getRealPath("/integrations/scripts/");
	boolean exists = objIEFAttrMappingBase.isValidationFileExist(sDirPath);
	if (exists) {
  %>

 <script language="javascript">
    //XSSOK
    var sFile = './scripts/IEFAttrMapValidation<%=sIntegrationName%>.js'
    var html_doc = document.getElementsByTagName('head')[0];
    js = document.createElement('script');
    js.setAttribute('type', 'text/javascript');
    js.setAttribute('src', sFile);
    html_doc.appendChild(js);
</script>
 <%
 }
 %>
<script language="JavaScript">
function checkforRestrictedChar(evt)
  {
   var charCode = (evt.which) ? evt.which : evt.keyCode
   var keychar = String.fromCharCode(charCode)
   if(keychar == '|' | keychar == ',')
	{
                //XSSOK
		alert("<%=sillegalChar%>")
		return false;
	}
}
function refreshCADAttributeTxt()
    {
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		var cadAttrName = tableDisplayFrame.document.getElementById ( "txtCADAttrName" );
		cadAttrName.value="";
    }
function refreshENOVIAAttributeVal()
    {
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		var EnoviaAttrType = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrType" );
		var ENOVIAAttrName = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrName" );
		
		EnoviaAttrType.selectedIndex = 0;
		ENOVIAAttrName.selectedIndex = 0;
		ENOVIAAttrName.disabled = true;
    }

function changeTypeCombo(sMapType)
    {
		var typeName="";
		var typeId

		var tableDisplayFrame = findFrame(top,'tableDisplay');
		var sFormObj = tableDisplayFrame.document.forms['frmAddAttribute']
                //XSSOK
		if(sMapType == "<%=sMAPPINGTYPE_ENOVIATOCAD%>")
			typeId = tableDisplayFrame.document.getElementById ( "cmbENOVIAType" );
		//XSSOK
		else if(sMapType == "<%=sMAPPINGTYPE_CADTOENOVIA%>")
			typeId = tableDisplayFrame.document.getElementById ( "cmbCADType" );

		if(typeId.selectedIndex == 0)
		{
			var EnoviaAttrType = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrType" );
			var ENOVIAAttrName = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrName" );
			var cadAttrName = tableDisplayFrame.document.getElementById ( "txtCADAttrName" );
		
			EnoviaAttrType.disabled = true;
			cadAttrName.disabled = true;
			ENOVIAAttrName.disabled = true;
			//XSSOK
			alert("<%=sBlankChar%>")
		}
		else
		{
	 	        typeName = typeId.options[typeId.selectedIndex].value;
		}

		//XSSOK
		sFormObj.sAction.value = "<%=sEVENT_TYPECHANGE%>";

		//XSSOK
		if(sMapType == "<%=sMAPPINGTYPE_ENOVIATOCAD%>")
			sFormObj.ENOVIATypeVar.value =typeName;
		//XSSOK
		else if(sMapType == "<%=sMAPPINGTYPE_CADTOENOVIA%>")
			sFormObj.CADTypeVar.value =typeName;

		sFormObj.submit();
    }
 function changeENOVIAAttrTypeCombo()
    {
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		var sFormObj = tableDisplayFrame.document.forms['frmAddAttribute']

                var EnoviaAttrType = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrType" );
		var ENOVIAAttrName = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrName" );

		var cadAttrName = tableDisplayFrame.document.getElementById ( "txtCADAttrName" );

		var sAttriVar="";
		
	    if(EnoviaAttrType.selectedIndex == 0)
		{
			ENOVIAAttrName.disabled = true;
			//XSSOK
			alert("<%=sBlankChar%>")
			return false;
		}
		
		//XSSOK
		else if(EnoviaAttrType.selectedIndex == <%=EVOVIATYPEBASIC_INDEX%>)
		    //XSSOK
			sAttriVar="<%=sEVOVIATYPE_BASIC%>";
		//XSSOK
		else if(EnoviaAttrType.selectedIndex == <%=EVOVIATYPEATTRIBUTE_INDEX%>)
		    //XSSOK
			sAttriVar="<%=sEVOVIATYPE_ATTRIBUTE%>";
		//XSSOK
		else if(EnoviaAttrType.selectedIndex == <%=EVOVIATYPEEXPRESSION_INDEX%>)
			//XSSOK
			sAttriVar="<%=sEVOVIATYPE_EXPRESSION%>";

		var sENOVIA = tableDisplayFrame.document.getElementById ( "cmbENOVIAType" );

		var sENOVIAType = sENOVIA.options[sENOVIA.selectedIndex].value;

		var sCAD = tableDisplayFrame.document.getElementById ( "cmbCADType" );
		var sCADType = sCAD.options[sCAD.selectedIndex].value;

		sFormObj.CADAttrName.value = cadAttrName.value;
		sFormObj.attri.value = sENOVIAType;
		//XSSOK
		sFormObj.sAction.value = "<%=sEVENT_ENOVIATYPEATTRIBUTECHANGE%>";
		sFormObj.ENOVIATypeVar.value = sENOVIAType;
		sFormObj.CADTypeVar.value =sCADType;
		sFormObj.ENOVIAAttriType.value =sAttriVar;
        sFormObj.submit();
    }
	function changeENOVIAAttrValueCombo()
	{
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		var ENOVIAAttrName = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrName" );
		if(ENOVIAAttrName.selectedIndex == 0)
		{
                        //XSSOK
			alert("<%=sBlankChar%>")
			cadAttrName.disabled = true;
			return false;
		}
	}
    function doneMethod(sMapType)
    {
		var sENOVIA="";
		var sENOVIAType="";
		var sENOVIAAttrType="";
		var sENOVIAAttrTypeName="";
		var sENOVIAAttrName="";
		var sENOVIAAttrValue="";
        var sENOVIAAttrExpr="";
        var sCAD="";
		var sCADType="";
		var sCADAttr="";
		var sCADAttrName="";

        var tableDisplayFrame = findFrame(top,'tableDisplay');
		var sFormObj = tableDisplayFrame.document.forms['frmAddAttribute']

		sENOVIA = tableDisplayFrame.document.getElementById ( "cmbENOVIAType" );
		if(sENOVIA.selectedIndex != -1 )
			sENOVIAType = sENOVIA.options[sENOVIA.selectedIndex].value;

		sENOVIAAttrType = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrType" );
	
		var sENOVIAAttrTempValue ="";
		
		//XSSOK
		if(sENOVIAAttrType.selectedIndex == <%=EVOVIATYPEEXPRESSION_INDEX%>)
		{
		    //XSSOK
			sENOVIAAttrTypeName="<%=sEVOVIATYPE_EXPRESSION%>";
			var sENOVIAAttrExpr = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrName" ).value;
			
			if(sENOVIAAttrExpr == '')
				sENOVIAAttrValue = "";
			else
			        sENOVIAAttrValue = "expr(" + sENOVIAAttrExpr + ")";
		}
		else
		{
		    //XSSOK
			if(sENOVIAAttrType.selectedIndex == <%=EVOVIATYPEBASIC_INDEX%>)
			    //XSSOK
				sENOVIAAttrTypeName="<%=sEVOVIATYPE_BASIC%>";
			//XSSOK
			else if(sENOVIAAttrType.selectedIndex == <%=EVOVIATYPEATTRIBUTE_INDEX%>)
			    //XSSOK
				sENOVIAAttrTypeName="<%=sEVOVIATYPE_ATTRIBUTE%>";
				
		        sENOVIAAttrName = tableDisplayFrame.document.getElementById ( "cmbENOVIAAttrName" );
		        sENOVIAAttrTempValue = sENOVIAAttrName.options[sENOVIAAttrName.selectedIndex].text;
		}

		//XSSOK
		if(sENOVIAAttrType.selectedIndex == <%=EVOVIATYPEBASIC_INDEX%>)
		{
			sENOVIAAttrValue = '$$'+sENOVIAAttrTempValue+'$$';
		}
		//XSSOK
		else if(sENOVIAAttrType.selectedIndex == <%=EVOVIATYPEATTRIBUTE_INDEX%>)
		{
			sENOVIAAttrValue = sENOVIAAttrTempValue;
		}
		else if(sENOVIAAttrType.selectedIndex == 0)
		{
			sENOVIAAttrValue = "";
		}

		sCAD = tableDisplayFrame.document.getElementById ( "cmbCADType" );
		if(sCAD.selectedIndex != -1 )
			sCADType = sCAD.options[sCAD.selectedIndex].value;

		sCADAttr = tableDisplayFrame.document.getElementById ( "txtCADAttrName" );
		sCADAttrName = sCADAttr.value;

		if(sCADAttrName.indexOf("|") > -1 || sCADAttrName.indexOf(",") > -1)
		{
                        //XSSOK
			alert("<%=sillegalChar%>")
			return;
		}

		var sAttrValue="";

		//XSSOK
		if(sMapType == "<%=sMAPPINGTYPE_ENOVIATOCAD%>")
			sAttrValue = sENOVIAType +','+ sENOVIAAttrValue + '|' + sCADType +','+sCADAttrName;
		//XSSOK
		if(sMapType == "<%=sMAPPINGTYPE_CADTOENOVIA%>")
			sAttrValue = sCADType +','+ sCADAttrName + '|' + sENOVIAType +','+ sENOVIAAttrValue;

		//XSSOK
		if(sENOVIAAttrType.selectedIndex == <%=EVOVIATYPEBASIC_INDEX%> || sENOVIAAttrType.selectedIndex == <%=EVOVIATYPEATTRIBUTE_INDEX%>)
			sENOVIAAttrValue = sENOVIAAttrTempValue;
		else if(sENOVIAAttrType.selectedIndex == 0)
			sENOVIAAttrValue = "";

		sFormObj.attri.value = sAttrValue;
		sFormObj.ENOVIATypeVar.value = sENOVIAType;
		sFormObj.ENOVIAAttriType.value = sENOVIAAttrTypeName;
		
		//IR#377761
		//sFormObj.ENOVIAAttriNameValue.value = sENOVIAAttrValue;
		sFormObj.ENOVIAAttriNameValue.value=sENOVIAAttrExpr;
		
		sFormObj.CADTypeVar.value = sCADType;
		sFormObj.CADAttrName.value = sCADAttrName;

		if(sENOVIAType=="" || sCADType=="" || sCADAttrName == "" || sENOVIAAttrValue == "" || sENOVIAAttrTypeName=="")
		{
		    //XSSOK
			sFormObj.sAction.value = "<%=sACTION_ERROR%>";
			sFormObj.sError.value = "IEF0341100336";
			sFormObj.submit();
			return;
		}


		var bReturnVal ;
		//XSSOK
		if(<%=exists%>)
		{
		    //XSSOK
			bReturnVal = validateCADAttrData(sCADType,sCADAttrName,sENOVIAType,sENOVIAAttrValue,"<%=sMappingType%>");
			var bValiation = bReturnVal.substring(0,bReturnVal.lastIndexOf('|'));

			if(bValiation == 'true')
			{
			    //XSSOK
				sFormObj.sAction.value = "<%=sACTION_ADD%>";
				sFormObj.submit();
			}
			else
			{
				var errorcode = bReturnVal.substring(bReturnVal.lastIndexOf('|') + 1,bReturnVal.length);
				//XSSOK
				sFormObj.sAction.value = "<%=sACTION_ERROR%>";
				sFormObj.sError.value = errorcode;
				sFormObj.submit();
			}
		}
		else
		{
		    //XSSOK
			sFormObj.sAction.value = "<%=sACTION_ADD%>";
			sFormObj.submit();
		}
	}

</script>
<%

	String gcoName = objIEFAttrMappingBase.getsGCOName();
	String sAction = request.getParameter("sAction");

	if(sAction!=null){
		ENOCsrfGuard.validateRequest(context, session, request, response);
	}
	String sAttri = request.getParameter("attri");

	String sENOVIATypeVar = Request.getParameter(request,"ENOVIATypeVar");
	String sENOVIAAttriType = Request.getParameter(request,"ENOVIAAttriType");
	String sCADTypeVar = Request.getParameter(request,"CADTypeVar");
	String sCADAttrName	=Request.getParameter(request,"CADAttrName");
	String sENOVIAAttriNameValue	=Request.getParameter(request,"ENOVIAAttriNameValue");

	if(sAction == null) 					sAction = "";
	if(sAttri == null) 						sAttri = "";
	if(sENOVIATypeVar == null) 				sENOVIATypeVar = "";
	if(sENOVIAAttriType == null) 			sENOVIAAttriType = "";
	if(sCADTypeVar == null) 				sCADTypeVar = "";
	if(sCADAttrName == null) 				sCADAttrName = "";
	if(sENOVIAAttriNameValue == null) 		sENOVIAAttriNameValue = "";

	String sErrorCode = Request.getParameter(request,"sError");
	boolean bReturn = objIEFAttrMappingBase.executeAction(null,sAction,sAttri,sErrorCode);

	if(bReturn && sACTION_ADD.equals(sAction))
	{
	%>
		<script>
		//XSSOK
		window.parent.opener.top.location.href = "IEFAttribMappingFS.jsp?gcoName=<%=gcoName%>&MappingType=<%=sMappingType%>&firstTime=false";
		window.close();
		</script>
	<%
	}

	if("".equals(sError))
		sError = objIEFAttrMappingBase.getsErrorMessage();

	sError    					= MCADUrlUtil.hexEncode(sError);
	sAction    					= MCADUrlUtil.hexEncode(sAction);
	sAttri  					= MCADUrlUtil.hexEncode(sAttri);
	sENOVIATypeVar    			= MCADUrlUtil.hexEncode(sENOVIATypeVar);
	sENOVIAAttriType  			= MCADUrlUtil.hexEncode(sENOVIAAttriType);
	sCADTypeVar    				= MCADUrlUtil.hexEncode(sCADTypeVar);
	sCADAttrName  				= MCADUrlUtil.hexEncode(sCADAttrName);
	sENOVIAAttriNameValue  		= MCADUrlUtil.hexEncode(sENOVIAAttriNameValue);
	
	%>
</head>

<frameset rows="50,*,60" frameborder="no" framespacing="2">
    <!--XSSOK-->
	<frame name="headerDisplay" src="IEFAddAttribMappingHeader.jsp?MappingType=<%=sMappingType%>"   marginwidth="0" marginheight="0" scrolling="no"/>
	 <%
	 if(sMAPPINGTYPE_ENOVIATOCAD.equals(sMappingType))
	 {
	 %>
	        <!--XSSOK-->
		<frame name="tableDisplay" src="IEFAddAttribMxToCADContent.jsp?sAction=<%=sAction%>&attri=<%=sAttri%>&ENOVIATypeVar=<%=sENOVIATypeVar%>&ENOVIAAttriType=<%=sENOVIAAttriType%>&CADTypeVar=<%=sCADTypeVar%>&CADAttrName=<%=sCADAttrName%>&ENOVIAAttriNameValue=<%=sENOVIAAttriNameValue%>"   marginwidth="4" marginheight="1"/>
	<%
	 }
	%>
	<%
	 if(sMAPPINGTYPE_CADTOENOVIA.equals(sMappingType))
	 {
	 %>
	        <!--XSSOK-->
		<frame name="tableDisplay" src="IEFAddAttribCADToMxContent.jsp?sAction=<%=sAction%>&attri=<%=sAttri%>&ENOVIATypeVar=<%=sENOVIATypeVar%>&ENOVIAAttriType=<%=sENOVIAAttriType%>&CADTypeVar=<%=sCADTypeVar%>&CADAttrName=<%=sCADAttrName%>&ENOVIAAttriNameValue=<%=sENOVIAAttriNameValue%>"   marginwidth="4" marginheight="1"/>
	<%
	 }
	%>
	<!--XSSOK-->
	<frame name="bottomDisplay" src="IEFAddAttribMappingFooter.jsp?errorMessage=<%=sError%>" marginwidth="0" marginheight="0" noresize="noresize" scrolling="no"/>
</frameset>
</html>

