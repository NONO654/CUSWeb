<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="text" version="4.0" encoding="UTF-8" indent="no"/>

    <xsl:template match="SEARCH">
        <xsl:for-each select="SEARCH_ITEM">
            <xsl:for-each select="ATTRIBUTE">
                <!--<xsl:value-of select="@id"/>=-->"<xsl:value-of select="."/>",
            </xsl:for-each>
            <xsl:text>&#10;&#13;</xsl:text>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
