<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
    <!-- apply all templates -->
    <xsl:template match="/">
        <xsl:apply-templates select="//param"/>
    </xsl:template>
    
    <!-- param -->
    <xsl:template match="param">
    <xsl:choose>
        <xsl:when test="@name = 'showingAdvanced'">pageControl.setShowingAdvanced(<xsl:value-of select="."/>);</xsl:when>
        <xsl:when test="@name = 'title'">pageControl.setTitle("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'wrapColSize'">pageControl.setWrapColSize("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'webReportOwner'">pageControl.setOwner("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'resultsTitle'">pageControl.setResultsTitle("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'helpMarker'">pageControl.setHelpMarker("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'helpMarkerSuiteDir'">pageControl.setHelpMarkerSuiteDir("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'type'">pageControl.setType("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'metricsReportContentURL'">pageControl.setReportContentURL("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'savedReportName'">pageControl.setSavedReportName("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'commandname'">pageControl.setCommandName("<xsl:value-of select="."/>");</xsl:when>
        <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
