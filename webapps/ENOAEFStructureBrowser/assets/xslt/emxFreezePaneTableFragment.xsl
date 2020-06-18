<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8"
		indent="yes" />
	<xsl:variable name="lcletters">
		abcdefghijklmnopqrstuvwxyz
	</xsl:variable>
	<xsl:variable name="ucletters">
		ABCDEFGHIJKLMNOPQRSTUVWXYZ
	</xsl:variable>
	<xsl:variable name="split" select="/mxRoot/setting[@name='split']" />
	<xsl:variable name="isFromCtxSearch" select="/mxRoot/requestMap/setting[@name='fromCtxSearch']"/>
	<xsl:variable name="rowHeight" select="/mxRoot/setting[@name='rowHeight']" />
	<xsl:variable name="compare"
		select="/mxRoot/requestMap/setting[@name='IsStructureCompare']" />
	<xsl:variable name="uiAutomation"
		select="/mxRoot/requestMap/setting[@name='uiAutomation']" />
	<xsl:variable name="dbTableName"
		select="/mxRoot/requestMap/setting[@name='selectedTable']" />
	<xsl:variable name="sbMode" select="/mxRoot/setting[@name='sbMode']" />
	<xsl:variable name="reportType">
		<xsl:if
			test="/mxRoot/requestMap/setting[@name='IsStructureCompare'] = 'TRUE'">
			<xsl:value-of select="/mxRoot/requestMap/setting[@name='reportType']" />
		</xsl:if>
	</xsl:variable>

	<xsl:key name="displayedColumns"
		match="/mxRoot/columns/column[position() &gt; /mxRoot/setting[@name='split'] and ( not(settings/setting[@name='Display Mode']) or settings/setting[@name='Display Mode'] = /mxRoot/setting[@name='sbMode'] )]"
		use="@index" />

	<xsl:template match="/mxRoot">
		<xsl:call-template name="tableBody" />
	</xsl:template>
	<!-- COLUMN RULES -->
	<xsl:template match="column" mode="ruletop">
		<xsl:variable name="displayMode">
			<xsl:choose>
				<xsl:when test="settings/setting[@name = 'Display Mode']">
					<xsl:value-of select="settings/setting[@name='Display Mode']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Both</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">
			<td>
				<xsl:choose>
					<xsl:when test="@type = 'separator'">
						<xsl:attribute name="class">mx_separator</xsl:attribute>
					</xsl:when>
					<xsl:when test="@type = 'File'">
						<xsl:attribute name="width">25</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="width"><xsl:choose><xsl:when
							test="settings/setting[@name='Width']"><xsl:value-of select="settings/setting[@name='Width']" /></xsl:when><xsl:when
							test="(string-length(@label)*15) &gt; 205">205</xsl:when><xsl:otherwise><xsl:value-of
							select="(string-length(@label)*15)" /></xsl:otherwise></xsl:choose></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template match="column" mode="rulemiddle">
		<xsl:variable name="displayMode">
			<xsl:choose>
				<xsl:when test="settings/setting[@name = 'Display Mode']">
					<xsl:value-of select="settings/setting[@name='Display Mode']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Both</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">

			<xsl:choose>
				<xsl:when test="settings/setting/@name='Group Header'">
					<xsl:if
						test="settings/setting[@name='Group Header'][not(text()=preceding::setting)]">
						<xsl:variable name="currentText"
							select="settings/setting[@name='Group Header']/text()" />
						<th class="mx_group-header" height="5">
							<xsl:if
								test="number(count(//setting[@name='Group Header'][$currentText = text()])*2) &gt; 1">
								<xsl:attribute name="colspan">
				                            <xsl:value-of
									select="count(//setting[@name='Group Header'][$currentText = text()])*2" />
		                	              </xsl:attribute>
							</xsl:if>
							<table>
								<tr class="rule">
									<th height="1" />
								</tr>
							</table>
						</th>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<!-- height is 5 here because of "rule" rendering in IE. Value of 1 
						only works in Moz -->
					<!-- LINEUP -->
					<th class="mx_group-header" height="5" />
					<th class="mx_group-header" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template match="column" mode="rulebottom">
		<xsl:variable name="displayMode">
			<xsl:choose>
				<xsl:when test="settings/setting[@name = 'Display Mode']">
					<xsl:value-of select="settings/setting[@name='Display Mode']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Both</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">

			<xsl:choose>
				<xsl:when test="settings/setting/@name='Group Header'">
					<xsl:if
						test="settings/setting[@name='Group Header'][not(text()=preceding::setting)]">
						<xsl:variable name="currentText"
							select="settings/setting[@name='Group Header']/text()" />
						<th class="mx_group-header">
							<xsl:if
								test="number(count(//setting[@name='Group Header'][$currentText = text()])*2) &gt; 1">
								<xsl:attribute name="colspan">
				                            <xsl:value-of
									select="count(//setting[@name='Group Header'][$currentText = text()])*2" />
		                	              </xsl:attribute>
							</xsl:if>
							<xsl:value-of select="settings/setting[@name='Group Header']/text()" />
						</th>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<!-- height -->
					<th height="20">&#160;</th>
					<th />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template match="column">
		<xsl:param name="tblName" select="." />
		<xsl:variable name="displayMode">
			<xsl:choose>
				<xsl:when test="settings/setting[@name = 'Display Mode']">
					<xsl:value-of select="settings/setting[@name='Display Mode']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Both</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="preserveSpacesCss">
			<xsl:choose>
				<xsl:when
					test="settings/setting[@name='Preserve Spaces']='true' or settings/setting[@name='Preserve Spaces']='TRUE'">
					<xsl:text>verbatim</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">


			<td id="{@name}">
				<xsl:if
					test="settings/setting[@name='Editable']='true' and settings/setting[@name='Input Type']">
					<xsl:choose>
						<xsl:when test="settings/setting[@name='Required']='true'">
							<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
								select="$preserveSpacesCss" /></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">mx_editable <xsl:value-of
								select="$preserveSpacesCss" /></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<table>
					<tr>
						<xsl:choose>
							<xsl:when test="contains(@label,'img') and contains(@label,'src')">
								<th id="{@name}">
									<xsl:copy-of select="imageHeader/node()" />
								</th>
							</xsl:when>
							<xsl:when test="@type='separator'">
								<td class="mx_separator">&#160;</td>
							</xsl:when>
							<xsl:when test="contains(@label,'nbsp')">
								<th>&#160;</th>
							</xsl:when>
							<xsl:otherwise>
								<th id="{@name}">
									<xsl:variable name="columnIndex">
										<xsl:choose>
											<xsl:when test="$tblName ='headTable'">
												<xsl:value-of select="position()+1" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="position()" />
											</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="settings/setting[@name='Sortable'] = 'false'">
											<xsl:value-of select="@label" />
										</xsl:when>
										<xsl:otherwise>
											<a href="javascript:sortTable({$columnIndex})">
												<xsl:value-of select="@label" />
											</a>
										</xsl:otherwise>
									</xsl:choose>
								</th>
							</xsl:otherwise>
						</xsl:choose>
						<!-- <th width="100%">&#160;</th> -->
					</tr>
				</table>
			</td>
			<!-- <td class="mx_sizer" width="2"/> -->
		</xsl:if>
	</xsl:template>
	<!-- END COLUMN RULES -->
	<!-- TABLE BODY -->
	<xsl:template name="tableBody">
		<xsl:apply-templates select="columns" mode="body">
			<xsl:with-param name="tblName" select="'bodyTable'" />
			<xsl:with-param name="path"
				select="columns/column[position() &gt; $split]" />
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="column" mode="hiddenrowtag">
		<xsl:variable name="displayMode">
			<xsl:choose>
				<xsl:when test="settings/setting[@name = 'Display Mode']">
					<xsl:value-of select="settings/setting[@name='Display Mode']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Both</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">
			<xsl:variable name="cellIndex" select="position()" />
			<xsl:variable name="rowNumber"
				select="settings/setting[@name = 'Row Number']" />
			<xsl:variable name="addToHiddenRow"
				select="settings/setting[@name = 'Add To Hidden Row']" />
			<xsl:if
				test="$cellIndex &gt; $split and ($rowNumber = '1' or $addToHiddenRow = 'true')">
				<td id="ROW_{$cellIndex}">
					<xsl:attribute name="width">
                                   <xsl:choose>
                                          <xsl:when test="@type='separator'">6</xsl:when>
                                          <xsl:when test="@type='File'">27</xsl:when>
                                          <xsl:when
						test="settings/setting[@name='Width']">
                                                 <xsl:value-of
						select="settings/setting[@name='Width'] + 2" /> 
                                          </xsl:when>
                                          <xsl:when
						test="(string-length(@label)*15) &gt; 205">205</xsl:when>
                                          <xsl:when
						test="$compare = 'TRUE' and $cellIndex = 1+$split and ($reportType = 'Complete_Summary_Report' or $reportType = 'Difference_Only_Report' or $reportType = 'Common_Report')">200</xsl:when>
                                          <xsl:otherwise>
                                                 <xsl:value-of
						select="(string-length(@label)*15)" />
                                          </xsl:otherwise>
                                   </xsl:choose>
                            </xsl:attribute>
				</td>
				<!--<th width="2" class="mx_hidden-row"/> -->
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template match="columns" mode="body">
		<xsl:param name="tblName" select="bodyTable" />
		<xsl:param name="path" select="column" />
		<table id="{$tblName}">
			<xsl:if test="$uiAutomation = 'true' ">
				<xsl:attribute name="data-aid"><xsl:value-of select="$dbTableName" /></xsl:attribute>
			</xsl:if>
			<!-- <tbody> -->
			<tr class="mx_hidden-row">
				<xsl:apply-templates select="//mxRoot/columns/column"
					mode="hiddenrowtag" />
			</tr>
			<xsl:if
				test="not(//r) or /mxRoot/setting[@name='numberOfObjectsFiltered']/text() = '0'">
				<tr>
					<td align="center">
						<xsl:if test="number(count($path)*2) &gt; 1">
							<xsl:attribute name="colspan">
				                            <xsl:value-of select="count($path)*2" />
		                	              </xsl:attribute>
						</xsl:if>
						<xsl:value-of
							select="/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='NoObjectsFound']/value" />
					</td>
				</tr>
			</xsl:if>
			<xsl:if test="/mxRoot/setting[@name='first-row']/text() &gt; '0'">
				<tr height="{/mxRoot/setting[@name='tophiddenHeight']}">
					<td align="center" class="bgPattern">
						<xsl:if test="number(count($path)*2) &gt; 1">
							<xsl:attribute name="colspan">
				                            <xsl:value-of select="count($path)*2" />
		                	              </xsl:attribute>
						</xsl:if>
					</td>
				</tr>
			</xsl:if>
			<!-- <xsl:apply-templates select="/mxRoot/rows/r[position() &gt;= /mxRoot/setting[@name='first-row'] 
				and position() &lt;= /mxRoot/setting[@name='first-row'] + /mxRoot/setting[@name='page-size']]"> 
				<xsl:apply-templates select="/mxRoot/rows//r[(@level = '0' or count(ancestor::r[not(@display) 
				or @display = 'none']) = '0') and position() >= /mxRoot/setting[@name='first-row'] 
				and position() &lt;= /mxRoot/setting[@name='first-row'] + /mxRoot/setting[@name='page-size']]"> -->
			<xsl:apply-templates select="/mxRoot/rows/r">
				<xsl:with-param name="tblName" select="$tblName" />
			</xsl:apply-templates>
			<xsl:if
				test="(/mxRoot/setting[@name='total-rows']/text() - (/mxRoot/setting[@name='first-row']/text() + /mxRoot/setting[@name='page-size']/text()))  &gt; '0'">
				<tr height="{/mxRoot/setting[@name='bottomhiddenHeight']}">
					<td align="center" class="bgPattern">
						<xsl:if test="number(count($path)*2) &gt; 1">
							<xsl:attribute name="colspan">
				                            <xsl:value-of select="count($path)*2" />
		                	              </xsl:attribute>
						</xsl:if>
					</td>
				</tr>
			</xsl:if>
			<!-- </tbody> -->
		</table>
	</xsl:template>
	<xsl:template match="column" mode="body">
		<xsl:variable name="displayMode">
			<xsl:choose>
				<xsl:when test="settings/setting[@name = 'Display Mode']">
					<xsl:value-of select="settings/setting[@name='Display Mode']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Both</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">

			<th height="18">
				<xsl:choose>
					<xsl:when test="@type='separator'">
						<xsl:attribute name="class">mx_separator</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="width"><xsl:choose><xsl:when
							test="settings/setting[@name='Width']"><xsl:value-of select="settings/setting[@name='Width']" /></xsl:when><xsl:when
							test="(string-length(@label)*15) &gt; 205">205</xsl:when><xsl:otherwise><xsl:value-of
							select="(string-length(@label)*15)" /></xsl:otherwise></xsl:choose></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</th>
			<!-- <td class="mx_sizer" width="2"/> -->
		</xsl:if>
	</xsl:template>
	<!-- ROWS -->
	<xsl:template match="r">
		<xsl:param name="tblName" select="." />
		<xsl:variable name="oid" select="string(@o)" />
		<xsl:variable name="relId" select="string(@r)" />
		<xsl:variable name="id" select="string(@id)" />
		<xsl:variable name="rg" select="string(@rg)" />
		<xsl:variable name="filter" select="string(@filter)" />
		<xsl:variable name="displayRow" select="string(@displayRow)" />
		<xsl:variable name="checked" select="string(@checked)" />
		<xsl:variable name="error" select="string(@e)" />
		<xsl:variable name="status" select="@status" />
		<xsl:variable name="navigated" select="string(@navigated)" /> <!-- Added for Step through changes -->
		<xsl:variable name="css-class">
			<xsl:choose>
				<xsl:when test="position() mod 2 = 0">
					mx_altRow
				</xsl:when>
				<xsl:otherwise>
					even
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="height">
			<xsl:choose>
	<!-- 		<xsl:when test="/mxRoot/requestMap/setting[@name='cellwrap'] = 'false'">
					<xsl:text> </xsl:text>
				</xsl:when>	-->
				<xsl:when test="@height">
					<xsl:value-of select="string(@height)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>25</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="height_row2">
			<xsl:choose>
				<xsl:when test="$rg">
					<xsl:text>0</xsl:text>
				</xsl:when>
		<!--	<xsl:when test="/mxRoot/requestMap/setting[@name='cellwrap'] = 'false'">
					<xsl:text> </xsl:text>
				</xsl:when>  -->
				<xsl:when test="@height_row2">
					<xsl:value-of select="string(@height_row2)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>25</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="objectName" select="./node()/@a" />
		<xsl:if test="not($displayRow = 'false')">
			<xsl:if test="not($filter = 'true')">
				<tr id="{$id}" o="{$oid}" r="{$relId}" height="{$height}">
					<xsl:if test="$uiAutomation = 'true' ">
						<xsl:attribute name="data-aid"><xsl:value-of
							select="$objectName" /></xsl:attribute>
					</xsl:if>
					<xsl:if test="ancestor::node()[@display = 'none']">
						<xsl:attribute name="style">display:none</xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$error">
							<xsl:attribute name="class">error</xsl:attribute>
						</xsl:when>
						<xsl:when test="$rg">
							<xsl:attribute name="class"><xsl:value-of
								select="$rg" /> heading</xsl:attribute>
						</xsl:when>
						<xsl:when test="$checked = 'checked'">
							<xsl:attribute name="class"><xsl:value-of
								select="$css-class" /> mx_rowSelected</xsl:attribute>
							<xsl:if test="@level='0'">
								<xsl:attribute name="class"><xsl:value-of
									select="$css-class" /> root-node mx_rowSelected</xsl:attribute>
							</xsl:if>
						</xsl:when>
						
						<!-- Added for step through changes -->
						<xsl:when test="$navigated = 'true' and $compare = 'TRUE'">
							<xsl:attribute name="class"><xsl:value-of
								select="$css-class" /> mx_rowHighlight</xsl:attribute>
							<xsl:if test="@level='0'">
								<xsl:attribute name="class"><xsl:value-of
									select="$css-class" /> root-node mx_rowHighlight</xsl:attribute>
							</xsl:if>
						</xsl:when>
						
						<xsl:when test="@level='0'">
							<xsl:attribute name="class">root-node <xsl:value-of
								select="$css-class" /></xsl:attribute>
							<xsl:if test="$checked = 'checked'">
								<xsl:attribute name="class">root-node mx_rowSelected</xsl:attribute>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class"><xsl:value-of
								select="$css-class" /></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:apply-templates select="c[key('displayedColumns', @index)]"
						mode="right">
						<xsl:with-param name="rowNumber" select="'1'" />
					</xsl:apply-templates>
				</tr>

				<xsl:if
					test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
					<tr id="{$id}" o="{$oid}" r="{$relId}" height="{$height_row2}">
						<xsl:if test="$uiAutomation = 'true' ">
							<xsl:attribute name="data-aid"><xsl:value-of
								select="$objectName" /></xsl:attribute>
						</xsl:if>
						<xsl:if test="ancestor::node()[@display = 'none']">
							<xsl:attribute name="style">display:none</xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$error">
								<xsl:attribute name="class">error</xsl:attribute>
							</xsl:when>
							<xsl:when test="$checked = 'checked'">
								<xsl:attribute name="class">mx_rowSelected</xsl:attribute>
								<xsl:if test="@level='0'">
									<xsl:attribute name="class">root-node mx_rowSelected</xsl:attribute>
								</xsl:if>
							</xsl:when>
							
							<!-- Added for step through changes -->
							<xsl:when test="$navigated = 'true' and $compare = 'TRUE'">
								<xsl:attribute name="class">mx_rowHighlight</xsl:attribute>
								<xsl:if test="@level='0'">
									<xsl:attribute name="class">root-node mx_rowHighlight</xsl:attribute>
								</xsl:if>
							</xsl:when>
							
							<xsl:when test="@level='0'">
								<xsl:attribute name="class">root-node</xsl:attribute>
								<xsl:if test="$checked = 'checked'">
									<xsl:attribute name="class">root-node mx_rowSelected</xsl:attribute>
								</xsl:if>
							</xsl:when>
							<xsl:when test="$status = 'cut'">
								<xsl:attribute name="class">mx_cut</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class">even</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="not($rg)">
							<xsl:apply-templates select="c[key('displayedColumns', @index)]"
								mode="right">
								<xsl:with-param name="rowNumber" select="'2'" />
							</xsl:apply-templates>
						</xsl:if>
					</tr>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template match="c" mode="right">
		<xsl:param name="rowNumber" select="." />
		<xsl:variable name="level" select="parent::r[@level]" />
		<xsl:choose>
			<xsl:when test="parent::r/@level='0'">
				<xsl:call-template name="tableBodyth">
					<xsl:with-param name="rowNumber" select="$rowNumber" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="tableBodytd">
					<xsl:with-param name="rowNumber" select="$rowNumber" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tableBodytd">
		<xsl:param name="rowNumber" select="." />
		<xsl:variable name="cellIndex" select="@index" />
		<xsl:variable name="visualCue" select="string(parent::r/@visualCue)" />
		<xsl:variable name="level" select="parent::r/@level" />
		<xsl:variable name="matchresult" select="string(parent::r/@matchresult)" />
		<xsl:variable name="compareResult" select="string(@compareResult)" />
		<xsl:variable name="columnSynch" select="string(@columnSynch)" />
		<xsl:variable name="status" select="parent::r/@status" />
		<xsl:variable name="id" select="parent::r/@id" />
		<xsl:variable name="relId" select="parent::r/@r" />
		<xsl:variable name="parentOid" select="parent::r/@p" />
		<xsl:variable name="calc" select="parent::r/@calc" />
		<xsl:variable name="currentColumn" select="key('displayedColumns', @index)" />
		<xsl:variable name="colName" select="$currentColumn/@name" />
		<xsl:variable name="expr" select="$currentColumn/@expression" />
		<xsl:variable name="currentSettings" select="$currentColumn/settings" />
		<xsl:variable name="compareBy" select="$currentColumn/@compareBy" />
		
		<xsl:variable name="varFieldType"
			select="$currentSettings/setting[@name = 'Column Type']" />
		<xsl:variable name="Field_Type"
			select="translate($varFieldType,$ucletters,$lcletters)" />
		<xsl:variable name="settingRowNumber"
			select="$currentSettings/setting[@name='Row Number']" />
		<xsl:variable name="dropZone"
			select="$currentSettings/setting[@name='DropZone']" />
		<xsl:variable name="oid" select="parent::r/@o" />
		<xsl:variable name="isRequiredColumn"
			select="$currentSettings/setting[@name='Required']='true' or $currentSettings/setting[@name='Required']='TRUE'" />
		<xsl:variable name="iFH" select="string(@iFH) = 'true'" />
		<xsl:variable name="rg" select="parent::r/@rg" />
		<xsl:variable name="preserveSpaces"
			select="$currentSettings/setting[@name='Preserve Spaces']='true' or $currentSettings/setting[@name='Preserve Spaces']='TRUE'" />
		<xsl:variable name="preserveSpacesCss">
			<xsl:choose>
				<xsl:when
					test="not($rg) and ($currentSettings/setting[@name='Preserve Spaces']='true' or $currentSettings/setting[@name='Preserve Spaces']='TRUE')">
					<xsl:text>verbatim</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="styleCell" select="string(@styleCell)" />
		<xsl:variable name="styleColumn" select="string(@styleColumn)" />
		<xsl:variable name="styleRow" select="string(@styleRow)" />
		<xsl:variable name="facetColorClass">
			<xsl:if test="$currentColumn/@colorize = 'yes'">
				<xsl:value-of select="string(@facetColoring)" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="customStyle">
			<xsl:choose>
				<xsl:when test="not($styleCell = '')">
					<xsl:value-of select="string(@styleCell)" />
				</xsl:when>
				<xsl:when test="not($styleRow = '')">
					<xsl:value-of select="string(@styleRow)" />
				</xsl:when>
				<xsl:when test="not($styleColumn = '')">
					<xsl:value-of select="string(@styleColumn)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="rmbid">
			<xsl:choose>
				<xsl:when test="@altOID">
					<xsl:value-of select="@altOID" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../@o" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="RMBMenu"
			select="$currentSettings/setting[@name = 'RMB Menu']" />

		<!-- Blank cell in second row -->
		<xsl:if
			test="$rowNumber = '2' and $currentSettings/setting[@name='BlankCell']='true' and not($rg)">
			<td>
				<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
					<xsl:attribute name="rowspan">
						<xsl:value-of select="$currentSettings/setting[@name='Row Span']" />
					</xsl:attribute>
				</xsl:if>

				<xsl:if
					test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
					<xsl:attribute name="colspan">
						<xsl:value-of
						select="$currentSettings/setting[@name='Column Span'] div 2 + 1" />
					</xsl:attribute>
				</xsl:if>
				<xsl:if
					test="/mxRoot/setting[@name = 'sbMode'] = 'view' and parent::r/@checked='checked'">
					<xsl:attribute name="class">mx_rowStyle</xsl:attribute>
				</xsl:if>
				&#160;
			</td>
		</xsl:if>
		<!-- Regular columns rendering -->
		<xsl:if test="$settingRowNumber = $rowNumber">

			<td position="{$cellIndex}" rowNumber="{$settingRowNumber}" rmbID="{$rmbid}"
				rmbrow="{$id}">
				<xsl:if test="string-length($dropZone) &gt; 0 ">
					<!-- ondrop="drop(event)" ondragover="allowDrop(event)" -->
					<xsl:attribute name="data-drop"><xsl:value-of
						select="$dropZone" /></xsl:attribute>
					<xsl:attribute name="ondrop">emxEditableTable.drop(event)</xsl:attribute>
					<xsl:attribute name="ondragover">emxEditableTable.allowDrop(event)</xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($RMBMenu) &gt; 0 ">
					<xsl:attribute name="rmb"><xsl:value-of
						select="$RMBMenu" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$uiAutomation = 'true' ">
					<xsl:attribute name="data-aid"><xsl:value-of
						select="$colName" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$Field_Type = 'image'">
					<xsl:if test="@height != ''">
						<xsl:variable name="cht">
							height:
							<xsl:value-of select="@height" />
							px
						</xsl:variable>
						<xsl:attribute name="style">
							<xsl:value-of select="$cht" />
						</xsl:attribute>
					</xsl:if>
				</xsl:if>
				<xsl:if test="not($rg)">
					<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
						<xsl:attribute name="rowspan">
						<xsl:value-of select="$currentSettings/setting[@name='Row Span']" />
					</xsl:attribute>
					</xsl:if>

					<xsl:if
						test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
						<xsl:attribute name="colspan">
						<xsl:value-of
							select="$currentSettings/setting[@name='Column Span'] div 2 + 1" />
					</xsl:attribute>
					</xsl:if>

					<xsl:if test="$currentSettings/setting[@name='Row Span']/text() = '2'">
						<xsl:choose>
							<xsl:when test="/mxRoot/setting[@name='isIE'] = 'true'">
								<xsl:attribute name="style">height: 50px;</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="style">height: 49px;</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:if>
				<!-- first place we can add a class add facetColor here as the default. 
					We will add facet color to each style -->
				<xsl:if test="not($preserveSpacesCss = '')">
					<xsl:attribute name="class"><xsl:value-of
						select="$preserveSpacesCss" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="not($facetColorClass = '')">
					<xsl:attribute name="class"><xsl:value-of
						select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="not($customStyle = '')">
					<xsl:attribute name="class"><xsl:value-of
						select="concat($customStyle, ' ', $facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when
						test="not($status = 'cut' or $status = 'add' or $status = 'resequence' or $status = 'new' or $status = 'lookup')">
						<xsl:choose>
							<xsl:when
								test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
								<xsl:choose>
									<xsl:when test="@edited='true'">
										<xsl:choose>
											<xsl:when test="$isRequiredColumn">
												<xsl:attribute name="class">mx_editable mx_required mx_edited <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="class">mx_editable mx_edited <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="not($customStyle = '')">
										<xsl:choose>
											<xsl:when test="@edited='true'">
												<xsl:attribute name="class"><xsl:value-of
													select="$customStyle" /> mx_editable mx_edited <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /> /></xsl:attribute>
											</xsl:when>
											<xsl:when test="$isRequiredColumn">
												<xsl:attribute name="class"><xsl:value-of
													select="$customStyle" /> mx_editable mx_required <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="class"><xsl:value-of
													select="$customStyle" /> mx_editable <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="not(/mxRoot/setting[@name = 'sbMode'] = 'view')">
												<xsl:choose>
													<xsl:when test="$isRequiredColumn">
														<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
															select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
													</xsl:when>
													<xsl:otherwise>
														<xsl:choose>
															<xsl:when test="$styleColumn">
																<xsl:attribute name="class">mx_editable <xsl:value-of
																	select="concat($styleColumn, ' ', $facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
																<xsl:attribute name="class">mx_editable <xsl:value-of
																	select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$status = 'cut'">
								<xsl:attribute name="class">mx_cut <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>
							<xsl:when
								test="$status = 'add' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
								<xsl:choose>
									<xsl:when test="@edited='true'">
										<xsl:choose>
											<xsl:when test="$isRequiredColumn">
												<xsl:attribute name="class">mx_editable mx_required mx_edited mx_add <xsl:value-of
													select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="class">mx_editable mx_edited mx_add <xsl:value-of
													select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="$isRequiredColumn">
										<xsl:attribute name="class">mx_editable mx_required mx_add <xsl:value-of
											select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="class">mx_editable mx_add <xsl:value-of
											select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when
								test="$status = 'add' and $currentSettings/setting[@name='Editable']='false'">
								<xsl:attribute name="class">mx_add <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>
							<xsl:when test="$status = 'resequence'">
								<xsl:attribute name="class">mx_resequence <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>

							<xsl:when
								test="$status = 'new' and ($currentSettings/setting/@name='Add Input Type')">
								<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>

							<xsl:when
								test="$status = 'lookup' and ($currentSettings/setting/@name='Lookup Input Type')">
								<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>

							<xsl:when
								test="($status = 'new' or $status = 'lookup') and $isRequiredColumn">
								<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>

							<xsl:when test="$status = 'new' or $status = 'lookup'">
								<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<!-- </xsl:otherwise> </xsl:choose> -->

				<!-- Added by to highlight the entire row  -->
				<xsl:if test="$matchresult='right'">
					<xsl:attribute name="class">mx_unique-row <xsl:value-of
						select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$compareResult='different'">
					<xsl:attribute name="class">mx_common-attribute-change <xsl:value-of
						select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$compareBy = 'false'">
					<xsl:attribute name="class">mx_no-compare-column</xsl:attribute>
				</xsl:if>
				
				<xsl:if test="$columnSynch='true'">
					<xsl:choose>
						<xsl:when test="@edited='true'">
							<xsl:attribute name="class">mx_attr-change <xsl:value-of
								select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">mx_sync-row <xsl:value-of
								select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="$visualCue = 'true'">
					<xsl:attribute name="class">retainedRows <xsl:value-of
						select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				
				<!-- Added markup for sync operation -->
				<xsl:if test="$status='cut' and $compare = 'TRUE' and $matchresult='right'">
					<xsl:attribute name="class">mx_cut <xsl:value-of
						select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='left'">
					<xsl:attribute name="class">mx_add <xsl:value-of
						select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='right'">
					<xsl:attribute name="class">mx_rowStyle <xsl:value-of
					select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if> 
				
				<xsl:if test="$calc = 'true'">
					<xsl:attribute name="class">calculatedRows <xsl:value-of
						select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
				</xsl:if>
				<xsl:if
					test="$compare = 'TRUE' and $cellIndex = 1+$split and $reportType != 'Difference_Only_Report' and $reportType != 'Unique_toLeft_Report' and $reportType != 'Unique_toRight_Report' and $reportType != 'Common_Report'">
					<xsl:variable name="space_level">padding-left:
						<xsl:choose>
							<xsl:when
								test="count(/mxRoot/rows/r[@level = '0']) = '1' or count(/mxRoot/rows/r[@level = '0']) = '0'">
								<xsl:value-of select="number(19*($level))" />px
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="number(19*($level -1))" />px
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:attribute name="style">
		                            <xsl:value-of select="$space_level" />
		                        </xsl:attribute>
				</xsl:if>


				<xsl:choose>
					<xsl:when test="$currentColumn/@type='separator'">
						<xsl:attribute name="class">mx_separator</xsl:attribute>
					</xsl:when>
					<xsl:when
						test="$currentColumn/@type='businessobject'and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'] or $iFH)">

						<xsl:attribute name="title">
                            <xsl:choose>
                            <xsl:when test="./mxLink">
                                <xsl:for-each select="./mxLink/node()">
                                    <xsl:value-of select="." />
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                            	<xsl:value-of select="text()" />
                            </xsl:otherwise>
                            </xsl:choose>
                         </xsl:attribute>

						<xsl:if
							test="@i and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
							<img src="{@i}" border="0" height="16" />
						</xsl:if>
						<xsl:variable name="href">
							<xsl:if
								test="$currentColumn/@href and not($status = 'new') and not($status = 'lookup')">
								<xsl:call-template name="href">
									<xsl:with-param name="col" select="$currentColumn" />
								</xsl:call-template>
							</xsl:if>
						</xsl:variable>
						<xsl:choose>
							<!-- cell with href -->
							<xsl:when
								test="string-length($href) &gt; 0 and not($href = '#DENIED!') and ($isFromCtxSearch = 'false')">
								<xsl:element name="a">
									<xsl:attribute name="href"><xsl:value-of
										select="normalize-space($href)" /></xsl:attribute>
									<xsl:if test="$expr = 'name'">
										<xsl:attribute name="class">
                                                                        <xsl:value-of
											select="'object'" />
                                                                    </xsl:attribute>
									</xsl:if>
									<xsl:value-of select="." />
								</xsl:element>
							</xsl:when>
							<xsl:when test="./mxLink">
								<xsl:choose>
									<xsl:when
										test="$currentSettings/setting[@name='isMultiVal'] = 'true'">
										<table class="multi-attr">
											<xsl:for-each select="./mxLink/node()">
												<tr>
													<td>
														<xsl:copy-of select="." />
													</td>
												</tr>
											</xsl:for-each>
										</table>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="./mxLink/node()">
											<xsl:copy-of select="." />
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<!--cell without href -->
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$expr = 'name'">
										<span class="object">
											<xsl:value-of select="." />
										</span>
									</xsl:when>
									<xsl:when test="string-length(text()) = 0">
										&#160;
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when
												test="$currentSettings/setting[@name='isMultiVal'] = 'true'">
												<table class="multi-attr">
													<xsl:variable name="strData" select="." />
													<xsl:call-template name="splitByDelimiter">
														<xsl:with-param name="str" select="$strData" />
													</xsl:call-template>
												</table>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="." />
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- ICON COLUMN -->
					<xsl:when
						test="$currentColumn/@type='icon' and 
                                            not(@editMask and contains($currentSettings/setting[@name='Column Icon'],'iconActionEdit'))and not($calc = 'true') and not($rg)">
						<xsl:call-template name="iconColumn">
							<xsl:with-param name="col" select="$currentColumn" />
						</xsl:call-template>
					</xsl:when>

					<xsl:when test="$currentColumn/@type='checkbox'">
						<xsl:choose>
							<xsl:when
								test="$currentSettings/setting[@name='True Image'] and $currentSettings/setting[@name='False Image']">
								<xsl:if test="not(string(@a) = 'none')">
									<img border="0" height="16">
										<xsl:attribute name="onclick">
										<xsl:value-of
											select="concat(&quot;booleanToggleImg(this , '&quot; , parent::r/@id , &quot;','&quot; , $colName, &quot;')&quot;)" />
									</xsl:attribute>
										<xsl:choose>
											<xsl:when test="string(@a) = 'true'">
												<xsl:attribute name="src">
												<xsl:value-of
													select="$currentSettings/setting[@name='True Image']" />
											</xsl:attribute>
												<xsl:attribute name="title">
												<xsl:value-of
													select="$currentSettings/setting[@name='True Tooltip']" />
											</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="src">
												<xsl:value-of
													select="$currentSettings/setting[@name='False Image']" />
											</xsl:attribute>
												<xsl:attribute name="title">
												<xsl:value-of
													select="$currentSettings/setting[@name='False Tooltip']" />
											</xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</img>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<input type="checkbox" class="small" name="chkList" id="rmbrow-{$id}"
									value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
									onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">

									<xsl:if
										test="(string(@a) = 'false') or (parent::r/@disableSelection = 'true')">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="parent::r/@checked = 'checked'">
										<xsl:attribute name="checked">
														<xsl:value-of select="parent::r/@checked" />
													</xsl:attribute>
									</xsl:if>
								</input>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<!-- PROGRAM HTML OR FILE -->
					<!--xsl:when test="span"><xsl:value-of select="span/text()"/></xsl:when -->
					<xsl:when
						test="$currentColumn/@type='programHTMLOutput' or $currentColumn/@type='File' or $iFH">
						<xsl:if test="$iFH">
							<xsl:attribute name="iFH">true</xsl:attribute>
						</xsl:if>
                        <xsl:for-each select="./node()"><xsl:copy-of select="." /></xsl:for-each>
					</xsl:when>
					<!-- IMAGE -->
					<xsl:when test="$Field_Type = 'image'">
						<xsl:variable name="href">
							<xsl:call-template name="href">
								<xsl:with-param name="col" select="$currentColumn" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:choose>
							<xsl:when
								test="string-length($href) &gt; 0 and not($href = '#DENIED!')">
								<xsl:element name="a">
									<xsl:attribute name="href"><xsl:value-of
										select="normalize-space($href)" /></xsl:attribute>
									<xsl:for-each select="./node()">
										<xsl:copy-of select="." />
									</xsl:for-each>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="./node()">
									<xsl:copy-of select="." />
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when
						test="$currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression']">
						<xsl:for-each select="./node()">
							<xsl:copy-of select="." />
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="title">
                                            <xsl:choose>
                                            <xsl:when test="./mxLink">
                                                <xsl:for-each
							select="./mxLink/node()">
                                                          <xsl:value-of
							select="." />
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of
							select="text()" />
                                            </xsl:otherwise>
                                            </xsl:choose>
                                         </xsl:attribute>
						<xsl:if test="@i">
							<img src="{@i}" border="0" height="16" />
						</xsl:if>
						<xsl:variable name="href">
							<xsl:if
								test="$currentColumn/@href and not($status = 'new') and not($status = 'lookup')">
								<xsl:call-template name="href">
									<xsl:with-param name="col" select="$currentColumn" />
								</xsl:call-template>
							</xsl:if>
						</xsl:variable>
						<xsl:choose>
							<!-- cell with href -->
							<xsl:when
								test="string-length($href) &gt; 0 and not($href = '#DENIED!') and ($isFromCtxSearch = 'false')">
								<xsl:element name="a">
									<xsl:attribute name="href"><xsl:value-of
										select="normalize-space($href)" /></xsl:attribute>
									<xsl:value-of select="." />
								</xsl:element>
							</xsl:when>
							<xsl:when test="./mxLink">
								<xsl:for-each select="./mxLink/node()">
									<xsl:copy-of select="." />
								</xsl:for-each>
							</xsl:when>
							<!--cell without href -->
							<xsl:otherwise>
								<xsl:value-of select="text()" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:variable name="oldVal" select="@a" />
				<xsl:variable name="newVal" select="." />
				<xsl:if test="@edited='true' and not(string($oldVal) = string($newVal))">
					<span>&#160;</span>
					<span class="original-value">
						<xsl:value-of select="@d" />
					</span>
				</xsl:if>
			</td>
		</xsl:if>
	</xsl:template>
	<xsl:template name="tableBodyth">
		<xsl:param name="rowNumber" select="." />
		<xsl:variable name="cellIndex" select="@index" />
		<xsl:variable name="visualCue" select="string(parent::r/@visualCue)" />
		<xsl:variable name="status" select="parent::r/@status" />
		<xsl:variable name="id" select="parent::r/@id" />
		<xsl:variable name="relId" select="parent::r/@r" />
		<xsl:variable name="parentOid" select="parent::r/@p" />
		<xsl:variable name="currentColumn" select="key('displayedColumns', @index)" />
		<xsl:variable name="colName" select="$currentColumn/@name" />
		<xsl:variable name="expr" select="$currentColumn/@expression" />
		<xsl:variable name="currentSettings" select="$currentColumn/settings" />
		<xsl:variable name="varFieldType"
			select="$currentSettings/setting[@name = 'Column Type']" />
		<xsl:variable name="Field_Type"
			select="translate($varFieldType,$ucletters,$lcletters)" />
		<xsl:variable name="settingRowNumber"
			select="$currentSettings/setting[@name='Row Number']" />
		<xsl:variable name="oid" select="parent::r/@o" />
		<xsl:variable name="styleCell" select="string(@styleCell)" />
		<xsl:variable name="styleColumn" select="string(@styleColumn)" />
		<xsl:variable name="styleRow" select="string(@styleRow)" />
		<xsl:variable name="isRequiredColumn"
			select="$currentSettings/setting[@name='Required']='true' or $currentSettings/setting[@name='Required']='TRUE'" />
		<xsl:variable name="iFH" select="string(@iFH) = 'true'" />
		<xsl:variable name="rg" select="parent::r/@rg" />
		<xsl:variable name="compareBy" select="$currentColumn/@compareBy" />
		<xsl:variable name="matchresult" select="string(parent::r/@matchresult)" />
		
		<xsl:variable name="preserveSpacesCss">
			<xsl:choose>
				<xsl:when
					test="not($rg) and ($currentSettings/setting[@name='Preserve Spaces']='true' or $currentSettings/setting[@name='Preserve Spaces']='TRUE')">
					<xsl:text>verbatim</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="displayMode">
			<xsl:choose>
				<xsl:when test="$currentSettings/setting[@name = 'Display Mode']">
					<xsl:value-of select="$currentSettings/setting[@name='Display Mode']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Both</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="rmbid">
			<xsl:choose>
				<xsl:when test="@altOID">
					<xsl:value-of select="@altOID" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../@o" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="RMBMenu"
			select="$currentSettings/setting[@name = 'RMB Menu']" />
		<xsl:variable name="customStyle">
			<xsl:choose>
				<xsl:when test="not($styleCell = '')">
					<xsl:value-of select="string(@styleCell)" />
				</xsl:when>
				<xsl:when test="not($styleRow = '')">
					<xsl:value-of select="string(@styleRow)" />
				</xsl:when>
				<xsl:when test="not($styleColumn = '')">
					<xsl:value-of select="string(@styleColumn)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="facetColorClass">
			<xsl:if test="$currentColumn/@colorize = 'yes'">
				<xsl:value-of select="string(@facetColoring)" />
			</xsl:if>
		</xsl:variable>
		<xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">
			<xsl:if test="$cellIndex &gt; $split">
				<!-- Blank cell rendering only in second row -->
				<xsl:if
					test="$rowNumber = '2' and $currentSettings/setting[@name='BlankCell'] = 'true'">
					<td>
						<xsl:if
							test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
							<xsl:attribute name="rowspan">
							<xsl:value-of select="$currentSettings/setting[@name='Row Span']" />
						</xsl:attribute>
						</xsl:if>

						<xsl:if
							test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
							<xsl:attribute name="colspan">
							<xsl:value-of
								select="$currentSettings/setting[@name='Column Span'] div 2 + 1" />
						</xsl:attribute>
						</xsl:if>
						&#160;
					</td>
				</xsl:if>

				<!-- Regular cells rendering -->
				<xsl:if test="$settingRowNumber = $rowNumber">

					<td position="{$cellIndex}" rmbID="{$rmbid}" rmbrow="{$id}"
						rowNumber="{$settingRowNumber}">
						<xsl:if test="string-length($RMBMenu) &gt; 0 ">
							<xsl:attribute name="rmb"><xsl:value-of
								select="$RMBMenu" /></xsl:attribute>
						</xsl:if>
						<xsl:if test="$uiAutomation = 'true' ">
							<xsl:attribute name="data-aid"><xsl:value-of
								select="$colName" /></xsl:attribute>
						</xsl:if>
						
						<!-- table body th for root node-->
						<xsl:if test="$compareBy='false'">
							<xsl:attribute name="class">mx_no-compare-column<xsl:value-of
							select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:if>
						
						<xsl:if test="not($rg)">
							<xsl:if
								test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
								<xsl:attribute name="rowspan">
							<xsl:value-of select="$currentSettings/setting[@name='Row Span']" />
						</xsl:attribute>
							</xsl:if>

							<xsl:if
								test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
								<xsl:attribute name="colspan">
						<xsl:value-of
									select="$currentSettings/setting[@name='Column Span'] div 2 + 1" />
					  </xsl:attribute>
							</xsl:if>

							<xsl:if test="$currentSettings/setting[@name='Row Span']/text() = '2'">
								<xsl:choose>
									<xsl:when test="/mxRoot/setting[@name='isIE'] = 'true'">
										<xsl:attribute name="style">height: 50px;</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="style">height: 49px;</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:if>
						<!-- first place we can add a class add facetColor here as the default. 
							We will add facet color to each style -->
						<xsl:if test="not($preserveSpacesCss = '')">
							<xsl:attribute name="class"><xsl:value-of
								select="$preserveSpacesCss" /></xsl:attribute>
						</xsl:if>
						<xsl:if test="not($facetColorClass = '')">
							<xsl:attribute name="class"><xsl:value-of
								select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:if>

						<xsl:if test="not($customStyle = '')">
							<xsl:attribute name="class"><xsl:value-of
								select="concat($customStyle, ' ', $facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<xsl:when
								test="$status = 'new' and ($currentSettings/setting/@name='Add Input Type')">
								<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
									select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>

							<xsl:when
								test="$status = 'lookup' and ($currentSettings/setting/@name='Lookup Input Type')">
								<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
									select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>

							<xsl:when
								test="($status = 'new' or $status = 'lookup') and $isRequiredColumn">
								<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
									select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>

							<xsl:when test="$status = 'new' or $status = 'lookup'">
								<xsl:attribute name="class">mx_editable <xsl:value-of
									select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:when>
							<xsl:when
								test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
								<xsl:choose>
									<xsl:when test="@edited='true'">
										<xsl:choose>
											<xsl:when test="$isRequiredColumn">
												<xsl:attribute name="class">mx_editable mx_required mx_edited <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="class">mx_editable mx_edited <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:when test="not($customStyle = '')">
										<xsl:choose>
											<xsl:when test="@edited='true'">
												<xsl:attribute name="class"><xsl:value-of
													select="$customStyle" /> mx_editable mx_edited <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:when>
											<xsl:when test="$isRequiredColumn">
												<xsl:attribute name="class"><xsl:value-of
													select="$customStyle" /> mx_editable mx_required <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="class"><xsl:value-of
													select="$customStyle" /> mx_editable <xsl:value-of
													select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="not(/mxRoot/setting[@name = 'sbMode'] = 'view')">
												<xsl:choose>
													<xsl:when test="$isRequiredColumn">
														<xsl:attribute name="class">mx_editable mx_required <xsl:value-of
															select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
													</xsl:when>
													<xsl:when test="$styleColumn">
														<xsl:attribute name="class">mx_editable <xsl:value-of
															select="concat($styleColumn, ' ', $facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
													</xsl:when>
													<xsl:otherwise>
														<xsl:attribute name="class">mx_editable <xsl:value-of
															select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
						<xsl:if test="$visualCue = 'true'">
							<xsl:attribute name="class">retainedRows <xsl:value-of
								select="concat($facetColorClass, ' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:if>

						<!-- Added markup for sync operation -->
						<xsl:if test="$status='cut' and $compare = 'TRUE' and $matchresult='right'">
							<xsl:attribute name="class">mx_cut <xsl:value-of
								select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:if>
						<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='left'">
							<xsl:attribute name="class">mx_add <xsl:value-of
								select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
						</xsl:if>

						<xsl:choose>
							<xsl:when test="$currentColumn/@type='separator'">
								<xsl:attribute name="class">mx_separator</xsl:attribute>
							</xsl:when>
							<xsl:when
								test="$currentColumn/@type='businessobject' and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'] or $iFH)">
								<xsl:if test="string-length(text()) &gt; 0 ">
									<xsl:choose>
										<xsl:when
											test="$currentColumn/settings/setting[@name='RowGroupCalculation']!='' and ($rg)">
											<xsl:attribute name="title">Formula : <xsl:value-of
												select="$currentColumn/settings/setting[@name='RowGroupCalculation']" /></xsl:attribute>
											<xsl:attribute name="class">mx_rg_calculation</xsl:attribute>

											<xsl:element name="a">
												<xsl:attribute name="href">#</xsl:attribute>
												<xsl:attribute name="class"><xsl:value-of select="'object'" 
													/></xsl:attribute>
												<xsl:attribute name="class">root-node</xsl:attribute>
												<xsl:value-of select="." />
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
									<xsl:attribute name="title"><xsl:value-of
										select="text()" /></xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:if
									test="@i and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
									<img src="{@i}" border="0" height="16" />
								</xsl:if>
								<xsl:variable name="href">
									<xsl:if
										test="$currentColumn/@href and not($status = 'new') and not($status = 'lookup')">
										<xsl:call-template name="href">
											<xsl:with-param name="col" select="$currentColumn" />
										</xsl:call-template>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<!-- cell with href -->
									<xsl:when
										test="string-length($href) &gt; 0 and not($href = '#DENIED!') and ($isFromCtxSearch = 'false')">
										<xsl:element name="a">
											<xsl:attribute name="href"><xsl:value-of
												select="normalize-space($href)" /></xsl:attribute>
											<xsl:if test="$expr = 'name'">
												<xsl:attribute name="class">
                                                                        <xsl:value-of
													select="'object'" />
                                                                    </xsl:attribute>
											</xsl:if>
											<xsl:value-of select="." />
										</xsl:element>
									</xsl:when>
									<!--cell without href -->
									<xsl:when test="./mxLink">
										<xsl:for-each select="./mxLink/node()">
											<xsl:copy-of select="." />
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<xsl:when test="$expr = 'name'">
												<span class="object">
													<xsl:value-of select="." />
												</span>
											</xsl:when>
											<xsl:when test="string-length(text()) = 0"></xsl:when>
											<xsl:otherwise>
												<xsl:choose>
													<xsl:when
														test="$currentSettings/setting[@name='isMultiVal'] = 'true'">
														<table class="multi-attr">
															<xsl:variable name="strData" select="." />
															<xsl:call-template name="splitByDelimiter">
																<xsl:with-param name="str" select="$strData" />
															</xsl:call-template>
														</table>
													</xsl:when>
													<xsl:otherwise>
														<xsl:if test="not($rg)">
														<xsl:value-of select="." />
														</xsl:if>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<!-- ICON COLUMN -->
							<xsl:when
								test="$currentColumn/@type='icon' and 
                                            not(@editMask and contains($currentSettings/setting[@name='Column Icon'],'iconActionEdit')) and not($rg)">
								<xsl:call-template name="iconColumn">
									<xsl:with-param name="col" select="$currentColumn" />
								</xsl:call-template>
							</xsl:when>

							<xsl:when test="$currentColumn/@type='checkbox'">
								<xsl:choose>
									<xsl:when
										test="$currentSettings/setting[@name='True Image'] and $currentSettings/setting[@name='False Image']">
										<xsl:if test="not(string(@a) = 'none')">
											<img border="0" height="16">
												<xsl:attribute name="onclick">
												<xsl:value-of
													select="concat(&quot;booleanToggleImg(this , '&quot; , parent::r/@id , &quot;','&quot; , $colName, &quot;')&quot;)" />
											</xsl:attribute>
												<xsl:choose>
													<xsl:when test="string(@a) = 'true'">
														<xsl:attribute name="src">
														<xsl:value-of
															select="$currentSettings/setting[@name='True Image']" />
													</xsl:attribute>
														<xsl:attribute name="title">
														<xsl:value-of
															select="$currentSettings/setting[@name='True Tooltip']" />
													</xsl:attribute>
													</xsl:when>
													<xsl:otherwise>
														<xsl:attribute name="src">
														<xsl:value-of
															select="$currentSettings/setting[@name='False Image']" />
													</xsl:attribute>
														<xsl:attribute name="title">
														<xsl:value-of
															select="$currentSettings/setting[@name='False Tooltip']" />
													</xsl:attribute>
													</xsl:otherwise>
												</xsl:choose>
											</img>
										</xsl:if>
									</xsl:when>
									<xsl:otherwise>
										<input type="checkbox" class="small" name="chkList" id="rmbrow-{$id}"
											value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
											onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">

											<xsl:if
												test="(string(@a) = 'false') or (parent::r/@disableSelection = 'true')">
												<xsl:attribute name="disabled">true</xsl:attribute>
											</xsl:if>
											<xsl:if test="parent::r/@checked = 'checked'">
												<xsl:attribute name="checked">
														<xsl:value-of select="parent::r/@checked" />
													</xsl:attribute>
											</xsl:if>
										</input>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>

							<!-- PROGRAM HTML OR FILE -->
							<!--xsl:when test="span"><xsl:value-of select="span/text()"/></xsl:when -->
							<xsl:when
								test="$currentColumn/@type='programHTMLOutput' or $currentColumn/@type='File' or $iFH">
								<xsl:if test="$iFH">
									<xsl:attribute name="iFH">true</xsl:attribute>
								</xsl:if>
								<xsl:for-each select="./node()"><xsl:copy-of select="." /></xsl:for-each>
							</xsl:when>
							<xsl:when
								test="$currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression']">
								<xsl:for-each select="./node()">
									<xsl:copy-of select="." />
								</xsl:for-each>
							</xsl:when>
							<!-- IMAGE -->
							<xsl:when test="$Field_Type = 'image'">
								<xsl:variable name="href">
									<xsl:call-template name="href">
										<xsl:with-param name="col" select="$currentColumn" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:choose>
									<xsl:when
										test="string-length($href) &gt; 0 and not($href = '#DENIED!')">
										<xsl:element name="a">
											<xsl:attribute name="href"><xsl:value-of
												select="normalize-space($href)" /></xsl:attribute>
											<xsl:for-each select="./node()">
												<xsl:copy-of select="." />
											</xsl:for-each>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:for-each select="./node()">
											<xsl:copy-of select="." />
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$currentColumn/settings/setting[@name='RowGroupCalculation']!='' and ($rg)">
										<xsl:attribute name="title"><xsl:value-of select="$currentColumn/settings/setting[@name='RowGroupCalculation']" /></xsl:attribute>
										<xsl:attribute name="class">mx_rg_calculation</xsl:attribute>
										<xsl:value-of select="text()" />
									</xsl:when>
									<xsl:otherwise>
								<xsl:attribute name="title">
                                                <xsl:choose>
                                                        <xsl:when
									test="./mxLink">
                                                                <xsl:for-each
									select="./mxLink/node()">
                                          <xsl:value-of
									select="." />
                                                                </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                                <xsl:value-of
									select="text()" />
                                                        </xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								
								<xsl:if
									test="@i and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
									<img src="{@i}" border="0" height="16" />
								</xsl:if>
								<xsl:variable name="href">
									<xsl:if
										test="$currentColumn/@href and not($status = 'new') and not($status = 'lookup')">
										<xsl:call-template name="href">
											<xsl:with-param name="col" select="$currentColumn" />
										</xsl:call-template>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<!-- cell with href -->
									<xsl:when
										test="string-length($href) &gt; 0 and not($href = '#DENIED!') and ($isFromCtxSearch = 'false')">
										<xsl:element name="a">
											<xsl:attribute name="href"><xsl:value-of
												select="normalize-space($href)" /></xsl:attribute>
											<xsl:value-of select="." />
										</xsl:element>
									</xsl:when>
									<xsl:when test="./mxLink">
										<xsl:for-each select="./mxLink/node()">
											<xsl:copy-of select="." />
										</xsl:for-each>
									</xsl:when>
									<!--cell without href -->
									<xsl:otherwise>
										<xsl:if test="not($rg)">
										<xsl:value-of select="text()" />
										</xsl:if>	
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:variable name="oldVal" select="@a" />
						<xsl:variable name="newVal" select="." />
						<xsl:if
							test="@edited='true' and not(string($oldVal) = string($newVal))">
							<span>&#160;</span>
							<span class="original-value">
								<xsl:value-of select="@d" />
							</span>
						</xsl:if>
					</td>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<!--ICON COLUMN TEMPLATE -->
	<xsl:template name="iconColumn">
		<xsl:param name="col" select="." />
		<xsl:choose>
			<xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
				<xsl:variable name="href">
					<xsl:call-template name="href">
						<xsl:with-param name="col" select="$col" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="image">
					<xsl:call-template name="cellImage">
						<xsl:with-param name="col" select="$col" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<!-- Image with href -->
					<xsl:when test="string-length($href) &gt; 0">
						<xsl:element name="a">
							<xsl:attribute name="href"><xsl:value-of
								select="normalize-space($href)" /></xsl:attribute>
							<xsl:copy-of select="$image" />
						</xsl:element>
					</xsl:when>
					<!--Image without href -->
					<xsl:otherwise>
						<xsl:copy-of select="$image" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when
						test="not(contains($col/settings/setting[@name='Column Icon'], 'iconNewWindow.gif'))">
						<xsl:call-template name="cellImage">
							<xsl:with-param name="col" select="$col" />
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="''" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- HREF TEMPLATE -->
	<xsl:template name="href">
		<xsl:choose>
			<xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
				<xsl:variable name="oid">
					<xsl:choose>
						<xsl:when test="@altOID">
							<xsl:value-of select="@altOID" />
						</xsl:when>
						<!-- Start addition for structure compare -->
						<xsl:when test="$compare = 'TRUE'">
							<xsl:variable name="matchresult" select="../@matchresult"></xsl:variable>
							<xsl:choose>
								<xsl:when test="$matchresult = 'common' or $matchresult = 'parent'">
									<xsl:value-of select="../@o2" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="../@o" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<!-- End addition for structure compare -->
						<xsl:otherwise>
							<xsl:value-of select="../@o" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="relId" select="../@r" />
				<xsl:variable name="parentId" select="../@p" />
				<xsl:variable name="quote">
					"
				</xsl:variable>
				<xsl:variable name="escape">
					\"
				</xsl:variable>
				<xsl:variable name="currentNode">
					<xsl:call-template name="replace-string">
						<xsl:with-param name="text" select="." />
						<xsl:with-param name="from" select="$quote" />
						<xsl:with-param name="to" select="$escape" />
					</xsl:call-template>
				</xsl:variable>
				javascript:link("
				<xsl:value-of select="@index" />
				","
				<xsl:value-of select="$oid" />
				","
				<xsl:value-of select="$relId" />
				","
				<xsl:value-of select="$parentId" />
				","
				<xsl:value-of select="$currentNode" />
				")
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'#DENIED!'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="replace-string">
		<xsl:param name="text" />
		<xsl:param name="from" />
		<xsl:param name="to" />
		<xsl:choose>
			<xsl:when test="contains($text, $from)">
				<xsl:variable name="before" select="substring-before($text, $from)" />
				<xsl:variable name="after" select="substring-after($text, $from)" />
				<xsl:variable name="prefix" select="concat($before, $to)" />
				<xsl:value-of select="$before" />
				<xsl:value-of select="$to" />
				<xsl:call-template name="replace-string">
					<xsl:with-param name="text" select="$after" />
					<xsl:with-param name="from" select="$from" />
					<xsl:with-param name="to" select="$to" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	<!-- CELL IMAGE -->
	<xsl:template name="cellImage">
		<xsl:param name="col" select="." />
		<xsl:element name="img">
			<xsl:attribute name="height">16</xsl:attribute>
			<xsl:attribute name="src"><xsl:value-of
				select="$col/settings/setting[@name='Column Icon']" /></xsl:attribute>
			<xsl:attribute name="title"><xsl:value-of select="$col/@alt" /></xsl:attribute>
			<xsl:attribute name="border">0</xsl:attribute>
		</xsl:element>
	</xsl:template>
	<!-- To diplay Mutli-value attribute in SB -->
	<xsl:template name="splitByDelimiter">
		<xsl:param name="str" />
		<xsl:choose>
			<xsl:when test="contains($str,'0x08')">
				<tr>
					<td>
						<xsl:value-of select="substring-before($str,'0x08')" />
					</td>
				</tr>
				<xsl:call-template name="splitByDelimiter">
					<xsl:with-param name="str" select="substring-after($str,'0x08')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<tr>
					<td>
						<xsl:value-of select="$str" />
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- END TABLE BODY -->
</xsl:stylesheet>

