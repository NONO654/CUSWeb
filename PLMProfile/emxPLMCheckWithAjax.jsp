<%--  emxCreateBusinessRuleDisplay.jsp - Creation Business Rule
--%>
<%@ include file = "../emxUICommonAppInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@ page import = "com.matrixone.apps.domain.util.PropertyUtil"%>
<%@ page import = "java.util.Map"%>
<%@ page import = "java.util.List"%>
<%@ page import = "java.util.Iterator"%>
<%@ page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import = "java.net.URLEncoder" %>
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
System.out.println("Begin emxPLMCheckWithAjax.jsp");
String form = emxGetParameter(request,"form");
String objectId = emxGetParameter(request,"objectId");
String languageStr      = request.getHeader("Accept-Language");
String requiredName = EnoviaResourceBundle.getProperty(context, "emxComponents.Common.NameError", "emxComponentsStringResource", languageStr);
String requiredType = EnoviaResourceBundle.getProperty(context, "emxComponents.Common.TypeError", "emxComponentsStringResource", languageStr);
String requiredParent = EnoviaResourceBundle.getProperty(context, "emxComponents.Common.RequiredText", "emxComponentsStringResource", languageStr);
String onCreate = emxGetParameter(request,"onCreate");
String parentId = emxGetParameter(request,"parentId");
System.out.println("form "+form);
System.out.println("onCreate "+onCreate);
System.out.println("objectId "+objectId);
System.out.println("parentId "+parentId);
String parentName = "";
if(parentId != null && parentId.length() != 0) {
	DomainObject object = DomainObject.newInstance(context, parentId);
	parentName = object.getInfo(context, DomainConstants.SELECT_NAME);
}
System.out.println("End emxPLMCheckWithAjax.jsp");
%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
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
			getTopWindow().refreshTablePage();
			var createObject = xmlhttp.responseXML.getElementsByTagName("createObject");
			if (createObject != null && createObject.length > 0) {
				var url = "";
				$.each(createObject, function(i, v){
					url = "emxPLMCheckForm.jsp?mode=edit&formId=PLMCheckModifyWebForm&targetLocation=popup&PopupSize=Medium&objectId="+$(this).attr('id');
				});
				<%if(onCreate.equals("edit")){%>
				showModalDialog(url);
				<%}%>
				close(true);
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
			xmlhttp.open("GET","emxPLMCheckDialog.jsp?command=create&name="+encodeURIComponent(name)
					+"&typeModel="+encodeURIComponent(typeModel)+"&parentId=<%=parentId%>",true);
		} else {
			xmlhttp.open("GET","emxPLMCheckDialog.jsp?command=create&name="+encodeURIComponent(name)
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
		getTopWindow().closeSlideInDialog();
	} else {
		getTopWindow().close();
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
		if(xmlhttp.readyState==4 && xmlhttp.status==200) {
			parent.document.getElementById("imgProgressDiv").style.visibility = "hidden";
			clearErrors();
			manageError(doCreate, force, xmlhttp);
		}
	}
	var thisVar=getRuleArgumentList();
	var body=getRuleBody();
	xmlhttp.open("GET","emxPLMCheckDialog.jsp?command=edit"
				+"&body="+encodeURIComponent("#"+body+"#")+"&thisvar="+encodeURIComponent(thisVar)
				+"&objectId=<%=objectId%>&doSave="+force,true);
	xmlhttp.send(null);
}
function manageError(close, force, xmlhttp) {
	var parseErrors = xmlhttp.responseXML.getElementsByTagName("parseError");
	if (parseErrors != null && parseErrors.length > 0 && force != 2) {
		$.each(parseErrors, function(i, v) {
			var attrInfo = $(this).attr('i');
			if(attrInfo == "parse") {
				addErrorElement($(this).attr('l')-1, $(this).text());
			} else if(attrInfo == "exception") {
					alert("Error :"+$(this).text());
			}
		});
		if(close) {
			if (confirm('Contain error(s). Force save ?')) {
				check(close, 2);
			}
		}
	} else if (close) {
		if(force == 2){
			alert("Saved with error(s).");
		} else {
			alert("Saved.");
		}
		getTopWindow().close();
	} else if(!close){
		alert("No error !");
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
