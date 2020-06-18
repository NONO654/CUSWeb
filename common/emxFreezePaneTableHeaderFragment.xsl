<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
       <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
        <xsl:variable name="split" select="/mxRoot/setting[@name='split']"/>
        <xsl:variable name="compare" select="/mxRoot/requestMap/setting[@name='IsStructureCompare']" />
        <xsl:variable name="tableHeadClass" select="/mxRoot/requestMap/setting[@name='tableHeadClass']" />
		 <xsl:variable name="isUnix" select="/mxRoot/setting[@name='isUnix']"/>
		 <xsl:variable name="isIE" select="/mxRoot/setting[@name='isIE']"/>    	        
         <xsl:variable name="isMobile" select="/mxRoot/setting[@name='isMobile']"/>
         <xsl:variable name="isPCTouch" select="/mxRoot/setting[@name='isPCTouch']"/>
         <xsl:variable name="sizerWidth">
            <xsl:choose>
                <xsl:when test="($isMobile = 'true') or ($isPCTouch = 'true')">20</xsl:when>
                <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
         </xsl:variable>          
		 <xsl:variable name="sbMode" select="/mxRoot/setting[@name='sbMode']"/>
		 <xsl:variable name="uiAutomation" select="/mxRoot/requestMap/setting[@name='uiAutomation']"/>
         <xsl:variable name="dbTableName" select="/mxRoot/requestMap/setting[@name='selectedTable']"/>
       <xsl:variable name="reportType">
	      	<xsl:if test="/mxRoot/requestMap/setting[@name='IsStructureCompare'] = 'TRUE'">                                                    
	            <xsl:value-of select="/mxRoot/requestMap/setting[@name='reportType']" />                                                
	        </xsl:if>
       </xsl:variable>
	<xsl:variable name="toggle">
         	<xsl:choose>
                  	<xsl:when test="/mxRoot/requestMap/setting[@name='toggle']">                                                    
                        <xsl:text>2</xsl:text>                                                  
                    </xsl:when>                                                   
                    <xsl:otherwise>                                                    
                       <xsl:text>1</xsl:text>                                                    
                    </xsl:otherwise>                                                  
           </xsl:choose>                                           
    </xsl:variable>
    <xsl:template match="/mxRoot">
           <xsl:call-template name="tableBody"/>
    </xsl:template>
    <xsl:template name="tableBody">
           <xsl:apply-templates select="columns">
                  <xsl:with-param name="tblName" select="'headTable'"/>
                  <xsl:with-param name="path" select="columns/column[position() &gt; $split]"/>
           </xsl:apply-templates>
    </xsl:template>    		 
	<xsl:template match="columns">
		<xsl:param name="tblName" select="'headTable'"/>
		<xsl:param name="path" select="column[position() &gt; $split]"/>
		<table width="100%" border="0" id="{$tblName}">
		    <xsl:if test="/mxRoot/requestMap/setting[@name = 'tableHeadClass']">
		    	<xsl:attribute name="class"><xsl:value-of select="$tableHeadClass"/></xsl:attribute>
		    </xsl:if>
			<xsl:if test="$uiAutomation = 'true' ">
		    	<xsl:attribute name="data-aid"><xsl:value-of select="$dbTableName"/></xsl:attribute>
		    </xsl:if>
			<tr class="mx_hidden-row">
				<xsl:apply-templates select="//mxRoot/columns/column" mode="hiddenrowtag"/>
			</tr>
			<xsl:if test="/mxRoot/tableControlMap/setting[@name='HasGroupHeader']/value = 'true'">
				<tr class="mx_group-header">
					<xsl:apply-templates select="$path" mode="rulebottom">
						<xsl:with-param name="tblName" select="$tblName"/>
					</xsl:apply-templates>
				</tr>
			</xsl:if>			
			<tr>
				<!-- First Row of Header -->			
				<xsl:apply-templates select="$path">
					<xsl:with-param name="tblName" select="$tblName"/>
					<xsl:with-param name="rowNumber" select="'1'"/>
				</xsl:apply-templates>
			</tr>
			<!-- Second Row of Header -->
			<xsl:if test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
				<tr>
					<xsl:apply-templates select="$path">
						<xsl:with-param name="tblName" select="$tblName"/>
						<xsl:with-param name="rowNumber" select="'2'"/>
					</xsl:apply-templates>
				</tr>
			</xsl:if>
		</table>
	</xsl:template>

	<xsl:template match="column" mode="rulebottom">
	<xsl:param name="tblName" select="."/>
	<xsl:variable name="currentText" select="settings/setting[@name='Group Header']/text()"/>
	<xsl:variable name="currentPosition" select="position()"/>	
    <xsl:variable name="displayMode">
            <xsl:choose>
                    <xsl:when test="settings/setting[@name='Display Mode']">                                                    
                        <xsl:value-of select="settings/setting[@name='Display Mode']"/>                                                  
                    </xsl:when>                                                   
                    <xsl:otherwise>                                                    
                       <xsl:text>Both</xsl:text>                                                    
                    </xsl:otherwise>                                                  
           </xsl:choose>                                           
    </xsl:variable>
    <xsl:if test="($displayMode = 'Both' or $displayMode = $sbMode)">
	<xsl:if test="settings/setting[@name='Row Number']='1'">
		<xsl:choose>
			<xsl:when test="settings/setting/@name='Group Header'">	
					<xsl:if test="settings/setting/@name='Group Header' and settings/setting[@name='Col Span']/text() != '0'">
						<td class="mx_group-header">
						   <xsl:if test="number((settings/setting[@name='Col Span']/text())*2) &gt; 1">
		                     <xsl:attribute name="colspan">
				                 <xsl:value-of select="(settings/setting[@name='Col Span']/text())*2"/>
		                	  </xsl:attribute>
		                   </xsl:if>
							<xsl:value-of select="$currentText" />
						</td>
					</xsl:if>				
			</xsl:when>
			<xsl:otherwise>
				<td>&#160;</td>
				<td/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
	</xsl:if>
	</xsl:template>	

	<xsl:template match="column">
		<xsl:param name="tblName" select="."/>
		<xsl:param name="rowNumber" select="."/>
		<xsl:variable name="varFieldType" select="settings/setting[@name = 'Column Type']"/>
		<xsl:variable name="compareBy" select="string(@compareBy)"/>
		<xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
		<xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
		<xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)"/>
		<xsl:variable name="settingRowNumber" select="settings/setting[@name='Row Number']"/>
		<xsl:variable name="settingRowSpan" select="settings/setting[@name='Row Span']"/>
		<xsl:variable name="settingColumnSpan" select="settings/setting[@name='Column Span']"/>
		<xsl:variable name="colName" select="string(@name)"/>
		<xsl:variable name="alt" select="settings/setting[@name='alt']"/>
		<xsl:variable name="preserveSpacesCss">
            <xsl:choose>
                   <xsl:when test="settings/setting[@name='Preserve Spaces']='true' or settings/setting[@name='Preserve Spaces']='TRUE'">
                   		<xsl:text>verbatim</xsl:text>
                   </xsl:when>
                   <xsl:otherwise>
                   		<xsl:text></xsl:text>    
                   </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
	    <xsl:variable name="displayMode">
            <xsl:choose>
                    <xsl:when test="settings/setting[@name='Display Mode']">                                                    
                        <xsl:value-of select="settings/setting[@name='Display Mode']"/>                                                  
                    </xsl:when>                                                   
                    <xsl:otherwise>                                                    
                       <xsl:text>Both</xsl:text>                                                    
                    </xsl:otherwise>                                                  
           </xsl:choose>                                           
        </xsl:variable>
	    <xsl:if test="($displayMode = 'Both' or $displayMode = $sbMode)">
		<xsl:if test="$rowNumber = '2' and settings/setting[@name='BlankCell'] = 'true'">
			<th style="border-top: 2px solid white; height: 27;">&#160;</th>
		
			 <th class="mx_sizer" style="border-top: 2px solid white; height: 27;"> 
			
				<!-- img src="../images/utilSpacer.gif" width="2"/ -->
			</th>
		</xsl:if>
	<xsl:if test="($settingRowNumber/text() = $rowNumber)">
		<th id="{@name}">
			<xsl:if test="$uiAutomation = 'true' ">
		    	<xsl:attribute name="data-aid"><xsl:value-of select="$colName"/></xsl:attribute>
		    </xsl:if>
		<xsl:if test="number($settingRowSpan) &gt; 1">
			<xsl:attribute name="rowspan">
				<xsl:value-of select="$settingRowSpan"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="number($settingColumnSpan) &gt; 1">
			<xsl:attribute name="colspan">
				<xsl:value-of select="$settingColumnSpan"/>
			</xsl:attribute>
		</xsl:if>
			<xsl:if test="settings/setting[@name='Row Number']/text() = '2'">
				<xsl:attribute name="style">border-top: 2px solid white; height: 27;</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="settings/setting[@name='Row Span']/text() = '2'">
				<xsl:choose>
					<xsl:when test="$isIE = 'true'">
						<xsl:attribute name="style">height: 52px;</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="style">height: 50px;</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		
			<xsl:if test="settings/setting[@name='Editable']='true' or settings/setting[@name='Input Type']">
				<xsl:attribute name="class">mx_editable <xsl:if test="settings/setting[@name='Required']='true'"> mx_required</xsl:if></xsl:attribute>
			</xsl:if>
			<xsl:if test="$compareBy = 'false'">
				<xsl:attribute name="class">mx_no-compare-column</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@type='separator'">
					<xsl:attribute name="class">mx_separator</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<table>
						<tr>
							<!-- The check box for checking all -->
							<xsl:choose>
								<xsl:when test="$tblName = 'treeHeadTable'">
									<xsl:if test="/mxRoot/requestMap/setting[@name = 'selection'] = 'multiple' and position() = $toggle">
										<td height="25">
											<input type="checkbox" class="small" name="chkList" onclick="setCheckboxStatus(this)">
												<xsl:if test="/mxRoot/setting[@name = 'allRowSelected']= 'true'">
													<xsl:attribute name="checked">checked</xsl:attribute>	
									            </xsl:if>
											</input>
										</td>
									</xsl:if>
								</xsl:when>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="$Field_Type = 'image'">
									<td>
										<img src="images/iconColHeadImage.gif" align="absmiddle" border="0" title="{$alt}"/>
									</td>
								</xsl:when>
							
								<xsl:when test="$Field_Type='checkbox' and not(settings/setting[@name='True Image'])">
								<td>
									<input type="checkbox" class="small" name="chkList" onclick="setCheckboxStatus(this, true)"/>
								</td>
								</xsl:when>
							
								<xsl:when test="@type='File'">
									<td>
										<img src="images/iconSmallPaperclipVerticalR.gif" align="absmiddle" border="0" title="{$alt}"/>
									</td>
								</xsl:when>
								<xsl:when test="contains(@label,'img') and contains(@label,'src')">
									<td id="{@name}">
									 <xsl:attribute name="title"><xsl:value-of select="settings/setting[@name='alt']" /></xsl:attribute>
		                              <xsl:attribute name="width"><xsl:value-of select="settings/setting[@name='lblWidth']" /></xsl:attribute>
										<xsl:variable name="columnIndex">
											<xsl:choose>
												<xsl:when test="$tblName ='headTable'">
													<xsl:value-of select="position()+$split"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="position()"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="settings/setting[@name='Sortable'] != 'false'">
												<a href="javascript:sortTable({$columnIndex})">
													<xsl:copy-of select="imageHeader/node()" />
												</a>
											</xsl:when>
											<xsl:otherwise>
												<xsl:copy-of select="imageHeader/node()" />
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:when>
								<xsl:when test="contains(@label,'nbsp')">
									<td>&#160;</td>
								</xsl:when>
								<xsl:otherwise>
									<td id="{@name}">
		                            <xsl:attribute name="width"><xsl:value-of select="settings/setting[@name='lblWidth']" /></xsl:attribute>
		                             <xsl:if test="not($preserveSpacesCss = '')">
                    						<xsl:attribute name="class"><xsl:value-of select="$preserveSpacesCss"/></xsl:attribute>
                    				 </xsl:if>
			                          <xsl:if test="settings/setting[@name='Sortable'] != 'false'">
											<xsl:choose>
												<xsl:when test="settings/setting[@name='Editable']='true' and settings/setting[@name='Input Type']">
													<xsl:attribute name="class">mx_editable mx_sort-column <xsl:value-of select="$preserveSpacesCss"/></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="class">mx_sort-column <xsl:value-of select="$preserveSpacesCss"/></xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:if>
										<xsl:variable name="columnIndex">
											<xsl:choose>
												<xsl:when test="$tblName ='headTable'">
													<xsl:value-of select="position()+$split"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="position()"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="settings/setting[@name='Sortable'] = 'false'">
												<span><xsl:value-of select="@label"/></span>
											</xsl:when>
											<xsl:when test="$compare = 'TRUE'">
												<span><xsl:value-of select="@label"/></span>
											</xsl:when>
											<xsl:otherwise>
												<a href="javascript:sortTable({$columnIndex})">													
												<!--  	<xsl:choose>
														<xsl:when test="@label ='images/iconRetainedSearch.gif'">
															<img src="images/iconRetainedSearch.gif" align="middle" border="0"/>															
														</xsl:when>
														<xsl:otherwise> -->
															<xsl:value-of select="@label"/>	
														<!--  </xsl:otherwise>
												  </xsl:choose>	-->											
												</a>
											</xsl:otherwise>
										</xsl:choose>
									</td>
										<xsl:if test="not(settings/setting[@name='Sortable'] = 'false')">
										<td id="{@name}_sort">
                                          <xsl:attribute name="width"><xsl:value-of select="settings/setting[@name='sortWidth']" /></xsl:attribute> 										
										</td>
										</xsl:if>
									<xsl:if test="not(settings/setting[@name='Auto Filter'] = 'false')">
										<td id="{@name}_filter">
                                         <xsl:attribute name="width"><xsl:value-of select="settings/setting[@name='filterWidth']" /></xsl:attribute> 										
                                         </td>
                                         </xsl:if>
								</xsl:otherwise>
							</xsl:choose>
						</tr>
					</table>
				</xsl:otherwise>
			</xsl:choose>
		</th>
		<th>
			<xsl:if test="@type!= 'separator'">
				<xsl:attribute name="class">mx_sizer</xsl:attribute>
			</xsl:if>
		<xsl:if test="number($settingRowSpan) &gt; 1">
			<xsl:attribute name="rowspan">
				<xsl:value-of select="$settingRowSpan"/>
			</xsl:attribute>
		</xsl:if>
			<!-- img src="images/utilSpacer.gif" width="2"/ -->
		</th>
	</xsl:if>
	</xsl:if>
	</xsl:template>

	<xsl:template match="column" mode="hiddenrowtag">
		<xsl:variable name="cellIndex" select="position()"/>
		<xsl:variable name="rowNumber" select="settings/setting[@name = 'Row Number']"/>
		<xsl:variable name="addToHiddenRow" select="settings/setting[@name = 'Add To Hidden Row']"/>
        <xsl:variable name="displayMode">
            <xsl:choose>
                    <xsl:when test="settings/setting[@name='Display Mode']">                                                    
                        <xsl:value-of select="settings/setting[@name='Display Mode']"/>                                                  
                    </xsl:when>                                                   
                    <xsl:otherwise>                                                    
                       <xsl:text>Both</xsl:text>                                                    
                    </xsl:otherwise>                                                  
           </xsl:choose>                                           
        </xsl:variable>

        <xsl:if test="($displayMode = 'Both' or $displayMode = $sbMode)">
		<xsl:if test="$cellIndex &gt; $split and ($rowNumber = '1' or $addToHiddenRow = 'true')">
			<td id="ROW_{$cellIndex}">
				<xsl:attribute name="width">
					<xsl:choose>
						<xsl:when test="@type='separator'">6</xsl:when>
						<xsl:when test="@type='File'">25</xsl:when>
						<xsl:when test="@type='icon'">25</xsl:when>						
						<xsl:when test="settings/setting[@name='Width']">
							<xsl:value-of select="settings/setting[@name='Width']"/>
						</xsl:when>
						<!--  Commented for BUG:381723 <xsl:when test="(string-length(@name)*12) &gt; 205">205</xsl:when>   -->						
						<xsl:when test="$compare = 'TRUE' and $cellIndex = 1+$split and ($reportType = 'Complete_Summary_Report' or $reportType = 'Difference_Only_Report' or $reportType = 'Common_Report')">200</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="(string-length(@label)*15)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</td>
      <td width="{$sizerWidth}"/>
		</xsl:if>
		</xsl:if>
	</xsl:template>	
</xsl:stylesheet>
