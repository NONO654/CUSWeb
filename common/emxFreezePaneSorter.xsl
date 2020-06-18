<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:param name="sortColIndex" select="1"/>
	<xsl:param name="useSortValue" select="false()"/>
	<xsl:param name="sortOrder" select="'descending'"/>
	<xsl:template match="rows | r">
		<xsl:copy>
		<xsl:for-each select="@*">
			<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
		</xsl:for-each>
        <xsl:choose>
            <xsl:when test="$useSortValue=false()">
    			<xsl:apply-templates select="r">
    				<xsl:sort select="c[position()=$sortColIndex]" order="{$sortOrder}"/>
    			</xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
    			<xsl:apply-templates select="r">
    				<xsl:sort data-type="number" select="c[position()=$sortColIndex]/@sortValue" order="{$sortOrder}"/>
    			</xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
			<xsl:apply-templates select="c"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="/ | @* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
