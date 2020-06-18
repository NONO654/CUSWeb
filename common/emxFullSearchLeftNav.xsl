<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="expand">FullSearch.expand(this)</xsl:variable>
	<xsl:template match="/mxRoot/object">
	<div class="facet-body">
		<xsl:choose>
			<xsl:when test="@id='complex-control'">
				<xsl:apply-templates select="object[@id='breadcrumbs']" mode="complex-control-breadcrumb"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="imgName">
					<xsl:choose>
						<xsl:when test="./object[@id!='breadcrumbs']/@isExpanded='true'">images/fullSearchArrowCollapse.gif</xsl:when>
						<xsl:otherwise>images/fullSearchArrowExpand.gif</xsl:otherwise>	
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="imgid">
					<xsl:value-of select="./object[@id!='breadcrumbs']/@id"/>
				</xsl:variable>

		 <xsl:choose>
			 <xsl:when test="./object/@id = 'attributes'">
						<xsl:apply-templates select="object[@id='attributes']" mode="attPicker"/>			
				</xsl:when>
				<xsl:otherwise>
				<xsl:choose>
			 <xsl:when test="./object/@id = 'breadcrumbs'">
			    <ul>
					<xsl:apply-templates select="object[@id='breadcrumbs']" mode="selected"/>
				</ul>
				</xsl:when>
				<xsl:otherwise>
						<xsl:apply-templates select="object"/>
				</xsl:otherwise>
				</xsl:choose>				
				</xsl:otherwise>
			</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		</div>
	</xsl:template>
	<!--
		Attributes Breadcrumb Template
	-->
	<xsl:template match="object[string]" mode="selected">
	<xsl:variable name="isSelect" select="string(@isMandatory)"/>   
   <li>
        <ul>
        <xsl:if test="$isSelect = 'true'">
				<xsl:attribute name="class">preconfigured</xsl:attribute>
		</xsl:if>
          <li class="category">
				<a selected="true" filter_name="{string[@id='attribute']/text()}" filter_val="{string[@id='value']/text()}" operator="{string[@id='operator']/text()}" filter_index="{string[@id='index']/text()}">                 
					<xsl:if test="not($isSelect = 'true')">
						<xsl:attribute name="onclick">FullSearch.toggle(this)</xsl:attribute>
					</xsl:if>
				</a>
					<label><xsl:value-of select="string[@id='displayName']"/>:</label>
		  </li>
		  <xsl:for-each select="object[@id = 'children']/object">
			<li> 
				 <a selected="true" filter_name="{string[@id='attribute']/text()}" filter_val="{string[@id='value']/text()}" operator="{string[@id='operator']/text()}" filter_index="{string[@id='index']/text()}">                
					<xsl:if test="not($isSelect = 'true')">
						<xsl:attribute name="onclick">FullSearch.toggle(this)</xsl:attribute>
					</xsl:if>
				</a>
					<xsl:choose>
						<xsl:when test="contains(string[@id='operator']/text(),'Greater')">&gt; </xsl:when>
						<xsl:when test="contains(string[@id='operator']/text(),'Less')">&lt; </xsl:when>
						<xsl:when test="contains(string[@id='operator']/text(),'NotEquals')">!= </xsl:when>
						<xsl:otherwise/>
					</xsl:choose>
					<label><xsl:value-of select="string[@id='displayValue']"/></label>
			</li>
		 </xsl:for-each>
		</ul>
	 </li>
	</xsl:template>
	
	<!--
		Complex field Breadcrumb Template
	-->
	<xsl:template match="object" mode="complex-control-breadcrumb">
	<xsl:for-each select="object">
		<xsl:variable name="FNAME" select="string[@id='value']/text()" />
		<xsl:variable name="FDispVal" select="string[@id='displayValue']/text()" />
		<xsl:variable name="FSEP" select="string[@id='fieldSeparator']/text()" />
		<xsl:for-each select="object">
		</xsl:for-each>
		<ul id="complexcontrol_{$FNAME}"><li>
		<ul>
				<li class="category">
					<a selected="true" onclick="javascript:FullSearch.toggle(this,'{$FSEP}')" filter_name="{$FNAME}" filter_val="{string[@id='value']/text()}" operator="{string[@id='operator']/text()}" filter_index="{string[@id='index']/text()}">	
					</a>
		    		<label><xsl:value-of select="$FDispVal"/>:</label>	
				</li>
			<xsl:for-each select="object">
			<xsl:variable name="level" select="number[@id='level']/text()" />
				<li>
					<a selected="true" onclick="javascript:FullSearch.toggle(this,'{$FSEP}')" filter_name="{$FNAME}" filter_val="{string[@id='value']/text()}" operator="{string[@id='operator']/text()}" filter_index="{string[@id='index']/text()}">
					</a>
	         	<label><xsl:value-of select="string[@id='displayValue']/text()"/></label>
				</li>
			</xsl:for-each>
		 </ul>
		</li>
	 </ul>		
	</xsl:for-each>		
	</xsl:template>
	
	
	<!--
		Attribute template
	-->
	<xsl:template match="object[string]" mode="attPicker">
		<xsl:variable name="defaultunit">
			<xsl:choose>
				<xsl:when test="string[@id='defaultunit']">
					<xsl:value-of select="string[@id='defaultunit']/text()"/>
				</xsl:when>
			</xsl:choose>
			<xsl:value-of select="defaultunit/text()"/>
		</xsl:variable>
		<xsl:variable name="dataType">
			<xsl:value-of select="dataType/text()"/>
		</xsl:variable>
		<xsl:variable name="uomList">
			<xsl:value-of select="uomList/text()"/>
		</xsl:variable>
		<xsl:variable name="mandatorySearch">
			<xsl:value-of select="@mandatorySearch"/>
		</xsl:variable>
		<xsl:variable name="fieldName">
			<xsl:value-of select="field/text()"/>
		</xsl:variable>
		<div id="{generate-id()}">
			<xsl:choose>
				<xsl:when test="count(ancestor::object)=2">
					<xsl:attribute name="class">facet-attr</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">facet-attr</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			  <div class="facet-attr-head">
			     <div class="facet-title">
				<label>
					<xsl:if test="string-length($mandatorySearch) = 0 or $mandatorySearch = 'false'">
						<xsl:attribute name="onclick">FullSearch.toggle(this) </xsl:attribute>
					</xsl:if>
					<xsl:if test="number and string[@id='value']">
						<xsl:attribute name="filter_name"><xsl:value-of select="../../string/text()"/></xsl:attribute>
						<xsl:attribute name="filter_val"><xsl:value-of select="string/text()"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="number and string[@id='type']">
						<xsl:attribute name="filter_name"><xsl:value-of select="$fieldName"/></xsl:attribute>
						<xsl:attribute name="filter_val"><xsl:value-of select="string/text()"/></xsl:attribute>
						<xsl:attribute name="filter_DisplayValue"><xsl:value-of select="string[@id='displayValue']/text()"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="string">
						<xsl:if test="not(string[@id='type'])">
							<xsl:attribute name="filter_name"><xsl:value-of select="string[@id='attribute']/text()"/></xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="string[@id='displayValue']">
								<xsl:value-of select="string[@id='displayValue']/text()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="string/text()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="number and (string[@id='value'] or string[@id='type'])"> (<xsl:value-of select="number/text()"/>)</xsl:if>
				</label>
			  </div>
			</div>
			<xsl:if test="object/object[string]">
				<div id="sub_{generate-id()}" class="hide">
					<xsl:apply-templates select="object/object" mode="attPicker"/>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	<!--
		Generic Left Nav Template
	-->
	<xsl:template match="object[string]">
		<xsl:param name="depth" select="0" />
		<xsl:variable name="dataType">
			<xsl:value-of select="dataType/text()"/>
		</xsl:variable>
		<xsl:variable name="uomList">
			<xsl:value-of select="uomList/text()"/>
		</xsl:variable>
		<xsl:variable name="mandatorySearch">
			<xsl:value-of select="@mandatorySearch"/>
		</xsl:variable>
		<xsl:variable name="fieldName">
			<xsl:value-of select="field/text()"/>
		</xsl:variable>
		<div id="{generate-id()}">
			<xsl:choose>
				<xsl:when test="parent::node()/parent::object[@selected = 'true'] or @selected = 'true' or descendant::object[@selected = 'true']">
					<xsl:attribute name="class">show</xsl:attribute>
				</xsl:when>
				<xsl:when test="count(ancestor::object)=2">
					<xsl:attribute name="class">show</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">hide</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<div style="position:relative">
				<xsl:if test="@selected = 'true' or descendant::object[@selected = 'true']">
					<xsl:attribute name="class">selected</xsl:attribute>
				</xsl:if>
				<!-- <img src="images/utilSpacer.gif" height="1" width="{count(ancestor::object)* 5}"/> -->
				<xsl:if test="../object">
                        <xsl:apply-templates select="." mode="miscimages"/>
                </xsl:if>
                <xsl:apply-templates select="." mode="plusminusimage" >
                	<xsl:with-param name="depth" select="$depth" />
                </xsl:apply-templates>
				<a>
					<xsl:if test="string-length($mandatorySearch) = 0 or $mandatorySearch = 'false'">
						<xsl:attribute name="onclick">FullSearch.toggle(this) </xsl:attribute>
					</xsl:if>
					<xsl:attribute name="selected"><xsl:value-of select="@selected"/></xsl:attribute>
					<xsl:if test="number and string[@id='value']">
						<xsl:attribute name="filter_name"><xsl:value-of select="../../string/text()"/></xsl:attribute>
						<xsl:attribute name="filter_val"><xsl:value-of select="string/text()"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="string[@id='type']">
						<xsl:attribute name="filter_name"><xsl:value-of select="$fieldName"/></xsl:attribute>
						<xsl:attribute name="filter_val"><xsl:value-of select="string[@id='type']/text()"/></xsl:attribute>
						<xsl:attribute name="filter_DisplayValue"><xsl:value-of select="string[@id='displayValue']/text()"/></xsl:attribute>
					</xsl:if>
					<xsl:if test="string">
						<xsl:if test="not(string[@id='type'])">
							<xsl:attribute name="filter_name"><xsl:value-of select="string[@id='attribute']/text()"/></xsl:attribute>
						</xsl:if>
                        <xsl:if test="@selected = 'true' or descendant::object[@selected = 'true']">
                          <img src="images/fullSearchButtonSelected.gif" hspace="2"/>
                        </xsl:if>
						<xsl:choose>
							<xsl:when test="string[@id='displayValue']">
								<xsl:value-of select="string[@id='displayValue']/text()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="string/text()"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="number and (string[@id='value'] or string[@id='type'])and
									not(@selected = 'true' or descendant::object[@selected = 'true'])"> (<xsl:value-of select="number/text()"/>)</xsl:if>
				</a>
			</div>
			<xsl:if test="object/object[string]">
				<div id="sub_{generate-id()}" style="position:relative">
					<xsl:choose>
						<xsl:when test="@selected = 'true' or descendant::object[@selected = 'true']">
							<xsl:attribute name="class">show</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">hide</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates select="object/object">
						<xsl:with-param name="depth" select="$depth + 1" />
					</xsl:apply-templates>
				</div>
			</xsl:if>
		</div>
	</xsl:template>
	
	<xsl:template match="object" mode="miscimages">
            <xsl:for-each select="ancestor::node()[name() != 'mxRoot' and @selected]">
                <xsl:if test="not(mxRoot)">
                     <img height="16" width="16" style="position:relative">
                            <xsl:attribute name="src">
                                    <xsl:choose>
                                            <xsl:when test="parent::node() and not(following-sibling::object)">images/utilSpacer.gif</xsl:when>
                                            <xsl:otherwise>images/fullSearchTreeLineVert.gif</xsl:otherwise>
                                    </xsl:choose>                                                                
                            </xsl:attribute>
                    </img>
                </xsl:if>
            </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="object" mode="plusminusimage">
    <xsl:param name="depth"/>
    	<img width="16" height="16"  style="position:relative" hasSibling="{not(not(following-sibling::object))}" level="{$depth}" onclick="FullSearch.toggleTaxonomyExpand(this,'{field/text()}','{string[@id='type']/text()}')">
    		<xsl:attribute name="src">
            	<xsl:choose>
                        <xsl:when test="@isExpanded = 'true' and following-sibling::object">
                                <xsl:choose>
                                		<xsl:when test="@selected = 'true'">images/fullSearchTreeLineNodeOpen.gif</xsl:when>
                                        <xsl:when test="object/object[string]">images/fullSearchTreeLineNodeClosed.gif</xsl:when>
                                        <xsl:otherwise>images/fullSearchTreeLineNode.gif</xsl:otherwise>
                                </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:choose>
                                		<xsl:when test="@selected = 'true'">images/fullSearchTreeLineLastOpen.gif</xsl:when>
                                        <xsl:when test="object/object[string]">images/fullSearchTreeLineLastClosed.gif</xsl:when>
                                        <xsl:otherwise>images/fullSearchTreeLineLast.gif</xsl:otherwise>
                                </xsl:choose>
                        </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
        </img>
    </xsl:template>
</xsl:stylesheet>

