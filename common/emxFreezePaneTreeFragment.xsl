<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
       <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
       <xsl:variable name="split" select="/mxRoot/setting[@name='split']"/>
       <xsl:variable name="isFromCtxSearch" select="/mxRoot/requestMap/setting[@name='fromCtxSearch']"/>
       <xsl:variable name="rowHeight" select="/mxRoot/setting[@name='rowHeight']"/>
       <xsl:variable name="groupLevel" select="/mxRoot/setting[@name='groupLevel']"/>
       <xsl:variable name="singleRoot" select="/mxRoot/rows//r[@id ='0']"/>
       <xsl:variable name="compare" select="/mxRoot/requestMap/setting[@name='IsStructureCompare']"/>
       <xsl:variable name="sbMode" select="/mxRoot/setting[@name='sbMode']"/>
       <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
       <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
       <xsl:variable name="uiAutomation" select="/mxRoot/requestMap/setting[@name='uiAutomation']"/>
       <xsl:variable name="dbTableName" select="/mxRoot/requestMap/setting[@name='selectedTable']"/>
       
       <xsl:variable name="showDiffCodeIcon" select="/mxRoot/requestMap/setting[@name='diffCodeIcons']"/>
       <xsl:variable name="showSummaryIcons" select="/mxRoot/requestMap/setting[@name='summaryIcons']"/>
       
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
		<xsl:variable name="colorize" select="/mxRoot/setting[@name='colorize']" />
       <xsl:key name="columns" match="/mxRoot/columns/column[position() &lt;= /mxRoot/setting[@name='split']/text()]" use="@index"/>
       
       <xsl:template match="/mxRoot">
              <xsl:call-template name="treeBody"/>
       </xsl:template>
       <!-- COLUMN RULES -->
       <xsl:template match="column" mode="ruletop">
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
              <td>
                     <xsl:choose>
                            <xsl:when test="@type = 'separator'">
                                   <xsl:attribute name="class">mx_separator</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="@type = 'File'">
                                   <xsl:attribute name="width">25</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                   <xsl:attribute name="width"><xsl:choose><xsl:when test="settings/setting[@name='Width']"><xsl:value-of select="settings/setting[@name='Width']"/></xsl:when><xsl:when test="(string-length(@label)*15) &gt; 205">205</xsl:when><xsl:otherwise><xsl:value-of select="(string-length(@label)*15)"/></xsl:otherwise></xsl:choose></xsl:attribute>
                            </xsl:otherwise>
                     </xsl:choose>
              </td>
              </xsl:if>
       </xsl:template>
       <xsl:template match="column" mode="rulemiddle">
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
              <xsl:choose>
                     <xsl:when test="settings/setting/@name='Group Header'">
                            <xsl:if test="settings/setting[@name='Group Header'][not(text()=preceding::setting)]">
                                   <xsl:variable name="currentText" select="settings/setting[@name='Group Header']/text()"/>
                                   <td class="mx_group-header" height="5">
                                          		<xsl:if test="number(count(//setting[@name='Group Header'][$currentText = text()])*2) &gt; 1">
			                                          <xsl:attribute name="colspan">
				                                     <xsl:value-of select="count(//setting[@name='Group Header'][$currentText = text()])*2"/>
		                                          	</xsl:attribute>
		                                        </xsl:if>
                                          <table>
                                                 <tr class="rule">
                                                        <th height="1"/>
                                                 </tr>
                                          </table>
                                   </td>
                            </xsl:if>
                     </xsl:when>
                     <xsl:otherwise>
                            <!-- height is 5 here because of "rule" rendering in IE. Value of 1 only works in Moz-->
                            <!-- LINEUP -->
                            <td class="mx_group-header" height="5"/>
                            <td class="mx_group-header"/>
                     </xsl:otherwise>
              </xsl:choose>
              </xsl:if>
       </xsl:template>
       <xsl:template match="column" mode="rulebottom">
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
              <xsl:choose>
                     <xsl:when test="settings/setting/@name='Group Header'">
                            <xsl:if test="settings/setting[@name='Group Header'][not(text()=preceding::setting)]">
                                   <xsl:variable name="currentText" select="settings/setting[@name='Group Header']/text()"/>
                                   <td class="mx_group-header">
                                       	<xsl:if test="number(count(//setting[@name='Group Header'][$currentText = text()])*2) &gt; 1">
			                               <xsl:attribute name="colspan">
				                                 <xsl:value-of select="count(//setting[@name='Group Header'][$currentText = text()])*2"/>
		                                   </xsl:attribute>
		                                </xsl:if>
                                          <xsl:value-of select="settings/setting[@name='Group Header']/text()"/>
                                   </td>
                            </xsl:if>
                     </xsl:when>
                     <xsl:otherwise>
                            <!-- height -->
                            <td>&#160;</td>
                            <td/>
                     </xsl:otherwise>
              </xsl:choose>
              </xsl:if>
       </xsl:template>
       <xsl:template match="column">
              <xsl:param name="tblName" select="."/>
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
              <td id="{@name}">
                     <xsl:if test="settings/setting[@name='Editable']='true' and settings/setting[@name='Input Type']">
                            <xsl:attribute name="class">mx_editable</xsl:attribute>
                     </xsl:if>
                     <table>
                            <tr>
                                   <xsl:choose>
                                          <xsl:when test="contains(@label,'img') and contains(@label,'src')">
                                                 <th id="{@name}">
                                                        <xsl:copy-of select="imageHeader/node()"/>
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
													<xsl:if test="settings/setting[@name='Sortable'] != 'false'">
														<xsl:attribute name="class">mx_sort-column</xsl:attribute>
													</xsl:if>
                                                        <xsl:variable name="columnIndex">
                                                               <xsl:choose>
                                                                      <xsl:when test="$tblName ='headTable'">
                                                                             <xsl:value-of select="position()+1"/>
                                                                      </xsl:when>
                                                                      <xsl:otherwise>
                                                                             <xsl:value-of select="position()"/>
                                                                      </xsl:otherwise>
                                                               </xsl:choose>
                                                        </xsl:variable>
                                                        <xsl:choose>
                                                               <xsl:when test="settings/setting[@name='Sortable'] = 'false'">
                                                                      <xsl:value-of select="@label"/>
                                                               </xsl:when>
                                                               <xsl:otherwise>
                                                                      <a href="javascript:sortTable({$columnIndex})">
                                                                             <xsl:value-of select="@label"/>
                                                                      </a>
                                                               </xsl:otherwise>
                                                        </xsl:choose>
                                                 </th>
                                          </xsl:otherwise>
                                   </xsl:choose>
                                   <th width="100%">&#160;</th>
                            </tr>
                     </table>
              </td>
              </xsl:if>
              <!-- <td class="mx_sizer" width="2"/> -->
       </xsl:template>
       <!-- END COLUMN RULES -->
       <!--    TABLE BODY -->
       <xsl:template name="treeBody">
              <xsl:apply-templates select="columns" mode="body">
                     <xsl:with-param name="tblName" select="'treeBodyTable'"/>
                     <xsl:with-param name="path" select="columns/column[position() &lt;= $split]"/>
              </xsl:apply-templates>
       </xsl:template>
       <xsl:template match="column" mode="treehiddenrowtag">
		<xsl:variable name="cellIndex" select="@index" />
		<xsl:variable name="rowNumber" select="settings/setting[@name = 'Row Number']"/>
		<xsl:variable name="displayMode">
            <xsl:choose>
                <xsl:when test="settings/setting[@name = 'Display Mode']">
                    <xsl:value-of select="settings/setting[@name='Display Mode']"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Both</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">
		<xsl:variable name="addToHiddenRow" select="settings/setting[@name = 'Add To Hidden Row']"/>
		<xsl:if test="$rowNumber = '1' or $addToHiddenRow = 'true'">				
		<xsl:if test="$cellIndex &gt; 1">
			<td id="ROW_{$cellIndex}">
				<xsl:attribute name="width">
					<xsl:choose>
						<xsl:when test="@type='separator'">6</xsl:when>
						<xsl:when test="@type='File'">25</xsl:when>
						<xsl:when
							test="settings/setting[@name='Width']">
							<xsl:value-of
								select="settings/setting[@name='Width']" />
						</xsl:when>
						<xsl:when
							test="(string-length(@label)*15) &gt; 205">
							205
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="(string-length(@label)*15)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</td>
			<!--<td width="2"/>-->
		</xsl:if>		
		<xsl:if test="$cellIndex = 1">
			<td width="1" position="-1"></td>	
			<xsl:if test="$reportType = 'Difference_Only_Report' or $reportType = 'Unique_toLeft_Report' or $reportType = 'Unique_toRight_Report' or $reportType = 'Common_Report'">
					<td id="ROW_{$cellIndex}">
				<xsl:attribute name="width">50</xsl:attribute>					
					</td>
			</xsl:if>
			<xsl:if test="$reportType = 'Complete_Summary_Report' and /mxRoot/tableControlMap/setting[@name='HasDiffCodeColumn']/value = 'true'">
					<td id="ROW_{$cellIndex}">
				<xsl:attribute name="width">50</xsl:attribute>					
				    </td>
			</xsl:if>			
				 <td id="ROW_{$cellIndex}">
				<xsl:choose>
					<xsl:when test="$toggle ='2'">
							<xsl:attribute name="width">30</xsl:attribute>															
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="settings/setting[@name='Width']">
								<xsl:attribute name="width"><xsl:value-of select="settings/setting[@name='Width']" /></xsl:attribute>															
							</xsl:when>
							<xsl:otherwise>
									<xsl:attribute name="width">200</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>	
				 </td>
		</xsl:if>
	</xsl:if>
	</xsl:if>
	</xsl:template>	
       <xsl:template match="columns" mode="body">
              <xsl:param name="tblName" select="bodyTable"/>
              <xsl:param name="path" select="column"/>
              <table id="{$tblName}">
              		<xsl:if test="$uiAutomation = 'true' ">
		            	<xsl:attribute name="data-aid"><xsl:value-of select="$dbTableName"/></xsl:attribute>
		            </xsl:if>
					<xsl:if test="$colorize = 'yes'">
						<xsl:attribute name="colorize">yes</xsl:attribute>
					</xsl:if>
                            <tr class="mx_hidden-row">
                                   <xsl:apply-templates select="column[position() &lt;= $split]" mode="treehiddenrowtag"/>
                            </tr>
                            <xsl:if test="not(/mxRoot/rows/r[1]) or /mxRoot/setting[@name='numberOfObjectsFiltered']/text() = '0'">
                                   <tr>
                                       <td align="center">
                                       <xsl:if test="number(count($path)*2) &gt; 1">
		                                 <xsl:attribute name="colspan">
				                            <xsl:value-of select="count($path)*2"/>
		                	              </xsl:attribute>
		                               </xsl:if>
                                          &#160;
                                       </td>
                                   </tr>
                            </xsl:if>
                            <xsl:if test="/mxRoot/setting[@name='first-row']/text() &gt; '0'">
                                   <tr height="{/mxRoot/setting[@name='tophiddenHeight']}">
                                          <td align="center" class="bgPattern">
                                     <xsl:if test="number(count($path)*2) &gt; 1">
		                                 <xsl:attribute name="colspan">
				                            <xsl:value-of select="count($path)*2"/>
		                	              </xsl:attribute>
		                               </xsl:if>
		                               </td>
                                   </tr>
                            </xsl:if>
                            <xsl:apply-templates select="/mxRoot/rows/r">
                                   <xsl:with-param name="tblName" select="$tblName"/>
                            </xsl:apply-templates>
                            <xsl:if test="(/mxRoot/setting[@name='total-rows']/text() - (/mxRoot/setting[@name='first-row']/text() + /mxRoot/setting[@name='page-size']/text()))  &gt; '0'">
                                   <tr height="{/mxRoot/setting[@name='bottomhiddenHeight']}">
                                          <td align="center" class="bgPattern">
                                       <xsl:if test="number(count($path)*2) &gt; 1">
		                                 <xsl:attribute name="colspan">
				                            <xsl:value-of select="count($path)*2"/>
		                	              </xsl:attribute>
		                               </xsl:if>
		                               </td>
                                   </tr>
                            </xsl:if>
              </table>
       </xsl:template>
       <xsl:template match="column" mode="body">
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
              <th height="18">
                     <xsl:choose>
                            <xsl:when test="@type='separator'">
                                   <xsl:attribute name="class">mx_separator</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                   <xsl:attribute name="width"><xsl:choose><xsl:when test="settings/setting[@name='Width']"><xsl:value-of select="settings/setting[@name='Width']"/></xsl:when><xsl:when test="(string-length(@label)*15) &gt; 205">205</xsl:when><xsl:otherwise><xsl:value-of select="(string-length(@label)*15)"/></xsl:otherwise></xsl:choose></xsl:attribute>
                            </xsl:otherwise>
                     </xsl:choose>
              </th>
              </xsl:if>
       </xsl:template>
       <!-- ROWS -->
       <xsl:template match="r">
              <xsl:param name="tblName" select="."/>
              <xsl:variable name="oid" select="string(@o)"/>
              <xsl:variable name="relId" select="string(@r)"/>
              <xsl:variable name="id" select="string(@id)"/>
              <xsl:variable name="rg" select="string(@rg)"/>
              <xsl:variable name="filter" select="string(@filter)" />
              <xsl:variable name="displayRow" select="string(@displayRow)" />
          	  <xsl:variable name="checked" select="string(@checked)" /> 
          	  <xsl:variable name="navigated" select="string(@navigated)" /> <!-- Added for Step through changes -->
            <xsl:variable name="height">
                <xsl:choose>
                	<xsl:when test="/mxRoot/requestMap/setting[@name='cellwrap'] = 'false'">
                		<xsl:text> </xsl:text>
                	</xsl:when>
                    <xsl:when test="@height">
                        <xsl:value-of select="string(@height)"/>
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
					<xsl:when test="/mxRoot/requestMap/setting[@name='cellwrap'] = 'false'">
                		<xsl:text> </xsl:text>
                	</xsl:when>
                    <xsl:when test="@height_row2">
                        <xsl:value-of select="string(@height_row2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>25</xsl:text>
                    </xsl:otherwise>
                 </xsl:choose>
            </xsl:variable>
            <xsl:variable name="css-class">
                <xsl:choose>
                  <xsl:when test="position() mod 2 = 0">mx_altRow</xsl:when>
                  <xsl:otherwise>even</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
          	  <xsl:variable name="error" select="string(@e)"/>             
          	  <xsl:variable name="objectName" select="./node()/@a"/>     
          	          
              <xsl:if test="not($displayRow = 'false')">
	              <xsl:if test="not($filter = 'true')">
		              <tr id="{$id}" o="{$oid}" r="{$relId}" height="{$height}">		             
		              		<xsl:if test="$uiAutomation = 'true' ">
		              			<xsl:attribute name="data-aid"><xsl:value-of select="$objectName"/></xsl:attribute>
		            		</xsl:if>		             
		                     <xsl:if test="ancestor::node()[@display = 'none']">
		                            <xsl:attribute name="style">display:none</xsl:attribute>
		                     </xsl:if>
							<xsl:choose>
								<xsl:when test="$error">
									<xsl:attribute name="class">error</xsl:attribute>
								</xsl:when>
								<xsl:when test="$rg">
									<xsl:attribute name="class"><xsl:value-of select="$rg" /> heading</xsl:attribute>
								</xsl:when>
								<xsl:when test="$checked = 'checked'">
									<xsl:attribute name="class"><xsl:value-of select="$css-class"/> mx_rowSelected</xsl:attribute>
									<xsl:if test="@level='0'">
									<xsl:attribute name="class">root-node <xsl:value-of select="$css-class"/> mx_rowSelected</xsl:attribute>
									</xsl:if>
								</xsl:when>
								<xsl:when test="@level='0'">
									<xsl:attribute name="class">root-node <xsl:value-of select="$css-class"/></xsl:attribute>
									<xsl:if test="$checked = 'checked'">
									<xsl:attribute name="class">root-node <xsl:value-of select="$css-class"/> mx_rowSelected</xsl:attribute>
									</xsl:if>
								</xsl:when>								
								
								<!-- Added for Step through changes -->
								<xsl:when test="$navigated = 'true' and $compare = 'TRUE'">
									<xsl:attribute name="class"><xsl:value-of select="$css-class"/> mx_rowHighlight</xsl:attribute>
									<xsl:if test="@level='0'">
									<xsl:attribute name="class">root-node <xsl:value-of select="$css-class"/> mx_rowHighlight</xsl:attribute>
									</xsl:if>
								</xsl:when>
								
																
								<xsl:otherwise>
									<xsl:attribute name="class"><xsl:value-of select="$css-class"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
		                     
		                     <xsl:apply-templates select="c" mode="right">
                     			<xsl:with-param name="rowNumber" select="'1'"/>
                     		 </xsl:apply-templates>
		              </tr>
					  
					<xsl:if test="/mxRoot/requestMap/setting[@name='HasMergedCell']/value = 'true'">
	              		<tr id="{$id}" o="{$oid}" r="{$relId}" height="{$height_row2}">
	              			<xsl:if test="$uiAutomation = 'true' ">
		              			<xsl:attribute name="data-aid"><xsl:value-of select="$objectName"/></xsl:attribute>
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
								
								<!-- Added for Step through changes -->
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
								<xsl:otherwise>
									<xsl:attribute name="class">even</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:if test="not($rg)">
							<xsl:apply-templates select="c" mode="right">
								<xsl:with-param name="rowNumber" select="'2'"/>
							</xsl:apply-templates>
							</xsl:if>
	              		</tr>
              		</xsl:if>
	              </xsl:if>
	          </xsl:if>
       </xsl:template>
       <xsl:template match="c" mode="right">
       		  <xsl:param name="rowNumber" select="."/>
              <xsl:variable name="level" select="parent::r[@level]"/>
              <xsl:choose>
                     <xsl:when test="parent::r/@level='0'">
                            <xsl:call-template name="tableBodyth">
                            	<xsl:with-param name="rowNumber" select="$rowNumber"/>
                            </xsl:call-template>
                     </xsl:when>
                     <xsl:otherwise>
                            <xsl:call-template name="tableBodytd">
                            	<xsl:with-param name="rowNumber" select="$rowNumber"/>
                            </xsl:call-template>
                     </xsl:otherwise>
              </xsl:choose>
       </xsl:template>

       <xsl:template name="tableBodytd">
       		  <xsl:param name="rowNumber" select="."/>
              <xsl:variable name="cellIndex" select="@index"/>
              <xsl:variable name="visualCue" select="string(parent::r/@visualCue)"/>
              <xsl:variable name="matchresult" select="string(parent::r/@matchresult)"/>
              <xsl:variable name="diffcode" select="string(parent::r/@diffcode)"/>
              <xsl:variable name="compareResult" select="string(@compareResult)"/>
              <xsl:variable name="columnSynch" select="string(@columnSynch)"/>
	      	  <xsl:variable name="status" select="parent::r/@status"/>
	      	  <xsl:variable name="id" select="parent::r/@id"/>
	      	  <xsl:variable name="relId" select="parent::r/@r" />
			  <xsl:variable name="parentOid" select="parent::r/@p" />
			  <xsl:variable name="oid" select="parent::r/@o"/>
			  <xsl:variable name="calc" select="parent::r/@calc"/>
              <xsl:variable name="currentColumn" select="key('columns', @index)"/>
              <xsl:variable name="colName" select="$currentColumn/@name"/>
              <xsl:variable name="expr" select="$currentColumn/@expression" />
              <xsl:variable name="currentSettings" select="$currentColumn/settings"/>
              <xsl:variable name="varFieldType" select="$currentSettings/setting[@name = 'Column Type']"/>
              <xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)"/>
              <xsl:variable name="isRequiredColumn" select="$currentSettings/setting[@name='Required']='true' or $currentSettings/setting[@name='Required']='TRUE'"/>
              <xsl:variable name="iFH" select="string(@iFH) = 'true'"/>
              <xsl:variable name="rg" select="parent::r/@rg"/>              
	      <xsl:variable name="styleColumn" select="string(@styleColumn)"/>
              <xsl:variable name="styleCell" select="string(@styleCell)"/>
              <xsl:variable name="styleRow" select="string(@styleRow)"/>
              <xsl:variable name="compareBy" select="$currentColumn/@compareBy" />
			  <xsl:variable name="facetColorClass">
				<!--		disable column colorization
				 			<xsl:if test="$currentColumn/@colorize = 'yes' ">
								<xsl:value-of select="string(@facetColoring)" />
							</xsl:if> 
				-->		
				</xsl:variable> 
			  <xsl:variable name="facetColorClass2"> <!-- always using facet color set on first column -->
				  <xsl:if test="$cellIndex = 1">
						<xsl:value-of select="string(@facetColoring)" />
				  </xsl:if>
			  </xsl:variable>
              
              <xsl:variable name="preserveSpacesCss">
                     <xsl:choose>
                            <xsl:when test="not($rg) and ($currentSettings/setting[@name='Preserve Spaces']='true' or $currentSettings/setting[@name='Preserve Spaces']='TRUE')">
                            	<xsl:text>verbatim</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                            	<xsl:text></xsl:text>    
                            </xsl:otherwise>
                     </xsl:choose>
              </xsl:variable>
              
              
			  <xsl:variable name="customStyle">  
				<xsl:choose>
						<xsl:when test="not($styleCell = '')">
							   <xsl:value-of select="string(@styleCell)"/>
						</xsl:when>
						<xsl:when test="not($styleRow = '')">
							   <xsl:value-of select="string(@styleRow)"/>
						</xsl:when>
						<xsl:when test="not($styleColumn = '')">
							   <xsl:value-of select="string(@styleColumn)"/>
						</xsl:when>
						<xsl:otherwise>
							   <xsl:value-of select="''"/>
						</xsl:otherwise>
				 </xsl:choose>
			</xsl:variable>  
			<xsl:variable name="displayMode">
                <xsl:choose>
                    <xsl:when test="$currentSettings/setting[@name = 'Display Mode']">
                        <xsl:value-of select="$currentSettings/setting[@name='Display Mode']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Both</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>  
	 <xsl:if test="$displayMode = 'Both' or ($displayMode = $sbMode)">
              <xsl:if test="position() = 1 and ($reportType = 'Difference_Only_Report' or $reportType = 'Unique_toLeft_Report' or $reportType = 'Unique_toRight_Report' or $reportType = 'Common_Report')" >
              	<td>&#160;<xsl:value-of select="number(parent::r/@level)"/></td>
              </xsl:if>
              <xsl:if test="position() = 1 and $reportType = 'Complete_Summary_Report' and /mxRoot/tableControlMap/setting[@name='HasDiffCodeColumn']/value = 'true'" >
              	<td style="white-space:pre-wrap;">
              	<xsl:choose>
					<xsl:when test="$diffcode = 'SUMMOD' and $showSummaryIcons = 'true'">
						<a href="javascript:;"><img src="images/iconSmallPreviousCostClass.png"/></a>
					</xsl:when>
					<xsl:when test="$diffcode = 'ADD' and $showDiffCodeIcon = 'true'">
						<a href="javascript:;"><img src="images/iconStatusAdded.gif"/></a>
					</xsl:when>
					<xsl:when test="$diffcode = 'DEL' and $showDiffCodeIcon = 'true'">
						<a href="javascript:;"><img src="images/iconStatusRemoved.gif"/></a>
					</xsl:when>
					<xsl:when test="$diffcode = 'MOD' and $showDiffCodeIcon = 'true'">
						<a href="javascript:;"><img src="images/iconStatusChanged.gif"/></a>
					</xsl:when>
					<xsl:when test="$diffcode = 'RESEQ' and $showDiffCodeIcon = 'true'">
						<a href="javascript:;"><img src="images/iconStatusResequenced.gif"/></a>
					</xsl:when>
					<xsl:otherwise><xsl:value-of select="$diffcode"/></xsl:otherwise>
					 
				 </xsl:choose>
              	</td>
              </xsl:if>
              <xsl:variable name="rmbid">
               <xsl:choose>
                      <xsl:when test="@altOID">
                             <xsl:value-of select="@altOID"/>
                      </xsl:when>
                      <xsl:otherwise>
                             <xsl:value-of select="../@o"/>
                      </xsl:otherwise>
               </xsl:choose>
              </xsl:variable>
			  <xsl:variable name="RMBMenu" select="$currentSettings/setting[@name = 'RMB Menu']"/>
			<xsl:if test="$currentSettings/setting[@name='Row Number'] = $rowNumber">
              <xsl:if test="$cellIndex &lt;= $split and $cellIndex != $toggle">
					<xsl:if test="$cellIndex = 1">
						<td class="{$facetColorClass2}" position="-1">
							<xsl:if test="not($rg)">
								<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
									<xsl:attribute name="rowspan">
										<xsl:value-of select="$currentSettings/setting[@name='Row Span']" />
									</xsl:attribute>
								</xsl:if>
							</xsl:if>
						</td>
					</xsl:if>
				
                     <td position="{$cellIndex}" rmbID ="{$rmbid}" rmbrow="{$id}" rowNumber="{$currentSettings/setting[@name='Row Number']}">
                        <xsl:if test="string-length($RMBMenu) &gt; 0 ">
		                    <xsl:attribute name="rmb"><xsl:value-of select="$RMBMenu"/></xsl:attribute>
		                </xsl:if>
                     	<xsl:if test="not($rg)">
					<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
						<xsl:attribute name="rowspan">
							<xsl:value-of select="$currentSettings/setting[@name='Row Span']"/>
						</xsl:attribute>
					</xsl:if>
					
			<xsl:if test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
					<xsl:attribute name="colspan">
						<xsl:value-of select="$currentSettings/setting[@name='Column Span'] div 2 + 1"/>
					</xsl:attribute>
			</xsl:if>

						<xsl:if test="$currentSettings/setting[@name='Row Span']/text() = '2'">
							<xsl:attribute name="style">height: 50px;</xsl:attribute>
						</xsl:if>
                     	</xsl:if>
                    <!-- first place we can add a class
                        add facetColor here as the default. We will add facet color to each style -->
                        <xsl:if test="not($preserveSpacesCss = '')">
                                <xsl:attribute name="class"><xsl:value-of select="$preserveSpacesCss"/></xsl:attribute>
                            </xsl:if>
                        <xsl:if test="not($facetColorClass = '')">
                             <xsl:attribute name="class"><xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                        </xsl:if>                     	
						<xsl:if test="not($customStyle = '')">
							<xsl:attribute name="class"><xsl:value-of select="concat($customStyle, ' ', $preserveSpacesCss)"/></xsl:attribute>
						 </xsl:if>
                            		<xsl:choose>                        
                          		<xsl:when test="not($status = 'cut' or $status = 'add' or $status = 'resequence' or $status = 'new' or $status = 'lookup')"> 
                            		<xsl:choose>                        
		                                   <xsl:when test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
		                                          <xsl:choose>
		                                                 <xsl:when test="@edited='true'">
		                                                        <xsl:choose>
																		<xsl:when test="$isRequiredColumn">
																			<xsl:attribute name="class">mx_editable mx_required mx_edited <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																		</xsl:when>
																		<xsl:otherwise>
		                                                        <xsl:attribute name="class">mx_editable mx_edited <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																		</xsl:otherwise>
																</xsl:choose>
		                                                 </xsl:when>
														 <xsl:when test="not($customStyle = '')">
															<xsl:choose>
																 <xsl:when test="@edited='true'">
																		<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_edited <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																 </xsl:when>
																 <xsl:when test="$isRequiredColumn">
																		<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																 </xsl:when>
																 <xsl:otherwise>
																		<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																 </xsl:otherwise>
															</xsl:choose>
														 </xsl:when>
		                                                 <xsl:otherwise>
	                                                        <xsl:if test="not(/mxRoot/setting[@name = 'sbMode'] = 'view')">
		                                                        <xsl:choose>
																	<xsl:when test="$isRequiredColumn">
																		<xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																	</xsl:when>
																	<xsl:otherwise>
																	<xsl:choose>
																		<xsl:when test="$styleColumn">
																		<xsl:attribute name="class">mx_editable  <xsl:value-of select="concat($facetColorClass, ' ', $styleColumn, ' ', $preserveSpacesCss)"/></xsl:attribute>
																	</xsl:when>
																	<xsl:otherwise>
																	<xsl:attribute name="class">mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																	</xsl:otherwise>
																</xsl:choose>
																	</xsl:otherwise>
																</xsl:choose>
															</xsl:if>
		                                                 </xsl:otherwise>
		                                          </xsl:choose>
		                                 	</xsl:when>
                                 		</xsl:choose>   
                                   </xsl:when>
                                   <xsl:otherwise>
                                          <xsl:choose>
	                                          <xsl:when test="$status = 'cut'">
	                                          	<xsl:attribute name="class">mx_cut <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                          <xsl:when test="$status = 'add' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">	                                          	
                                                <xsl:choose>
                                                	  <xsl:when test="@edited='true'">
                                                        <xsl:choose>
															<xsl:when test="$isRequiredColumn">
																<xsl:attribute name="class">mx_editable mx_required mx_edited mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
															</xsl:when>
															<xsl:otherwise>
                                                       			<xsl:attribute name="class">mx_editable mx_edited mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
															</xsl:otherwise>
														</xsl:choose>
                                                    </xsl:when>
													<xsl:when test="$isRequiredColumn">
														<xsl:attribute name="class">mx_editable mx_required mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
													</xsl:when>
													<xsl:otherwise>
                                                <xsl:attribute name="class">mx_editable mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>		                                                 
													</xsl:otherwise>
												</xsl:choose>			                                                 
	                                          </xsl:when>
	                                          <xsl:when test="$status = 'add' and $currentSettings/setting[@name='Editable']='false'">
	                                          	<xsl:attribute name="class">mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                          <xsl:when test="$status = 'resequence'">
	                                          	<xsl:attribute name="class">mx_resequence <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
						                        <xsl:when test="$status = 'new' and ($currentSettings/setting/@name='Add Input Type')">
						                            <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
						                        </xsl:when>
						                       
						                        <xsl:when test="$status = 'lookup' and ($currentSettings/setting/@name='Lookup Input Type')">
						                           <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
						                        
						                        <xsl:when test="($status = 'new' or $status = 'lookup') and $isRequiredColumn">
						                           <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
						                        </xsl:when>
						                        
						                        <xsl:when test="$status = 'new' or $status = 'lookup'">
						                            <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
						                        </xsl:when>                 
	                                          <xsl:otherwise>
													<xsl:choose>
														<xsl:when test="@editMask = 'false'">
															<xsl:attribute name="class"><xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
														</xsl:when>
														<xsl:otherwise>
	                                          	<xsl:attribute name="class">mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                                   </xsl:otherwise>
                            </xsl:choose>
								</xsl:otherwise>
                            </xsl:choose>                            
								</xsl:otherwise>
                            </xsl:choose>                            
							                        
                            <!-- Added for highlight entire row -->                
                             <xsl:if test="$matchresult = 'left'">
                            	<xsl:attribute name="class">mx_unique-row <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                    		</xsl:if> 
                            <xsl:if test="$compareResult='different'">
                            	<xsl:attribute name="class">mx_common-attribute-change <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                            </xsl:if>
                             <xsl:if test="$compareBy = 'false'">
								<xsl:attribute name="class">mx_no-compare-column</xsl:attribute>
							</xsl:if>
							
                            <xsl:if test="$columnSynch='true'">
                            	<xsl:choose>
                            		<xsl:when test="@edited='true'">
                            			<xsl:attribute name="class">mx_attr-change <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                            		</xsl:when>
                            		<xsl:otherwise>
                            			<xsl:attribute name="class">mx_sync-row <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                            		</xsl:otherwise>                            	
                            	</xsl:choose>                            	
                            </xsl:if>
                            <xsl:if test="$visualCue ='true'">
		                        		<xsl:attribute name="class">retainedRows <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
		            			</xsl:if> 
		            			
		            		<!-- Added markup for sync operation--> 
							<xsl:if test="$status='cut' and $compare = 'TRUE' and $matchresult='left'">
								<xsl:attribute name="class">mx_cut <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='right'">
								<xsl:attribute name="class">mx_add <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='left'">
								<xsl:attribute name="class">mx_rowStyle <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if> 
							 
		            		<xsl:if test="$calc">
		                        		<xsl:attribute name="class">calculatedRows <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
		            			</xsl:if> 
                            
                            <xsl:choose>
                                   <xsl:when test="$currentColumn/@type='separator'">
                                          <xsl:attribute name="class">mx_separator</xsl:attribute>
                                   </xsl:when>
                                   <xsl:when test="$currentColumn/@type='businessobject' and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'] or $iFH)">
                       
                        <xsl:attribute name="title">
                            <xsl:choose>
                            <xsl:when test="./mxLink">
                                <xsl:for-each select="./mxLink/node()">
                                    <xsl:value-of select="."/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                            	<xsl:value-of select="text()"/>
                            </xsl:otherwise>
                            </xsl:choose>
                         </xsl:attribute>
                        
                         <xsl:if test="@i and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
                                   <img src="{@i}" border="0" height="16" />
                         </xsl:if>
                            
                                          <xsl:variable name="href">
                                                 <xsl:if test="$currentColumn/@href and not($status = 'new') and not($status = 'lookup')">
                                                        <xsl:call-template name="href">
                                                               <xsl:with-param name="col" select="$currentColumn"/>
                                                        </xsl:call-template>
                                                 </xsl:if>
                                          </xsl:variable>
                                          <xsl:choose>
                                                 <!-- cell with href -->
                                                 <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!') and ($isFromCtxSearch = 'false')">
                                                        <xsl:element name="a">
                                                                <xsl:if test="$expr = 'name'">
				                                                    <xsl:attribute name="class">
				                                                        <xsl:value-of select="'object'" />
				                                                    </xsl:attribute>
				                                                </xsl:if>
				                                                <xsl:attribute name="data-oid">
				                                                	<xsl:value-of select="$oid" />
				                                                </xsl:attribute>
				                                                <xsl:attribute name="data-icon">
				                                                	<xsl:value-of select="@i" />
				                                                </xsl:attribute>
                                                               <xsl:attribute name="href"><xsl:value-of select="normalize-space($href)"/></xsl:attribute>
                                                               <xsl:value-of select="."/>
                                                        </xsl:element>
                                                 </xsl:when>
                            <xsl:when test="./mxLink">
                                                    	<xsl:choose>
                                                    		 <xsl:when test="$currentSettings/setting[@name='isMultiVal'] = 'true'">
                                                    		  <table class= "multi-attr">
                                                    		   <xsl:for-each select="./mxLink/node()">
                                                          				  <tr><td><xsl:copy-of select="."/></td></tr>
                                                       			</xsl:for-each>
                                                       			 </table>
                                                    		 </xsl:when>
                                                    	<xsl:otherwise>
                                <xsl:for-each select="./mxLink/node()">
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                                                    	</xsl:otherwise>                                                        
                                                        </xsl:choose>
                            </xsl:when>
                                                 <!--cell without href -->
                                                 <xsl:otherwise>
                                                    <xsl:choose>
	                                                        		 <xsl:when test="$currentSettings/setting[@name='isMultiVal'] = 'true'">
	                                                        		 <table class = "multi-attr">
	                                          		             		 <xsl:variable name="strData" select="."/>
	                                           								<xsl:call-template name="splitByDelimiter">
																            <xsl:with-param name="str" select="$strData"/>
																        </xsl:call-template>
	                                                       		 </table>
	                                                       		</xsl:when>
                                                        <xsl:when test="$expr = 'name'">
		                                                  			  <span class="object">
		                                                        <xsl:value-of select="."/>
		                                                    </span>
		                                                </xsl:when>
		                                                <xsl:otherwise>
		                                                    <xsl:value-of select="."/>
		                                                </xsl:otherwise>
                                                    </xsl:choose>
                                                 </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:when>
                                  
                                   <xsl:when test="$currentColumn/@type='checkbox'" >
                                   		<input type="checkbox" class="small" name="chkList" id="rmbrow-{$id}"
													value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
													 onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">
													 
												<xsl:if test="(string(@a) = 'false') or (parent::r/@disableSelection = 'true')"> 
													 	<xsl:attribute name="disabled">true</xsl:attribute>
												</xsl:if>
												<xsl:if test="parent::r/@checked = 'checked'">
													<xsl:attribute name="checked">
														<xsl:value-of select="parent::r/@checked" />
													</xsl:attribute>
												</xsl:if>
										</input>
									</xsl:when>
                                   
                                   
                                   <!-- ICON COLUMN -->
                                   <xsl:when test="$currentColumn/@type='icon' and 
                                            not(@editMask and contains($currentSettings/setting[@name='Column Icon'],'iconActionEdit')) and not($calc = 'true')">
                                          <xsl:call-template name="iconColumn">
                                                 <xsl:with-param name="col" select="$currentColumn"/>
                                          </xsl:call-template>
                                   </xsl:when>
                                   <!--
                        PROGRAM HTML OR FILE
                    -->
                                   <xsl:when test="$iFH">
                                           <xsl:attribute name="iFH">true</xsl:attribute>
                                           <xsl:call-template name="rte"></xsl:call-template>
                                  </xsl:when>
                                  <xsl:when test="$currentColumn/@type='programHTMLOutput' or $currentColumn/@type='File'">
                                          <xsl:for-each select="./node()">
                                                 <xsl:choose>
                                                        <xsl:when test="@FPRootCol = 'true'">
                                                               <xsl:choose>
                                                                        <xsl:when test="$currentColumn/setting[@name = 'Root Label']">
                                                               <xsl:value-of select="/mxRoot/tableControlMap/setting[@name='ObjectInfo']/items/item[@name='name']/value"/>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                                <xsl:copy-of select="."/>
                                                                        </xsl:otherwise>
                                                                </xsl:choose>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                               <xsl:copy-of select="."/>
                                                        </xsl:otherwise>
                                                 </xsl:choose>
                                          </xsl:for-each>
                                   </xsl:when>
                                   <xsl:when test="$currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression']">
                                          <xsl:for-each select="./node()">
                                                 <xsl:copy-of select="."/>
                                          </xsl:for-each>
                                   </xsl:when>
                                   <!--
                        IMAGE
                    -->
                                   <xsl:when test="$Field_Type = 'image'">
                                          <xsl:variable name="href">
                                                 <xsl:call-template name="href">
                                                        <xsl:with-param name="col" select="$currentColumn"/>
                                                 </xsl:call-template>
                                          </xsl:variable>
                                          <xsl:choose>
	                                          <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')">
                                          <xsl:element name="a">
                                                 <xsl:attribute name="href"><xsl:value-of select="normalize-space($href)"/></xsl:attribute>
                                                 <xsl:for-each select="./node()">
                                                        <xsl:copy-of select="."/>
                                                 </xsl:for-each>
                                          </xsl:element>
                                   </xsl:when>
                                   <xsl:otherwise>
                                   <xsl:for-each select="./node()">
		                                              <xsl:copy-of select="."/>
		                                          </xsl:for-each>
		                                      </xsl:otherwise>
		                                  </xsl:choose>
                                   </xsl:when>
                                   <xsl:otherwise>
                       <xsl:attribute name="title">
                            <xsl:choose>
                            <xsl:when test="./mxLink">
                                <xsl:for-each select="./mxLink/node()">
                                          <xsl:value-of select="."/>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                            </xsl:choose>
                         </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="./mxLink">
                                    <xsl:for-each select="./mxLink/node()">
                                        <xsl:copy-of select="."/>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                                   </xsl:otherwise>
                            </xsl:choose>
			    <xsl:variable name="oldVal" select="@a"/>
                            <xsl:variable name="newVal" select="."/>
                            <xsl:if test="@edited='true' and not(string($oldVal) = string($newVal))">
	                            <span>&#160;</span>
	                            <span class="original-value"><xsl:value-of select="@d" /></span>
                            </xsl:if>
                     </td>
			  </xsl:if>
	          <xsl:if test="$cellIndex = $toggle">
					<xsl:if test="$cellIndex = 1">
						<td class="{$facetColorClass2}" position="-1">
							<xsl:if test="not($rg)">
								<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
									<xsl:attribute name="rowspan">
										<xsl:value-of select="$currentSettings/setting[@name='Row Span']" />
									</xsl:attribute>
								</xsl:if>
							</xsl:if>
						</td>
					</xsl:if>
                 <td position="{$cellIndex}" rowNumber="{$currentSettings/setting[@name='Row Number']}" rmbID ="{$rmbid}" rmbrow="{$id}" >				
                   <xsl:if test="string-length($RMBMenu) &gt; 0 ">
		                <xsl:attribute name="rmb"><xsl:value-of select="$RMBMenu"/></xsl:attribute>
		            </xsl:if>
                 	<xsl:if test="$uiAutomation = 'true' ">
		              	<xsl:attribute name="data-aid"><xsl:value-of select="$colName"/></xsl:attribute>
		            </xsl:if>				
					<xsl:if test="not($rg)">
					<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
					<xsl:attribute name="rowspan">
						<xsl:value-of select="$currentSettings/setting[@name='Row Span']"/>
					</xsl:attribute>
					</xsl:if>
					
			     <xsl:if test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
					  <xsl:attribute name="colspan">
						 <xsl:value-of select="$currentSettings/setting[@name='Column Span'] div 2 + 1"/>
					  </xsl:attribute>
			      </xsl:if>
					
					<xsl:if test="$currentSettings/setting[@name='Row Span']/text() = '2'">
						<xsl:attribute name="style">height: 50px;</xsl:attribute>
					</xsl:if>
					</xsl:if>
					<xsl:if test="not($customStyle = '')">
						<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> <xsl:value-of select="$facetColorClass" /></xsl:attribute>
					 </xsl:if>
	          		<xsl:choose>                        
	                   <xsl:when test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
	                          <xsl:choose>
	                                 <xsl:when test="@edited='true'">
	                                      <xsl:choose>
												<xsl:when test="$isRequiredColumn">
													<xsl:attribute name="class">mx_editable mx_required mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
                                                    <xsl:attribute name="class">mx_editable mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												</xsl:otherwise>
										</xsl:choose>
	                                 </xsl:when>
									 <xsl:when test="not($customStyle = '')">
										<xsl:choose>
											  <xsl:when test="@edited='true'">
			                                      <xsl:choose>
														<xsl:when test="$isRequiredColumn">
															<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_required mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
														</xsl:when>
														<xsl:otherwise>
		                                                    <xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
														</xsl:otherwise>
												</xsl:choose>
											 </xsl:when>
											 <xsl:otherwise>
													<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable <xsl:value-of select="$facetColorClass" /></xsl:attribute>
											 </xsl:otherwise>
										</xsl:choose>
									 </xsl:when>
	                                 <xsl:otherwise>
                           		 		<xsl:choose>
                                      		<xsl:when test="not(/mxRoot/setting[@name = 'sbMode'] = 'view')">
                                               <xsl:choose>
												   <xsl:when test="$isRequiredColumn">
													    <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												   </xsl:when>
												   <xsl:otherwise>
		                                            	<xsl:attribute name="class">mx_editable <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												   </xsl:otherwise>
												</xsl:choose>
											</xsl:when>
                                   		</xsl:choose>
	                                 </xsl:otherwise>
	                          </xsl:choose>
	                 	</xsl:when>
	               	</xsl:choose> 
	             	<xsl:if test="parent::r/@checked='checked' or $visualCue ='true'">
						<xsl:choose>                        
	                         <xsl:when test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
                                <xsl:choose>
                                     <xsl:when test="@edited='true'">
                                            <xsl:choose>
												<xsl:when test="$isRequiredColumn">
													<xsl:attribute name="class">mx_editable mx_required mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
                                                    <xsl:attribute name="class">mx_editable mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
                                     </xsl:when>
                                     <xsl:when test="not($customStyle = '')">
										<xsl:choose>
											  <xsl:when test="@edited='true'">
			                                      <xsl:choose>
														<xsl:when test="$isRequiredColumn">
															<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_required mx_edited mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
														</xsl:when>
														<xsl:otherwise>
		                                                    <xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_edited mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
														</xsl:otherwise>
												</xsl:choose>
	                                 		 </xsl:when>
	                                 		 <xsl:when test="$isRequiredColumn">
													<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_required mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
											</xsl:when>
											 <xsl:otherwise>
													<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
											 </xsl:otherwise>
										</xsl:choose>
									 </xsl:when>
									 <xsl:when test="$isRequiredColumn">
										<xsl:attribute name="class"> mx_editable mx_required mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
									 </xsl:when>
                                     <xsl:otherwise>
                                            <xsl:attribute name="class">mx_editable mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                                     </xsl:otherwise>
                                </xsl:choose>
                       		</xsl:when>
	                       	<xsl:otherwise>
	                       		<xsl:attribute name="class">mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
	                       	</xsl:otherwise>
                     	</xsl:choose>
					</xsl:if>
		            <xsl:if test="$matchresult = 'left'">
                            	<xsl:attribute name="class">mx_unique-row <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$compareResult='different'">
                            	<xsl:attribute name="class">mx_common-attribute-change <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$compareBy = 'false'">
								<xsl:attribute name="class">mx_no-compare-column</xsl:attribute>
					</xsl:if>
					 <!-- Added markup for sync operation -->
							<xsl:if test="$status='cut' and $compare = 'TRUE' and $matchresult='left'">
								<xsl:attribute name="class">mx_cut <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='right'">
								<xsl:attribute name="class">mx_add <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if>   
							
							<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='left'">
								<xsl:attribute name="class">mx_rowStyle <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if> 
					
                    <xsl:if test="$calc='true'">
                         <xsl:attribute name="class">calculatedRows <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                    </xsl:if>
                    <xsl:choose>
                    
                    	<xsl:when test="$status = 'new' and ($currentSettings/setting/@name='Add Input Type')">
                            <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
	                    </xsl:when>
                       
                        <xsl:when test="$status = 'lookup' and ($currentSettings/setting/@name='Lookup Input Type')">
                           <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
	                    </xsl:when>
                        
                        <xsl:when test="($status = 'new' or $status = 'lookup') and $isRequiredColumn">
							<xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
						</xsl:when>
                        
                        <xsl:when test="$status = 'new' or $status = 'lookup'">
                            <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
	                    </xsl:when>
                    </xsl:choose> 
              	<xsl:call-template name="treeBodytd">
              		<xsl:with-param name="rowNumber" select="$rowNumber"/>
              	</xsl:call-template>
                </td>
           </xsl:if>
       </xsl:if>
       <xsl:if test="$split = 1 and $rowNumber = '2'">
        <td>&#160;</td>
       </xsl:if>
       <xsl:if test="$currentSettings/setting[@name='BlankCell'] = 'true' and $rowNumber = '2'">
		<td>
			<xsl:if test="not($rg)">
			<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
			<xsl:attribute name="rowspan">
				<xsl:value-of select="$currentSettings/setting[@name='Row Span']"/>
			</xsl:attribute>
			</xsl:if>
			
			<xsl:if test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
					<xsl:attribute name="colspan">
						<xsl:value-of select="$currentSettings/setting[@name='Column Span'] div 2 + 1"/>
					</xsl:attribute>
			</xsl:if>
			</xsl:if>
			<xsl:if test="/mxRoot/setting[@name = 'sbMode'] = 'view' and parent::r/@checked='checked'">
				<xsl:attribute name="class">mx_rowStyle <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
			</xsl:if>
			&#160;
		</td>
		</xsl:if>
		</xsl:if>
	</xsl:template>
	
	 <xsl:template name="rte">
	    <xsl:for-each select="./node()">
              <xsl:choose>
                  <xsl:when test="name(.) != 'br'">
                       <xsl:choose>
        		          <xsl:when test="name(.) = 'p'">
          					  <xsl:call-template name="rte"></xsl:call-template>
       			  		  </xsl:when>
             	  		  <xsl:otherwise>
         					  <xsl:copy-of select="."/>
        		          </xsl:otherwise>
                       </xsl:choose>   
                  </xsl:when>
              </xsl:choose>
        </xsl:for-each>
	 </xsl:template>
	 
       <xsl:template name="tableBodyth">
       		<xsl:param name="rowNumber" select="."/>
              <xsl:variable name="cellIndex" select="position()"/>
              <xsl:variable name="visualCue" select="string(parent::r/@visualCue)"/>
	      	  <xsl:variable name="status" select="parent::r/@status"/>
	      	  <xsl:variable name="id" select="parent::r/@id" />
	      	  <xsl:variable name="relId" select="parent::r/@r" />
			  <xsl:variable name="parentOid" select="parent::r/@p" />
			  <xsl:variable name="oid" select="parent::r/@o"/>
	      	  <xsl:variable name="currentColumn" select="key('columns', @index)"/>
	      	  <xsl:variable name="colName" select="$currentColumn/@name"/>
              <xsl:variable name="expr" select="$currentColumn/@expression" />
              <xsl:variable name="currentSettings" select="$currentColumn/settings"/>
              <xsl:variable name="varFieldType" select="$currentSettings/setting[@name = 'Column Type']"/>
              <xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)"/>
              <xsl:variable name="isRequiredColumn" select="$currentSettings/setting[@name='Required']='true' or $currentSettings/setting[@name='Required']='TRUE'"/>
              <xsl:variable name="settingRowSpan" select="$currentSettings/setting[@name='Row Span']"/>
		      <xsl:variable name="iFH" select="string(@iFH) = 'true'"/>
		      <xsl:variable name="rg" select="parent::r/@rg"/>
		<xsl:variable name="styleColumn" select="string(@styleColumn)"/>
              <xsl:variable name="styleCell" select="string(@styleCell)"/>
              <xsl:variable name="styleRow" select="string(@styleRow)"/>  
              <xsl:variable name="compareBy" select="$currentColumn/@compareBy" />
              <xsl:variable name="matchresult" select="string(parent::r/@matchresult)"/>
              
              <xsl:variable name="preserveSpacesCss">
                  <xsl:choose>
                      <xsl:when test="not($rg) and ($currentSettings/setting[@name='Preserve Spaces']='true' or $currentSettings/setting[@name='Preserve Spaces']='TRUE')">
                      	<xsl:text>verbatim</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                      	<xsl:text></xsl:text>    
                      </xsl:otherwise>
                  </xsl:choose>
              </xsl:variable>
			  <xsl:variable name="customStyle">  
					<xsl:choose>
							<xsl:when test="not($styleCell = '')">
								   <xsl:value-of select="string(@styleCell)"/>
							</xsl:when>
							<xsl:when test="not($styleRow = '')">
								   <xsl:value-of select="string(@styleRow)"/>
							</xsl:when>
							<xsl:when test="not($styleColumn = '')">
								   <xsl:value-of select="string(@styleColumn)"/>
							</xsl:when>
							<xsl:otherwise>
								   <xsl:value-of select="''"/>
							</xsl:otherwise>
					 </xsl:choose>
				</xsl:variable>  
				<xsl:variable name="facetColorClass">
				<!-- disable column colorization
				 			<xsl:if test="$currentColumn/@colorize = 'yes'">
								<xsl:value-of select="string(@facetColoring)" />
							</xsl:if>  
				-->
				</xsl:variable>
				<xsl:variable name="facetColorClass2">
					<xsl:if test="$cellIndex = 1">
						<xsl:value-of select="string(@facetColoring)" />
					</xsl:if>
				</xsl:variable>
              <xsl:if test="position() = 1 and ($reportType = 'Difference_Only_Report' or $reportType = 'Unique_toLeft_Report' or $reportType = 'Unique_toRight_Report' or $reportType = 'Common_Report')">
              	<td>&#160;<xsl:value-of select="number(parent::r/@level)"/></td>
              </xsl:if>
              <xsl:if test="position() = 1 and $reportType = 'Complete_Summary_Report' and /mxRoot/tableControlMap/setting[@name='HasDiffCodeColumn']/value = 'true'">
              	<td>&#160;<xsl:value-of select="''"/></td>
              </xsl:if>
              <xsl:variable name="rmbid">
                     <xsl:choose>
                            <xsl:when test="@altOID">
                                   <xsl:value-of select="@altOID"/>
                            </xsl:when>
                            <xsl:otherwise>
                                   <xsl:value-of select="../@o"/>
                            </xsl:otherwise>
                     </xsl:choose>
              </xsl:variable>
			  <xsl:variable name="RMBMenu" select="$currentSettings/setting[@name = 'RMB Menu']"/>
			  <xsl:variable name="displayMode">
                <xsl:choose>
                    <xsl:when test="$currentSettings/setting[@name = 'Display Mode']">
                        <xsl:value-of select="$currentSettings/setting[@name='Display Mode']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Both</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
    		<xsl:if test="($displayMode = 'Both' or $displayMode = $sbMode)">
              <xsl:if test="$currentSettings/setting[@name='Row Number'] = $rowNumber">
				<xsl:if test="$cellIndex &lt;= $split and $cellIndex != $toggle">
					<xsl:if test="$cellIndex = 1">
						<td class="{$facetColorClass2}" position="-1">
							<xsl:if test="not($rg)">
								<xsl:if test="number($settingRowSpan) &gt; 1">
									<xsl:attribute name="rowspan">
										  <xsl:value-of select="$settingRowSpan" />
									</xsl:attribute>
								</xsl:if>
							</xsl:if>
						</td>
					</xsl:if>
                     <td position="{$cellIndex}" rmbID ="{$rmbid}" rmbrow="{$id}"  rowNumber="{$currentSettings/setting[@name='Row Number']}">
					    <xsl:if test="string-length($RMBMenu) &gt; 0 ">
		                    <xsl:attribute name="rmb"><xsl:value-of select="$RMBMenu"/></xsl:attribute>
		                </xsl:if>
						<xsl:if test="not($rg)">
						 <xsl:if test="number($settingRowSpan) &gt; 1">
						 	<xsl:attribute name="rowspan">
						 	  <xsl:value-of select="$settingRowSpan"/>
						 	</xsl:attribute>
				   		</xsl:if>
			           <xsl:if test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
					      <xsl:attribute name="colspan">
						      <xsl:value-of select="$currentSettings/setting[@name='Column Span'] div 2 + 1"/>
					     </xsl:attribute>
			          </xsl:if>
						
						<xsl:if test="$currentSettings/setting[@name='Row Span']/text() = '2'">
							<xsl:attribute name="style">height: 50px;</xsl:attribute>
						</xsl:if>
						</xsl:if>
                    <!-- first place we can add a class
                        add facetColor here as the default. We will add facet color to each style -->
                        <xsl:if test="not($preserveSpacesCss = '')">
                            <xsl:attribute name="class"><xsl:value-of select="$preserveSpacesCss"/></xsl:attribute>
                        </xsl:if>
                        <xsl:if test="not($facetColorClass = '')">
                            <xsl:attribute name="class"><xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                        </xsl:if> 
						<xsl:if test="not($customStyle = '')">
							<xsl:attribute name="class"><xsl:value-of select="concat($customStyle, ' ', $facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
						 </xsl:if>
						
						
                          <xsl:choose>
                            	<xsl:when test="/mxRoot/setting[@name = 'sbMode'] = 'view' and parent::r/@checked='checked'">
                            		<xsl:attribute name="class">mx_rowStyle <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                            	</xsl:when>
                            	<xsl:otherwise>
                          <xsl:choose>
                          
                            	<xsl:when test="not($status = 'cut' or $status = 'add' or $status = 'resequence' or $status = 'new' or $status = 'lookup')"> 
                            		<xsl:choose>                        
		                                   <xsl:when test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
		                                          <xsl:choose>
		                                                 <xsl:when test="@edited='true'">
		                                                         <xsl:choose>
																		<xsl:when test="$isRequiredColumn">
																			<xsl:attribute name="class">mx_editable mx_required mx_edited <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																		</xsl:when>
																		<xsl:otherwise>
		                                                        <xsl:attribute name="class">mx_editable mx_edited <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																		</xsl:otherwise>
																</xsl:choose>
		                                                 </xsl:when>
														 <xsl:when test="not($customStyle = '')">
															<xsl:choose>
																 <xsl:when test="@edited='true'">
																	 <xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_edited <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																 </xsl:when>
																  <xsl:when test="$isRequiredColumn">
																	 <xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	 														 	 </xsl:when>
																 <xsl:otherwise>
																	 <xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																 </xsl:otherwise>
															</xsl:choose>
														 </xsl:when>
		                                                 <xsl:otherwise>
	                                                         <xsl:choose>
			                                           			<xsl:when test="not(/mxRoot/setting[@name = 'sbMode'] = 'view')">
			                                                        <xsl:choose>
																		<xsl:when test="$isRequiredColumn">
																			<xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																		</xsl:when>
																		<xsl:when test="$styleColumn">
																		<xsl:attribute name="class">mx_editable <xsl:value-of select="concat($styleColumn, ' ', $facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																		</xsl:when>
																		<xsl:otherwise>
		                                                        			<xsl:attribute name="class">mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
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
	                                          	<xsl:attribute name="class">mx_cut <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                          <xsl:when test="$status = 'add' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">	                                          	
                                                 <xsl:choose>
                                                 	   <xsl:when test="@edited='true'">
	                                                        <xsl:choose>
																<xsl:when test="$isRequiredColumn">
																	<xsl:attribute name="class">mx_editable mx_required mx_edited mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																</xsl:when>
																<xsl:otherwise>
                                                        			<xsl:attribute name="class">mx_editable mx_edited mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																</xsl:otherwise>
															</xsl:choose>
	                                                    </xsl:when>
														<xsl:when test="$isRequiredColumn">
															<xsl:attribute name="class">mx_editable mx_required mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
														</xsl:when>
														<xsl:otherwise>
                                                   <xsl:attribute name="class">mx_editable mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>		                                                 
														</xsl:otherwise>
												</xsl:choose>	                                                 
	                                          </xsl:when>
	                                          <xsl:when test="$status = 'add' and $currentSettings/setting[@name='Editable']='false'">
	                                          	<xsl:attribute name="class">mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                          <xsl:when test="$status = 'resequence'">
	                                          	<xsl:attribute name="class">mx_resequence <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                          <xsl:when test="$status = 'new' and ($currentSettings/setting/@name='Add Input Type')">
                                                   <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                         
	                                          <xsl:when test="$status = 'lookup' and ($currentSettings/setting/@name='Lookup Input Type')">
                                                   <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                          
	                                          <xsl:when test="($status = 'new' or $status = 'lookup') and $isRequiredColumn">
                                                   <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>
	                                          
	                                          <xsl:when test="$status = 'new' or $status = 'lookup'">
                                                   <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:when>                                   	                                          
	                                          <xsl:otherwise>
	                                          	<xsl:attribute name="class">mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                                          </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:otherwise>
                            </xsl:choose>
								</xsl:otherwise>
                            </xsl:choose>
                             <xsl:if test="$visualCue ='true'">
		                             <xsl:attribute name="class">retainedRows <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
		                     </xsl:if>		                     

		                     <!-- Root node row -->
		                     <xsl:if test="$compareBy = 'false'">
								<xsl:attribute name="class">mx_no-compare-column</xsl:attribute>
							 </xsl:if>
							 
							 <!-- Added markup for sync operation -->
							<xsl:if test="$status='cut' and $compare = 'TRUE' and $matchresult='left'">
								<xsl:attribute name="class">mx_cut <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='left'">
								<xsl:attribute name="class">mx_add <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if>
							<xsl:if test="$status='add' and $compare = 'TRUE' and $matchresult='left'">
								<xsl:attribute name="class">mx_rowStyle <xsl:value-of
									select="concat($facetColorClass,' ', $preserveSpacesCss)" /></xsl:attribute>
							</xsl:if>                    

                            <xsl:choose>
                                   <xsl:when test="$currentColumn/@type='separator'">
                                          <xsl:attribute name="class">mx_separator</xsl:attribute>
                                   </xsl:when>
                                   <xsl:when test="$currentColumn/@type='businessobject' and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'] or $iFH)">
                                          <xsl:if test="string-length(text()) &gt; 0 ">
                                          <xsl:attribute name="title"><xsl:value-of select="text()"/></xsl:attribute>
                                          </xsl:if>
                                            <xsl:if test="@i and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
                                                    <img src="{@i}" height="16" border="0"/>
                                            </xsl:if>                                          
                                          <xsl:variable name="href">
                                                 <xsl:if test="$currentColumn/@href and not($status = 'new') and not($status = 'lookup')">
                                                        <xsl:call-template name="href">
                                                               <xsl:with-param name="col" select="$currentColumn"/>
                                                        </xsl:call-template>
                                                 </xsl:if>
                                          </xsl:variable>
                                          <xsl:choose>
                                                 <!-- cell with href -->
                                                 <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')  and ($isFromCtxSearch = 'false')">
                                                        <xsl:element name="a">
                                                            <xsl:if test="$expr = 'name'">
			                                                    <xsl:attribute
			                                                    name="class">
			                                                        <xsl:value-of
			                                                        select="'object'" />
			                                                    </xsl:attribute>
			                                                </xsl:if>
			                                                <xsl:attribute name="data-oid">
			                                                	<xsl:value-of select="$oid" />
			                                                </xsl:attribute>
			                                                <xsl:attribute name="data-icon">
			                                                	<xsl:value-of select="@i" />
			                                                </xsl:attribute>
                                                               <xsl:attribute name="href"><xsl:value-of select="normalize-space($href)"/></xsl:attribute>
                                                               <xsl:value-of select="."/>
                                                        </xsl:element>
                                                 </xsl:when>
                                                 <!--cell without href -->
                                                <xsl:when test="./mxLink">
                                                    <xsl:for-each select="./mxLink/node()">
                                                        <xsl:copy-of select="."/>
                                                    </xsl:for-each>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <xsl:choose>
                                                <xsl:when test="$expr = 'name'">
	                                                <span
	                                                class="object">
	                                                    <xsl:value-of select="."/>
	                                                </span>
	                                            </xsl:when>
	                                                        <xsl:when test="string-length(text()) = 0"></xsl:when>
	                                                        <xsl:otherwise>
	                                                          <xsl:choose>
	                                                        		 <xsl:when test="$currentSettings/setting[@name='isMultiVal'] = 'true'">
	                                                        		 <table class = "multi-attr">
	                                          		              		 <xsl:variable name="strData" select="."/>
	                                           								<xsl:call-template name="splitByDelimiter">
																	            <xsl:with-param name="str" select="$strData"/>
																	        </xsl:call-template>
	                                                        		 </table>
	                                                        		</xsl:when>
                                                 <xsl:otherwise>
                                                        <xsl:value-of select="."/>
                                                 </xsl:otherwise>
																</xsl:choose>                                                        
	                                                        </xsl:otherwise>
	                                                        </xsl:choose>
	                                                        </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:when>
                                   
                                  <xsl:when test="$currentColumn/@type='checkbox'" >
                                  		<input type="checkbox" class="small" name="chkList" id="rmbrow-{$id}"
													value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
													 onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">
													 
												<xsl:if test="(string(@a) = 'false') or (parent::r/@disableSelection = 'true')"> 
													 	<xsl:attribute name="disabled">true</xsl:attribute>
												</xsl:if>
												<xsl:if test="parent::r/@checked = 'checked'">
													<xsl:attribute name="checked">
														<xsl:value-of select="parent::r/@checked" />
													</xsl:attribute>
												</xsl:if>
										</input>	   
								 </xsl:when>	 
									
                                   <!-- ICON COLUMN -->
                                   <xsl:when test="$currentColumn/@type='icon' and 
                                            not(@editMask and contains($currentSettings/setting[@name='Column Icon'],'iconActionEdit'))">
                                          <xsl:call-template name="iconColumn">
                                                 <xsl:with-param name="col" select="$currentColumn"/>
                                          </xsl:call-template>
                                   </xsl:when>
                                   
                                   <xsl:when test="$iFH">
                                           <xsl:attribute name="iFH">true</xsl:attribute>                                         
                                           <xsl:call-template name="rte"></xsl:call-template>
                                  </xsl:when>
                                   <!--
                        PROGRAM HTML OR FILE
                    -->
                                   <!--xsl:when test="span"><xsl:value-of select="span/text()"/></xsl:when-->
                           <xsl:when test="$currentColumn/@type='programHTMLOutput' or $currentColumn/@type='File'">
                            <xsl:variable name="varRootValue"><xsl:value-of select="@FPRootCol"/></xsl:variable>
                            <xsl:for-each select="./node()">
                                <xsl:choose>
                                         <xsl:when test="$varRootValue = 'true'">
                                                <xsl:choose>
                                                        <xsl:when test="$currentColumn/setting[@name = 'Root Label']">
                                                <xsl:value-of select="/mxRoot/tableControlMap/setting[@name='ObjectInfo']/items/item[@name='name']/value"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                                <xsl:copy-of select="."/>
                                                        </xsl:otherwise>
                                                </xsl:choose>
                                         </xsl:when>
                                         <xsl:otherwise>
                                                <xsl:copy-of select="."/>
                                         </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                                   </xsl:when>
                                   <xsl:when test="$currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression']">
                                          <xsl:for-each select="./node()">
                                                 <xsl:copy-of select="."/>
                                          </xsl:for-each>
                                   </xsl:when>
                                   <!--
                        IMAGE
                    -->
                                   <xsl:when test="$Field_Type = 'image'">
                                          <xsl:variable name="href">
                                                 <xsl:call-template name="href">
                                                        <xsl:with-param name="col" select="$currentColumn"/>
                                                 </xsl:call-template>
                                          </xsl:variable>
                                          <xsl:choose>
                                              <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')">
                                          <xsl:element name="a">
                                                 <xsl:attribute name="href"><xsl:value-of select="normalize-space($href)"/></xsl:attribute>
                                                 <xsl:for-each select="./node()">
                                                        <xsl:copy-of select="."/>
                                                 </xsl:for-each>
                                          </xsl:element>
                                   </xsl:when>
                                   <xsl:otherwise>
                                   <xsl:for-each select="./node()">
                                                      <xsl:copy-of select="."/>
                                                  </xsl:for-each>
                                              </xsl:otherwise>
                                          </xsl:choose>
                                   </xsl:when>
                                   <xsl:otherwise>
                                   		<xsl:choose>
	                                   		<xsl:when test="$currentSettings/setting[@name='RowGroupCalculation']!='' and ($rg)">
												<xsl:attribute name="title"><xsl:value-of select="$currentSettings/setting[@name='RowGroupCalculation']" /></xsl:attribute>
												<xsl:attribute name="class">mx_rg_calculation</xsl:attribute>
												<xsl:value-of select="."/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>
												<xsl:value-of select="."/>
											</xsl:otherwise>
										</xsl:choose>
                                   </xsl:otherwise>
                            </xsl:choose>
			    <xsl:variable name="oldVal" select="@a"/>
                            <xsl:variable name="newVal" select="."/>
                            <xsl:if test="@edited='true' and not(string($oldVal) = string($newVal))">
	                            <span>&#160;</span>
	                            <span class="original-value"><xsl:value-of select="@d" /></span>
                            </xsl:if>
                     </td>
					 <!--
                     <th class="mx_sizer" width="2">
						<xsl:attribute name="rowspan">
							<xsl:value-of select="$currentSettings/setting[@name='Row Span']"/>
						</xsl:attribute>
                     </th>
					 -->
              </xsl:if>
              <xsl:if test="$cellIndex = $toggle">
					<xsl:if test="$cellIndex = 1">
						<td class="{$facetColorClass2}" position="-1">
							<xsl:if test="not($rg)">
								<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
									<xsl:attribute name="rowspan">
										<xsl:value-of select="$currentSettings/setting[@name='Row Span']" />
									</xsl:attribute>
								</xsl:if>
							</xsl:if>
						</td>
					</xsl:if>
                     <td position="{$cellIndex}" rowNumber="{$currentSettings/setting[@name='Row Number']}" rmbID ="{$rmbid}" rmbrow="{$id}" >
                        <xsl:if test="string-length($RMBMenu) &gt; 0 ">
		                    <xsl:attribute name="rmb"><xsl:value-of select="$RMBMenu"/></xsl:attribute>
		                </xsl:if>
                     	<xsl:if test="$uiAutomation = 'true' ">
		              			<xsl:attribute name="data-aid"><xsl:value-of select="$colName"/></xsl:attribute>
		            		</xsl:if>
                     	<xsl:if test="not($rg)">
                     	<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
						<xsl:attribute name="rowspan">
							<xsl:value-of select="$currentSettings/setting[@name='Row Span']"/>
						</xsl:attribute>
						</xsl:if>
			           <xsl:if test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
				      	<xsl:attribute name="colspan">
						  <xsl:value-of select="$currentSettings/setting[@name='Column Span'] div 2 + 1"/>
					</xsl:attribute>
			         </xsl:if>
						
						<xsl:if test="$currentSettings/setting[@name='Row Span']/text() = '2'">
							<xsl:attribute name="style">height: 50px;</xsl:attribute>
						</xsl:if>
                     	</xsl:if>
						<xsl:if test="not($customStyle = '')">
							<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> <xsl:value-of select="$facetColorClass" /></xsl:attribute>
						 </xsl:if>
						
						<xsl:choose>                        
	                   		<xsl:when test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
	                          <xsl:choose>
	                                 <xsl:when test="@edited='true'">
	                                         <xsl:choose>
												<xsl:when test="$isRequiredColumn">
													<xsl:attribute name="class">mx_editable mx_required mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
                                                    <xsl:attribute name="class">mx_editable mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
	                                 </xsl:when>
									 <xsl:when test="not($customStyle = '')">
										<xsl:choose>
											 <xsl:when test="@edited='true'">
													<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_edited <xsl:value-of select="$facetColorClass" /></xsl:attribute>
											 </xsl:when>
											  <xsl:when test="$isRequiredColumn">
											  	 <xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
											  </xsl:when>
											 <xsl:otherwise>
													<xsl:attribute name="class"><xsl:value-of select="$customStyle"/> mx_editable <xsl:value-of select="$facetColorClass" /></xsl:attribute>
											 </xsl:otherwise>
										</xsl:choose>
									 </xsl:when>
	                                 <xsl:otherwise>                                   		
                                   		 <xsl:choose>
                                      		<xsl:when test="not(/mxRoot/setting[@name = 'sbMode'] = 'view')">
                                               <xsl:choose>
													<xsl:when test="$isRequiredColumn">
														<xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
													</xsl:when>
													<xsl:otherwise>
	                                                   	<xsl:attribute name="class">mx_editable <xsl:value-of select="$facetColorClass" /></xsl:attribute>
													</xsl:otherwise>
												</xsl:choose>
										  	</xsl:when>
                                        </xsl:choose>
	                                 </xsl:otherwise>
	                          </xsl:choose>
	                 		</xsl:when>
	               		</xsl:choose> 
						
                     	<xsl:if test="parent::r/@checked='checked' or $visualCue ='true'">
						<xsl:choose>                        
	                         <xsl:when test="$currentSettings/setting/@name='Input Type' and not(@editMask) and $currentSettings/setting[@name='Editable']='true'">
                                <xsl:choose>
                                     <xsl:when test="@edited='true'">
                                            <xsl:attribute name="class">mx_editable mx_edited mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                                     </xsl:when>
                                     <xsl:otherwise>
                                            <xsl:attribute name="class">mx_editable mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                                     </xsl:otherwise>
                                </xsl:choose>
                       		</xsl:when>
	                       	<xsl:otherwise>
	                       		<xsl:attribute name="class">mx_rowStyle <xsl:value-of select="$facetColorClass" /></xsl:attribute>
	                       	</xsl:otherwise>
                     	</xsl:choose>
					</xsl:if>                                                            
					  <xsl:choose>
					  
					  	<xsl:when test="$status = 'new' and ($currentSettings/setting/@name='Add Input Type')">
                            <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                         </xsl:when>
                        
                         <xsl:when test="$status = 'lookup' and ($currentSettings/setting/@name='Lookup Input Type')">
                             <xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                         </xsl:when>
                         
                         <xsl:when test="($status = 'new' or $status = 'lookup') and $isRequiredColumn">
							<xsl:attribute name="class">mx_editable mx_required <xsl:value-of select="$facetColorClass" /></xsl:attribute>
						 </xsl:when>
                         
                         <xsl:when test="$status = 'new' or $status = 'lookup'">
                             <xsl:attribute name="class">mx_editable <xsl:value-of select="$facetColorClass" /></xsl:attribute>
                         </xsl:when>
                        </xsl:choose>
					                                                    
                     	<xsl:call-template name="treeBodyth">
                     		<xsl:with-param name="rowNumber" select="$rowNumber"/>
                     	</xsl:call-template>
                     </td>
              </xsl:if>
            </xsl:if>
            <xsl:if test="$split = 1 and $rowNumber = '2'">
	         <td>&#160;</td>
	        </xsl:if>
            <xsl:if test="$currentSettings/setting[@name='BlankCell'] = 'true' and $rowNumber = '2'">
				<td>
					<xsl:if test="not($rg)">
					<xsl:if test="number($currentSettings/setting[@name='Row Span']) &gt; 1">
					<xsl:attribute name="rowspan">
						<xsl:value-of select="$currentSettings/setting[@name='Row Span']"/>
					</xsl:attribute>
					</xsl:if>
			        <xsl:if test="number($currentSettings/setting[@name='Column Span'] div 2 + 1) &gt; 1">
					   <xsl:attribute name="colspan">
						  <xsl:value-of select="$currentSettings/setting[@name='Column Span'] div 2 + 1"/>
					   </xsl:attribute>
			       </xsl:if>
					</xsl:if>
					<xsl:if test="/mxRoot/setting[@name = 'sbMode'] = 'view' and parent::r/@checked='checked'">
						<xsl:attribute name="class">mx_rowStyle <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
					</xsl:if>
					&#160;
				</td>
			</xsl:if>
			</xsl:if>
       </xsl:template>
       <xsl:template name="treeBodytd">
        <xsl:param name="rowNumber" select="."/>
		<xsl:variable name="status" select="parent::r/@status" />
		<xsl:variable name="titleValue" select="parent::r/@titleValue" />
		<xsl:variable name="matchresult" select="string(parent::r/@matchresult)"/>
		<xsl:variable name="compareResult" select="string(@compareResult)"/>
		<xsl:variable name="columnSynch" select="string(@columnSynch)"/>
		<xsl:variable name="indentedView" select="/mxRoot/requestMap/setting[@name = 'isIndentedView']" />
		<xsl:variable name="id" select="parent::r/@id" />
		<xsl:variable name="groupedColumnName" select="parent::r/@groupedColumnName"/>
		<xsl:variable name="groupName" select="@a"/>
		<xsl:variable name="oid" select="parent::r/@o" />
		<xsl:variable name="relId" select="parent::r/@r" />
		<xsl:variable name="level" select="parent::r/@level" />
		<xsl:variable name="parentOid" select="parent::r/@p" />
		<xsl:variable name="direction" select="parent::r/@d" />
		<xsl:variable name="calc" select="parent::r/@calc" />
        <xsl:variable name="rg" select="parent::r/@rg"/>
		<xsl:variable name="error" select="parent::r/@e" />
		<xsl:variable name="display" select="parent::r/@display" />
		<xsl:variable name="disableExpand" select="parent::r/@disableExpand" />
		<xsl:variable name="cellIndex" select="position()" />
		<xsl:variable name="currentColumn" select="/mxRoot/columns/column[$cellIndex]" />
		<xsl:variable name="expr" select="/mxRoot/columns/column[$cellIndex]/@expression" />
		<xsl:variable name="currentSettings" select="$currentColumn/settings" />
		<xsl:variable name="varFieldType" select="$currentSettings/setting[@name = 'Column Type']" />
		<xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)"/>
		<xsl:variable name="isRequiredColumn" select="$currentSettings/setting[@name='Required']='true' or $currentSettings/setting[@name='Required']='TRUE'" /> 
		<xsl:variable name="compareBy" select="$currentColumn/@compareBy" />
		
		<xsl:variable name="preserveSpacesCss">
            <xsl:choose>
                   <xsl:when test="not($rg) and ($currentSettings/setting[@name='Preserve Spaces']='true' or $currentSettings/setting[@name='Preserve Spaces']='TRUE')">
                   	<xsl:text>verbatim</xsl:text>
                   </xsl:when>
                   <xsl:otherwise>
                   	<xsl:text></xsl:text>    
                   </xsl:otherwise>
            </xsl:choose>
         </xsl:variable> 
		 <xsl:variable name="rmbid">
               <xsl:choose>
                      <xsl:when test="@altOID">
                             <xsl:value-of select="@altOID"/>
                      </xsl:when>
                      <xsl:otherwise>
                             <xsl:value-of select="../@o"/>
                      </xsl:otherwise>
               </xsl:choose>
         </xsl:variable>
		<xsl:variable name="RMBMenu" select="$currentSettings/setting[@name = 'RMB Menu']"/>
		<xsl:variable name="facetColorClass">
		<!-- disable column colorization
		 			<xsl:if test="$currentColumn/@colorize = 'yes'">
						<xsl:value-of select="string(@facetColoring)" />
					</xsl:if>  
		-->
		</xsl:variable>
		<xsl:if test="$currentSettings/setting[@name='Row Number'] = $rowNumber">
		
			<div id="{$id}" o="{$oid}" r="{$relId}" t="{@t}">
				<table>
					<tr id="{$id}" o="{$oid}" r="{$relId}">
						<td>						
							<xsl:if test="$reportType != 'Difference_Only_Report' and $reportType != 'Unique_toLeft_Report' and $reportType != 'Unique_toRight_Report' and $reportType != 'Common_Report'">
                            	<xsl:choose> 
                            		<xsl:when test="normalize-space($indentedView) = 'false' and not($rg)">
                            			<img src="images/utilSpacer.gif"
											height="1" width="{number(19*($level - 1))}" border="0" align="middle" />
                            		</xsl:when>
                            		<xsl:otherwise>
                            			<img src="images/utilSpacer.gif"
											height="1" width="{number(19*$level)}" border="0" align="middle" />
                            		</xsl:otherwise>
                            	</xsl:choose>
                            </xsl:if>
						</td>
						
						<xsl:choose>
							<xsl:when
								test="$singleRoot and $groupLevel and not($rg)">
								<td><img src="images/utilSpacer.gif"
									height="1" width="{number(19*($groupLevel - 1))}" border="0" align="middle" /></td>
							</xsl:when>
							<xsl:when test="$groupLevel and not($rg)">
								<td><img src="images/utilSpacer.gif"
										height="1" width="{number(19*($groupLevel))}" border="0" align="middle" /></td>
							</xsl:when>
						</xsl:choose>
						<!-- add height here for bigger rows -->
						<xsl:if test="(normalize-space($indentedView)= 'true' and not($calc)) or $rg">
							<td width="13">
								<xsl:variable name="img">
									<xsl:choose>
											<xsl:when test="not($display = 'block')">
												<xsl:choose>
											        <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
											<xsl:value-of select="'images/utilTreeLineNodeClosedSB.gif'"/>
										</xsl:when>				
										<xsl:otherwise>
														<xsl:value-of select="'images/utilTreeLineNodeClosedSBDisabled.gif'"/>
											        </xsl:otherwise>
											    </xsl:choose>
										    </xsl:when>				
											<xsl:otherwise>
												<xsl:choose>
													 <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
											<xsl:value-of select="'images/utilTreeLineNodeOpenSB.gif'"/>
													</xsl:when>
													<xsl:otherwise>
													    <xsl:value-of select="'images/utilTreeLineNodeOpenSBDisabled.gif'"/>
													</xsl:otherwise>
												</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								 <xsl:if test="normalize-space($indentedView)= 'true' or $rg">
	                             <xsl:choose>
	                             	<xsl:when test=" $status = 'add' and $disableExpand = 'true' ">	                                                        	
	                             	 <img src="images/utilTreeLineNodeClosedSBDisabled.gif" border="0" align="top"/>
	                                </xsl:when>
	                            	<xsl:when test="$status = 'cut' or $status = 'resequence' or $status = 'new' or $status = 'lookup'">	                                                        	
	                             	 <img src="images/utilTreeLineNodeClosedSBDisabled.gif" border="0" align="top"/>
	                                </xsl:when>
	                                <xsl:when test="$status = 'new'">	                                                        	
                                        <img src="images/utilTreeLineNodeOpenSBDisabled.gif" border="0" align="top"/>
	                                </xsl:when>
	                                <xsl:when test=" $status = 'add' ">	                                                        	
										<xsl:if test="parent::r/@hChild = 'true' or parent::r/@hChild = '' or not(parent::r/@hChild)">
	                             	<a href="javascript:toggle('{$id}')">
	                                    <img id="img_{$id}" src="{$img}" alt="" border="0" align="top"/>
	                                 </a>                                
									</xsl:if>
									<xsl:if test="parent::r/@hChild = 'false'">
										<a href="javascript:void">
											<img id="img_{$id}" src="images/utilSpacer.gif" width="16" alt="" border="0"
													align="top" />
	                                 </a>                                
									</xsl:if>
	                                </xsl:when>
	                                    <xsl:when test="$rg">
                                        <a onclick="toggleRowGrouping('{$id}');">
                                            <img id="img_{$id}" src="{$img}" alt="" border="0" align="top"/>
                                        </a>
                                    </xsl:when>
                                <xsl:otherwise>                                                            	
                                	<xsl:choose>
											 <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">	                                                            	
												 <xsl:if test="parent::r/@hChild = 'true' or parent::r/@hChild = '' or not(parent::r/@hChild)">
	                                	<a href="javascript:toggle('{$id}')">
	                                    <img id="img_{$id}" src="{$img}" alt="" border="0" align="top"/>
	                                 </a>
												 </xsl:if>
												 <xsl:if test="parent::r/@hChild = 'false'">
													<a href="javascript:void">
														<img id="img_{$id}" src="images/utilSpacer.gif" width="16" alt="" border="0" align="top"/>
													 </a>
												 </xsl:if>
												 
	                                 		 </xsl:when>
											<!--Hyperlink disabled for show access-->
											<xsl:otherwise>
											    <img id="img_{$id}" src="{$img}" alt="" border="0" align="top"/>
											</xsl:otherwise>
									</xsl:choose>
	                                </xsl:otherwise>
	                            </xsl:choose>
	                             </xsl:if>
							</td>
						</xsl:if>
						<td>						
							<xsl:choose>
								<xsl:when test="parent::r/@d= 'to'">
	                                 <xsl:if test="normalize-space($indentedView)= 'true' and $reportType != 'Difference_Only_Report' and $reportType != 'Unique_toLeft_Report' and $reportType != 'Unique_toRight_Report' and $reportType != 'Common_Report'">
	                                 	<xsl:choose>
											 	<xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
	                              	<a href="javascript:;">	<img src="images/utilTreeToArrow.gif" height="19" border="0" align="top"/></a>
	                              				</xsl:when>
											 	<!--Hyperlink disabled for show access-->
											 	<xsl:otherwise>
											     	<img src="images/utilTreeToArrow.gif" height="19" border="0" align="top"/>
											 	</xsl:otherwise>
										 </xsl:choose>
	                                 </xsl:if>
		                       </xsl:when>
		                       <xsl:when test="parent::r/@d = 'from'">
	                               	<xsl:if test="normalize-space($indentedView)= 'true' and $reportType != 'Difference_Only_Report' and $reportType != 'Unique_toLeft_Report' and $reportType != 'Unique_toRight_Report' and $reportType != 'Common_Report'">
	                               		<xsl:choose>
											 <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
	                              		<a href="javascript:;"> <img src="images/utilTreeFromArrow.gif" height="19" border="0" align="top"/>
                                				</a>
                                			</xsl:when>
											<!--Hyperlink disabled for show access-->
											<xsl:otherwise>
											    <img src="images/utilTreeFromArrow.gif" height="19" border="0" align="top"/>
											</xsl:otherwise>
										</xsl:choose>
                                	</xsl:if>
		                       </xsl:when>
							</xsl:choose>
						</td>						
						<td>						
							<!-- CHECKBOX -->
							<xsl:if
								test="(/mxRoot/requestMap/setting[@name = 'selection'] = 'multiple' or parent::r/@s = 'm') and not($calc)">
                                <xsl:if test="not($rg)">
                                    <input type="checkbox"
                                        name="emxTableRowIdActual" class="small" id="rmbrow-{$id}"
                                        value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
                                        onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">
                                        <xsl:if test="parent::r/@disableSelection = 'true'">
                                            <xsl:attribute name="disabled">true</xsl:attribute>
                                        </xsl:if>
                                        <xsl:if test="parent::r/@checked = 'checked'">
                                            <xsl:attribute name="checked">
                                                <xsl:value-of
                                                    select="parent::r/@checked" />
                                            </xsl:attribute>
                                        </xsl:if>
                                    </input>
                                </xsl:if>
                                <xsl:if test="$rg">
                                    <input type="checkbox"
                                    name="emxTableRowIdGroup" class="small" id="rmbrowgp-{$id}"
									value="{concat($groupName,'|',$groupedColumnName,'|',$id)}"
									onclick="doRowGroupCheckboxClick('{$id}', this.checked); doCheckSelectAll();">

 									<xsl:if test="parent::r/@disableSelection = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="parent::r/@checked = 'checked'">
										<xsl:attribute name="checked">
											<xsl:value-of
												select="parent::r/@checked" />
										</xsl:attribute>
									</xsl:if>
                                    </input>
                                </xsl:if>
							</xsl:if>
							<!-- RADIO -->
							<xsl:if
								test="/mxRoot/requestMap/setting[@name = 'selection'] = 'single' or parent::r/@s = 's'">
								<xsl:if test="not($rg)">
								<input type="radio"
									name="emxTableRowIdActual" class="small" id="rmbrow-{$id}"
									value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
									onclick="doFreezePaneRadioClick(this)">
									<xsl:if test="parent::r/@disableSelection = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="parent::r/@checked = 'checked'">
										<xsl:attribute name="checked">
											<xsl:value-of
												select="parent::r/@checked" />
										</xsl:attribute>
									</xsl:if>
								</input>
							</xsl:if>		
							</xsl:if>		
							</td>
							<xsl:if test="not($rg)">
							<td id="icon_{$id}">					
							<xsl:if test="@i and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
								<xsl:choose>
								     <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
								<a href="javascript:;"><img src="{@i}" /></a>
									 </xsl:when>
									 <!--Hyperlink disabled for show access-->
									 <xsl:otherwise>
									    <img src="{@i}" height="16" align="middle" border="0" />
									 </xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							<xsl:if test="not(string(parent::r/@level) = '0') and not($compare = 'TRUE')">
								<xsl:choose>
									<xsl:when test="($status = 'new' or $status = 'lookup' or $status = 'cut' or $status = 'add' or $status = 'resequence' or $status = 'changed') and $error">
										<a href="javascript:;"><img src="images/iconStatusError.gif">
											<xsl:attribute name="onmouseover">errorTip(event, this,'<xsl:value-of select="$id"/>')</xsl:attribute>
										</img>&#160;</a>
									</xsl:when>
									<xsl:when test="$status = 'cut'">
										<a href="javascript:;"><img  title="{$titleValue}" src="images/iconStatusRemoved.gif" /></a>&#160;
									</xsl:when>
									<xsl:when test="$status = 'add'">
										<a href="javascript:;"><img  title="{$titleValue}" src="images/iconStatusAdded.gif" /></a>&#160;
									</xsl:when>	              
									<xsl:when test="$status = 'resequence'">
										<a href="javascript:;"><img src="images/iconStatusResequenced.gif" /></a>&#160;
									</xsl:when>
									<xsl:when test="$status = 'changed'">
										<a href="javascript:;"><img  title="{$titleValue}" src="images/iconStatusChanged.gif" /></a>&#160;
									</xsl:when>
									<xsl:when test="$status = 'new'">
										<a href="javascript:;"><img src="images/iconActionCreate.gif" /></a>&#160;
									</xsl:when>
									<xsl:when test="$status = 'lookup'">
										<a href="javascript:;"><img src="images/iconActionAdd.gif" /></a>&#160;
									</xsl:when>
								</xsl:choose>
							</xsl:if>

							</td>							
							</xsl:if>							
							<td title="{c[1]}" position="1" rmb = "{$RMBMenu}" rmbID = "{$rmbid}" rmbrow="{$id}">
							<!-- first place we can add a class
	                        add facetColor here as the default. We will add facet color to each style -->
	                        <xsl:if test="not($preserveSpacesCss = '')">
                    			<xsl:attribute name="class"><xsl:value-of select="$preserveSpacesCss"/></xsl:attribute>
                    		</xsl:if>
	                        <xsl:if test="not($facetColorClass = '')">
	                            <xsl:attribute name="class"><xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                        </xsl:if> 
	                        
	                        <xsl:if test="$compareBy = 'false'">
									<xsl:attribute name="class">mx_no-compare-column</xsl:attribute>
							</xsl:if>
							
							<xsl:if test="$columnSynch='true'">
                            	<xsl:choose>
	                            		<xsl:when test="@edited='true'">
	                            			<xsl:attribute name="class">mx_attr-change <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                            		</xsl:when>
	                            		<xsl:otherwise>
	                            			<xsl:attribute name="class">mx_sync-row <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
	                            		</xsl:otherwise>                            	
	                            </xsl:choose>                            	
	                        </xsl:if>
	                        <xsl:if test="($status = 'cut' or $status = 'add') and $compare = 'TRUE'">
									  <xsl:choose>
										  <xsl:when test="$status = 'cut' and $matchresult='left'">
											<xsl:attribute name="class">mx_cut <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>
										  <xsl:when test="$status = 'add' and $matchresult='right'"> 	
											<xsl:attribute name="class">mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>
										  <xsl:when test="$status = 'add' and $matchresult='left'"> 	
											<xsl:attribute name="class">mx_rowStyle <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>
										  
							    	</xsl:choose>
							</xsl:if>
	                            
	                        
							<!-- STATUS -->
							  <xsl:if test="($status = 'cut' or $status = 'add' or $status = 'resequence') and not($compare = 'TRUE')">
									  <xsl:choose>
										  <xsl:when test="$status = 'cut'">
											<xsl:attribute name="class">mx_cut <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>
										  <xsl:when test="$status = 'add'"> 	
											<xsl:attribute name="class">mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>
										  <xsl:when test="$status = 'resequence'">
											<xsl:attribute name="class">mx_resequence <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>										 
										  <xsl:otherwise>
											<xsl:attribute name="class">mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
								   </xsl:otherwise>
							    </xsl:choose>
								   </xsl:if>
								   
								
							    <!-- STATUS -->							
							<xsl:choose>
								<xsl:when
									test="$currentColumn/@type='separator'">
									<xsl:attribute name="class">mx_separator</xsl:attribute>
								</xsl:when>
								<xsl:when
									test="$currentColumn/@type='businessobject' and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
									<xsl:if test="string-length(text()) &gt; 0 ">
									<xsl:attribute name="title">
										<xsl:value-of select="text()" />
									</xsl:attribute>
									</xsl:if>
									<xsl:variable name="href">
										<xsl:if
											test="$currentColumn/@href and not($calc) and not($status = 'new') and not($status = 'lookup') and not($rg)">
											<xsl:call-template
												name="href">
												<xsl:with-param
													name="col" select="$currentColumn" />
											</xsl:call-template>
										</xsl:if>
									</xsl:variable>
									<xsl:choose>
										<!-- cell with href -->
										<xsl:when
											test="string-length($href) &gt; 0 and not($href = '#DENIED!')  and ($isFromCtxSearch = 'false')">
											<xsl:element name="a">
												<xsl:attribute
													name="href">
													<xsl:value-of
														select="normalize-space($href)" />
												</xsl:attribute>
												<xsl:if test="$expr = 'name'">
												    <xsl:attribute
                                                    name="class">
                                                        <xsl:value-of
                                                        select="'object'" />
                                                    </xsl:attribute>
												</xsl:if>
												<xsl:attribute name="data-oid">
                                                	<xsl:value-of select="$oid" />
                                                </xsl:attribute>
                                                <xsl:attribute name="data-icon">
                                                	<xsl:value-of select="@i" />
                                                </xsl:attribute>
												<xsl:choose>
													<xsl:when
														test="@FPRootCol = 'true'">
														<xsl:value-of
															select="/mxRoot/tableControlMap/setting[@name='ObjectInfo']/items/item[@name='name']/value" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of
															select="." />
													</xsl:otherwise>
												</xsl:choose>
											</xsl:element>
										</xsl:when>
										<xsl:when
											test="$currentColumn/@type='programHTMLOutput'">
											<xsl:for-each
												select="./node()">
												<xsl:choose>
													<xsl:when
														test="@FPRootCol = 'true'">
														<xsl:value-of
															select="/mxRoot/tableControlMap/setting[@name='ObjectInfo']/items/item[@name='name']/value" />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of
															select="." />
													</xsl:otherwise>
												</xsl:choose>
											</xsl:for-each>
										</xsl:when>
										<xsl:when test="./mxLink">
											<xsl:for-each
												select="./mxLink/node()">
												<xsl:copy-of select="." />
											</xsl:for-each>
										</xsl:when>
										<!--cell without href -->
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when
													test="@FPRootCol = 'true'">
													<xsl:value-of
														select="/mxRoot/tableControlMap/setting[@name='ObjectInfo']/items/item[@name='name']/value" />
												</xsl:when>
												<xsl:when test="$expr = 'name'">
												    <span class="object">
												        <xsl:value-of
                                                        select="." />
												    </span>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of
														select="." />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<!-- ICON COLUMN -->
								<xsl:when
									test="$currentColumn/@type='icon' and not(@editMask and contains($currentSettings/setting[@name='Column Icon'],'iconActionEdit'))">
									<xsl:call-template
										name="iconColumn">
										<xsl:with-param name="col"
											select="$currentColumn" />
									</xsl:call-template>
								</xsl:when>
								<!--	PROGRAM HTML OR FILE	-->
								<xsl:when
									test="$currentColumn/@type='programHTMLOutput' or $currentColumn/@type='File'">
									<xsl:variable name="varRootValue">
										<xsl:value-of
											select="@FPRootCol" />
									</xsl:variable>
									<xsl:for-each select="./node()">
										<xsl:choose>
											<xsl:when
												test="$varRootValue = 'true'">
												<xsl:value-of
													select="/mxRoot/tableControlMap/setting[@name='ObjectInfo']/items/item[@name='name']/value" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:copy-of select="." />
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression']">
                                       <xsl:for-each select="./node()">
                                              <xsl:copy-of select="."/>
                                       </xsl:for-each>
                                </xsl:when>
                                
                                <xsl:when test="$currentColumn/@type='checkbox'" >
                                  		<input type="checkbox" class="small" name="chkList" id="rmbrow-{$id}"
													value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
													 onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">
													 
												<xsl:if test="(string(@a) = 'false') or (parent::r/@disableSelection = 'true')"> 
													 	<xsl:attribute name="disabled">true</xsl:attribute>
												</xsl:if>
												<xsl:if test="parent::r/@checked = 'checked'">
													<xsl:attribute name="checked">
														<xsl:value-of select="parent::r/@checked" />
													</xsl:attribute>
												</xsl:if>
									</input>
						    </xsl:when>
                                 
								<!--	IMAGE	-->
								<xsl:when
									test="$Field_Type = 'image'">
									<xsl:variable name="href">
										<xsl:call-template
											name="href">
											<xsl:with-param name="col"
												select="$currentColumn" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:choose>
									    <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')">
									<xsl:element name="a">
										<xsl:attribute name="href">
											<xsl:value-of select="normalize-space($href)" />
										</xsl:attribute>
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
									    <xsl:attribute name="title">
                                                <xsl:choose>
                                                        <xsl:when test="./mxLink">
                                                                <xsl:for-each select="./mxLink/node()">
                            										<xsl:value-of select="."/>
                                                                </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                                <xsl:value-of select="text()"/>
                                                        </xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:variable name="href">
                                                 <xsl:if test="$currentColumn/@href  and not($status = 'new') and not($status = 'lookup') and not($rg)">
                                                        <xsl:call-template name="href">
                                                               <xsl:with-param name="col" select="$currentColumn"/>
                                                        </xsl:call-template>
                                                 </xsl:if>
                                         </xsl:variable>
                                         <xsl:choose>
                                                 <!-- cell with href -->
                                                 <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')  and ($isFromCtxSearch = 'false')">
                                                        <xsl:element name="a">
                                                               <xsl:attribute name="href"><xsl:value-of select="normalize-space($href)"/></xsl:attribute>
				                                                <xsl:attribute name="data-oid">
				                                                	<xsl:value-of select="$oid" />
				                                                </xsl:attribute>
				                                                <xsl:attribute name="data-icon">
				                                                	<xsl:value-of select="@i" />
				                                                </xsl:attribute>
                                                                <xsl:if test="$expr = 'name'">
				                                                    <xsl:attribute
				                                                    name="class">
				                                                        <xsl:value-of
				                                                        select="'object'" />
				                                                    </xsl:attribute>
				                                                </xsl:if>
                                                               <xsl:value-of select="."/>
                                                        </xsl:element>
                                                 </xsl:when>
                                                  <xsl:when test="./mxLink">
                                                        <xsl:for-each select="./mxLink/node()">
                                                                <xsl:copy-of select="."/>
                                                        </xsl:for-each>
                                                 </xsl:when>
                                                <!--cell without href -->
                                                 <xsl:otherwise>
                                                    <xsl:choose>
                                                        <xsl:when test="$expr = 'name' and not($rg)">
                                                             <xsl:attribute
                                                             name="class">
                                                                 <xsl:value-of
                                                                 select="'object'" />
                                                             </xsl:attribute>
                                                         </xsl:when>
	                                                    <xsl:otherwise>
	                                                        <xsl:value-of select="text()"/>
	                                                    </xsl:otherwise>
                                                    </xsl:choose>
                                                 </xsl:otherwise>
                                        </xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
                            <xsl:if test="$rg">
							    <span>&#160;(<xsl:value-of select="parent::r/@count"/>)</span>
                            </xsl:if>
							<xsl:variable name="oldVal" select="@a"/>
						    <xsl:variable name="newVal" select="."/>
						    <xsl:if test="@edited='true' and not(string($oldVal) = string($newVal))">
							    <span>&#160;</span>
							    <span class="original-value"><xsl:value-of select="@d" /></span>
						    </xsl:if>
						</td>
					</tr>
				</table>
			</div>
	</xsl:if>
	</xsl:template>
	<xsl:template name="treeBodyth">
		<xsl:param name="rowNumber" select="."/>
		<xsl:variable name="status" select="parent::r/@status"/>
		<xsl:variable name="titleValue" select="parent::r/@titleValue" />
		<xsl:variable name="rg" select="parent::r/@rg"/>
		<xsl:variable name="indentedView" select="/mxRoot/requestMap/setting[@name = 'isIndentedView']" />
		<xsl:variable name="id" select="parent::r/@id" />
		<xsl:variable name="groupedColumnName" select="parent::r/@groupedColumnName"/>
		<xsl:variable name="groupName" select="@a"/>
		<xsl:variable name="oid" select="parent::r/@o" />
		<xsl:variable name="relId" select="parent::r/@r" />
		<xsl:variable name="level" select="parent::r/@level" />
		<xsl:variable name="error" select="string(parent::r/@e)"/> 
		<xsl:variable name="parentOid" select="parent::r/@p" />
		<xsl:variable name="direction" select="parent::r/@d" />
		<xsl:variable name="display" select="parent::r/@display" />
		<xsl:variable name="cellIndex" select="position()" />
		<xsl:variable name="currentColumn" select="/mxRoot/columns/column[$cellIndex]" />
		<xsl:variable name="expr" select="/mxRoot/columns/column[$cellIndex]/@expression" />
		<xsl:variable name="currentSettings" select="$currentColumn/settings" />
		<xsl:variable name="varFieldType" select="$currentSettings/setting[@name = 'Column Type']" />
		<xsl:variable name="Field_Type" select="translate($varFieldType,$ucletters,$lcletters)"/>
		<xsl:variable name="hideRootCheckBox" select="/mxRoot/requestMap/setting[@name = 'hideRootSelection'] = 'true'"/>
		<xsl:variable name="isRequiredColumn" select="$currentSettings/setting[@name='Required']='true' or $currentSettings/setting[@name='Required']='TRUE'" /> 
		<xsl:variable name="matchresult" select="string(parent::r/@matchresult)"/>
		
		<xsl:variable name="preserveSpacesCss">
            <xsl:choose>
                <xsl:when test="not($rg) and ($currentSettings/setting[@name='Preserve Spaces']='true' or $currentSettings/setting[@name='Preserve Spaces']='TRUE')">
                   	<xsl:text>verbatim</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   	<xsl:text></xsl:text>    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
		 <xsl:variable name="rmbid">
               <xsl:choose>
                      <xsl:when test="@altOID">
                             <xsl:value-of select="@altOID"/>
                      </xsl:when>
                      <xsl:otherwise>
                             <xsl:value-of select="../@o"/>
                      </xsl:otherwise>
               </xsl:choose>
        </xsl:variable>
		<xsl:variable name="RMBMenu" select="$currentSettings/setting[@name = 'RMB Menu']"/>
		<xsl:variable name="facetColorClass">
		<!-- <xsl:if test="$currentColumn/@colorize = 'yes'">
						<xsl:value-of select="string(@facetColoring)" />
			</xsl:if>
		-->
		</xsl:variable> 
		<xsl:if test="$currentSettings/setting[@name='Row Number'] = $rowNumber">
		
			<div id="{$id}" o="{$oid}" r="{$relId}" t="{@t}">
				<table>
					<tr id="{$id}" o="{$oid}" r="{$relId}">
					
						<xsl:choose>
							<xsl:when
								test="not($singleRoot) and $groupLevel and not($rg)">
								<td><img src="images/utilSpacer.gif"
									height="1" width="{number(19*($groupLevel))}" border="0" align="middle" /></td>
							</xsl:when>
						</xsl:choose>
								
						<xsl:if test="normalize-space($indentedView)= 'true' or $rg">		
						<td width="13">
							<xsl:variable name="img">
								<xsl:choose>
									<xsl:when test="$status = 'new' or $status = 'lookup'">
                             	 		<xsl:value-of select="'images/utilTreeLineNodeClosedSBDisabled.gif'"/>
                                	</xsl:when>
                                	<xsl:when test="$status = 'new'">
						<xsl:value-of select="'images/utilTreeLineNodeOpenSBDisabled.gif'"/>
                                	</xsl:when>
									<xsl:when test="not($display = 'block')">
										<xsl:choose>
											<xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
										<xsl:value-of select="'images/utilTreeLineNodeClosedSB.gif'"/>
									</xsl:when>
									<xsl:otherwise>
												<xsl:value-of select="'images/utilTreeLineNodeClosedSBDisabled.gif'"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
										     <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
										<xsl:value-of select="'images/utilTreeLineNodeOpenSB.gif'"/>
											 </xsl:when>
										    <xsl:otherwise>
										        <xsl:value-of select="'images/utilTreeLineNodeOpenSBDisabled.gif'"/>
										    </xsl:otherwise>
									    </xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$rg">
                                    <a onclick="toggleRowGrouping('{$id}');">
                                        <img id="img_{$id}" src="{$img}" alt="" border="0" align="top"/>
                                    </a>
                                </xsl:when>
                                <xsl:when test="normalize-space($indentedView)= 'true'">
                                	<xsl:choose>
                                         <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
                                    <a href="javascript:toggle('{$id}')">
                                        <img id="img_{$id}" src="{$img}" alt="" border="0" align="top"/>
                                    </a>
                                </xsl:when>
                                		<xsl:otherwise>
                                            <img id="img_{$id}" src="{$img}" alt="" border="0" align="top"/>
                                        </xsl:otherwise>
                            		</xsl:choose>
                            	</xsl:when>
                            </xsl:choose>
						</td>						
						</xsl:if>					
						<td>							
							<xsl:choose>
	                            <xsl:when test="parent::r/@d = 'to'">
	                                 <xsl:if test="normalize-space($indentedView)= 'true'">
	                                 	 <xsl:choose>
											<xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
	                              <a href="javascript:;">  <img src="images/utilTreeToArrow.gif" height="19" border="0" align="top"/></a>
	                              			</xsl:when>
											<!--Hyperlink disabled for show access-->
											<xsl:otherwise>
											    <img src="images/utilTreeToArrow.gif" height="19" border="0" align="top"/>
											</xsl:otherwise>
										 </xsl:choose>
	                                 </xsl:if>
	                            </xsl:when>
	                            <xsl:when test="parent::r/@d = 'from'">
	                                    <xsl:if test="normalize-space($indentedView)= 'true'">
	                                    	<xsl:choose>
												<xsl:when test="parent::r/@ra='t'  or not(parent::r/@ra) ">
	                               <a href="javascript:;"> <img src="images/utilTreeFromArrow.gif" height="19" border="0" align="top"/>
	                                  				</a> 
	                                  			</xsl:when>
	                                  			<xsl:otherwise>
	                                  				<img src="images/utilTreeFromArrow.gif" height="19" border="0" align="top"/>
	                                  			</xsl:otherwise>
	                                  		</xsl:choose> 
	                                  	</xsl:if>   
	                            </xsl:when>
	                        </xsl:choose>
							<!-- CHECKBOX -->
							<xsl:if test="(/mxRoot/requestMap/setting[@name = 'selection'] = 'multiple' or parent::r/@s = 'm') and not($id='0' and $hideRootCheckBox)">
                                <xsl:if test="not($rg)">
                                    <input type="checkbox"
                                    name="emxTableRowIdActual" class="small" id="rmbrow-{$id}"
									value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
									onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">
									<xsl:if test="parent::r/@disableSelection = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="parent::r/@checked = 'checked'">
										<xsl:attribute name="checked">
											<xsl:value-of
												select="parent::r/@checked" />
										</xsl:attribute>
									</xsl:if>
                                    </input>
                                </xsl:if>
                                <xsl:if test="$rg">
                                    <input type="checkbox"
                                    name="emxTableRowIdGroup" class="small" id="rmbrowgp-{$id}"
									value="{concat($groupName,'|',$groupedColumnName,'|',$id)}"
									onclick="doRowGroupCheckboxClick('{$id}', this.checked); doCheckSelectAll();">

 									<xsl:if test="parent::r/@disableSelection = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="parent::r/@checked = 'checked'">
										<xsl:attribute name="checked">
											<xsl:value-of
												select="parent::r/@checked" />
										</xsl:attribute>
									</xsl:if>
                                    </input>
                                </xsl:if>
							</xsl:if>
							<!-- RADIO -->
							<xsl:if test="/mxRoot/requestMap/setting[@name = 'selection'] = 'single' or parent::r/@s = 's'">
								<xsl:if test="not($rg)">
								<input type="radio"
									name="emxTableRowIdActual" class="small" id="rmbrow-{$id}"
									value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
									onclick="doFreezePaneRadioClick(this)">
									<xsl:if test="parent::r/@disableSelection = 'true'">
										<xsl:attribute name="disabled">true</xsl:attribute>
									</xsl:if>
									<xsl:if test="parent::r/@checked = 'checked'">
										<xsl:attribute name="checked">
											<xsl:value-of
												select="parent::r/@checked" />
										</xsl:attribute>
									</xsl:if>
								</input>
								</xsl:if>	
							</xsl:if>		
							</td>
							<xsl:if test="not($rg)">
							<td id="icon_{$id}">					
							<xsl:if test="@i and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
								<xsl:choose>
									 <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
								<a href="javascript:;"><img src="{@i}" /></a>
									 </xsl:when>
									<!--Hyperlink disabled for show access-->
									<xsl:otherwise>
									    <img border="0" src="{@i}" height="16" align="middle" />
									</xsl:otherwise>
								</xsl:choose>
								&#160;
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$error">
									<img src="images/iconStatusError.gif" height="16" align="middle">
										<xsl:attribute name="onmouseover">errorTip(event, this,'<xsl:value-of select="$id"/>')</xsl:attribute>
									</img>&#160;
								</xsl:when>
								<xsl:when test="$status = 'cut'">
									<img title="{$titleValue}" src="images/iconStatusRemoved.gif" height="16" align="middle"/>&#160;
								</xsl:when>
								<xsl:when test="$status = 'add'">
									<img title="{$titleValue}" src="images/iconStatusAdded.gif" height="16" align="middle"/>&#160;
								</xsl:when>	              
								<xsl:when test="$status = 'resequence'">
									<img src="images/iconStatusResequenced.gif" height="16" align="middle"/>&#160;
								</xsl:when>
								<xsl:when test="$status = 'changed'">
								<img title="{$titleValue}" src="images/iconStatusChanged.gif" height="16" align="middle"/>&#160;
								</xsl:when>
								<xsl:when test="$status = 'new'">
								<img src="images/iconActionCreate.gif" height="16" align="middle"/>&#160;
								</xsl:when>
								<xsl:when test="$status = 'lookup'">
								<img src="images/iconActionAdd.gif" height="16" align="middle"/>&#160;
								</xsl:when>
							</xsl:choose>						
							</td>
							</xsl:if>
							<td title="{c[1]}" position="1" valign="middle" rmbID = "{$rmbid}" rmbrow="{$id}">
						   <xsl:if test="string-length($RMBMenu) &gt; 0 ">
		                      <xsl:attribute name="rmb"><xsl:value-of select="$RMBMenu"/></xsl:attribute>
		                   </xsl:if>
							<!-- first place we can add a class
                            add facetColor here as the default. We will add facet color to each style -->
                            <xsl:if test="not($preserveSpacesCss = '')">
                    			<xsl:attribute name="class"><xsl:value-of select="$preserveSpacesCss"/></xsl:attribute>
                   			</xsl:if>
                            <xsl:if test="not($facetColorClass = '')">
                                <xsl:attribute name="class"><xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
                            </xsl:if>
							<!-- STATUS -->
							  <xsl:if test="$status = 'cut' or $status = 'add' or $status = 'resequence' or $status = 'new' or $status = 'lookup'">
                              <!-- first place we can add a class
                                   add facetColor here as the default. We will add facet color to each style -->
			                        <xsl:if test="not($facetColorClass = '')">
			                             <xsl:attribute name="class"><xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
			                        </xsl:if> 							  
									  <xsl:choose>
										  <xsl:when test="$status = 'cut'">
											<xsl:attribute name="class">mx_cut <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>
										  <xsl:when test="$status = 'add' and /mxRoot/columns/column[1]/settings/setting[@name='Editable']='true'">
											 <xsl:choose>
                                                 	   <xsl:when test="@edited='true'">
	                                                        <xsl:choose>
																<xsl:when test="$isRequiredColumn">
																	<xsl:attribute name="class">mx_editable mx_required mx_edited mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																</xsl:when>
																<xsl:otherwise>
                                                        			<xsl:attribute name="class">mx_editable mx_edited mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
																</xsl:otherwise>
															</xsl:choose>
	                                                    </xsl:when>
														<xsl:when test="$isRequiredColumn">
															<xsl:attribute name="class">mx_editable mx_required mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
														</xsl:when>
														<xsl:otherwise>
                                                   <xsl:attribute name="class">mx_editable mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>		                                                 
														</xsl:otherwise>
												</xsl:choose>
										  </xsl:when>
										  <xsl:when test="$status = 'add' and /mxRoot/columns/column[1]/settings/setting[@name='Editable']='false'">
											<xsl:attribute name="class">mx_add <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>
										  <xsl:when test="$status = 'resequence'">
											<xsl:attribute name="class">mx_resequence <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
										  </xsl:when>							  
										  <xsl:otherwise>
											<xsl:attribute name="class">mx_editable <xsl:value-of select="concat($facetColorClass, ' ', $preserveSpacesCss)"/></xsl:attribute>
								   </xsl:otherwise>
							    </xsl:choose>
								   </xsl:if>
							    <!-- STATUS -->
							<xsl:choose>
								<xsl:when
									test="$currentColumn/@type='separator'">
									<xsl:attribute name="class">mx_separator</xsl:attribute>
								</xsl:when>
								<xsl:when
									test="$currentColumn/@type='businessobject' and not($currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression'])">
									<xsl:if test="string-length(text()) &gt; 0 ">
									<xsl:attribute name="title">
										<xsl:value-of select="text()" />
									</xsl:attribute>
									</xsl:if>
									<xsl:variable name="href">
										<xsl:if
											test="$currentColumn/@href and not($status = 'new') and not($status = 'lookup') and not($rg)">
											<xsl:call-template
												name="href">
												<xsl:with-param
													name="col" select="$currentColumn" />
											</xsl:call-template>
										</xsl:if>
									</xsl:variable>
									<xsl:choose>
										<!-- cell with href -->
										<xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')  and ($isFromCtxSearch = 'false')">
											<xsl:element name="a">
												<xsl:attribute name="href">
													<xsl:value-of select="normalize-space($href)" />
												</xsl:attribute>
                                                <xsl:attribute name="data-oid">
                                                	<xsl:value-of select="$oid" />
												</xsl:attribute>
												<xsl:attribute name="data-icon">
                                                	<xsl:value-of select="@i" />
                                                </xsl:attribute>
												<xsl:if test="$expr = 'name'">
                                                    <xsl:attribute name="class">
                                                        <xsl:value-of select="'object'" />
                                                    </xsl:attribute>
                                                </xsl:if>
												<xsl:choose>
													<xsl:when test="@FPRootCol = 'true'">
														 <xsl:value-of select="." />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="." />
													</xsl:otherwise>
												</xsl:choose>
											</xsl:element>
										</xsl:when>
										<xsl:when test="$currentColumn/@type='programHTMLOutput'">
											<xsl:for-each select="./node()">
												<xsl:choose>
													<xsl:when test="@FPRootCol = 'true'">
														 <xsl:value-of select="." />
													</xsl:when>
													<xsl:otherwise>
														<xsl:value-of select="." />
													</xsl:otherwise>
												</xsl:choose>
											</xsl:for-each>
										</xsl:when>
										<xsl:when test="./mxLink">
											<xsl:for-each select="./mxLink/node()">
												<xsl:copy-of select="." />
											</xsl:for-each>
										</xsl:when>
										<!--cell without href -->
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="$expr = 'name'">
													<span class="object">
														<xsl:value-of select="." />
                                                     </span>
                                                 </xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="." />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<!-- ICON COLUMN -->
								<xsl:when test="$currentColumn/@type='icon' and not(@editMask and contains($currentSettings/setting[@name='Column Icon'],'iconActionEdit'))">
									<xsl:call-template name="iconColumn">
										<xsl:with-param name="col" select="$currentColumn" />
									</xsl:call-template>
								</xsl:when>
								<!--	PROGRAM HTML OR FILE	-->
								<xsl:when test="$currentColumn/@type='programHTMLOutput' or $currentColumn/@type='File'">
									<xsl:variable name="varRootValue">
										<xsl:value-of select="@FPRootCol" />
									</xsl:variable>
									<xsl:for-each select="./node()">
										<xsl:choose>
											<xsl:when test="$varRootValue = 'true'">
												<xsl:choose>
													<xsl:when test="$currentColumn/setting[@name = 'Root Label']">
														<xsl:value-of select="/mxRoot/tableControlMap/setting[@name='ObjectInfo']/items/item[@name='name']/value"/>
													</xsl:when>
													<xsl:otherwise>
													        <xsl:copy-of select="."/>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>
												<xsl:copy-of select="." />
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:when>
								<xsl:when test="$currentSettings/setting[@name='Alternate OID expression'] or $currentSettings/setting[@name='Alternate Policy expression']">
                                       <xsl:for-each select="./node()">
                                              <xsl:copy-of select="."/>
                                       </xsl:for-each>
                                </xsl:when>
								<!--	IMAGE	-->
								<xsl:when test="$Field_Type = 'image'">
									<xsl:variable name="href">
										<xsl:call-template name="href">
											<xsl:with-param name="col" select="$currentColumn" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:choose>
									    <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')">
									<xsl:element name="a">
										<xsl:attribute name="href">
											<xsl:value-of select="normalize-space($href)" />
										</xsl:attribute>
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
							
								<xsl:when test="$currentColumn/@type='checkbox'" >
                                  		<input type="checkbox" class="small" name="chkList" id="rmbrow-{$id}"
													value="{concat($relId,'|',$oid,'|',$parentOid,'|',$id)}"
													 onclick="doFreezePaneCheckboxClick(this, event); doCheckSelectAll();">
													 
												<xsl:if test="(string(@a) = 'false') or (parent::r/@disableSelection = 'true')"> 
													 	<xsl:attribute name="disabled">true</xsl:attribute>
												</xsl:if>
												<xsl:if test="parent::r/@checked = 'checked'">
													<xsl:attribute name="checked">
														<xsl:value-of select="parent::r/@checked" />
													</xsl:attribute>
												</xsl:if>
									</input>
						    </xsl:when>
								<xsl:otherwise>
									   <xsl:attribute name="title">
                                                <xsl:choose>
                                                        <xsl:when test="./mxLink">
                                                                <xsl:for-each select="./mxLink/node()">
                            										<xsl:value-of select="."/>
                                                                </xsl:for-each>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                                <xsl:value-of select="text()"/>
                                                        </xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:variable name="href">
                                                 <xsl:if test="$currentColumn/@href  and not($status = 'new') and not($status = 'lookup') and not($rg)">
                                                        <xsl:call-template name="href">
                                                               <xsl:with-param name="col" select="$currentColumn"/>
                                                        </xsl:call-template>
                                                 </xsl:if>
                                         </xsl:variable>
                                         <xsl:choose>
                                                 <!-- cell with href -->
                                                 <xsl:when test="string-length($href) &gt; 0 and not($href = '#DENIED!')  and ($isFromCtxSearch = 'false')">
                                                        <xsl:element name="a">
                                                               <xsl:attribute name="href"><xsl:value-of select="normalize-space($href)"/></xsl:attribute>
                                                               <xsl:value-of select="."/>
                                                        </xsl:element>
                                                 </xsl:when>
                                                  <xsl:when test="./mxLink">
                                                        <xsl:for-each select="./mxLink/node()">
                                                                <xsl:copy-of select="."/>
                                                        </xsl:for-each>
                                                 </xsl:when>
                                                <!--cell without href -->
                                                 <xsl:otherwise>
                                                        <xsl:value-of select="text()"/>
                                                 </xsl:otherwise>
                                        </xsl:choose>

								</xsl:otherwise>
							</xsl:choose>
                            <xsl:if test="$rg">
							    <span>&#160;(<xsl:value-of select="parent::r/@count"/>)</span>
                            </xsl:if>
							<xsl:variable name="oldVal" select="@a"/>
						    <xsl:variable name="newVal" select="."/>
						    <xsl:if test="@edited='true' and not(string($oldVal) = string($newVal))">

						    <xsl:variable name="string1" select="@a"/>
						    <xsl:variable name="from1" select="'&gt;'"/>
						    <xsl:variable name="from2" select="'&lt;'"/>
						    <xsl:variable name="string2" select="substring-after($string1, $from1)"/>
						    <xsl:variable name="string3" select="substring-before($string2, $from2)"/>
							    <span>&#160;</span>
						    <span class="original-value"><xsl:value-of select="@d"/></span>

						    </xsl:if>
						</td>
					</tr>
				</table>
			</div>
	</xsl:if>
	</xsl:template>
       <!--ICON COLUMN TEMPLATE -->
       <xsl:template name="iconColumn">
              <xsl:param name="col" select="."/>
              <xsl:choose>
				   <xsl:when test="parent::r/@ra='t' or not(parent::r/@ra) ">
              <xsl:variable name="href">
                     <xsl:call-template name="href">
                            <xsl:with-param name="col" select="$col"/>
                     </xsl:call-template>
              </xsl:variable>
              <xsl:variable name="image">
                     <xsl:call-template name="cellImage">
                            <xsl:with-param name="col" select="$col"/>
                     </xsl:call-template>
              </xsl:variable>
              <xsl:choose>
                     <!-- Image with href -->
                     <xsl:when test="string-length($href) &gt; 0">
                            <xsl:element name="a">
                                   <xsl:attribute name="href"><xsl:value-of select="normalize-space($href)"/></xsl:attribute>
                                   <xsl:copy-of select="$image"/>
                            </xsl:element>
                     </xsl:when>
                     <!--Image without href -->
                     <xsl:otherwise>
                            <xsl:copy-of select="$image"/>
                     </xsl:otherwise>
              </xsl:choose>
              	  </xsl:when>
				  <!--Hyperlink disabled for show access-->
				  <xsl:otherwise>
				      <!-- Dont show new window launcher "show only" access-->
					  <xsl:choose>
						  <xsl:when test="not(contains($col/settings/setting[@name='Column Icon'], 'iconNewWindow.gif'))">
	                          <xsl:call-template name="cellImage">
	                              <xsl:with-param name="col" select="$col"/>
	                          </xsl:call-template>
						  </xsl:when>
						  <xsl:otherwise>
						       <xsl:value-of select="''"/>
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
                                   <xsl:value-of select="@altOID"/>
                            </xsl:when>
                            <xsl:otherwise>
                                   <xsl:value-of select="../@o"/>
                            </xsl:otherwise>
                     </xsl:choose>
              </xsl:variable>
              <xsl:variable name="relId" select="../@r"/>
              <xsl:variable name="parentId" select="../@p"/>
              <xsl:variable name="quote">"</xsl:variable>
              <xsl:variable name="escape">\"</xsl:variable>
              <xsl:variable name="currentNode"><xsl:call-template name="replace-string"><xsl:with-param name="text" select="."/><xsl:with-param name="from" select="$quote"/><xsl:with-param name="to" select="$escape"/></xsl:call-template></xsl:variable>
          javascript:link("<xsl:value-of select="@index"/>","<xsl:value-of select="$oid"/>","<xsl:value-of select="$relId"/>","<xsl:value-of select="$parentId"/>","<xsl:value-of select="$currentNode"/>")
          </xsl:when>
	      <xsl:otherwise>
		       <xsl:value-of select="'#DENIED!'"/>
	      </xsl:otherwise>
       </xsl:choose>
    </xsl:template>
       <!-- CELL IMAGE -->
       <xsl:template name="cellImage">
              <xsl:param name="col" select="."/>
              <xsl:element name="img">
                     <xsl:attribute name="height">16</xsl:attribute>
                     <xsl:attribute name="src"><xsl:value-of select="$col/settings/setting[@name='Column Icon']"/></xsl:attribute>
                     <xsl:attribute name="title"><xsl:value-of select="$col/@alt"/></xsl:attribute>
                     <xsl:attribute name="border">0</xsl:attribute>
              </xsl:element>
       </xsl:template>
       <!-- END TABLE BODY -->
       
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
    
           <!-- To diplay Mutli-value attribute in SB -->
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

