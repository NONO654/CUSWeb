<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" version="1.0" encoding="UTF-16" indent="no" omit-xml-declaration="yes"/>
<xsl:variable name="mode"><xsl:value-of select="/ROOT/@mode"/></xsl:variable>

<!--                                      User Settings                                  -->
<xsl:variable name="showPrice">false</xsl:variable> <!--  Change to false in order to hide the Price fields -->
<xsl:variable name="showHelpIcon">true</xsl:variable><!--  Change to false in order to hide the help icon -->
<xsl:variable name="showQuantity">false</xsl:variable><!--  Change to false in order to hide the quantity field -->
<xsl:variable name="DBChooserLimit"><xsl:value-of select="/ROOT/@DBChooserLimit"/></xsl:variable><!-- Change number in order to set the maximum number of sub-features for which the parent feature is to be displayed without a DB chooser -->
<xsl:variable name="CacheChooserLimit"><xsl:value-of select="/ROOT/@CacheChooserLimit"/></xsl:variable><!-- Change number in order to set the maximum number of sub-features for which the parent feature is to be displayed without a cache chooser -->
<xsl:variable name="DropDownLimit"><xsl:value-of select="/ROOT/@DropDownLimit"/></xsl:variable><!-- Change number in order to set the maximum number of sub-features for which the parent feature is to be displayed without a DropDown -->
<xsl:variable name="MPRList"><xsl:value-of select="/ROOT/@MPRList"/></xsl:variable><!-- MPRList -->
<xsl:variable name="BasePrice"><xsl:value-of select="/ROOT/@BasePrice"/></xsl:variable><!-- Base Price -->
<xsl:variable name="contextObjectId"><xsl:value-of select="/ROOT/@contextObjectId"/></xsl:variable>
<xsl:variable name="startEffectivity"><xsl:value-of select="/ROOT/@startEffectivity"/></xsl:variable>

<xsl:variable name="i18FnO"><xsl:value-of select="/ROOT/@i18FnO"/></xsl:variable>
<xsl:variable name="i18BasePrice"><xsl:value-of select="/ROOT/@i18BasePrice"/></xsl:variable>
<xsl:variable name="i18Help"><xsl:value-of select="/ROOT/@i18Help"/></xsl:variable>
<xsl:variable name="i18Quantity"><xsl:value-of select="/ROOT/@i18Quantity"/></xsl:variable>
<xsl:variable name="i18EachPrice"><xsl:value-of select="/ROOT/@i18EachPrice"/></xsl:variable>
<xsl:variable name="i18ExtendedPrice"><xsl:value-of select="/ROOT/@i18ExtendedPrice"/></xsl:variable>
<xsl:variable name="i18TotalPrice"><xsl:value-of select="/ROOT/@i18TotalPrice"/></xsl:variable>
<xsl:variable name="i18Remove"><xsl:value-of select="/ROOT/@i18Remove"/></xsl:variable>
<xsl:variable name="i18Choices"><xsl:value-of select="/ROOT/@i18Choices"/></xsl:variable>
<xsl:variable name="i18Name"><xsl:value-of select="/ROOT/@i18Name"/></xsl:variable>
<xsl:variable name="i18Filter"><xsl:value-of select="/ROOT/@i18Filter"/></xsl:variable>

<!--                                      Main template                                  -->
<xsl:template match="ROOT">
<frame name="CalendarFrame"></frame>
<form name="featureOptions" method="post">
<input type="hidden" id="lstTrueMPRId">
<xsl:attribute name="lstTrueMPRId"><xsl:value-of select="$MPRList"/></xsl:attribute>
</input>
<input type="hidden" id="strExcludeListMPR" strExcludeListMPR=""></input>
<div id="editResponse"></div>
<div id="mx_divConfiguratorBody">
<table id="featureOptionsTable" cellspacing="0" cellpadding="0" border="0">
<thead id="mx_divBasePrice">
<tr>
<th class="mx_status">&#160;</th>
<th class="mx_name">&#160;</th>
<th class="mx_info"><xsl:if test="$showHelpIcon='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if>&#160;</th>
<th class="mx_quantity">
<xsl:if test="$showQuantity='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if>&#160;</th>
<th class="mx_each-price">
<xsl:if test="$showPrice='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if><xsl:value-of select="$i18BasePrice"/></th>
<th class="mx_extended-price">
<xsl:if test="$showPrice='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if>
<input id="BasePrice" type="text" readonly="">
<xsl:attribute name="value"><xsl:value-of select="$BasePrice"/></xsl:attribute>
</input>
</th>
</tr>
<tr>
<th class="mx_status">&#160;</th>
<th class="mx_name"><xsl:value-of select="$i18FnO"/></th>
<th class="mx_info">
<xsl:if test="$showHelpIcon='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if><xsl:value-of select="$i18Help"/></th>
<th class="mx_quantity">
<xsl:if test="$showQuantity='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if><xsl:value-of select="$i18Quantity"/></th>
<th class="mx_each-price">
<xsl:if test="$showPrice='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if><xsl:value-of select="$i18EachPrice"/></th>
<th class="mx_extended-price">
<xsl:if test="$showPrice='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if><xsl:value-of select="$i18ExtendedPrice"/></th>
</tr>
</thead>

<tbody id="featureOptionsBody">
<xsl:choose>
  <xsl:when test="$mode='view'">
	<xsl:apply-templates select="PARENT_NODE[Selected_State='true']">
		<xsl:sort select="Sequence_Number" data-type="number"/>
		<xsl:with-param name="depth" select="0"/>
	</xsl:apply-templates>
	<xsl:apply-templates select="./Conflict"/>
	</xsl:when>
	<xsl:otherwise>
	<xsl:apply-templates select="*">
		<xsl:sort select="Sequence_Number" data-type="number"/>
		<xsl:with-param name="depth" select="0"/>
	</xsl:apply-templates>
	</xsl:otherwise>
</xsl:choose>
</tbody>
</table>
</div>
<div id="mx_divTotalPrice">
<table cellspacing="0" cellpadding="0" border="0">
<xsl:if test="$showPrice='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if>
<tbody>
</tbody>
<tr>
<td class="mx_info">&#160;</td>
<td class="mx_quantity">&#160;</td>
<td class="mx_each-price"><xsl:value-of select="$i18TotalPrice"/></td>
<td class="mx_extended-price">
<input id="TotalPrice" type="text" readonly="" value="0" name=""/>
</td>
</tr>
</table>
</div>
</form>
</xsl:template>


<!--                               template for displaying Characteristics                 -->
<xsl:template name="DisplayCharacteristic" match="PARENT_NODE[SubFeature_Count &lt; $DBChooserLimit or $mode='view']">
<xsl:param name="depth" select="0"/>
<xsl:if test="Availability='true'">
<tr>
<xsl:attribute name="class">
   <xsl:if test="Conflict='true'">mx_error</xsl:if>
</xsl:attribute>
<xsl:attribute name="id">MprRow<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
<xsl:if test="$depth=0">
<xsl:attribute name="istoplevel">true</xsl:attribute>
</xsl:if>
  <!--Display status icon depending on whether this charateristic has been selected-->
<xsl:call-template name="DisplayStatusIcon"/>
<td><table class="mx_feature-option" cellspacing="0" cellpadding="0" border="0">
	<tbody>
		<tr>
		 <!--Indent the row based on the node level-->
		     <xsl:call-template name="DisplaySpace">
             <xsl:with-param name="indentationCount" select="$depth"></xsl:with-param>
             </xsl:call-template>
		   <xsl:if test="parent::PARENT_NODE and not($mode='view')">
		   <td class="mx-input-cell">
		   <div>
		      <xsl:attribute name="id"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
		      <xsl:attribute name="selectiontype"><xsl:value-of select="../Selection_Type"/></xsl:attribute>
		      <xsl:attribute name="ftrlstid"><xsl:value-of select="./ID"/></xsl:attribute>
		      <xsl:attribute name="innerhtmlid"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
		      <xsl:attribute name="groupname"><xsl:value-of select="../ID"/></xsl:attribute>
		      <input>
		         <xsl:attribute name="featurerowlevel"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
		         <xsl:attribute name="id"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
		         <xsl:attribute name="onclick">validate('<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
		         <xsl:if test="../Selection_Type='Single'">
		            <xsl:attribute name="type">radio</xsl:attribute>
		            <xsl:attribute name="value">radiobutton</xsl:attribute>
		            <xsl:attribute name="name"><xsl:value-of select="../ID"/></xsl:attribute>
		         </xsl:if>
		         <xsl:if test="../Selection_Type='Multiple'">
		            <xsl:attribute name="type">checkbox</xsl:attribute>
		            <xsl:attribute name="value">checkbox</xsl:attribute>
                    <xsl:attribute name="name"><xsl:value-of select="../ID"/></xsl:attribute>
		         </xsl:if>
		         <xsl:if test="./Selected_State='true'">
		            <xsl:attribute name="checked"/>
		         </xsl:if>
		      </input>
		   </div>
		   </td>
		   </xsl:if>
             <!--Display the characteristic icon as well as name -->
		     <td class="" mx_icon=""><img  src="../common/images/iconSmallConfigurationfeature.gif"/></td>
		     <td class="mx_feature-option"><xsl:value-of select="Name"></xsl:value-of></td>
		   </tr>
	</tbody>
</table>
</td>
<xsl:call-template name="DisplayHelpIcon"/>
<xsl:call-template name="DisplayQuantity"/>
<xsl:call-template name="DisplayEachPrice"/>
<xsl:call-template name="DisplayExtendedPrice"/>
</tr>
<!--Display child nodes-->
	<!-- <xsl:choose> -->
		<!-- <xsl:when test="KeyIn_Type='Blank'">-->	
		  <xsl:choose>
		      <xsl:when test="$mode='view'">
		        <xsl:apply-templates select="PARENT_NODE[Selected_State='true']|LEAF_NODE[Selected_State='true']">
                        <xsl:sort select="Sequence_Number" data-type="number"/>
                        <xsl:with-param name="depth" select="$depth+1"/>
                </xsl:apply-templates>
		      </xsl:when>
		      <xsl:otherwise>
<xsl:apply-templates select="*">
		<xsl:sort select="Sequence_Number" data-type="number"/>
		<xsl:with-param name="depth" select="$depth+1"/>
</xsl:apply-templates> 
              </xsl:otherwise>
          </xsl:choose> 
		<!-- </xsl:when> -->
		<!-- <xsl:otherwise> -->
		<xsl:if test="KeyIn_Type!='Blank' and count(child::LEAF_NODE[Availability='false'])=0">
			<xsl:call-template name="DisplayKeyIn">
				<xsl:with-param name="depth" select="$depth+1"/>
			</xsl:call-template>
        </xsl:if>
		<!-- </xsl:otherwise> -->
		<!-- </xsl:choose> -->
</xsl:if>
</xsl:template>

<!--                               template for displaying Characteristics with DbChooser                 -->
<xsl:template name="DisplayCharacteristicWithDBChooser" match="PARENT_NODE[SubFeature_Count >= $DBChooserLimit and not($mode='view')]">
<xsl:param name="depth" select="0"/>
<xsl:if test="Availability='true'">
<tr>
<xsl:attribute name="class">
 <xsl:if test="Conflict='true'">mx_error</xsl:if>
</xsl:attribute>
   
<xsl:attribute name="id">MprRow<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
<xsl:if test="$depth=0">
<xsl:attribute name="istoplevel">true</xsl:attribute>
</xsl:if>
  <!--Display status icon depending on whether this charateristic has been selected-->
<xsl:call-template name="DisplayStatusIcon"/>
<td><table class="mx_feature-option" cellspacing="0" cellpadding="0" border="0">
	<tbody>
		<tr>
		 <!--Indent the row based on the node level-->
		     <xsl:call-template name="DisplaySpace">
             <xsl:with-param name="indentationCount" select="$depth"></xsl:with-param>
             </xsl:call-template>
		   <xsl:if test="parent::PARENT_NODE">
		      <td class="mx-input-cell">
		         <div>
		            <xsl:attribute name="id"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
		            <xsl:attribute name="selectiontype"><xsl:value-of select="../Selection_Type"/></xsl:attribute>
		            <xsl:attribute name="ftrlstid"><xsl:value-of select="./ID"/></xsl:attribute>
		            <xsl:attribute name="innerhtmlid"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
		            <xsl:attribute name="groupname"><xsl:value-of select="../ID"/></xsl:attribute>
		            <input>
		               <xsl:attribute name="featurerowlevel"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
		               <xsl:attribute name="id"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
		               <xsl:attribute name="onclick">validate('<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
		               <xsl:if test="../Selection_Type='Single'">
		                  <xsl:attribute name="type">radio</xsl:attribute>
		                  <xsl:attribute name="value">radiobutton</xsl:attribute>
		                  <xsl:attribute name="name"><xsl:value-of select="../ID"/></xsl:attribute>
		               </xsl:if>
		               <xsl:if test="../Selection_Type='Multiple'">
		                  <xsl:attribute name="type">checkbox</xsl:attribute>
		                  <xsl:attribute name="value">checkbox</xsl:attribute>
                          <xsl:attribute name="name"><xsl:value-of select="../ID"/></xsl:attribute>
		               </xsl:if>
		               <xsl:if test="./Selected_State='true'">
		                  <xsl:attribute name="checked"/>
		               </xsl:if>
		            </input>
		         </div>
		      </td>
		   </xsl:if>
             <!--Display the characteristic icon as well as name -->
		     <td class="" mx_icon=""><img  src="../common/images/iconSmallConfigurationfeature.gif"/></td>
		     <td class="mx_feature-option"><xsl:value-of select="Name"></xsl:value-of></td>
			 <td>
				 <input type="button" class="button" value="..." size="200" name="btnType">
					 <xsl:attribute name="onclick">showSubfeaturesChooser('<xsl:value-of select="OBJECTID"/>','0','<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>','<xsl:value-of select="Selection_Type"/>','<xsl:value-of select="$contextObjectId"/>','<xsl:value-of select="$startEffectivity"/>')</xsl:attribute>
					 </input>
				 </td>
		</tr>
	</tbody>
</table>
</td>
<xsl:call-template name="DisplayHelpIcon"/>
<xsl:call-template name="DisplayQuantity"/>
<xsl:call-template name="DisplayEachPrice"/>
<xsl:call-template name="DisplayExtendedPrice"/>
</tr>
<!--Display child nodes-->
<xsl:for-each select="child::PARENT_NODE[Selected_State = 'true']|LEAF_NODE[Selected_State='true']">
		<xsl:sort select="Sequence_Number" data-type="number"/>
		<xsl:if test="name(.)='PARENT_NODE'">
			<xsl:call-template name="DisplayCharacteristicWithDBChooser">
				<xsl:with-param name="depth" select="$depth+1"/>
			</xsl:call-template>
		</xsl:if>
	<xsl:if test="name(.)='LEAF_NODE'">
			<xsl:call-template name="DisplayOptionForDBChosser">
				<xsl:with-param name="depth" select="$depth+1"/>
			</xsl:call-template>
		</xsl:if>	
</xsl:for-each> 
<xsl:if test="KeyIn_Type!='Blank' and count(child::LEAF_NODE[Availability='false'])=0">
            <xsl:call-template name="DisplayKeyIn">
                <xsl:with-param name="depth" select="$depth+1"/>
            </xsl:call-template>
        </xsl:if> 
</xsl:if>
</xsl:template>


<!--                              Default template do nothing                              -->
<xsl:template name="SelectParentOrLeaf" match="*">
</xsl:template>

<!--                               template for displaying Options under a DB Chooser                        -->
 <xsl:template name="DisplayOptionForDBChosser" match="LEAF_NODE[not($mode='view') and count(preceding-sibling::LEAF_NODE[Availability='true'] | following-sibling::LEAF_NODE[Availability='true']) &lt;2 or ../Selection_Type='Multiple' and count(preceding-sibling::LEAF_NODE[Availability='true'] | following-sibling::LEAF_NODE[Availability='true']) &lt;$DBChooserLimit]">
<xsl:param name="depth" select="0"/>
<xsl:if test="Availability='true'">
<tr>
<xsl:attribute name="class">
   <xsl:if test="Conflict='true'">mx_error</xsl:if>
</xsl:attribute>
        
<xsl:attribute name="id">MprRow<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
<!--Display status icon depending on whether this option has been selected-->
<xsl:call-template name="DisplayStatusIcon"/>
<td>
<table class="mx_feature-option" cellspacing="0" cellpadding="0">
	<tbody>
		<tr>
			   <!--Indent the row based on the node depth-->
		<xsl:call-template name="DisplaySpace">
                <xsl:with-param name="indentationCount" select="$depth"></xsl:with-param>
         </xsl:call-template>
         <!-- Display the icon for removing the db chooser option             -->
         <td class="mx-icon">
         <img  src="../common/images/iconActionRemove.gif" title="Remove">
         <xsl:attribute name="onclick">removeAddedRows('<xsl:value-of select="ID"/>')</xsl:attribute>
         <xsl:attribute name="title"><xsl:value-of select="$i18Remove"/></xsl:attribute>
         </img>
         </td>
          <!--Display the option name as well as radio button or check box-->
		<td class="mx_input-cell">
		<div>
		<xsl:attribute name="id"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
		<xsl:attribute name="maximumquantity"><xsl:value-of select="./Maximum_Quantity"/></xsl:attribute>
		<xsl:attribute name="minimumquantity"><xsl:value-of select="./Minimum_Quantity"/></xsl:attribute>
		<xsl:attribute name="selectiontype"><xsl:value-of select="../Selection_Type"/></xsl:attribute>
		<xsl:attribute name="ftrlstid"><xsl:value-of select="./ID"/></xsl:attribute>
		<xsl:attribute name="innerhtmlid"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
		<xsl:attribute name="groupname"><xsl:value-of select="../ID"/></xsl:attribute>
		</div>
		</td>
		<td class="mx_option"><xsl:value-of select="Name"></xsl:value-of></td>
		</tr>
</tbody>
</table>
</td>
<xsl:call-template name="DisplayHelpIcon"/>
<xsl:call-template name="DisplayQuantity"/>
<xsl:call-template name="DisplayEachPrice"/>
<xsl:call-template name="DisplayExtendedPrice"/>
</tr>
</xsl:if>
</xsl:template>

<!--                                template for displaying configuration options with cache chooser            -->
<!--  <xsl:template name="DisplayCacheChooserForOptions" match="LEAF_NODE[not($mode='view') and count(preceding-sibling::LEAF_NODE[Availability='true'] | following-sibling::LEAF_NODE[Availability='true'])+1 >= $CacheChooserLimit and ../Selection_Type='Single' and count(preceding-sibling::PARENT_NODE[Availability='true'] | following-sibling::PARENT_NODE[Availability='true']) =0]">-->
 <xsl:template name="DisplayCacheChooserForOptions" match="LEAF_NODE[not($mode='view') and ../SubFeature_Count >= $CacheChooserLimit  and ../Selection_Type='Single'] ">
<xsl:param name="depth" select="0"/>
<xsl:variable name="parentId"><xsl:for-each select="."><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:for-each></xsl:variable>
<xsl:if test="count(preceding-sibling::LEAF_NODE[Availability='true'])=0">
<xsl:if test="Availability='true'">
<tr>
<xsl:attribute name="class">
        <xsl:if test="count(preceding-sibling::LEAF_NODE[Conflict='true'] | following-sibling::LEAF_NODE[Conflict='true']) > 0 or Conflict='true'">mx_error</xsl:if>
</xsl:attribute>
        
<xsl:attribute name="id">MprRow<xsl:value-of select="$parentId"/></xsl:attribute>
<!--Display status icon depending on whether this option has been selected-->
<xsl:choose>
<xsl:when test="count(preceding-sibling::LEAF_NODE[Conflict='true'] | following-sibling::LEAF_NODE[Conflict='true']) > 0 or Conflict='true'">
  <xsl:for-each select="../LEAF_NODE[Conflict='true'][1]">
    <xsl:call-template name="DisplayStatusIcon">
        <xsl:with-param name="displayError">true</xsl:with-param>
    </xsl:call-template>
  </xsl:for-each>
</xsl:when>
<xsl:when test="count(preceding-sibling::LEAF_NODE[Changed='true'] | following-sibling::LEAF_NODE[Changed='true']) > 0 or Changed='true'">
  <xsl:for-each select="../LEAF_NODE[Changed='true'][1]">
    <xsl:call-template name="DisplayStatusIcon">
        <xsl:with-param name="displayChange">true</xsl:with-param>
    </xsl:call-template>
  </xsl:for-each>
</xsl:when>
    <xsl:otherwise>
<xsl:call-template name="DisplayStatusIcon"/>
    </xsl:otherwise>
</xsl:choose>

<td>
<table class="mx_feature-option" cellspacing="0" cellpadding="0">
    <tbody>
        <tr>
               <!--Indent the row based on the node depth-->
        <xsl:call-template name="DisplaySpace">
                <xsl:with-param name="indentationCount" select="$depth"></xsl:with-param>
         </xsl:call-template>
         <td class="mx_input-cell">
        <div>
        <xsl:attribute name="id"><xsl:value-of select="$parentId"/></xsl:attribute>
        <xsl:attribute name="mprrowid"><xsl:value-of select="$parentId"/></xsl:attribute>
        <xsl:attribute name="innerhtmlid"><xsl:value-of select="../ID"/></xsl:attribute>
        <xsl:attribute name="name">chooser<xsl:value-of select="$parentId"/></xsl:attribute>
        <xsl:for-each select="../LEAF_NODE[Selected_State='true'][1]">
        <xsl:attribute name="orderedquantity"><xsl:value-of select="Quantity"/></xsl:attribute>
        <xsl:attribute name="maximumquantity"><xsl:value-of select="Maximum_Quantity"/></xsl:attribute>
        <xsl:attribute name="minimumquantity"><xsl:value-of select="Minimum_Quantity"/></xsl:attribute>
        </xsl:for-each>
        <input type="text" readonly="" currentSelectionFtrlstId="">
            <xsl:attribute name="id">chooserElement<xsl:value-of select="../ID"/></xsl:attribute>
            <xsl:attribute name="onchange">validate('<xsl:value-of select="$parentId"/>','<xsl:value-of select="$parentId"/>', false, false, true)</xsl:attribute>
            <xsl:for-each select="../LEAF_NODE[Selected_State='true'][1]">
                <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
            </xsl:for-each>
            <xsl:attribute name="name"><xsl:value-of select="$parentId"/></xsl:attribute>
        </input>
        <input class="button" type="button" size="200" value="...">
            <xsl:attribute name="onclick">getY(event);toggleVisibilityOfFilterLayerDialog('chooserLayerDiv<xsl:value-of select="$parentId"/>',true)</xsl:attribute>
        </input>
        </div>
        <div style="visibility: hidden;" id="mx_divLayerDialog" class="mx_filterable-list">
        <xsl:attribute name="name">chooserLayerDiv<xsl:value-of select="$parentId"></xsl:value-of> </xsl:attribute>
            <div id="mx_divLayerDialogHeader">
            <table cellspacing="0" cellpadding="0" border="0"><tbody><tr><td class="title"><xsl:value-of select="../Name"/>: <xsl:value-of select="$i18Choices"/></td>
            <td class="buttons"><a class="button cancel"><xsl:attribute name="onclick">getY(event);toggleVisibilityOfFilterLayerDialog('chooserLayerDiv<xsl:value-of select="$parentId"/>',false)</xsl:attribute></a>
            <a class="button done">
            <xsl:attribute name="onclick">validate('<xsl:value-of select="$parentId"/>','<xsl:value-of select="$parentId"/>', false, false, true)</xsl:attribute>
            </a></td></tr></tbody></table>
            
            </div>
            <div id="mx_divLayerDialogBody">
            <table cellspacing="0" cellpadding="0" border="0"><tbody><tr><td class="label"><xsl:value-of select="$i18Name"/></td>
            <td> <input type="text" name="filter-input" value="*"><xsl:attribute name="id"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>filterInput</xsl:attribute></input></td>
            <td><input type="button" name="filter-action">
                <xsl:attribute name="onclick">performFilterAction('<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>filterInput','chooserLayerUL<xsl:value-of select="$parentId"/>')</xsl:attribute>
                <xsl:attribute name="value"><xsl:value-of select="$i18Filter"></xsl:value-of> </xsl:attribute>
            </input></td></tr></tbody></table>
            <ul defaultliid="">
                <xsl:attribute name="id">chooserLayerUL<xsl:value-of select="$parentId"></xsl:value-of> </xsl:attribute>
                <xsl:attribute name="featurerowlevel"><xsl:value-of select="$parentId"/></xsl:attribute>
                <xsl:for-each select="../LEAF_NODE[Selected_State='true'][1]">
                    <xsl:attribute name="lastSelectionFtrlstId"><xsl:value-of select="ID"/></xsl:attribute>
                </xsl:for-each>
                <xsl:for-each select="../LEAF_NODE">
                    <xsl:sort select="Sequence_Number" data-type="number"/>
                    <xsl:if test="Availability='true'">
                        <li onclick="makeOptionSelectionFromFilter(this)">
                        <xsl:attribute name="id"><xsl:value-of select="ID"/></xsl:attribute>
                        <xsl:value-of select="Name"/></li>
                   </xsl:if>
                </xsl:for-each>
                
            </ul>
            </div>
        </div>
        </td>
        </tr>
        </tbody>
        </table>
        </td>
            <xsl:if test="count(../LEAF_NODE[Selected_State='true'])>0">
<xsl:for-each select="../LEAF_NODE[Selected_State='true']">
    <xsl:call-template name="DisplayHelpIcon"/>
    <xsl:call-template name="DisplayQuantity"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
    <xsl:call-template name="DisplayEachPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
    <xsl:call-template name="DisplayExtendedPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
</xsl:for-each>
</xsl:if>
<xsl:if test="count(../LEAF_NODE[Selected_State='true'])=0">
   <xsl:call-template name="DisplayHelpIcon"/>
    <xsl:call-template name="DisplayQuantity"><xsl:with-param name="Prefix" select="$parentId"></xsl:with-param></xsl:call-template>
    <xsl:call-template name="DisplayEachPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
    <xsl:call-template name="DisplayExtendedPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
</xsl:if>
</tr>
        </xsl:if>
        </xsl:if>
</xsl:template>
<!--                                template for displaying configuration options with drop down            -->
<!--<xsl:template name="DisplayDropDownForOptions" match="LEAF_NODE[not($mode='view') and count(preceding-sibling::LEAF_NODE[Availability='true'] | following-sibling::LEAF_NODE[Availability='true'])+1 >= $DropDownLimit and count(preceding-sibling::LEAF_NODE[Availability='true'] | following-sibling::LEAF_NODE[Availability='true'])+1 &lt; $CacheChooserLimit and ../Selection_Type='Single']">-->
 <xsl:template name="DisplayDropDownForOptions" match="LEAF_NODE[not($mode='view') and ( ../SubFeature_Count >= $DropDownLimit and  ../SubFeature_Count &lt; $CacheChooserLimit) and ../Selection_Type='Single']">
<xsl:param name="depth" select="0"/>
<xsl:variable name="parentId"><xsl:for-each select="."><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:for-each></xsl:variable>
<xsl:if test="count(preceding-sibling::LEAF_NODE[Availability='true'])=0">
<xsl:if test="Availability='true'">
<tr>
      
<xsl:attribute name="id">MprRow<xsl:value-of select="$parentId"/></xsl:attribute>
<xsl:attribute name="class">
		<xsl:if test="count(preceding-sibling::LEAF_NODE[Conflict='true'] | following-sibling::LEAF_NODE[Conflict='true']) > 0 or Conflict='true'">mx_error</xsl:if>
</xsl:attribute>
  
<!--Display status icon depending on whether this option has been selected-->
<xsl:choose>
<xsl:when test="count(preceding-sibling::LEAF_NODE[Conflict='true'] | following-sibling::LEAF_NODE[Conflict='true']) > 0 or Conflict='true'">
  <xsl:for-each select="../LEAF_NODE[Conflict='true'][1]">
	<xsl:call-template name="DisplayStatusIcon">
		<xsl:with-param name="displayError">true</xsl:with-param>
	</xsl:call-template>
  </xsl:for-each>
</xsl:when>
<xsl:when test="count(preceding-sibling::LEAF_NODE[Changed='true'] | following-sibling::LEAF_NODE[Changed='true']) > 0 or Changed='true'">
  <xsl:for-each select="../LEAF_NODE[Changed='true'][1]">
    <xsl:call-template name="DisplayStatusIcon">
        <xsl:with-param name="displayChange">true</xsl:with-param>
    </xsl:call-template>
  </xsl:for-each>
</xsl:when>
	<xsl:otherwise>
<xsl:call-template name="DisplayStatusIcon"/>
	</xsl:otherwise>
</xsl:choose>

    <td>
<table class="mx_feature-option" cellspacing="0" cellpadding="0">
	<tbody>
		<tr>
			   <!--Indent the row based on the node depth-->
		<xsl:call-template name="DisplaySpace">
                <xsl:with-param name="indentationCount" select="$depth"></xsl:with-param>
         </xsl:call-template>
         <td class="mx_input-cell">
		<div>
		<xsl:attribute name="id"><xsl:value-of select="$parentId"/></xsl:attribute>
		<xsl:attribute name="mprrowid"><xsl:value-of select="$parentId"/></xsl:attribute>
		<xsl:attribute name="innerhtmlid"><xsl:value-of select="../ID"/></xsl:attribute>
		<!--<xsl:attribute name="name"><xsl:value-of select="$parentId"/></xsl:attribute>-->
<select>
   <xsl:attribute name="id">comboElement<xsl:value-of select="../ID"/></xsl:attribute>
	<xsl:attribute name="onchange">validate('<xsl:value-of select="$parentId"/>','<xsl:value-of select="$parentId"/>', false, false, true)</xsl:attribute>
	<xsl:attribute name="featurerowlevel"><xsl:value-of select="$parentId"/></xsl:attribute>
<!--	<xsl:attribute name="name">comboElName<xsl:value-of select="../ID"/></xsl:attribute>-->
   <xsl:attribute name="name"><xsl:value-of select="$parentId"/></xsl:attribute>
	<xsl:for-each select="../LEAF_NODE[Availability='true']">
	  		<xsl:sort select="Sequence_Number" data-type="number"/>
		<option comboownerforoptionrowconflict="" keyintype="Blank" one="" only="" select=""><xsl:if test="./Selected_State='true'"><xsl:attribute name="selected">selected</xsl:attribute><!--<xsl:attribute name="name"><xsl:value-of select="$parentId"/></xsl:attribute>--></xsl:if>
		<!--<xsl:attribute name="featurerowlevel"><xsl:value-of select="$parentId"/></xsl:attribute>-->
		<xsl:attribute name="value"><xsl:value-of select="ID"/></xsl:attribute>
		<xsl:attribute name="orderedquantity"><xsl:value-of select="Quantity"/></xsl:attribute>
    	<xsl:attribute name="dmaximumquantity"><xsl:value-of select="Maximum_Quantity"/></xsl:attribute>
		<xsl:attribute name="minimumquantity"><xsl:value-of select="Minimum_Quantity"/></xsl:attribute>
		<xsl:attribute name="sequenceorder"><xsl:value-of select="Sequence_Number"/></xsl:attribute>
		<xsl:attribute name="dlistprice"><xsl:value-of select="Price"/></xsl:attribute>
		<xsl:attribute name="selectiontype"><xsl:value-of select="../Selection_Type"/></xsl:attribute>
		<xsl:value-of select="./Name"/>
		</option>
		
	</xsl:for-each>
	<option><xsl:if test="count(../LEAF_NODE[Selected_State='true'])=0"><xsl:attribute name="selected">selected</xsl:attribute></xsl:if></option>
	
</select>
		</div>
		</td>
		</tr>
</tbody>
</table>
</td>
<xsl:if test="count(../LEAF_NODE[Selected_State='true'])>0">
<xsl:for-each select="../LEAF_NODE[Selected_State='true']">
	<xsl:call-template name="DisplayHelpIcon"/>
	<xsl:call-template name="DisplayQuantity"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
	<xsl:call-template name="DisplayEachPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
	<xsl:call-template name="DisplayExtendedPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
</xsl:for-each>
</xsl:if>
<xsl:if test="count(../LEAF_NODE[Selected_State='true'])=0">
   <xsl:call-template name="DisplayHelpIcon"/>
	<xsl:call-template name="DisplayQuantity"><xsl:with-param name="Prefix" select="$parentId"></xsl:with-param></xsl:call-template>
	<xsl:call-template name="DisplayEachPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
	<xsl:call-template name="DisplayExtendedPrice"><xsl:with-param name="Prefix" select="$parentId"/></xsl:call-template>
</xsl:if>
</tr>
<tr>
<xsl:attribute name="id"><xsl:value-of select="$parentId"/>keyInRowForCombo</xsl:attribute>	
</tr>
</xsl:if>
</xsl:if>

</xsl:template>

<!--                               template for displaying Options                        -->
 <!-- <xsl:template name="DisplayOption" match="LEAF_NODE[count(preceding-sibling::LEAF_NODE[Availability='true'] | following-sibling::LEAF_NODE[Availability='true'])+1 &lt; $DropDownLimit or ../Selection_Type='Multiple' or $mode='view']"> -->
  <xsl:template name="DisplayOption" match="LEAF_NODE[ ../SubFeature_Count  &lt; $DropDownLimit or ../Selection_Type='Multiple' or $mode='view']">
<xsl:param name="depth" select="0"/>
<xsl:if test="Availability='true'">
<tr>
<xsl:attribute name="class">
  <xsl:if test="Conflict='true'">mx_error</xsl:if>
</xsl:attribute>
        
<xsl:attribute name="id">MprRow<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
<!--Display status icon depending on whether this option has been selected-->
<xsl:call-template name="DisplayStatusIcon"/>
<td>
<table class="mx_feature-option" cellspacing="0" cellpadding="0">
	<tbody>
		<tr>
			   <!--Indent the row based on the node depth-->
		<xsl:call-template name="DisplaySpace">
                <xsl:with-param name="indentationCount" select="$depth"></xsl:with-param>
         </xsl:call-template>
          <!--Display the option name as well as radio button or check box-->
        <xsl:if test="not($mode='view')">
		<td class="mx_input-cell">
		<div>
		<xsl:attribute name="id"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
		<xsl:attribute name="maximumquantity"><xsl:value-of select="./Maximum_Quantity"/></xsl:attribute>
		<xsl:attribute name="minimumquantity"><xsl:value-of select="./Minimum_Quantity"/></xsl:attribute>
		<xsl:attribute name="selectiontype"><xsl:value-of select="../Selection_Type"/></xsl:attribute>
		<xsl:attribute name="ftrlstid"><xsl:value-of select="./ID"/></xsl:attribute>
		<xsl:attribute name="innerhtmlid"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
		<xsl:attribute name="groupname"><xsl:value-of select="../ID"/></xsl:attribute>
		<input>
		<xsl:attribute name="featurerowlevel"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
	    <xsl:attribute name="id"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
		<xsl:attribute name="onclick">validate('<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
		<xsl:if test="../Selection_Type='Single'">
		  <xsl:attribute name="type">radio</xsl:attribute>
  		  <xsl:attribute name="value">radiobutton</xsl:attribute>
		  <xsl:attribute name="name"><xsl:value-of select="../ID"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="../Selection_Type='Multiple'">
		  <xsl:attribute name="type">checkbox</xsl:attribute>
  		  <xsl:attribute name="value">checkbox</xsl:attribute>
          <xsl:attribute name="name"><xsl:value-of select="../ID"/></xsl:attribute>
		</xsl:if>
		<xsl:if test="./Selected_State='true'">
			<xsl:attribute name="checked"/>
		</xsl:if>
		</input>
		</div>
		</td>
		</xsl:if>
		<td class="mx_option"><xsl:value-of select="Name"></xsl:value-of></td>
		</tr>
</tbody>
</table>
</td>
<xsl:call-template name="DisplayHelpIcon"/>
<xsl:call-template name="DisplayQuantity"/>
<xsl:call-template name="DisplayEachPrice"/>
<xsl:call-template name="DisplayExtendedPrice"/>
</tr>
</xsl:if>
</xsl:template>

<!--                               template for indenting the structure                    -->
<xsl:template name="DisplaySpace">
<xsl:param name="indentationCount" select="0"/>
        <td>
    <div>
       <xsl:attribute name="class">level-<xsl:value-of select="$indentationCount*2"/></xsl:attribute>
	</div>
		  </td>
</xsl:template>

<!--                               template for displaying the status icon                   -->
<xsl:template name="DisplayStatusIcon">
<xsl:param name="id">
    <xsl:value-of select="./ID"/>
</xsl:param>
<xsl:param name="parentid">
    <xsl:value-of select="../ID"/>
</xsl:param>

	<xsl:param name="displayError" select="false"/>
	<xsl:param name="displayChange" select="false"/>
        <td class="mx_status">
		     <div>
		     <xsl:attribute name="id">E<xsl:value-of select="$parentid"/>c<xsl:value-of select="$id"/></xsl:attribute>
		     <xsl:attribute name="mprrowid"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
		     <xsl:choose>
		             <xsl:when test="./Conflict='true' or $displayError='true'">
		                     <img  src="../common/images/iconStatusError.gif">
		                     	<xsl:attribute name="onmouseover">getY(event);displayConflictDetails('E<xsl:value-of select="$parentid"/>c<xsl:value-of select="$id"/>','<xsl:value-of select="$id"/>')</xsl:attribute>
		                     </img>
		             </xsl:when>
		              <xsl:when test="./Changed='true' or $displayChange='true'">
                             <img  src="../common/images/iconStatusChanged.gif">
                                <xsl:attribute name="onmouseover">getY(event);displayConflictDetails('E<xsl:value-of select="$parentid"/>c<xsl:value-of select="$id"/>','<xsl:value-of select="$id"/>')</xsl:attribute>
                             </img>
                     </xsl:when>
		     		<xsl:when test="./Selected_State='true' and name()='PARENT_NODE'"><img  src="../common/images/iconStatusComplete.gif"/></xsl:when>
		     </xsl:choose>
		     </div>
		  </td>
		  
</xsl:template>

<!--                               template for displaying the help icon                   -->
<xsl:template name="DisplayHelpIcon">
        <td class="mx_info">
        <xsl:if test="$showHelpIcon='false'">
        <xsl:attribute name="style">display:none</xsl:attribute>
        </xsl:if>
		     <a class="mx_button-info"> 
				 <xsl:attribute name="href">javascript:fnloadHelp('<xsl:value-of select="./ID"/>')</xsl:attribute>
				 <img border="0" src="../common/images/utilSpacer.gif"/>
		     </a>
		  </td>
</xsl:template>


<!--                              template for displaying the quantity                   -->
<xsl:template name="DisplayQuantity">
<xsl:param name="Prefix">
<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>
</xsl:param>
<td class="mx_quantity">
<xsl:if test="$showQuantity='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if>
<xsl:choose>
	<xsl:when test="name()='PARENT_NODE'">&#160;</xsl:when>
	<xsl:otherwise>
    <xsl:if test="./Selected_State='false'"><a><xsl:attribute name="id">
			    <xsl:value-of select="$Prefix"/>OrderedQuantity</xsl:attribute>0.0</a></xsl:if>
    <xsl:if test="./Selected_State='true'">
      <xsl:choose>
		<xsl:when test="./Mininmum_Quantity = ./MaximumQuantity or $mode='view'">
			<a><xsl:attribute name="id">
			    <xsl:value-of select="$Prefix"/>OrderedQuantity</xsl:attribute><xsl:value-of select="./Minimum_Quantity"/></a>
		</xsl:when>
		<xsl:otherwise>
			<input type="text">
			    <xsl:attribute name="id">
			    <xsl:value-of select="$Prefix"/>OrderedQuantity</xsl:attribute>
			    <xsl:attribute name="onchange">checkOrderedQuantity('<xsl:value-of select="$Prefix"/>OrderedQuantity','<xsl:value-of select="$Prefix"/>','<xsl:value-of select="$Prefix"/>ExtPrice','<xsl:value-of select="$Prefix"/>EachPrice',true)</xsl:attribute>
				<xsl:attribute name="value">
				<xsl:choose>
				<xsl:when test="./Quantity=0"><xsl:value-of select="./Minimum_Quantity"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="./Quantity"/></xsl:otherwise>
				</xsl:choose>
				</xsl:attribute>
		    </input>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:if>
	</xsl:otherwise>
</xsl:choose>
</td>
</xsl:template>

<!--                               template for displaying each price                    -->
<xsl:template name="DisplayEachPrice">
<xsl:param name="Prefix">
<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>
</xsl:param>
<td class="mx_each-price">
<xsl:if test="$showPrice='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if>
<xsl:choose>
	<xsl:when test="name()='PARENT_NODE'">&#160;</xsl:when>
	<xsl:otherwise>
            <input type="text" readonly="" name="EachPrice">
              <xsl:attribute name="id"><xsl:value-of select="$Prefix"/>EachPrice</xsl:attribute>
              <xsl:attribute name="value"><xsl:value-of select="./Price"/></xsl:attribute>
            </input>
    </xsl:otherwise>
</xsl:choose>
</td>
</xsl:template>

<!--                               template for displaying extended price                    -->
<xsl:template name="DisplayExtendedPrice">
<xsl:param name="Prefix">
<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>
</xsl:param>
<!--  calculate Ext Price- for PC Create - it will be min*price and for Edit case it will be quatity set*price-->
<xsl:param name="extPriceCalc">
<xsl:choose>
 <xsl:when test="./Quantity=0">
  <xsl:value-of select="./Minimum_Quantity*./Price"/>
 </xsl:when>
 <xsl:otherwise>
  <xsl:value-of select="./Quantity*./Price"/>
 </xsl:otherwise>
</xsl:choose>
</xsl:param>

<td class="mx_extended-price">
<xsl:if test="$showPrice='false'">
<xsl:attribute name="style">display:none</xsl:attribute>
</xsl:if>
<xsl:choose>
	<xsl:when test="name()='PARENT_NODE'">&#160;</xsl:when>
	<xsl:otherwise>
            <input type="text" readonly="" name="ExtPrice">
            <xsl:attribute name="value">
                 <xsl:choose>
					<xsl:when test="./Selected_State='false'">0.0</xsl:when>
					<xsl:otherwise><xsl:value-of select='format-number($extPriceCalc,"0.00")'/></xsl:otherwise>
				</xsl:choose>		  
             </xsl:attribute>
                              <xsl:attribute name="id"><xsl:value-of select="$Prefix"/>ExtPrice</xsl:attribute>
                              <xsl:attribute name="relatedftrelementid"><xsl:value-of select="../ID"/>c<xsl:value-of select="./ID"/></xsl:attribute>
            </input>
    </xsl:otherwise>
</xsl:choose>
</td>
</xsl:template>
	
<!--                               template for displaying input for keyin                             -->
<xsl:template name="DisplayKeyIn">
	<xsl:param name="depth" select="0"/>
	<xsl:if test="not($mode='view' and KeyIn_Value='')">
	<tr>
		<!-- status icon -->
		<td class="mx_status">&#160;</td>
		<!--Indent the row based on the node level-->
		<td>
			<table class="mx_feature-option" cellspacing="0" cellpadding="0" border="0">
				<tbody>
					<tr>
						<xsl:call-template name="DisplaySpace">
							<xsl:with-param name="indentationCount" select="$depth"></xsl:with-param>
						</xsl:call-template>
						<xsl:if test="not($mode='view')">
						<td class="mx_input-cell">
					       <input>
                              <xsl:attribute name="featurerowlevel"><xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/></xsl:attribute>
                                <xsl:attribute name="id"><xsl:value-of select="./ID"/>keyIn</xsl:attribute>
                                <xsl:attribute name="onclick">onKeyInSelected('<xsl:value-of select="ID"/>','<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
                                <xsl:if test="Selection_Type='Single'">
                                    <xsl:attribute name="type">radio</xsl:attribute>
                                    <xsl:attribute name="value">radiobutton</xsl:attribute>
                                    <xsl:attribute name="name"><xsl:value-of select="./ID"/></xsl:attribute>
                                </xsl:if>
                                <xsl:if test="Selection_Type='Multiple'">
                                    <xsl:attribute name="type">checkbox</xsl:attribute>
                                    <xsl:attribute name="value">checkbox</xsl:attribute>
                                    <xsl:attribute name="name"><xsl:value-of select="./ID"/></xsl:attribute>
                                </xsl:if>
                                <xsl:if test="KeyIn_Value!=''">
                                    <xsl:attribute name="checked"/>
                                </xsl:if>
                            </input>
                        </td>
                        </xsl:if>
						<xsl:choose>
							<xsl:when test="KeyIn_Type='Input'">
								<xsl:call-template name="DisplayInputKeyIn"></xsl:call-template>
							</xsl:when>
							<xsl:when test="KeyIn_Type='Date'">
								<xsl:call-template name="DisplayDateKeyIn"></xsl:call-template>
							</xsl:when>
							<xsl:when test="KeyIn_Type='Integer'">
								<xsl:call-template name="DisplayIntegerKeyIn"></xsl:call-template>
							</xsl:when>
							<xsl:when test="KeyIn_Type='Real'">
								<xsl:call-template name="DisplayRealKeyIn"></xsl:call-template>
							</xsl:when>
							<xsl:when test="KeyIn_Type='Text Area'">
								<xsl:call-template name="DisplayTextAreaKeyIn"></xsl:call-template>
							</xsl:when>
						</xsl:choose>
					</tr>
				</tbody>					
			</table>
		</td>
		<xsl:call-template name="DisplayHelpIcon"/>
		<xsl:call-template name="DisplayQuantity"/>
		<xsl:call-template name="DisplayEachPrice"/>
		<xsl:call-template name="DisplayExtendedPrice"/>
	</tr>
	</xsl:if>
</xsl:template>

<!--                           template for displaying field for key in type "Input"                          -->
<xsl:template name="DisplayInputKeyIn">
	<td class="text-field">
	<xsl:choose>
	<xsl:when test="not($mode='view')">
	<input type="text" name="txtKeyInText">
		<xsl:attribute name="onchange">javascript:this.value=checkForBadChars(this.value,false);updateKeyInValue(this.value,'<xsl:value-of select="./ID"/>','<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
		<xsl:attribute name="id"><xsl:value-of select="./ID"/></xsl:attribute>
		<xsl:attribute name="value"><xsl:value-of select="./KeyIn_Value"/></xsl:attribute>
	</input>
	</xsl:when>
	<xsl:otherwise>
	   <xsl:value-of select="./KeyIn_Value"/>
	   </xsl:otherwise>
	 </xsl:choose>
	</td>
</xsl:template>
 

<!--                          template for displaying field for key in type ="TextArea"                      -->
<xsl:template name="DisplayTextAreaKeyIn">
	<td class="text-field">
	<xsl:choose>
    <xsl:when test="not($mode='view')">
	<textarea name="txtKeyInText" cols="25" rows="5">
		<xsl:attribute name="onchange">javascript:this.value=checkForBadChars(this.value,false);updateKeyInValue(this.value,'<xsl:value-of select="./ID"/>','<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
		<xsl:attribute name="id"><xsl:value-of select="./ID"/></xsl:attribute>
		<xsl:value-of select="./KeyIn_Value"/>
	</textarea>
	</xsl:when>
    <xsl:otherwise>
       <xsl:value-of select="./KeyIn_Value"/>
       </xsl:otherwise>
    </xsl:choose>
	</td>
</xsl:template>
	
<!--                        template for displaying field for key in type = "Integer"                        -->
<xsl:template name="DisplayIntegerKeyIn">
	<td class="text-field">
	<xsl:choose>
    <xsl:when test="not($mode='view')">
		<input type="text" name="txtKeyInText">
			<xsl:attribute name="onchange">javascript:this.value=inputNumberCheck(this.value,0,1);updateKeyInValue(this.value,'<xsl:value-of select="./ID"/>','<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
			<xsl:attribute name="id"><xsl:value-of select="./ID"/></xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="./KeyIn_Value"/></xsl:attribute>
		</input>
		</xsl:when>
    <xsl:otherwise>
       <xsl:value-of select="./KeyIn_Value"/>
       </xsl:otherwise>
    </xsl:choose>
	</td>
</xsl:template>
	
<!--                        template for displaying field for key in type = "Real"                        -->
<xsl:template name="DisplayRealKeyIn">
	<td class="text-field">
	<xsl:choose>
    <xsl:when test="not($mode='view')">
		<input type="text" name="txtKeyInText">
			<xsl:attribute name="onchange">javascript:this.value=inputNumberCheck(this.value,2,1);updateKeyInValue(this.value,'<xsl:value-of select="./ID"/>','<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
			<xsl:attribute name="id"><xsl:value-of select="./ID"/></xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="./KeyIn_Value"/></xsl:attribute>
		</input>
	</xsl:when>
    <xsl:otherwise>
       <xsl:value-of select="./KeyIn_Value"/>
       </xsl:otherwise>
    </xsl:choose>
	</td>
</xsl:template>

<!--                        template for displaying field for key in type = "Date"                        -->
    <xsl:template name="DisplayDateKeyIn">
        <xsl:choose>
            <xsl:when test="not($mode='view')">
        <td class="mx_input-cell">
            <input type="text" readOnly="" size="20">
                <xsl:attribute name="onchange">javascript:this.value=inputNumberCheck(this.value,2,1);updateKeyInValue(this.value,'<xsl:value-of select="./ID"/>','<xsl:number format="1" level="multiple" count="PARENT_NODE|LEAF_NODE"/>')</xsl:attribute>
                <xsl:attribute name="name">Cal_<xsl:value-of select="./ID"/></xsl:attribute>
                <xsl:attribute name="id">Cal_<xsl:value-of select="./ID"/></xsl:attribute>
                <xsl:attribute name="value"><xsl:value-of select="./KeyIn_Value"/></xsl:attribute>
            </input>
            <a>
                <xsl:attribute name="href">javascript:showCalendar('featureOptions','Cal_<xsl:value-of select="./ID"/>','','',callbackForDateKeyIn)</xsl:attribute>
                <img border="0" src="../common/images/iconSmallCalendar.gif" valign="bottom"/>
            </a> 

        </td>
          </xsl:when>
        <xsl:otherwise>
             <td><xsl:value-of select="./KeyIn_Value"/></td>
       </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
    
<!--                        template for displaying logical feature conflict                             -->
<xsl:template name="DisplayLogicalFeatureConflict" match="/ROOT/Conflict">
<tr class="mx_error">
    <xsl:call-template name="DisplayStatusIcon">
            <xsl:with-param name="id" select="ID"></xsl:with-param>
            <xsl:with-param name="parentid" select="PARENT_ID"></xsl:with-param>
            <xsl:with-param name="displayError">true</xsl:with-param>
     </xsl:call-template>
 </tr>
</xsl:template>
    
</xsl:stylesheet> 


