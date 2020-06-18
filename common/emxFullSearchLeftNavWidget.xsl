<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="expand">FullSearch.expand(this)</xsl:variable>
	<xsl:variable name="currLevel"><xsl:value-of select="number(/mxRoot/object/@currLevel)" /></xsl:variable>
	<xsl:variable name="hasSibling"><xsl:value-of select="string(/mxRoot/object/@hasSibling)" /></xsl:variable>
    <xsl:template match="/mxRoot/object">
        <div>
        <xsl:apply-templates select="object/object"/>
        </div>
    </xsl:template>
    
	<xsl:template match="object[string]">
        <xsl:variable name="dataType">
            <xsl:value-of select="dataType/text()"/>
        </xsl:variable>
        <xsl:variable name="uomList">
            <xsl:value-of select="uomList/text()"/>
        </xsl:variable>
        <xsl:variable name="mandatorySearch">
            <xsl:value-of select="@mandatorySearch"/>
        </xsl:variable>
        <xsl:variable name="fieldName">
            <xsl:value-of select="field/text()"/>
        </xsl:variable>
        <div id="{string[@id='type']/text()}_{generate-id()}" class="show">
            <div style="position:relative" class="show">
                <xsl:if test="@selected = 'true' or descendant::object[@selected = 'true']">
                    <xsl:attribute name="class">selected</xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="." mode="miscimages"/>
                
                <xsl:apply-templates select="." mode="plusminusimage" />
                <a>
                    <xsl:if test="string-length($mandatorySearch) = 0 or $mandatorySearch = 'false'">
                        <xsl:attribute name="onclick">FullSearch.toggle(this) </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="number and string[@id='value']">
                        <xsl:attribute name="filter_name"><xsl:value-of select="../../string/text()"/></xsl:attribute>
                        <xsl:attribute name="filter_val"><xsl:value-of select="string/text()"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string[@id='type']">
                        <xsl:attribute name="filter_name"><xsl:value-of select="$fieldName"/></xsl:attribute>
                        <xsl:attribute name="filter_val"><xsl:value-of select="string[@id='type']/text()"/></xsl:attribute>
                        <xsl:attribute name="filter_DisplayValue"><xsl:value-of select="string[@id='displayValue']/text()"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="string">
                        <xsl:if test="not(string[@id='type'])">
                            <xsl:attribute name="filter_name"><xsl:value-of select="string[@id='attribute']/text()"/></xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@selected = 'true' or descendant::object[@selected = 'true']">
                          <img src="images/fullSearchButtonSelected.gif" hspace="2"/>
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="string[@id='displayValue']">
                                <xsl:value-of select="string[@id='displayValue']/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="string/text()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:if test="number and (string[@id='value'] or string[@id='type'])and
                                    not(@selected = 'true' or descendant::object[@selected = 'true'])"> (<xsl:value-of select="number/text()"/>)</xsl:if>
                </a>
            </div>
            <xsl:if test="object/object[string]">
                <div id="sub_{string[@id='type']/text()}_{generate-id()}" style="position:relative">
                    <xsl:choose>
                        <xsl:when test="parent::node()/parent::object[@selected = 'true'] or string[@id='type']/text() = 'hasChild' or @selected = 'true' or descendant::object[@selected = 'true']">
                            <xsl:attribute name="class">show</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">hide</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="object/object"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>
    
    
	<xsl:template match="object" name="test" mode="miscimages">
		    <xsl:param name="num">0</xsl:param> <!-- param has initial value -->
		    <xsl:if test="not($num = $currLevel)">
		        <img height="16" width="16" style="position:relative" src="images/utilSpacer.gif">
                </img>
		        <xsl:call-template name="test">
		            <xsl:with-param name="num">
		                <xsl:value-of select="$num + 1" />
		            </xsl:with-param>
		        </xsl:call-template>
		    </xsl:if>
            
    </xsl:template>
    
    <xsl:template match="object" mode="plusminusimage">
    	<img width="16" height="16"  style="position:relative" hasSibling="{not(not(following-sibling::object))}" level="{$currLevel}" onclick="FullSearch.toggleTaxonomyExpand(this,'{field/text()}','{string[@id='type']/text()}')">
    		<xsl:attribute name="src">
            	<xsl:choose>
                        <xsl:when test="@isExpanded = 'true' and following-sibling::object">
                                <xsl:choose>
                                		<xsl:when test="@selected = 'true'">images/fullSearchTreeLineNodeOpen.gif</xsl:when>
                                        <xsl:when test="object/object[string]">images/fullSearchTreeLineNodeClosed.gif</xsl:when>
                                        <xsl:otherwise>images/fullSearchTreeLineNode.gif</xsl:otherwise>
                                </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:choose>
                                		<xsl:when test="@selected = 'true'">images/fullSearchTreeLineLastOpen.gif</xsl:when>
                                        <xsl:when test="object/object[string]">images/fullSearchTreeLineLastClosed.gif</xsl:when>
                                        <xsl:otherwise>images/fullSearchTreeLineLast.gif</xsl:otherwise>
                                </xsl:choose>
                        </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
        </img>
    </xsl:template>
</xsl:stylesheet>
