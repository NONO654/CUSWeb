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
        <xsl:when test="@name = 'helpMarker'">pageControl.setHelpMarker("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'helpMarkerSuiteDir'">pageControl.setHelpMarkerSuiteDir("<xsl:value-of select="."/>");</xsl:when>        
		<xsl:when test="@name = 'type'">pageControl.setType("<xsl:value-of select="."/>");</xsl:when>
		<xsl:when test="@name = 'searchContentURL'">pageControl.setSearchContentURL("<xsl:value-of select="."/>");</xsl:when>
		<xsl:when test="@name = 'savedSearchName'">pageControl.setSavedSearchName("<xsl:value-of select="."/>");</xsl:when>
		
		<!-- added for Consolidated Search -->
		<xsl:when test="@name = 'program'">pageControl.setURLProgram("<xsl:value-of select="."/>");</xsl:when>
		<xsl:when test="@name = 'expandProgram'">pageControl.setExpandProgram("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'relationship'">pageControl.setRelationship("<xsl:value-of select="."/>");</xsl:when>
       
		<xsl:when test="@name = 'sortColumnName'">pageControl.setSortColumnName("<xsl:value-of select="."/>");</xsl:when>		
		<xsl:when test="@name = 'selection'">pageControl.setSelection("<xsl:value-of select="."/>");</xsl:when>		
		<xsl:when test="@name = 'requestedType'">pageControl.setRequestType("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'defaultSearch'">pageControl.setDefaultSearch("<xsl:value-of select="."/>");</xsl:when>
       
      
		<xsl:when test="@name = 'table'">pageControl.setTable("<xsl:value-of select="."/>");</xsl:when>		
		<xsl:when test="@name = 'tableSetting'">pageControl.setTableSetting("<xsl:value-of select="."/>");</xsl:when>
		<xsl:when test="@name = 'programSetting'">pageControl.setProgram("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'functionSetting'">pageControl.setFunction("<xsl:value-of select="."/>");</xsl:when>
        <xsl:when test="@name = 'searchType'">pageControl.setSearchType("<xsl:value-of select="."/>");</xsl:when>        
		<xsl:when test="@name = 'hideHeader'">pageControl.setHideHeader("<xsl:value-of select="."/>");</xsl:when>
		<xsl:when test="@name = 'hideFooter'">pageControl.setHideFooter("<xsl:value-of select="."/>");</xsl:when>
		<xsl:when test="@name = 'searchProgram'">pageControl.setSearchProgram("<xsl:value-of select="."/>");</xsl:when>
		<xsl:when test="@name = 'searchTable'">pageControl.setSearchTable("<xsl:value-of select="."/>");</xsl:when>		    
	   	<xsl:when test="@name = 'valuePair'">pageControl.setValuePair("<xsl:value-of select="."/>");pageControl.storeUnique();</xsl:when>
	 			
		<!-- ended for Consolidated Search -->		
		
		<xsl:otherwise></xsl:otherwise>
	</xsl:choose>
	
	</xsl:template>
</xsl:stylesheet>
