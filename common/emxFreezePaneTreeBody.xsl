<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="split" select="/mxRoot/setting[@name='split']"/>
	<xsl:variable name="urlParameters">timeStamp=<xsl:value-of select="//setting[@name='timeStamp']"/>&amp;rowBuffer=<xsl:value-of select="//setting[@name='rowBuffer']"/>&amp;<xsl:for-each select="//requestMap/setting">
			<xsl:value-of select="@name"/>=<xsl:value-of select="text()"/>
			<xsl:if test="position()!=last()">&amp;</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="level" select="0"/>
	<xsl:template match="/mxRoot">
		<xsl:call-template name="treeBody"/>
	</xsl:template>
</xsl:stylesheet>
