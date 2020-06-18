<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:aef="http://www.matrixone.com/aef" exclude-result-prefixes="aef">
    
        <xsl:output method="html" version="1.0" encoding="UTF-8" />
		<xsl:variable name="NotTypes" select="/aef:typechooser/aef:notTypes/@NotTypes"/>
        <!-- match all -->
        <xsl:template match="/">
                <div><xsl:apply-templates select="*"/></div>
        </xsl:template>
        
        <!-- match <typechooser/> -->
        <xsl:template match="aef:typechooser">
                <xsl:apply-templates select="aef:root"/>        
        </xsl:template>
        
        <!-- match <root /> -->
        <xsl:template match="aef:root">
                <div id="divRootA">
                        <table>
                                <tbody>
                                        <tr>
                                                <xsl:apply-templates select="aef:label"/>
                                        </tr>
                                </tbody>
                        </table>
                </div>
                <div id="divRootB">
                        <xsl:apply-templates select="aef:type"/>
                </div>
        </xsl:template>

        <!-- match <aef:type /> -->
        <xsl:template match="aef:type">
                <xsl:variable name="divId" select="generate-id()"/>
                <div id="div{$divId}A">
                        <table>
                                <tbody>
                                        <tr>
                                                <xsl:if test="../aef:type and ../../aef:type">
                                                        <td><xsl:apply-templates select="." mode="miscimages"/></td>
                                                </xsl:if>
                                                <td onclick="objTypeChooser.toggleExpand(&apos;{$divId}&apos;, &apos;{@name}&apos;, &apos;{$NotTypes}&apos;)" id="td{$divId}"><xsl:apply-templates select="." mode="plusminusimage"/></td>
                                                <xsl:choose>
                                                        <xsl:when test="//@selection = 'multiple'"><td><input id="chk{$divId}" type="checkbox" value="{@name}|{aef:label/aef:text}" style="height: 16px;padding:0px;margin:0px"><xsl:if test="@abstract='true' and //@abstractselect='false'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if></input></td></xsl:when>
                                                        <xsl:otherwise><td><input type="radio" name="radType" value="{@name}|{aef:label/aef:text}" style="height: 16px;padding:0px;margin:0px"><xsl:if test="@abstract='true' and //@abstractselect='false'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if></input></td></xsl:otherwise>
                                                </xsl:choose>
                                                                             
                                                <xsl:apply-templates select="*"/>
                                        </tr>
                                </tbody>
                        </table>
                </div>
                <div id="div{$divId}B" style="display:none">
                        <xsl:choose>
                                <xsl:when test="aef:type"><xsl:apply-templates select="aef:type"/></xsl:when>
                                <xsl:otherwise><img src="images/iconStatusLoading.gif" alt=""/></xsl:otherwise>
                        </xsl:choose>                        
                </div>
        </xsl:template>

        <!-- match <aef:type /> -->
        <xsl:template match="aef:type">
                <xsl:variable name="divId" select="generate-id()"/>
                <div id="div{$divId}A">
                        <table>
                                <tbody>
                                        <tr>
                                                <xsl:if test="../aef:type and ../../aef:type">
                                                        <td><xsl:apply-templates select="." mode="miscimages"/></td>
                                                </xsl:if>
                                                <td onclick="objTypeChooser.toggleExpand(&apos;{$divId}&apos;, &apos;{@name}&apos;, &apos;{$NotTypes}&apos;)" id="td{$divId}"><xsl:apply-templates select="." mode="plusminusimage"/></td>
                                                <xsl:choose>
                                                        <xsl:when test="//@selection = 'multiple'"><td><input id="chk{$divId}" type="checkbox" value="{@name}|{aef:label/aef:text}" style="height: 16px;padding:0px;margin:0px"><xsl:if test="@abstract='true' and //@abstractselect='false'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if></input></td></xsl:when>
                                                        <xsl:otherwise><td><input type="radio" name="radType" value="{@name}|{aef:label/aef:text}" style="height: 16px;padding:0px;margin:0px"><xsl:if test="@abstract='true' and //@abstractselect='false'"><xsl:attribute name="disabled">disabled</xsl:attribute></xsl:if></input></td></xsl:otherwise>
                                                </xsl:choose>
                                                                             
                                                <xsl:apply-templates select="aef:label"/>
                                        </tr>
                                </tbody>
                        </table>
                </div>
                <div id="div{$divId}B" style="display:none">
                        <xsl:choose>
                                <xsl:when test="aef:type"><xsl:apply-templates select="aef:type"/></xsl:when>
                                <xsl:otherwise><img src="images/iconStatusLoading.gif" alt=""/></xsl:otherwise>
                        </xsl:choose>                        
                </div>
        </xsl:template>

        <!-- match <type /> -->
        <xsl:template match="aef:type" mode="miscimages">
                <xsl:for-each select="ancestor::node()[not(name() = 'aef:root') and not(name() = 'aef:typechooser') and not(name() = '')]"><xsl:if test="not(../aef:root)"><img height="19" width="19">
                                <xsl:attribute name="src">
                                        <xsl:choose>
                                                <xsl:when test="parent::node() and not(following-sibling::aef:type)">images/utilSpacer.gif</xsl:when>
                                                <xsl:otherwise>images/utilTreeLineVert.gif</xsl:otherwise>
                                        </xsl:choose>                                                                
                                </xsl:attribute>
                        </img></xsl:if></xsl:for-each>
        </xsl:template>

        <!-- match <type /> -->
        <xsl:template match="aef:type" mode="plusminusimage">
                <xsl:choose>
                        <xsl:when test="../aef:root"></xsl:when>
                        <xsl:otherwise><img width="19" height="19"><xsl:attribute name="src">
                                <xsl:choose>
                                        <xsl:when test="following-sibling::aef:type">
                                                <xsl:choose>
                                                        <xsl:when test="aef:type or @haschildren=&apos;true&apos;">images/utilTreeLineNodeClosed.gif</xsl:when>
                                                        <xsl:otherwise>images/utilTreeLineNode.gif</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <xsl:choose>
                                                        <xsl:when test="aef:type or @haschildren=&apos;true&apos;">images/utilTreeLineLastClosed.gif</xsl:when>
                                                        <xsl:otherwise>images/utilTreeLineLast.gif</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:otherwise>
                                </xsl:choose>
                        </xsl:attribute></img></xsl:otherwise>
                </xsl:choose>
        </xsl:template>


        <xsl:template match="aef:label">
            <xsl:apply-templates select="*"/>
        </xsl:template>
        
        <xsl:template match="aef:image">
            <td class="node-icon"><img src="{@src}" width="16" height="16"/></td>
        </xsl:template>
        
        <xsl:template match="aef:text">
            <td class="node-text"><xsl:value-of select="."/></td>        
        </xsl:template>

 </xsl:stylesheet>
