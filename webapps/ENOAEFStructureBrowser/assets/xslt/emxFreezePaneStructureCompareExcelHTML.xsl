<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="split" select="/mxRoot/setting[@name='split']"/>
	<!-- 
     ! root template
     !-->
	<xsl:template match="mxRoot">
		<html>
			<head>
				<style type="text/css">
					
					h1, h2, p, th, td {
					    padding:0;
					    margin:0;
					    font-family:Verdana, Arial, Helvetica, sans-serif;
					    font-size:9pt;
					}
					
					h1, h2 {
					    margin-bottom:0.5em;
					    font-weight:bold;
					}
					
					h1 {font-size:15pt;}
					
					h2 {font-size:13pt;}
					
					p {
					    font-size:8pt;
					    line-height:11pt;
					}
					
					div.report-header {
					    border-top:1pt solid #000;
					    border-bottom:1pt solid #000;
					    padding:4pt 0 10pt;
					    margin-bottom:1em;
					}
					
					table {
					    border-collapse:collapse;
					    width:100%;
					}
					
					th,
					td {
					    padding:2pt 4pt;
					    text-align:left;
					    color:#000;
					    background:#f0f0f0;
					    border-bottom:1px solid #FFF;
					    border-right:1px solid #FFF;
					}
					
					th {
					    font-weight:bold;
					    color:#FFF;
					    background:#369;
					}
					
					tr.root-node td {background:#dcdcdc;}
					
					tr th.separator,
					tr td.separator {
					    padding:3px;
					    background:#FFF;
					    border:none;
					}
					
					tr th.compare_column {background:#d00;}
					
					tr td.unique-value {background:#ffffdb;}
					
					tr td.attribute-change {background:#96BBE8;}
				</style>
			</head>
			<body>
				<hr noshade="noshade"/>
				<table>
					<tr>
						<td nowrap="nowrap">
							<h1>
								<xsl:value-of select="//setting[@name='PageHeader']"/>
							</h1>
							<BR></BR>
							<h2><xsl:value-of select="//setting[@name='subHeaderLabel']"/></h2>
							<xsl:if test="//setting[@name='subHeader']">
								<span class="pageSubTitle">
									<xsl:value-of select="//setting[@name='subHeader']"/>
								</span>
							</xsl:if>
						</td>
					</tr>
				</table>
				<hr noshade="noshade"/>
				<table width="100%">
					<xsl:apply-templates select="columns"/>
					<xsl:apply-templates select="rows"/>
				</table>
			</body>
		</html>
	</xsl:template>
	
	<!-- 
     ! columns template
     !-->
	<xsl:template match="columns">
	<xsl:variable name="isIndentedView" select="//setting[@name='isIndentedView']"/>
	<xsl:variable name="settingReportType" select="//setting[@name='reportType']"/>
		<thead>
			<xsl:if test="//setting/@name='Group Header'">
				<tr class="Columnheader1">
					<xsl:if test="normalize-space($isIndentedView) = 'true'">
						<td/>
					</xsl:if>
					<xsl:apply-templates select="column" mode="group-header"/>
				</tr>
			</xsl:if>
			<tr class="Columnheader2">
			<xsl:choose>
				<xsl:when test="normalize-space($isIndentedView) = 'true' and $settingReportType = 'Complete_Summary_Report'  and  /mxRoot/tableControlMap/setting[@name='HasDiffCodeColumn']/value = 'true'">
					<th>
					<xsl:choose>
		                <xsl:when test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
								<xsl:attribute name="rowspan">2</xsl:attribute>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="//setting[@name='Labels']//item[@name='DiffCode']/value" />
					</th>
		                </xsl:when>
		                <xsl:otherwise>
					<xsl:if test="normalize-space($isIndentedView) = 'true' and not($settingReportType = 'Complete_Summary_Report')">
						<th>
							<xsl:choose>
								<xsl:when test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
									<xsl:attribute name="rowspan">2</xsl:attribute>
								</xsl:when>
			        </xsl:choose>
							<xsl:value-of select="//setting[@name='Labels']//item[@name='Level']/value" />
						</th>
				</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
				<xsl:apply-templates select="column">
					<xsl:with-param name="rowNumber" select="'1'"/>
                </xsl:apply-templates>                
			</tr>
			<xsl:if test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
                 <tr>	                                
                      <xsl:apply-templates select="column">
                      	<xsl:with-param name="rowNumber" select="'2'"/>	                                
                      </xsl:apply-templates>
                 </tr>
            </xsl:if>
		</thead>
	</xsl:template>
	
	<!-- 
     ! column template
     !-->
	<xsl:template match="column">
		<xsl:param name="rowNumber" select="."/>
		<xsl:variable name="settingRowNumber" select="settings/setting[@name='Row Number']"/>
		<xsl:variable name="settingRowSpan" select="settings/setting[@name='Row Span']"/>
		<xsl:variable name="settingColumnSpan" select="settings/setting[@name='Column Span']"/>
		<xsl:variable name="compareBy" select="string(@compareBy)"/>
		<xsl:if test="$rowNumber = '2' and settings/setting[@name='BlankCell'] = 'true'">
			<th></th>		
		</xsl:if>
		<xsl:if test="($settingRowNumber/text() = $rowNumber)">
		<xsl:choose>
			<!-- image for the column header-->
			<xsl:when test="contains(@label,'img') and contains(@label,'src')">
				<th nowrap="nowrap">
                   <xsl:if test="number($settingRowSpan) &gt; 1">
                     <xsl:attribute name="rowspan">
						<xsl:value-of select="$settingRowSpan"/>
					 </xsl:attribute>
				   </xsl:if>
	               <xsl:if test="number(($settingColumnSpan + 1) div 2) &gt; 1">
					   <xsl:attribute name="colspan">
						   <xsl:value-of select="($settingColumnSpan + 1) div 2"/>
					   </xsl:attribute>
				    </xsl:if>
					<xsl:if test="$compareBy = 'true'">
						<xsl:attribute name="class">compare_column</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="@name"/>
				</th>
			</xsl:when>
			<xsl:when test="@type='separator'">
				<td class="separator" width="10" style="background-color:white"></td>
			</xsl:when>
			<xsl:when test="contains(@label,'nbsp')">
				<th nowrap="nowrap">
                   <xsl:if test="number($settingRowSpan) &gt; 1">
                     <xsl:attribute name="rowspan">
						<xsl:value-of select="$settingRowSpan"/>
					 </xsl:attribute>
				   </xsl:if>
	               <xsl:if test="number(($settingColumnSpan + 1) div 2) &gt; 1">
					   <xsl:attribute name="colspan">
						   <xsl:value-of select="($settingColumnSpan + 1) div 2"/>
					   </xsl:attribute>
				    </xsl:if>
					<xsl:if test="$compareBy = 'true'">
						<xsl:attribute name="class">compare_column</xsl:attribute>
					</xsl:if>				
				</th>
			</xsl:when>
			<xsl:otherwise>
				<th>
                   <xsl:if test="number($settingRowSpan) &gt; 1">
                     <xsl:attribute name="rowspan">
						<xsl:value-of select="$settingRowSpan"/>
					 </xsl:attribute>
				   </xsl:if>
	               <xsl:if test="number(($settingColumnSpan + 1) div 2) &gt; 1">
					   <xsl:attribute name="colspan">
						   <xsl:value-of select="($settingColumnSpan + 1) div 2"/>
					   </xsl:attribute>
				    </xsl:if>
					<xsl:if test="$compareBy = 'true'">
						<xsl:attribute name="class">compare_column</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="@label"/>
				</th>
			</xsl:otherwise>
		</xsl:choose>	
		</xsl:if>
	</xsl:template>
	
	<!-- 
     ! column template (for group headers)
     !-->	
	<xsl:template match="column" mode="group-header">
		<xsl:if test="settings/setting[@name='Row Number']/text() = '1'">
			<xsl:choose>
				<xsl:when test="settings/setting/@name='Group Header'">
					<xsl:if test="settings/setting[@name='Group Header'][not(text()=preceding::setting)]">
						<xsl:variable name="currentText" select="settings/setting[@name='Group Header']/text()"/>
						<th nowrap="nowrap" class="groupheader">
						<xsl:if test="number(count(//setting[@name='Group Header'][$currentText = text()])) &gt; 1">
				            <xsl:attribute name="colspan">
					         <xsl:value-of select="count(//setting[@name='Group Header'][$currentText = text()])"/>
				            </xsl:attribute>
			            </xsl:if>
							<xsl:value-of select="settings/setting[@name='Group Header']/text()"/>
						</th>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<!--TODO check this height -->
					<td nowrap="nowrap" height="19"></td>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<!-- 
     ! rows template
     !-->
	<xsl:template match="rows">
		<tbody>
			<xsl:apply-templates select="*"/>
		</tbody>
	</xsl:template>
	
	<!-- 
     ! row template
     !-->
	<xsl:template match="r">
	<xsl:variable name="isIndentedView" select="//setting[@name='isIndentedView']"/>
	<xsl:variable name="display" select="string(@display)"/>
	<xsl:variable name="id" select="string(@id)"/>
	<xsl:variable name="filter" select="string(@filter)" />
	<xsl:variable name="displayRow" select="string(@displayRow)" />
	<xsl:variable name="settingReportType" select="//setting[@name='reportType']"/>
	
    <xsl:if test="not($filter = 'true') and not($displayRow = 'false')">
		<tr>
			<xsl:if test="$id = '0'">
           		<xsl:attribute name="class">rootNodeRow</xsl:attribute>
            </xsl:if>
            <xsl:if test="not($id = '0')">
       			<xsl:attribute name="class">columns</xsl:attribute>
            </xsl:if>
			<!-- row indicating level -->
			<xsl:choose>
				<xsl:when test="normalize-space($isIndentedView) = 'true' and $settingReportType = 'Complete_Summary_Report'  and  /mxRoot/tableControlMap/setting[@name='HasDiffCodeColumn']/value = 'true'">
					<td>
					<xsl:choose>
						<xsl:when test="not(count(ancestor-or-self::r) = '1')">
			                <xsl:attribute name="class">listCell</xsl:attribute>
				<xsl:choose>
                     <xsl:when test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
									<xsl:attribute name="rowspan">2</xsl:attribute>
								</xsl:when>
							</xsl:choose>
								<xsl:value-of select="string(@diffcode)" />	
                     </xsl:when>
                     <xsl:otherwise>
								<xsl:value-of select="''" />
            		 </xsl:otherwise>
               </xsl:choose>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="normalize-space($isIndentedView) = 'true' and not($settingReportType = 'Complete_Summary_Report')">
						<td class="listCell">
						<xsl:choose>
		                     <xsl:when test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
		                        <xsl:attribute name="rowspan">2</xsl:attribute>
		                     </xsl:when>
		               	</xsl:choose>
		            	<xsl:value-of select="count(ancestor-or-self::r)-1"/>
		               	</td>
			</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<!-- other table cells -->
			<xsl:apply-templates select="c">
                        	<xsl:with-param name="rowNumber" select="'1'"/>
            </xsl:apply-templates>
		</tr>
		
		<xsl:if test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
            <tr>                        
                <!-- other table cells -->
                <xsl:apply-templates select="c">
                	<xsl:with-param name="rowNumber" select="'2'"/>
                </xsl:apply-templates>
            </tr>
        </xsl:if>		
		
		<!-- any child rows -->
		<xsl:if test="$display = 'block'">
			<xsl:apply-templates select="r"/>
		</xsl:if>
	</xsl:if>
	</xsl:template>
	
	<!-- 
     ! cell template
     !-->
	<xsl:template match="c">
	<xsl:param name="rowNumber" select="."/>
	<xsl:variable name="cellIndex" select="position()"/>
        <xsl:variable name="currentColumn" select="/mxRoot/columns/column[$cellIndex]"/>
        <xsl:variable name="settingRowNumber" select="$currentColumn/settings/setting[@name='Row Number']"/>
        <xsl:variable name="matchresult" select="string(parent::r/@matchresult)"/>
	<xsl:variable name="compareResult" select="string(@compareResult)"/>
	<xsl:variable name="currentCellValue">
      	<xsl:call-template name="replace-string">
		<xsl:with-param name="text" select="."/>
		<xsl:with-param name="from" select="'&#10;'"/>
		<xsl:with-param name="to" select="'N:eW:Li:nE'"/>
	</xsl:call-template>
 	</xsl:variable>
        <xsl:if test="$settingRowNumber = $rowNumber">
		<td align="left">
			<xsl:if test="$matchresult='left' and $cellIndex = 1">
               	<xsl:attribute name="class">unique_row</xsl:attribute>
            </xsl:if>
            <xsl:if test="$matchresult='right' and $cellIndex = $split+1">
               	<xsl:attribute name="class">unique_row</xsl:attribute>
            </xsl:if>
			<xsl:if test="$compareResult='different'">
               	<xsl:attribute name="class">attribute_change</xsl:attribute>
            </xsl:if>
			<xsl:if test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
			<xsl:if test="number($currentColumn/settings/setting[@name='Row Span']) &gt; 1">
				<xsl:attribute name="rowspan">
					<xsl:value-of select="$currentColumn/settings/setting[@name='Row Span']"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="number(($currentColumn/settings/setting[@name='Column Span'] + 1) div 2) &gt; 1">
				<xsl:attribute name="colspan">
					<xsl:value-of select="($currentColumn/settings/setting[@name='Column Span'] + 1) div 2"/>
				</xsl:attribute>
			</xsl:if>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="@image">
					<img src="{@image}" border="0"/>
				</xsl:when>
				<xsl:when test="@icon">
					<table border="0">
						<tr>
							<td><img src="{@icon}" alt="*" width="16" height="16"/></td>
							<td><span class="object"><xsl:value-of select="."/></span></td>
						</tr>						
					</table>
				</xsl:when>
				<!-- <xsl:when test="contains(text(),'nbsp')"></xsl:when> -->
                <xsl:when test="./mxLink">
                    <xsl:for-each select="./mxLink/node()">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </xsl:when>
				<xsl:when test="text() != ''"><xsl:value-of select="$currentCellValue"/></xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>			
		</td>
		</xsl:if>
	</xsl:template>
	
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
