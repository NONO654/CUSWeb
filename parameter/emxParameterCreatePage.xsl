<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:aef="http://www.matrixone.com/aef">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:variable name="mode" select="//aef:requestMap/aef:setting[@name='mode']" />
	<xsl:variable name="targetLocation" select="//aef:requestMap/aef:setting[@name='targetLocation']" />
	<xsl:variable name="slideinType" select="//aef:requestMap/aef:setting[@name='slideinType']" />
	
	<xsl:variable name="showApply" select="//aef:requestMap/aef:setting[@name='showApply']" />
	<xsl:variable name="spellCheckerURL" select="//aef:requestMap/aef:setting[@name='spellCheckerURL']" />
	<xsl:variable name="spellCheckerLang" select="//aef:requestMap/aef:setting[@name='spellCheckerLang']" />
	<xsl:include href="../common/emxCreateHeader.xsl"/>
	<xsl:include href="../common/emxCreateBody.xsl"/>
	<xsl:include href="../parameter/emxParameterCreateFooter.xsl"/>
	<xsl:variable name="urlParameters">uiType=form&amp;printerFriendly=false&amp;export=false&amp;timeStamp=<xsl:value-of select="//aef:setting[@name='timeStamp']"/>&amp;<xsl:for-each select="//aef:requestMap/aef:setting[not(@name='timeStamp')]">
			<xsl:value-of select="@name"/>=<xsl:value-of select="text()"/>
			<xsl:if test="position()!=last()">&amp;</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="slideinui">
		<xsl:choose>
	        <xsl:when test="$targetLocation = 'slidein'">
	           	<xsl:choose>
	           	<xsl:when test="$slideinType = 'wider'">false</xsl:when>
	           	<xsl:otherwise>true</xsl:otherwise>
	           	</xsl:choose>
	        </xsl:when>
	        <xsl:otherwise>false</xsl:otherwise>
	    </xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="isUnix" select="/mxRoot/setting[@name='isUnix']"/>	
	<xsl:variable name="isMobile" select="/mxRoot/setting[@name='isMobile']"/>
	<xsl:variable name="isPCTouch" select="/mxRoot/setting[@name='isPCTouch']"/>
	<xsl:template match="aef:mxRoot">
		<xsl:variable name="ext">
			<xsl:choose>
				<xsl:when test="$isUnix = 'true'">_Unix</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>	
		<html>
			<head>
				<title>
					<xsl:value-of select="aef:setting[@name='header']"/>
				</title>
				<!--
					IR-182849V6R2013x ZAPSECURITY + XSS: Most of the URL Parameters passed to emxCreate.jsp are found to be affected and hence they are encoded using encodeURIComponent to address the issue
				-->
				<script type="text/javascript">
					var timeStamp = "<xsl:value-of select="aef:setting[@name='timeStamp']"/>";
					var urlParameters = encodeURIComponent('"<xsl:value-of select="$urlParameters"/>"');
				</script>				
				
				<script type="text/javascript">
					<xsl:value-of disable-output-escaping="yes" select="formConstants"/>
				</script>				
				<script type="text/javascript">
					<xsl:value-of disable-output-escaping="yes" select="JSValidations"/>
				</script>				
		        <script src="../webapps/AmdLoader/AmdLoader.js"></script>
		        <script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
		        <script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
                <script src="../common/scripts/emxJSValidationUtil.js" type="text/javascript"/>
				<script src="../common/scripts/emxUIConstants.js" type="text/javascript"/>
				<script src="../common/scripts/emxUICore.js" type="text/javascript"/>
				<script src="../common/scripts/emxUIModal.js" type="text/javascript"/>
				<script src="../common/scripts/emxUICoreMenu.js" type="text/javascript"/>
				<script src="../common/scripts/emxUIToolbar.js" type="text/javascript"/>
				<script src="../common/scripts/emxNavigatorHelp.js" type="text/javascript"/>
				<script src="../common/scripts/emxUIPopups.js" type="text/javascript"/>
				<script src="../common/scripts/emxUICreate.js" type="text/javascript"/>
				<script src="../common/scripts/emxUICalendar.js" type="text/javascript"/>
				<script src="../common/scripts/emxUIFormUtil.js" type="text/javascript"/>
				<script src="../parameter/emxParameterUIFormUtil.js" type="text/javascript"/>
				<script src="../common/scripts/emxTypeAhead.js" type="text/javascript" />
				<script src="../common/scripts/emxQuery.js" type="text/javascript" />
				<script src="../common/scripts/emxUIFormHandler.js" type="text/javascript" />
			    <script src="../common/scripts/jquery-latest.js" type="text/javascript" />
			    <script src="../common/scripts/emxUIRTE.js" type="text/javascript" />
			    <script src="../common/scripts/emxUIRTEToolbar.js" type="text/javascript" />
				<link rel="stylesheet" href="../common/styles/emxUIDefault{$ext}.css"/>
                <link rel="stylesheet" href="../common/styles/emxUIMenu{$ext}.css"/>
                <link rel="stylesheet" href="../common/styles/emxUIToolbar{$ext}.css"/>
				<link rel="stylesheet" href="../common/styles/emxUIDOMLayout{$ext}.css"/>				
				<link rel="stylesheet" href="../common/styles/emxUIDialog{$ext}.css"/>
				<link rel="stylesheet" href="../common/styles/emxUIForm{$ext}.css"/>
				<link rel="stylesheet" href="../common/styles/emxUICalendar{$ext}.css"/>                
    <xsl:choose> 
    <xsl:when test="($isMobile = 'true') or ($isPCTouch = 'true')">
    	<link rel="stylesheet" type="text/css" href="mobile/styles/emxUIMobile.css"/>
    </xsl:when>
    <xsl:otherwise/>
   </xsl:choose>                
	<script type="text/javascript">
    	<xsl:value-of disable-output-escaping="yes" select="toolbarCode"/>
    </script>
               
                <script type="text/javascript">
                jQuery(document).ready(function($) {
                urlParameters = decodeURIComponent(urlParameters);
                if($('.rte').length){
                  var arr = $('.rte').rte({
                            css: ['../common/styles/emxUIDefault.css'],
                            controls_rte: rte_toolbar,
                            controls_html: html_toolbar
                            });
                           }
                          });
               </script>            
	<xsl:if test="string-length($spellCheckerURL) > 0">
		<script type="text/javascript" src="{$spellCheckerURL}"></script>
		<script type="text/javascript">
			if(emxUICore.isValidPageURL("<xsl:value-of select="$spellCheckerURL"/>")){
			function startSpellCheck(event){
			FormHandler.SpellCheckWindow = true;
			var spellCheckElem = $("textarea",
			event.parentNode).get(0)?$("textarea",
			event.parentNode).get(0):$("iframe",
			event.parentNode.parentNode).get(0);
			if(spellCheckElem.id == "" || spellCheckElem.id == null){
			spellCheckElem.id = spellCheckElem.name != "" ? spellCheckElem.name :
			spellCheckElem.title;
			}
                                
			doSpell({
			ctrl: spellCheckElem.id,
			lang:'<xsl:value-of select="$spellCheckerLang"/>',
			onFinish:onFinish
			});
			}

			onFinish = function(mSender){
			FormHandler.SpellCheckWindow = false;
			if(mSender.className == "rte"){
			mSender.contentWindow.focus();
			}else{
			mSender.focus();
			}
			}

			function addSpellCheckElem(id) {
			var element = document.createElement("input");
			element.setAttribute("type", "button");
		    element.setAttribute("value", emxUIConstants.SPELL_CHECK);    
		    element.setAttribute("name", "SpellCheck"); 
		    element.setAttribute("title", emxUIConstants.SPELL_CHECK);
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
	</xsl:if>                      
				<!--
					Custom Validation
				-->
				<xsl:for-each select="aef:CustomValidation/aef:setting">
					<script src="{text()}" type="text/javascript"/>
				</xsl:for-each>
				<xsl:for-each select="aef:fields/aef:field">
					<xsl:if test="aef:settings/aef:setting[@name = 'Data Type']">
						<xsl:choose>
							<xsl:when test="aef:actualValue != ''">
								<script>eval("var <xsl:value-of select="aef:settings/aef:setting[@name='jsFieldName']"/> = <xsl:value-of select="aef:actualValue"/>")</script>
							</xsl:when>
							<xsl:otherwise>
								<script>eval("var <xsl:value-of select="aef:settings/aef:setting[@name='jsFieldName']"/> = 0")</script>
							</xsl:otherwise>
						</xsl:choose>
						
					</xsl:if>
				</xsl:for-each>
			</head>
			<body onload="runValidate();adjustFrames();" onUnload="cancelCreate()">
				<xsl:attribute name="class">
					<xsl:choose>
	                <xsl:when test="$slideinui = 'true'">slide-in-panel</xsl:when>
	                <xsl:otherwise>dialog</xsl:otherwise>
	               </xsl:choose>
				</xsl:attribute>
					<xsl:call-template name="pageHead"/>
				<div id="divPageBody">
					<xsl:call-template name="pageBody"/>
					<iframe class="hidden-frame" name="formCreateHidden" height="0" width="0" style="position: absolute; top: -10px;" />
				</div>
				<div id="divPageFoot">
					<xsl:call-template name="pageFooter"/>
				</div>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
