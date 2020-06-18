<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	
	<!-- 
     ! root template
     !-->
	<xsl:template match="mxRoot">
		<html>
                        <head>
								<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
                               <title></title>
                               <style type="text/css">
                                body, th, td {
								font-family:verdana, helvetica, arial, sans-serif;
								font-size:8pt;
								}
                                th {
                               	font-weight:bold;
								}
								tr.rg1 {
										font-weight:bold;
										background-color:#333;
										color:#FFF;
										}
								tr.rg2 {
										font-weight:bold;
										background-color:#999;
										color:#000;
										}
								tr.rg3 {
										font-weight:bold;
										background-color:#ccc;
										color:#000;
										}
    				            </style>
            </head>
			<body>
				<hr noshade="noshade"/>
				<table border="0" width="100%">
					<tr>
						<td></td>
						<td width="60%" class="pageHeader"><b><xsl:value-of select="//setting[@name='PageHeader']"/><xsl:if test="//tableControlMap/setting[@name='subHeader']"><br/><span class="pageSubTitle">&#160;<xsl:value-of select="//tableControlMap/setting[@name='subHeader']"/></span></xsl:if></b></td>
						<td width="40%" align="right"></td>
						<td nowrap="nowrap"></td>
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
		<thead>
			<xsl:if test="//setting/@name='Group Header'">
				<tr>
					<xsl:if test="normalize-space($isIndentedView) = 'true'">
						<td/>
					</xsl:if>
					<xsl:apply-templates select="column" mode="group-header"/>
				</tr>
			</xsl:if>
			<tr>
			<xsl:if test="normalize-space($isIndentedView) = 'true'">
				<xsl:choose>
	                <xsl:when test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
	                	<th rowspan="2"><xsl:value-of select="//setting[@name='Labels']//item[@name='Level']/value"/></th>
	                </xsl:when>
	                <xsl:otherwise>
	                	<th><xsl:value-of select="//setting[@name='Labels']//item[@name='Level']/value"/></th>
	                </xsl:otherwise>
		        </xsl:choose>						
			</xsl:if>
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
		<xsl:if test="$rowNumber = '2' and settings/setting[@name='BlankCell'] = 'true'">
			<th align="left"></th>		
		</xsl:if>
		<xsl:if test="($settingRowNumber/text() = $rowNumber)">
		<xsl:choose>
			<!-- image for the column header-->
			<xsl:when test="contains(@label,'img') and contains(@label,'src')">
				<th nowrap="nowrap" align="left">
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
					<xsl:value-of select="@name"/>
				</th>
			</xsl:when>
			<xsl:when test="@type='separator'">
				<td class="separator" width="10" style="background-color:white"></td>
			</xsl:when>
			<xsl:when test="contains(@label,'nbsp')">
				<th nowrap="nowrap" align="left">
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
				</th>
			</xsl:when>
			<xsl:otherwise>
				<th align="left">
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
						<xsl:variable name="currentText" select="settings/setting[@name='Group Header']/text()"/>
					<th nowrap="nowrap" class="groupheader" >
						<xsl:value-of select="settings/setting[@name='Group Header']/text()"/>
					</th>
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
	<xsl:variable name="filter" select="string(@filter)" />        
	<xsl:variable name="rg" select="string(@rg)"/>
    <xsl:variable name="level" select="string(@level)"/>
    <xsl:if test="not($filter = 'true')">
			<tr><xsl:if test="$rg">
		          <xsl:choose>
                     <xsl:when test="$rg ='rg1'">
                     	<xsl:attribute name="class">rg1</xsl:attribute>
                     </xsl:when>
                      <xsl:when test="$rg ='rg2'">
                     	<xsl:attribute name="class">rg2</xsl:attribute>                    
                     </xsl:when>
                     <xsl:when test="$rg ='rg3'">
                     	<xsl:attribute name="class">rg3</xsl:attribute>
                     </xsl:when>
                  </xsl:choose>
                </xsl:if>
			<!-- row indicating level -->
			<xsl:if test="normalize-space($isIndentedView) = 'true'">
				<xsl:choose>
                     <xsl:when test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
                     	<td class="listCell" rowspan="2" align="left"><xsl:value-of select="count(ancestor-or-self::r)-1"/></td>
                     </xsl:when>
                     <xsl:when test="$rg">
               	     <td></td>
               		</xsl:when>
               		<xsl:when test="not($rg)">
               		<td><xsl:value-of select="$level+1"/></td>
               		</xsl:when>
               </xsl:choose>
			</xsl:if>
			
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
        <xsl:variable name="iFH" select="string(@iFH) = 'true'"/>
        <xsl:variable name="rg" select="parent::r/@rg"/>
        <xsl:variable name="count" select="parent::r/@count"/>
        <xsl:if test="$rowNumber = '2' and $currentColumn/settings/setting[@name='BlankCell'] = 'true'">
			<th align="left"></th>		
	    </xsl:if>
        <xsl:if test="$settingRowNumber = $rowNumber">
		<td class="listCell" align="left">
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
				<xsl:when test="starts-with(text(),'0')"><xsl:value-of select="."/></xsl:when>
				<!-- <xsl:when test="contains(text(),'nbsp')"></xsl:when> -->
                <xsl:when test="./mxLink">
                    <xsl:for-each select="./mxLink/node()">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$iFH">
                    <xsl:for-each select="./node()">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$currentColumn/settings/setting[@name='Alternate OID expression'] or $currentColumn/settings/setting[@name='Alternate Policy expression']">
                	<xsl:for-each select="./node()">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </xsl:when>
				<xsl:when test="text() !=''">
				<xsl:choose>
					 <xsl:when test="$currentColumn/settings/setting[@name='isMultiVal'] = 'true'">
	                                      <table class = "multi-attr">
	                                       <xsl:variable name="strData" select="."/>
	                                      	<xsl:call-template name="splitByDelimiter">
												<xsl:with-param name="str" select="$strData"/>
											 </xsl:call-template>
	                                      </table>
	                 </xsl:when>
	                   <xsl:otherwise>                     		
                        	<xsl:value-of select="." />
                        </xsl:otherwise>
                   </xsl:choose>
					<xsl:if test="$rg">
					<xsl:value-of select="." />
					<b><span>(<xsl:value-of select="$count"/>)</span></b>
				    </xsl:if>
				</xsl:when>
			</xsl:choose>			
		</td>
		</xsl:if>
	</xsl:template>
	
	<!-- To diplay Mutli-value attribute in SB Printer Friendly -->
       <xsl:template name="splitByDelimiter">
  	   <xsl:param name="str"/>
        <xsl:choose>
        <xsl:when test="contains($str,'0x08')">
        	<tr><td>
            <xsl:value-of select="substring-before($str,'0x08')"/>
            </td></tr>
			        <xsl:call-template name="splitByDelimiter">
				        <xsl:with-param name="str" select="substring-after($str,'0x08')"/>
    			    </xsl:call-template>
        </xsl:when>
	    <xsl:otherwise>
			   	  <tr><td>
		           <xsl:value-of select="$str"/>
		           </td></tr>
	    </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
</xsl:stylesheet>
