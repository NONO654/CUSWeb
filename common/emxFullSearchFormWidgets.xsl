<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="FNAME" select="/mxRoot/string[@id='fName']"/>
	<xsl:variable name="DATATYPE" select="/mxRoot/dataType"/>
	<xsl:variable name="OPERATOR" select="/mxRoot/string[@id='operator']"/>	
	<xsl:variable name="FIELDSEPARATOR" select="/mxRoot/string[@id='fieldSeparator']"/>
	<xsl:variable name="LEVELS" select="/mxRoot/number[@id='levels']"/>
	<xsl:variable name="formMode"></xsl:variable>
	<xsl:variable name="valueNodes" select="/mxRoot/object[@id='values']/object"/>
    <xsl:variable name="size" select="count($valueNodes)"/>
	<xsl:variable name="vaultOptions"
		select="/mxRoot/object[@id='vaultOptions']/object" />
	<xsl:variable name="isAutonomySearch"
		select="/mxRoot/string[@id='isAutonomySearch']" />
	<xsl:template match="/mxRoot">
	<div class="contents">
     <div class="head">
      <div class="content">
       <span class="title">
         <xsl:value-of select="string[@id='displayValue']/text()" />
       </span>
       <span class="actions">
	    <xsl:if test="string[@id='fieldSeparator']">
	     <button class="apply" id="applyBreadCrumbs" onclick="javascript:FullSearch.applyToBreadcrumbs('{$FNAME}','{$DATATYPE}','{$FIELDSEPARATOR}','{$LEVELS}','{string[@id='displayValue']/text()}')"/>&#160;
        </xsl:if>
   <button class="done" onclick="javascript:FullSearch.addInputToFilters('{$FNAME}','{$DATATYPE}','{$FIELDSEPARATOR}')"></button>&#160;<button class="cancel" onclick="javascript:FullSearch.removeFloatingDiv('{$FNAME}','{$FIELDSEPARATOR}')"></button>
       </span>
      </div>
    </div>
		<div class="body">
			<xsl:choose>
				<xsl:when test="$DATATYPE = 'timestamp' or $DATATYPE = 'real' or $DATATYPE = 'integer'">
					<xsl:call-template name="dateChooser"/>
				</xsl:when>
				<xsl:when test="string[@id='fieldSeparator']">
					<xsl:call-template name="complexField"/>
				</xsl:when>
				<xsl:otherwise>
					<ul>
						<xsl:if test="$FNAME = 'REVISION' and not($formMode = 'true')">
						<li>							
								<input type="checkbox" name="lastRevision_NavMode" id="lastRevision_NavMode" value="last" onclick="javascript:disableRevision('lastRevision_NavMode','latestRevision_NavMode')">
									<xsl:if test="string[@id = 'last']/text() = 'true'">
										<xsl:attribute name="checked">true</xsl:attribute>
									</xsl:if>															
									<xsl:attribute name="title"><xsl:value-of select="./string[@id = 'HighestTitle']/text()"/></xsl:attribute>
									<xsl:if test="(string[@id = 'last']/text() = 'true' or string[@id = 'latest']/text() = 'true') and (not(string[@id = 'defaultLastRev']/text() = 'true')) and string[@id = 'disabled']/text() = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
								</input>&#160;<xsl:value-of select="./string[@id = 'Highest']/text()"/>
						</li>
						<li>
								<input type="checkbox" name="latestRevision_NavMode" id="latestRevision_NavMode" value="latest" onclick="javascript:disableRevision('latestRevision_NavMode','lastRevision_NavMode')">									
									<xsl:if test="string[@id = 'latest']/text() = 'true'">
										<xsl:attribute name="checked">true</xsl:attribute>
									</xsl:if>								
									<xsl:attribute name="title"><xsl:value-of select="./string[@id = 'ByStateTitle']/text()"/></xsl:attribute>
									<xsl:if test="(string[@id = 'last']/text() = 'true' or string[@id = 'latest']/text() = 'true') and (not(string[@id = 'defaultLastRev']/text() = 'true')) and string[@id = 'disabled']/text() = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
								</input>&#160;<xsl:value-of select="./string[@id = 'ByState']/text()"/>
						</li>
						</xsl:if>
						<!-- modified for Mx361263 --> 
						<xsl:choose>
							<xsl:when test="$FNAME = 'VAULT' and $isAutonomySearch = 'false'">
							</xsl:when>
							<xsl:otherwise>
						<li><span class="input"><input type="text" name="input_{$FNAME}" id="input_{$FNAME}" value="">
							<xsl:if test="string[@id='minReqChars']">
								<xsl:attribute name="minReqChars"><xsl:value-of select="string[@id='minReqChars']/text()" /></xsl:attribute>
							</xsl:if>
			                <xsl:attribute name="onfocus">select()</xsl:attribute>
							<xsl:if test="$size > 0">
				                <xsl:attribute name="onkeyup">FullSearch.refineListBox(this);</xsl:attribute>
							</xsl:if>
							</input></span>
							</li>
							</xsl:otherwise>
						</xsl:choose>

						<!-- Mx361263 --> 
						<xsl:if test="$FNAME = 'VAULT' and $isAutonomySearch = 'false'">
							<li>
									<table>


										<xsl:for-each select="$vaultOptions">
											<tr>
												<td>
													<input type="radio" id="vaultOption" name="vaultSelction"
														value="{string[@id='value']/text()}">
														<xsl:choose>
															<xsl:when test="string[@id='value'] = 'SELECTED_VAULTS'">
																<xsl:attribute name="onClick">javascript:enableVaultSelectionList()</xsl:attribute>
																<xsl:attribute name="checked">checked</xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<xsl:attribute name="onClick">javascript:disableVaultSelectionList()</xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
													</input>
													<xsl:value-of select="string[@id='displayValue']/text()" />
												</td>
											</tr>
										</xsl:for-each>


									</table>
								</li>
						</xsl:if>
						<!-- Mx361263 end-->


						<xsl:if test="$size > 0">						
						<li><span class="input list"> 
						<xsl:call-template name="selectList"/></span></li>
						</xsl:if>
					</ul>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</div>
	</xsl:template>
	<!-- 
	Select List 
				-->
	<xsl:template name="selectList">
		<select name="{$FNAME}" id="select_{$FNAME}" multiple="yes">
            <xsl:choose>
              <xsl:when test="$size > 10">
                <xsl:attribute name="size">10</xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="size"><xsl:value-of select="$size"/></xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
			<xsl:for-each select="$valueNodes">
				<xsl:variable name="pos" select="position()"/>
				<option value="{string[@id='value']/text()}">
					<xsl:if test="string[@id='selected'] = 'true'">
						<xsl:attribute name="selected">selected</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="string[@id='displayValue']/text()"/>
                    <xsl:if test="../../string[@id='defaultunit']">
                        <xsl:value-of select="../../string[@id='defaultunit']/text()"/>
                    </xsl:if>
                    <xsl:if test="number[@id='count']">
    					(<xsl:value-of select="number[@id='count']/text()"/>)
                    </xsl:if>
				</option>
			</xsl:for-each>
		</select>
	</xsl:template>
	<!-- 
	Date Chooser 
					-->
	<xsl:template name="dateChooser">
		<ul>
			<li>
			<span class="input">
					<select name="{$FNAME}_operation" id="{$FNAME}_operation" onchange="javascript:FullSearch.enableToDateField(this,'{$FNAME}');">
						<xsl:choose>
							<xsl:when test="$DATATYPE = 'timestamp'">
								<option value="Equals">
									<xsl:if test="$OPERATOR = 'Equals'">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="string[@id='label-on']/text()"/>
								</option>
								<option value="Greater">
									<xsl:if test="$OPERATOR = 'Greater'">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="string[@id='label-on-or-after']/text()"/>
								</option>
								<option value="Less">
									<xsl:if test="$OPERATOR = 'Less'">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="string[@id='label-on-or-before']/text()"/>
								</option>
								<option value="Between">
									<xsl:if test="$OPERATOR = 'Between'">
										<xsl:attribute name="selected">selected</xsl:attribute>
									</xsl:if>
									<xsl:value-of select="string[@id='label-between']/text()"/>
								</option>
							</xsl:when>
							<xsl:otherwise>
								<option value="Equals">=</option>
								<option value="Greater">&gt;</option>
								<option value="Less">&lt;</option>
								<option value="Between">
									<xsl:value-of select="string[@id='label-between']/text()"/>
								</option>
							</xsl:otherwise>
						</xsl:choose>
					</select>
				  </span>
				</li>
				<xsl:if test="$DATATYPE = 'timestamp'">
					<li>
					<span class="input">
						<input name="{$FNAME}_fromvalue" id="{$FNAME}_fromvalue" value="{string[@id='fromvalue']/text()}" disabled="true"/>
					</span>
						<input type="hidden" name="{$FNAME}_fromvalue_msvalue" id="{$FNAME}_fromvalue_msvalue" value="{string[@id='frommsvalue']/text()}"/>
						<span class="image-button">
						<a href="javascript:showCalendar('full_search','{$FNAME}_fromvalue','{string[@id='fromvalue']/text()}')">
							<img border="0" src="images/iconSmallCalendar.gif" alt="Date Picker"/>
						</a>
						</span>
					</li>
				</xsl:if>
				<xsl:if test="$DATATYPE != 'timestamp'">
					<li>
						<span class="input">
						<input type="text" name="text_{$FNAME}" id="text_{$FNAME}"/><br/>
						<input type="text" name="text_to_{$FNAME}" id="text_to_{$FNAME}">
						  <xsl:if test="not($OPERATOR = 'Between')">
                              <xsl:attribute name="disabled">true</xsl:attribute>
                          </xsl:if>
						</input>
						</span>
					</li>
					<xsl:variable name="DEFAULT_UNIT" select="string[@id='defaultunit']"/>
					<xsl:if test="count(object[@id='uomList']/string) &gt; 0">
						<li>
						<span class="input">
							<select name="{$FNAME}_uom" id="{$FNAME}_uom" size="1">
								<xsl:for-each select="object[@id='uomList']/string">
									<option value="{text()}">
										<xsl:if test="text() = $DEFAULT_UNIT/text()">
											<xsl:attribute name="selected">selected</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="text()"/>
									</option>
								</xsl:for-each>
							</select>
							</span>
						</li>
					</xsl:if>
				</xsl:if>
				<li>
					<xsl:if test="$DATATYPE = 'timestamp'">
					<span class="input">
						<input name="{$FNAME}_tovalue" id="{$FNAME}_tovalue" value="{string[@id='tovalue']/text()}" disabled="true"/>
					</span>
						<input type="hidden" name="{$FNAME}_tovalue_msvalue" id="{$FNAME}_tovalue_msvalue"  value="{string[@id='tomsvalue']/text()}"/>
					<span class="image-button">
						<a id="{$FNAME}_tovalue_cal" href="javascript:;">
				            <xsl:choose>
								<xsl:when test="$OPERATOR = 'Between'">
									<xsl:attribute name="href">javascript:showCalendar('full_search','<xsl:value-of select="$FNAME"/>_tovalue','<xsl:value-of select="string[@id='tovalue']/text()"/>')</xsl:attribute>
								</xsl:when>
				              	<xsl:otherwise>
									<xsl:attribute name="href">javascript:;</xsl:attribute>
								</xsl:otherwise>
				            </xsl:choose>

							<img id="{$FNAME}_tovalue_cal_img" border="0" alt="Date Picker" src="">
								<xsl:choose>
								  <xsl:when test="$OPERATOR = 'Between'">
									<xsl:attribute name="src">images/iconSmallCalendar.gif</xsl:attribute>
								  </xsl:when>
								  <xsl:otherwise>
									<xsl:attribute name="src">images/iconSmallCalendarDisabled.gif</xsl:attribute>
								  </xsl:otherwise>
								</xsl:choose>
				            </img>
						</a>
						</span>
					</xsl:if>
				</li>
		</ul>
	</xsl:template>
	<xsl:template name="complexField">
		<div id="complex_{$FNAME}" name ="complex_{$FNAME}" />
	</xsl:template>
	<!-- 
	default template 
						-->
	<xsl:template match="@*|*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
