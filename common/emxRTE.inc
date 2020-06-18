 <%--  emxRTE.inc-  For enbling the Rich Text Editor and SpellChecker.
 Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
 --%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<script type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript">
if(typeof emxUICore != "object"){
	 document.write("<scri" + "pt language=\"JavaScript\" type=\"text/javascript\" src=\"../common/scripts/emxUICore.js\"></scr" + "ipt>");
}

</script>

<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIRTE.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIRTEToolbar.js"></script>

<script type="text/javascript">
jQuery(document).ready(function($) {
	if($('.rte').length){
		var arr = $('.rte').rte({
			css: ['../common/styles/emxUIDefault.css'],
			controls_rte: rte_toolbar,
			controls_html: html_toolbar
		});
	}
});
</script>

<%
String spellCheckerURL = EnoviaResourceBundle.getProperty(context,"emxFramework.spellchecker.URL");
if(spellCheckerURL.length()>0){
%>
<script type="text/javascript" src="<%=spellCheckerURL%>"></script>
<script type="text/javascript">
if(emxUICore.isValidPageURL("<%=spellCheckerURL%>")){
		function startSpellCheck(event){
			var spellCheckElem = $("textarea", event.parentNode).get(0)?$("textarea", event.parentNode).get(0):$("iframe", event.parentNode.parentNode).get(0);
			if(spellCheckElem.id == "" ||  spellCheckElem.id == null){
				spellCheckElem.id = spellCheckElem.name != "" ? spellCheckElem.name : spellCheckElem.title;
			}

			doSpell({
			ctrl: spellCheckElem.id,
			//XSSOK
			lang:'<%=UIUtil.getLanguageForSpellChecker(request)%>',
			onFinish:onFinish,
			onCancel:onFinish,
			onClose:onFinish
			});
		}
		
		onFinish = function(mSender){
			if(mSender.className == "rte"){
				mSender.contentWindow.focus();
			}else{
				mSender.focus();
			}
		}
		
		function addSpellCheckElem(id){
			var element = $('<input type="button" value=\"'+emxUIConstants.SPELL_CHECK+'\" name="SpellCheck" title=\"'+emxUIConstants.SPELL_CHECK+'\"/>');
			if(id){
				$('#'+id+'Id').after(element);
			}else{
			$("textarea:not('.rte')").after(element);
			$("div.rte-resizer").append(element);
			}				
			$(':button[name=SpellCheck]').bind('click',function(){
				startSpellCheck(this);
			});
		}
		$(document).ready(function() {
			addSpellCheckElem();
		});
	}
</script>
<%
}
%>
