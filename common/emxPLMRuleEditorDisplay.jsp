<%--  emxPLMRuleEditorDisplay.jsp
--%>
<%@ include file = "../emxUICommonAppInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@ page import = "com.matrixone.apps.domain.util.PropertyUtil"%>
<%@ page import = "java.util.Map"%>
<%@ page import = "java.util.List"%>
<%@ page import = "java.util.Iterator"%>
<%@ page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >   
<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<style>
.linedwrap {
	border: 1px solid #c0c0c0;
}
.linedwrap .lines {
	float: left;
	overflow: hidden;
	border-right: 1px solid #c0c0c0;
	margin-right: 5px;
}
.linedwrap .codelines {
	padding-top: 6px;
}
.linedwrap .codelines .lineno {
	color:#AAAAAA;
	padding-right: 0.5em;
	padding-top: 0.0em;
	text-align: right;
	white-space: nowrap;
}
.linedwrap .codelines .lineselect {
	color: red;
	background-color: PeachPuff;
	font-weight: bold;
}
.linedtextarea {
	padding: 0px;
	margin: 0px;
}
.linedtextarea textarea, .linedwrap .codelines .lineno {
	font-size: 10pt;
	font-family: monospace;
	line-height: normal !important;
}
.linedtextarea textarea {
	padding-right:0.3em;
	padding-top:0.3em;
	border: 0;
}
</style> 
<%
System.out.println("Begin emxPLMRuleEditorDisplay.jsp");
String form = emxGetParameter(request,"form");
String objectId = emxGetParameter(request,"objectId");
String languageStr      = request.getHeader("Accept-Language");
String requiredName = UINavigatorUtil.getI18nString("emxComponents.Common.NameError", "emxComponentsStringResource", languageStr);
String requiredType = UINavigatorUtil.getI18nString("emxComponents.Common.TypeError", "emxComponentsStringResource", languageStr);
String requiredParent = UINavigatorUtil.getI18nString("emxComponents.Common.RequiredText", "emxComponentsStringResource", languageStr);
String onCreate = emxGetParameter(request,"onCreate");
String parentId = emxGetParameter(request,"parentId");
String typeEdit = emxGetParameter(request,"typeEdit");
System.out.println("form "+form);
System.out.println("onCreate "+onCreate);
System.out.println("objectId "+objectId);
System.out.println("parentId "+parentId);
System.out.println("typeEdit "+typeEdit);
String parentName = "";
String UUIDSup = "5fe29379-cfe0-41eb-a503-a03b84ba831f";
String UUIDMin = "cf9d40c6-ca8a-4864-ae4e-eb840230be50";
String UUIDDiv = "9f168c73-05ed-4b78-8c6e-17d8b0e66c82";
if(parentId != null && parentId.length() != 0) {
	DomainObject object = DomainObject.newInstance(context, parentId);
	parentName = object.getInfo(context, DomainConstants.SELECT_NAME);
}
System.out.println("End emxPLMRuleEditorDisplay.jsp");
%>
<script type="text/javascript">
function createEntity() {
	parent.document.getElementById("imgProgressDiv").style.visibility = "visible";
	var xmlhttp;
    if (window.XMLHttpRequest) { 
		xmlhttp=new XMLHttpRequest();
    } else if (window.ActiveXObject) {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
    } else {
		alert("Your browser does not support XMLHTTP!");
    }
    xmlhttp.onreadystatechange=function() {
		if(xmlhttp.readyState==4 && xmlhttp.status==200){
			parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
			top.refreshTablePage();
			var createObject = xmlhttp.responseXML.getElementsByTagName("createObject");
			if (createObject != null && createObject.length > 0) {
				<%if(onCreate != null && onCreate.equals("edit")){%>
				var url = "";
				$.each(createObject, function(i, v){
					url = "emxPLMRuleEditorEditForm.jsp?targetLocation=popup&PopupSize=Medium&objectId="+$(this).attr('id');
				});
				showModalDialog(url);
				<%}%>
				top.closeSlideInDialog();
			} else {
				manageError(false, 0, xmlhttp);
			}
		}
	}
	var name=getEntityName();
	var typeModel=$('input[name=TypeChooserDisplay]').val();
	var parentId=$('input[name=Father]').val();
	var checked = $('input[name=RootRuleSet]').is(':checked');
	if(name.length != 0 && typeModel.length !=0 && (parentId.length !=0 && !checked || parentId.length==0 && checked) ) {
		if(parentId == "<%=parentId%>") {
			xmlhttp.open("GET","emxPLMRuleEditorDialog.jsp?command=create&name="+encodeURIComponent(name)
					+"&typeModel="+encodeURIComponent(typeModel)+"&parentId=<%=parentId%>",true);
		} else {
			xmlhttp.open("GET","emxPLMRuleEditorDialog.jsp?command=create&name="+encodeURIComponent(name)
					+"&typeModel="+encodeURIComponent(typeModel)+"&parentId="+parentId,true);
		}
	} else if(name.length == 0) {
		alert("<%=requiredName%>");
	} else if(typeModel.length == 0) {
		alert("<%=requiredType%>");
	} else if(parentId.length == 0){
		alert("<%=requiredParent%>");
	}
	xmlhttp.send(null);
}
function mainInitForm() {
	$('input[name=FatherDisplay]').val("<%=parentName%>");
	$('input[name=Father]').val("<%=parentId%>");
	$('input[name=RootRuleSet]').attr('checked', false);
	$(".form #calc_RootRuleSet td.inputField:first").remove();
	<%
	String ArgumentListLabel = emxGetParameter(request,"ArgumentListLabel");
	if(ArgumentListLabel != null) {
	%>
		$('label[for="ArgumentList"]').text("<%=ArgumentListLabel%>");
	<%}
	String BodyLabel = emxGetParameter(request,"BodyLabel");
	if(BodyLabel != null) {
	%>
		$('label[for="Body"]').text("<%=BodyLabel%>");
	<%}%>
	$('input[name=RootRuleSet]').click(function() {
		if($(this).is(':checked')) {
			$('input[name=FatherDisplay]').val('');
			$('input[name=FatherDisplay]').attr('disabled', 'disabled');
			$('input[name=Father]').val('');
			$('input[name=Father]').attr('disabled', 'disabled');
			$('input[name=btnFather]').attr('disabled', 'disabled');
		} else {
			$('input[name=FatherDisplay]').val("<%=parentName%>");
			$('input[name=Father]').val("<%=parentId%>");
			$('input[name=FatherDisplay]').removeAttr("disabled");
			$('input[name=Father]').removeAttr("disabled");
			$('input[name=btnFather]').removeAttr("disabled");
		}
	});
}
function close(slidein) {
	if(slidein == true) {
		top.closeSlideInDialog();
	} else {
		top.close();
	}
}
function check(doCreate, force){
	parent.document.getElementById("imgProgressDiv").style.visibility = "visible";
	var xmlhttp;
    if (window.XMLHttpRequest) { 
		xmlhttp=new XMLHttpRequest();
    } else if (window.ActiveXObject) {
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	} else {
		alert("Your browser does not support XMLHTTP!");
    }
    xmlhttp.onreadystatechange=function() {
		if(xmlhttp.readyState==4) {
			if(xmlhttp.status==200) {
				parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
				clearErrors();
	// 			alert('manage do create : ' + doCreate + ',force : ' + force);
				manageError(doCreate, force, xmlhttp);
			}
			else {
				parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
				console.log("Status de la réponse: %d (%s)", xmlhttp.status, xmlhttp.statusText);
	 			var error="<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Login.Error")%>";
				alert(error +" "+ xmlhttp.status +" "+ xmlhttp.statusText);
			}
		}
	}
	//IR-595018 S63 We add a flag to retrieve our informations though the request : boundary
    var boundary="--MyBRBoundary--";
	var thisVar=getRuleArgumentList();
	var body=getRuleBody();
	var hasPrec=getRulePriority();
	var name=getRuleName();
	var sup = new RegExp(">", 'g');
	var min = new RegExp("<", 'g');
	var div = new RegExp("/", 'g');
	body = body.replace(sup,"<%=UUIDSup%>");
	body = body.replace(min,"<%=UUIDMin%>");
	body = body.replace(div,"<%=UUIDDiv%>");
	body = encodeURIComponent("#"+body+"#");
	thisVar = encodeURIComponent(thisVar);
	name = encodeURIComponent(name);
	hasPrec = encodeURIComponent(hasPrec);
	var data = new FormData();
	data.append(boundary+"command", boundary+"edit");
	data.append(boundary+"body", boundary+body);
	data.append(boundary+"thisvar", boundary+thisVar);
	data.append(boundary+"hasprecedence", boundary+hasPrec);
	data.append(boundary+"name", boundary+name);
	data.append(boundary+"objectId",boundary+"<%=objectId%>");
	data.append(boundary+"doSave",boundary+force);
	data.append(boundary+"typeEdit",boundary+"<%=typeEdit%>");
// 	for (var key of data.entries()) {
//         console.log(key[0] + ', ' + key[1]);
//     }
<%-- 	var params = "command=edit&body="+body+"&thisvar="+thisVar+"&name="+name+"&objectId=<%=objectId%>&doSave="+force+"&typeEdit=<%=typeEdit%>"; --%>
	//IR-595018 S63 We change the method from GET to POST to send big data (body)
	xmlhttp.open("POST","emxPLMRuleEditorDialog.jsp",true);
	xmlhttp.setRequestHeader("Content-Type", "multipart/form-data; charset=utf-8");
	xmlhttp.send(data);
}
function manageError(close, force, xmlhttp) {
	var parseErrors = xmlhttp.responseXML.getElementsByTagName("parseError");
	if (parseErrors != null && parseErrors.length > 0 && force != 2) {
		$.each(parseErrors, function(i, v) {
			var attrInfo = $(this).attr('i');
			if(attrInfo == "parse") {
				addErrorElement($(this).attr('l')-1, $(this).text());
			} else if(attrInfo == "exception") {
				var error="<%=EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Login.Error")%>";
				alert(error+$(this).text());
// 				alert("Error :"+$(this).text());
			}
		});
		if(close) {
			var errMsg1="<%=EnoviaResourceBundle.getProperty(context, "emxDataSpecializationStringResource", context.getLocale(), "emxDataSpecialization.ErrMsg.AcceptParseError")%>";
			if (confirm(errMsg1)) {
				check(close, 2);
			}
// 			if (confirm('Contain error(s). Force save ?')) {
// 				check(close, 2);
// 			}
		}
	} else if (close) {
		if(force == 2){
			var errMsg2="<%=EnoviaResourceBundle.getProperty(context, "emxDataSpecializationStringResource", context.getLocale(), "emxDataSpecialization.ErrMsg.SaveParseError")%>";
			alert(errMsg2);
// 			alert("Saved with error(s).");
		}
			if (getTopWindow().opener) 
			{
				sbWindow = getTopWindow().opener.findFrame(getTopWindow().opener.getTopWindow(),"content");
	    	} 
			else 
	    	{
	    		sbWindow = findFrame(getTopWindow(),"content");
	    	}
			if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort)
			{
			   sbWindow.emxEditableTable.refreshStructureWithOutSort();
			   sbWindow.refreshRows();
			   sbWindow.expandAll();
			   sbWindow.location.href = sbWindow.location.href ;
			}
		getTopWindow().close();
	} else if(!close){
		var errMsg3="<%=EnoviaResourceBundle.getProperty(context, "emxDataSpecializationStringResource", context.getLocale(), "emxDataSpecialization.msg.NoError")%>";
		alert(errMsg3);
// 		alert("No error !");
	}
}
$('document').ready(mainInitForm);
</script>
</head>
<body onload="pageInit()">
	<form name="CreatePLMKnowledgeEntity" action="<rg:writePreProcessPageSubmitAction/>" method="post" style="margin:0px;padding:0px;">
		<div id="searchPage">
			<jsp:include page = "../common/emxFormEditDisplay.jsp" flush="true">
  				<jsp:param name="form" value="<%=form%>"/>
  			</jsp:include>
  		</div>
	</form>
 </body>
 
