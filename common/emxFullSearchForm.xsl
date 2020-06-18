<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="inclusionList">emxFramework.GenericSearch.Types</xsl:variable>
	<xsl:variable name="exclusionList"></xsl:variable>
	<xsl:variable name="searchPopup"></xsl:variable>
	<xsl:variable name="Indexed"></xsl:variable>
	<xsl:template match="/mxRoot/object/object[object/string]">				

<ul>
   <xsl:apply-templates select="object[position()]"/>
</ul>
	</xsl:template>
	<xsl:template match="object[string]">
		<xsl:variable name="varName" select="string[@id='attribute']/text()"/>
		<xsl:variable name="dataType" select="dataType/text()"/>
		<xsl:variable name="uiAutomation" select="string[@id='UIAutomation']/text()"/>
		<xsl:variable name="uomList" select="uomList/text()"/>
		<xsl:variable name="submitURL">
			<xsl:choose>
				<xsl:when test="string[@id='customChooser'] and string[@id='isFullSearch'] = 'true'">&amp;submitURL=../common/AEFSearchUtil.jsp</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="strTxtType">
	       	<xsl:call-template name="replace-string">
				<xsl:with-param name="text" select="$inclusionList"/>
				<xsl:with-param name="from" select="','"/>
				<xsl:with-param name="to" select="string[@id='refinementSeparator']"/>
			</xsl:call-template>
	    </xsl:variable>
	    <xsl:if test=" string($searchPopup) = 'true' or not((string[@id='attribute'] = 'NAME') and not(string($Indexed) = 'true'))='true'">
			<li>
				<xsl:if test="$uiAutomation = 'true' ">
		    		<xsl:attribute name="data-aid"><xsl:value-of select="$varName"/></xsl:attribute>
		    	</xsl:if>
				<!--Form Labels-->
				<label>
						<xsl:value-of select="./string[@id = 'displayValue']/text()"/>
				</label>
				<!--Form Inputs-->
				<xsl:choose>
					<xsl:when test="$dataType = 'string' and not(@parametric='true') and not(string[@id='chooser']) and not(string[@id='chooserJPO']) and not(string[@id='UserChooser']) and not(string[@id='customChooser']) and count(object[@id = 'values']/object) = 0 and not(string[@id='attribute'] = 'REVISION')">
						<span class="input large">
						<input type="text" value="" name="{$varName}" id="{$varName}" onFocus="FullSearch.displayDynamicTextarea(this)" size="30%" Delimiter="{string[@id='refinementSeparator']}">
							<xsl:if test="string[@id='selectedValue']">
								<xsl:attribute name="value"><xsl:value-of select="string[@id='selectedValue']/text()" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="string[@id='disabled'] = 'true'">
								<xsl:attribute name="disabled">true</xsl:attribute>
							</xsl:if>
							<xsl:if test="string[@id='minReqChars']">
								<xsl:attribute name="minReqChars"><xsl:value-of select="string[@id='minReqChars']/text()" /></xsl:attribute>
							</xsl:if>
						</input>
						</span>
					</xsl:when>
					<xsl:otherwise>
					   <span class="input large">
					   <xsl:if test="$varName = 'REVISION'" >
								<xsl:attribute name="class">input small</xsl:attribute>
						</xsl:if>
						<input onChange="formAddInput(this)" type="text" name="{$varName}" id="{$varName}">
							<xsl:if test="$varName = 'REVISION'" >
								<xsl:if test="string[@id = 'DisplayType']/text() = 'Chooser'">
								<xsl:attribute name="readOnly">true</xsl:attribute>
								</xsl:if>
							</xsl:if>
							
							<xsl:if test="($varName = 'TYPE') and not($inclusionList='emxFramework.GenericSearch.Types')">
									<xsl:attribute name="value"><xsl:value-of select="$strTxtType"/></xsl:attribute>
							</xsl:if>
							<xsl:if test="string[@id='selectedValue']">
								<xsl:attribute name="value"><xsl:value-of select="string[@id='selectedValue']/text()" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="string[@id='minReqChars']">
								<xsl:attribute name="minReqChars"><xsl:value-of select="string[@id='minReqChars']/text()" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="string[@id='disabled'] = 'true'">
								<xsl:attribute name="disabled">true</xsl:attribute>
							</xsl:if>
							<xsl:if test="string[@id='customChooser'] and string[@id='disabled'] = 'false' ">
								<xsl:attribute name="onKeyPress">checkEnterKeyPressed(event,'<xsl:value-of select="string[@id='customChooser']/text()"/>&amp;fromChooser=true&amp;formName=full_search&amp;frameName=window&amp;fieldNameActual=hidden_<xsl:value-of select="$varName"/>&amp;fieldNameDisplay=<xsl:value-of select="$varName"/>&amp;showInitialResults=true<xsl:value-of select="$submitURL"/>',<xsl:value-of select="$varName"/>)</xsl:attribute>
							</xsl:if>							
							<xsl:if test="not(string[@id='attribute'] = 'REVISION')">
									<xsl:choose>
										<xsl:when test="string[@id='customChooser'] and string[@id='disabled'] = 'false' ">																						
										</xsl:when>
										<xsl:when test="string[@id='chooserJPO'] or not(string[@id='UserChooser'])">
										<xsl:attribute name="readOnly">true</xsl:attribute>
											<xsl:attribute name="onclick">FullSearch.showValuesHierarchy(this.parentNode.nextSibling.nextSibling)</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
										<xsl:attribute name="readOnly">true</xsl:attribute>
											<xsl:choose>
											<xsl:when test="string[@id='UserChooser']">
												<xsl:attribute name="onclick">
watchForChange('<xsl:value-of select="$varName"/>',document.getElementById('<xsl:value-of select="$varName"/>').value);window.showChooser('<xsl:value-of select="string[@id='UserChooser']/text()"/>&amp;selectione=multiple&amp;fromChooser=true&amp;formName=full_search&amp;frameName=window&amp;fieldNameActual=hidden_<xsl:value-of select="$varName"/>&amp;fieldNameDisplay=<xsl:value-of select="$varName"/>&amp;submitURL=../components/emxPersonSearchProcess.jsp')</xsl:attribute>
											</xsl:when>
											<xsl:when test="string[@id='customChooser']">												
												<xsl:attribute name="onclick">
watchForChange('<xsl:value-of select="$varName"/>',document.getElementById('<xsl:value-of select="$varName"/>').value);showFullSearchChooser('<xsl:value-of select="string[@id='customChooser']/text()"/>&amp;fromChooser=true&amp;formName=full_search&amp;frameName=window&amp;fieldNameActual=hidden_<xsl:value-of select="$varName"/>&amp;fieldNameDisplay=<xsl:value-of select="$varName"/>&amp;showInitialResults=true<xsl:value-of select="$submitURL"/>',<xsl:value-of select="$varName"/>)</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
											<xsl:attribute name="onclick">FullSearch.showValuesHierarchy(this.parentNode.nextSibling.nextSibling)</xsl:attribute>
											</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
										</xsl:choose>									
							</xsl:if>
						</input>
						</span>
						<xsl:if test="$varName = 'REVISION'" >
							<xsl:if test = "string[@id = 'DisplayType']/text() = 'Chooser'">
							<input type="button" value="...">	
							<xsl:attribute name="onclick">FullSearch.showValuesHierarchy(this)</xsl:attribute>
							<xsl:if test="string and string[@id='attribute']">
								<xsl:attribute name="filter_name"><xsl:value-of select="string[@id='attribute']/text()"/></xsl:attribute>
							</xsl:if>							
							</input>
							</xsl:if>							
							<xsl:if test="not(string[@id='disabled'] = 'true')">
							<a>										
								<xsl:attribute name="href">javascript:FullSearch.resetField('REVISION', '<xsl:value-of select="string[@id='defaultFieldValue']/text()" />', '')</xsl:attribute>																
								<span class="image-button"><img src="../common/images/iconActionRefresh.gif">
									<xsl:attribute name="title"><xsl:value-of select="./string[@id = 'ResetFieldTitle']/text()"/></xsl:attribute>
								</img>
								</span>
							</a>
							</xsl:if>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="string[@id='attribute'] = 'REVISION'">
								&#160;<input type="checkbox" name="lastRevision" id="lastRevision" value="last" onclick="javascript:disableRevision('lastRevision','latestRevision')">
									<xsl:if test="string[@id = 'last']/text() = 'true'">
										<xsl:attribute name="checked">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="(string[@id = 'last']/text() = 'true' or string[@id = 'latest']/text() = 'true') and (not(string[@id = 'defaultLastRev']/text() = 'true')) and string[@id = 'disabled']/text() = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>									
									<xsl:attribute name="title"><xsl:value-of select="./string[@id = 'HighestTitle']/text()"/></xsl:attribute>
								</input>&#160;<xsl:value-of select="./string[@id = 'Highest']/text()"/>&#160;<input type="checkbox" name="latestRevision" id="latestRevision" value="latest" onclick="javascript:disableRevision('latestRevision','lastRevision')">
									<xsl:if test="string[@id = 'latest']/text() = 'true'">
										<xsl:attribute name="checked">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="(string[@id = 'last']/text() = 'true' or string[@id = 'latest']/text() = 'true') and (not(string[@id = 'defaultLatestRev']/text() = 'true')) and string[@id = 'disabled']/text() = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:attribute name="title"><xsl:value-of select="./string[@id = 'ByStateTitle']/text()"/></xsl:attribute>
								</input>&#160;<xsl:value-of select="./string[@id = 'ByState']/text()"/>
                            </xsl:when>
							<xsl:otherwise>
								<input type="hidden" name="hidden_{$varName}" id="hidden_{$varName}"/>
								<input type="button" value="...">
									<xsl:if test="string[@id='disabled'] = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:choose>
									   <!-- added not condition for Mx361263 -->
										<xsl:when test="string[@id='chooser']  and not ($varName='VAULT')">
											<xsl:attribute name="onclick">
watchForChange('<xsl:value-of select="$varName"/>',document.getElementById('<xsl:value-of select="$varName"/>').value);window.showChooser('<xsl:value-of select="string[@id='chooser']/text()"/>?callbackFunction=resetPolicyAndStateFields&amp;SelectType=multiselect&amp;SelectAbstractTypes=true&amp;InclusionList=<xsl:value-of select="$inclusionList"/>&amp;ExclusionList=<xsl:value-of select="$exclusionList"/>&amp;formName=full_search&amp;frameName=window&amp;fieldNameActual=hidden_<xsl:value-of select="$varName"/>&amp;fieldNameDisplay=<xsl:value-of select="$varName"/>')</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
											<xsl:when test="string[@id='UserChooser']">
												<xsl:attribute name="onclick">
watchForChange('<xsl:value-of select="$varName"/>',document.getElementById('<xsl:value-of select="$varName"/>').value);window.showChooser('<xsl:value-of select="string[@id='UserChooser']/text()"/>&amp;selectione=multiple&amp;fromChooser=true&amp;formName=full_search&amp;frameName=window&amp;fieldNameActual=hidden_<xsl:value-of select="$varName"/>&amp;fieldNameDisplay=<xsl:value-of select="$varName"/>&amp;submitURL=../common/AEFSearchUtil.jsp')</xsl:attribute>
											</xsl:when>
											<xsl:when test="string[@id='customChooser']">												
												<xsl:attribute name="onclick">
watchForChange('<xsl:value-of select="$varName"/>',document.getElementById('<xsl:value-of select="$varName"/>').value);showFullSearchChooser('<xsl:value-of select="string[@id='customChooser']/text()"/>&amp;fromChooser=true&amp;formName=full_search&amp;frameName=window&amp;fieldNameActual=hidden_<xsl:value-of select="$varName"/>&amp;fieldNameDisplay=<xsl:value-of select="$varName"/>&amp;showInitialResults=true<xsl:value-of select="$submitURL"/>',<xsl:value-of select="$varName"/>)</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
											<xsl:attribute name="onclick">FullSearch.showValuesHierarchy(this)</xsl:attribute>
											</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:if test="number and string[@id='value']">
										<xsl:attribute name="filter_name"><xsl:value-of select="$varName"/></xsl:attribute>
										<xsl:attribute name="filter_val"><xsl:value-of select="string/text()"/></xsl:attribute>
									</xsl:if>
									<xsl:if test="number and string[@id='type']">
										<xsl:attribute name="filter_name">type</xsl:attribute>
										<xsl:attribute name="filter_val"><xsl:value-of select="string/text()"/></xsl:attribute>
									</xsl:if>
									<xsl:if test="string and string[@id='attribute']">
										<xsl:attribute name="filter_name"><xsl:value-of select="string[@id='attribute']/text()"/></xsl:attribute>
									</xsl:if>
								</input>
									<xsl:choose>
										<xsl:when test="string[@id='disabled'] = 'true'">
										</xsl:when>
										<xsl:otherwise>
											<a>
												<xsl:if test="number and string[@id='value']">
													<xsl:attribute name="href">javascript:FullSearch.resetField('<xsl:value-of select="$varName"/>', '<xsl:value-of select="string[@id='defaultFieldValue']/text()" />, '<xsl:value-of select="string[@id='defaultDisplayValue']/text()" />')</xsl:attribute>
												</xsl:if>
												<xsl:if test="number and string[@id='type']">
													<xsl:attribute name="href">javascript:FullSearch.resetField('type', '<xsl:value-of select="string[@id='defaultFieldValue']/text()" />', '<xsl:value-of select="string[@id='defaultDisplayValue']/text()" />')</xsl:attribute>													
												</xsl:if>
												<xsl:if test="string and string[@id='attribute']">
													<xsl:attribute name="href">javascript:FullSearch.resetField('<xsl:value-of select="string[@id='attribute']/text()"/>', '<xsl:value-of select="string[@id='defaultFieldValue']/text()" />', '<xsl:value-of select="string[@id='defaultDisplayValue']/text()" />')</xsl:attribute>												
												</xsl:if>
												<span class="image-button">
												<img src="../common/images/iconActionRefresh.gif" border="0">
													<xsl:attribute name="title"><xsl:value-of select="string[@id = 'ResetFieldTitle']/text()"/></xsl:attribute>
												</img>
												</span>
											</a>
							</xsl:otherwise>
									</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</li>
			</xsl:if>
	</xsl:template>
	 	<!-- 
    ! utility template
    !-->
    <xsl:template name="replace-string">
	    <xsl:param name="text"/>
	    <xsl:param name="from"/>
	    <xsl:param name="to"/>
	
	    <xsl:choose>
	      <xsl:when test="contains($text, $from)">

	        <xsl:variable name="before" select="substring-before($text, $from)"/>
	        <xsl:variable name="after" select="substring-after($text, $from)"/>
	        <xsl:variable name="prefix" select="concat($before, $to)"/>

	        <xsl:value-of select="$before"/>
	        <xsl:value-of select="$to"/>
	        <xsl:call-template name="replace-string">
	          <xsl:with-param name="text" select="$after"/>
	          <xsl:with-param name="from" select="$from"/>
	          <xsl:with-param name="to" select="$to"/>
	        </xsl:call-template>
	      </xsl:when> 
	      <xsl:otherwise>
	        <xsl:value-of select="$text"/>  
	      </xsl:otherwise>
	    </xsl:choose>
	 </xsl:template>
</xsl:stylesheet>
