<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:aef="http://www.matrixone.com/aef">
    <xsl:output method="html" version="1.0" encoding="UTF-8" indent="no"/>
    <xsl:variable name="mode" select="//aef:requestMap/aef:setting[@name='mode']" />
    <xsl:variable name="targetLocation" select="//aef:requestMap/aef:setting[@name='targetLocation']" />
    <xsl:variable name="showApply" select="//aef:requestMap/aef:setting[@name='showApply']" />
    <xsl:include href="emxCreateHeader.xsl"/>
    <xsl:include href="emxCreateBody.xsl"/>
    <xsl:include href="emxCreateFooter.xsl"/>
    <xsl:variable name="urlParameters">uiType=form&amp;printerFriendly=false&amp;export=false&amp;timeStamp=<xsl:value-of select="//aef:setting[@name='timeStamp']"/>&amp;<xsl:for-each select="//aef:requestMap/aef:setting[not(@name='timeStamp')]">
            <xsl:value-of select="@name"/>=<xsl:value-of select="text()"/>
            <xsl:if test="position()!=last()">&amp;</xsl:if>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="isUnix" select="/mxRoot/setting[@name='isUnix']"/>  
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
                <script type="text/javascript">
                    var timeStamp = "<xsl:value-of select="aef:setting[@name='timeStamp']"/>";
                    var urlParameters = "<xsl:value-of select="$urlParameters"/>";
                </script>               
                <script src="emxUIConstantsJavaScriptInclude.jsp" type="text/javascript"/>
                <script src="emxFormConstantsJavascriptInclude.jsp" type="text/javascript"/>
                <script src="emxJSValidation.jsp" type="text/javascript"/>
                <script src="scripts/emxJSValidationUtil.js" type="text/javascript"/>
                <script src="scripts/emxUIConstants.js" type="text/javascript"/>
                <script src="scripts/emxUIModal.js" type="text/javascript"/>
                <script src="scripts/emxUICore.js" type="text/javascript"/>
                <script src="scripts/emxUICoreMenu.js" type="text/javascript"/>
                <script src="scripts/emxUIToolbar.js" type="text/javascript"/>
                <script src="scripts/emxNavigatorHelp.js" type="text/javascript"/>
                <script src="scripts/emxUIPopups.js" type="text/javascript"/>
                <script src="scripts/emxUICreate.js" type="text/javascript"/>
                <script src="scripts/emxUICalendar.js" type="text/javascript"/>
                <script src="scripts/emxUIFormUtil.js" type="text/javascript"/>
                <script src="scripts/emxTypeAhead.js" type="text/javascript" />
                <script src="scripts/emxUIJson.js" type="text/javascript" />
                <script src="scripts/emxQuery.js" type="text/javascript" />
                <script src="scripts/emxUIFormHandler.js" type="text/javascript" />
                <link rel="stylesheet" href="styles/emxUIDefault{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUIMenu{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUIToolbar{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUIDOMLayout{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUIDOMDialog{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUIDialog{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUIForm{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUICalendar{$ext}.css"/>
                <link rel="stylesheet" href="styles/emxUITypeAhead{$ext}.css" />
                                <script language="JavaScript" src="../common/emxToolbarJavaScript.jsp?{$urlParameters}&amp;mode=create" type="text/javascript"/>
                                
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
            <body onload="runValidate();smaHostListTypeCallBack();smaRunOptionTypeCallBack();" onUnload="cancelCreate()">
                <xsl:attribute name="class"> 
                    <xsl:choose>
                    <xsl:when test="$targetLocation = 'slidein'">
                        slide-in-panel
                    </xsl:when>
                    <xsl:otherwise>
                        dialog
                    </xsl:otherwise>
                   </xsl:choose>
                </xsl:attribute>
                    <xsl:call-template name="pageHead"/>
                <div id="divPageBody">
                    <xsl:call-template name="pageBody"/>
                    <iframe class="hidden-frame" name="formCreateHidden" src="emxBlank.jsp" height="0" width="0" style="position: absolute; top: -10px;" />
                </div>
                <div id="divPageFoot">
                    <xsl:call-template name="pageFooter"/>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
