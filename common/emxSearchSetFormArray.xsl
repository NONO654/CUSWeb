<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
	<!-- apply all templates -->
	<xsl:template match="/">var tmp = "";<xsl:apply-templates select="//formfield"/>
	</xsl:template>
	<!-- param -->
	<xsl:template match="formfield">
		<xsl:choose>
			<xsl:when test="@type='string'">
				<xsl:call-template name="stringField"/>
			</xsl:when>
			<xsl:when test="@type='boolean'">
				<xsl:call-template name="booleanField"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="objectField"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="stringField">tmp = decodeURI("<xsl:value-of select="."/>");pageControl.arrFormVals[<xsl:value-of select="position()-1"/>] = new Array("<xsl:value-of select="@name"/>",tmp,null,<xsl:value-of select="@disabled = 'true'"/>);tmp="";</xsl:template>
	<xsl:template name="booleanField">pageControl.arrFormVals[<xsl:value-of select="position()-1"/>] = new Array("<xsl:value-of select="@name"/>","<xsl:value-of select="."/>",<xsl:value-of select="@checked"/>);</xsl:template>
	<xsl:template name="objectField"><xsl:for-each select="value"><xsl:if test="position() = 1" >tmp = new Array();</xsl:if>tmp[tmp.length] =  new Array(<xsl:value-of select="."/>);</xsl:for-each>pageControl.arrFormVals[<xsl:value-of select="position()-1"/>] = new Array("<xsl:value-of select="@name"/>",tmp);tmp = "";</xsl:template>
</xsl:stylesheet>
