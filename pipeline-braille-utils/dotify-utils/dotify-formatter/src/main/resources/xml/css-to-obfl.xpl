<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step type="pxi:css-to-obfl"
                xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:px="http://www.daisy.org/ns/pipeline/xproc"
                xmlns:pxi="http://www.daisy.org/ns/pipeline/xproc/internal"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                xmlns:obfl="http://www.daisy.org/ns/2011/obfl"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-inline-prefixes="pxi xsl"
                version="1.0">
    
    <p:documentation>
        Convert a document with inline braille CSS to OBFL (Open Braille Formatting Language).
    </p:documentation>
    
    <p:input port="source" sequence="true"/>
    <p:output port="result" sequence="false"/>
    
    <p:option name="text-transform" required="true"/>
    <p:option name="duplex" select="'true'"/>
    <p:option name="skip-margin-top-of-page" select="'false'"/>
    
    <p:import href="http://www.daisy.org/pipeline/modules/common-utils/library.xpl"/>
    <p:import href="http://www.daisy.org/pipeline/modules/braille/css-utils/library.xpl"/>
    <p:import href="propagate-page-break.xpl"/>
    <p:import href="shift-obfl-marker.xpl"/>
    <p:import href="make-obfl-pseudo-elements.xpl"/>
    
    <p:declare-step type="pxi:recursive-parse-stylesheet-and-make-pseudo-elements">
        <p:input port="source"/>
        <p:output port="result" sequence="true"/>
        <css:parse-stylesheet>
            <p:documentation>
                Make css:page, css:volume, css:after, css:before, css:footnote-call, css:duplicate,
                css:alternate, css:_obfl-on-toc-start, css:_obfl-on-volume-start,
                css:_obfl-on-volume-end and css:_obfl-on-toc-end attributes.
            </p:documentation>
        </css:parse-stylesheet>
        <css:parse-properties properties="flow">
            <p:documentation>
                Make css:flow attributes.
            </p:documentation>
        </css:parse-properties>
        <p:choose>
            <p:when test="//*/@css:before|
                          //*/@css:after|
                          //*/@css:duplicate|
                          //*/@css:alternate|
                          //*/@css:footnote-call|
                          //*/@css:_obfl-on-toc-start|
                          //*/@css:_obfl-on-volume-start|
                          //*/@css:_obfl-on-volume-end|
                          //*/@css:_obfl-on-toc-end">
                <css:make-pseudo-elements>
                    <p:documentation>
                        Make css:before, css:after, css:duplicate, css:alternate and
                        css:footnote-call pseudo-elements from css:before, css:after, css:duplicate,
                        css:alternate and css:footnote-call attributes.
                    </p:documentation>
                </css:make-pseudo-elements>
                <pxi:make-obfl-pseudo-elements>
                    <p:documentation>
                        Make css:_obfl-on-toc-start, css:_obfl-on-volume-start,
                        css:_obfl-on-volume-end and css:_obfl-on-toc-end pseudo-element documents.
                    </p:documentation>
                </pxi:make-obfl-pseudo-elements>
                <p:for-each>
                    <pxi:recursive-parse-stylesheet-and-make-pseudo-elements/>
                </p:for-each>
            </p:when>
            <p:otherwise>
                <p:rename match="@css:_obfl-on-toc-start-ref" new-name="css:_obfl-on-toc-start"/>
                <p:rename match="@css:_obfl-on-volume-start-ref" new-name="css:_obfl-on-volume-start"/>
                <p:rename match="@css:_obfl-on-volume-end-ref" new-name="css:_obfl-on-volume-end"/>
                <p:rename match="@css:_obfl-on-toc-end-ref" new-name="css:_obfl-on-toc-end"/>
            </p:otherwise>
        </p:choose>
    </p:declare-step>
    
    <p:add-xml-base/>
    <px:message message="[progress pxi:css-to-obfl 1 p:xslt]"/>
    <p:xslt>
        <p:input port="stylesheet">
            <p:inline>
                <xsl:stylesheet version="2.0">
                    <xsl:template match="/*">
                        <xsl:copy>
                            <xsl:copy-of select="document('')/*/namespace::*[name()='obfl']"/>
                            <xsl:copy-of select="document('')/*/namespace::*[name()='css']"/>
                            <xsl:sequence select="@*|node()"/>
                        </xsl:copy>
                    </xsl:template>
                </xsl:stylesheet>
            </p:inline>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
    <px:message message="[progress pxi:css-to-obfl 1 css:parse-properties] Make css:display, css:render-table-by and css:table-header-policy attributes."/>
    <css:parse-properties properties="display render-table-by table-header-policy">
        <p:documentation>
            Make css:display, css:render-table-by and css:table-header-policy attributes.
        </p:documentation>
    </css:parse-properties>
    
    <px:message message="[progress pxi:css-to-obfl 2 css:render-table-by] Layout tables as lists."/>
    <css:render-table-by>
        <p:documentation>
            Layout tables as lists.
        </p:documentation>
    </css:render-table-by>
    
    <px:message message="[progress pxi:css-to-obfl 1 pxi:recursive-parse-stylesheet-and-make-pseudo-elements] Recursively parse stylesheet and make pseudo elements"/>
    <pxi:recursive-parse-stylesheet-and-make-pseudo-elements>
        <p:documentation>
            Make css:page and css:volume attributes, css:after, css:before, css:duplicate,
            css:alternate and css:footnote-call pseudo-elements, and css:_obfl-on-toc-start,
            css:_obfl-on-volume-start, css:_obfl-on-volume-end and css:_obfl-on-toc-end
            pseudo-element documents.
        </p:documentation>
    </pxi:recursive-parse-stylesheet-and-make-pseudo-elements>
    
    <px:message message="[progress pxi:css-to-obfl 5 for-each.parse-properties-and-eval-string-set]"/>
    <p:for-each>
        <px:message>
            <p:with-option name="message" select="concat('[progress for-each.parse-properties-and-eval-string-set 1/',p:iteration-size(),' for-each.parse-properties-and-eval-string-set.iteration]')"/>
        </px:message>
        <px:message message="[progress for-each.parse-properties-and-eval-string-set.iteration 50 css:parse-properties]"/>
        <css:parse-properties properties="content string-set counter-reset counter-set counter-increment -obfl-marker">
            <p:documentation>
                Make css:content, css:string-set, css:counter-reset, css:counter-set,
                css:counter-increment and css:_obfl-marker attributes.
            </p:documentation>
        </css:parse-properties>
        <px:message message="[progress for-each.parse-properties-and-eval-string-set.iteration 50 css:eval-string-set]"/>
        <css:eval-string-set>
            <p:documentation>
                Evaluate css:string-set attributes.
            </p:documentation>
        </css:eval-string-set>
    </p:for-each>
    
    <p:wrap-sequence wrapper="_"/>
    <px:message message="[progress pxi:css-to-obfl 2 css:parse-content]"/>
    <css:parse-content>
        <p:documentation>
            Make css:string, css:text, css:content and css:counter elements from css:content
            attributes. <!-- depends on make-pseudo-element -->
        </p:documentation>
    </css:parse-content>
    <p:filter select="/_/*"/>
    
    <p:group>
        <p:documentation>
            Split into a sequence of flows.
        </p:documentation>
        <px:message message="[progress pxi:css-to-obfl 1 pxi:css-to-obfl.foreach-parse-properties] Make css:flow attributes."/>
        <p:for-each>
            <px:message>
                <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.foreach-parse-properties 1/',p:iteration-size(),' css:parse-properties]')"/>
            </px:message>
            <css:parse-properties properties="flow">
                <p:documentation>
                    Make css:flow attributes.
                </p:documentation>
            </css:parse-properties>
        </p:for-each>
        <p:split-sequence test="/*[not(@css:flow)]" name="_1"/>
        <p:wrap wrapper="_" match="/*"/>
        <px:message message="[progress pxi:css-to-obfl 1 css:flow-into] Extract named flows based on css:flow attributes."/>
        <css:flow-into name="_2">
            <p:documentation>
                Extract named flows based on css:flow attributes. Extracted elements are replaced
                with empty css:_ elements with a css:id attribute.
            </p:documentation>
        </css:flow-into>
        <p:filter select="/_/*" name="_3"/>
        <p:identity>
            <p:input port="source">
                <p:pipe step="_3" port="result"/>
                <p:pipe step="_2" port="flows"/>
                <p:pipe step="_1" port="not-matched"/>
            </p:input>
        </p:identity>
    </p:group>
    
    <px:message message="[progress pxi:css-to-obfl 1 css:label-targets] Make css:id attributes."/>
    <css:label-targets name="label-targets">
        <p:documentation>
            Make css:id attributes. <!-- depends on parse-content -->
        </p:documentation>
    </css:label-targets>
    
    <px:message message="[progress pxi:css-to-obfl 1 css:eval-target-content] Evaluate css:content elements."/>
    <css:eval-target-content>
        <p:documentation>
            Evaluate css:content elements. <!-- depends on parse-content and label-targets -->
        </p:documentation>
    </css:eval-target-content>
    
    <px:message message="[progress pxi:css-to-obfl 2 pxi:css-to-obfl.for-each-parse-preserve-table-box]"/>
    <p:for-each>
        <px:message>
            <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.for-each-parse-preserve-table-box 1/',p:iteration-size(),' pxi:css-to-obfl.for-each-parse-preserve-table-box.part]')"/>
        </px:message>
        <px:message message="[progress pxi:css-to-obfl.for-each-parse-preserve-table-box.part 20 css:parse-properties] Make css:white-space, css:display, css:list-style-type, css:page-break-before and css:page-break-after attributes."/>
        <css:parse-properties properties="white-space display list-style-type page-break-before page-break-after">
            <p:documentation>
                Make css:white-space, css:display, css:list-style-type, css:page-break-before and
                css:page-break-after attributes.
            </p:documentation>
        </css:parse-properties>
        <px:message message="[progress pxi:css-to-obfl.for-each-parse-preserve-table-box.part 20 css:preserve-white-space] Make css:white-space elements from css:white-space attributes."/>
        <css:preserve-white-space>
            <p:documentation>
                Make css:white-space elements from css:white-space attributes.
            </p:documentation>
        </css:preserve-white-space>
        <p:add-attribute match="*[@css:display='-obfl-toc']" attribute-name="css:_obfl-toc" attribute-value="_">
            <p:documentation>
                Mark display:-obfl-toc elements.
            </p:documentation>
        </p:add-attribute>
        <p:add-attribute match="*[@css:display='-obfl-toc']" attribute-name="css:display" attribute-value="block">
            <p:documentation>
                Treat display:-obfl-toc as block.
            </p:documentation>
        </p:add-attribute>
        <px:message message="[progress pxi:css-to-obfl.for-each-parse-preserve-table-box.part 20 css:make-table-grid] Create table grid structures from HTML/DTBook tables."/>
        <css:make-table-grid>
            <p:documentation>
                Create table grid structures from HTML/DTBook tables.
            </p:documentation>
        </css:make-table-grid>
        <px:message message="[progress pxi:css-to-obfl.for-each-parse-preserve-table-box.part 20 css:make-boxes] Make css:box elements based on css:display and css:list-style-type attributes."/>
        <css:make-boxes>
            <p:documentation>
                Make css:box elements based on css:display and css:list-style-type attributes. <!--
                depends on flow-into, label-targets and make-table-grid -->
            </p:documentation>
        </css:make-boxes>
        <p:group>
            <p:documentation>
                Move css:render-table-by, css:_obfl-table-col-spacing, css:_obfl-table-row-spacing
                and css:_obfl-preferred-empty-space attributes to 'table' css:box elements.
            </p:documentation>
            <px:message message="[progress pxi:css-to-obfl.for-each-parse-preserve-table-box.part 20 css:parse-properties]"/>
            <css:parse-properties properties="-obfl-table-col-spacing -obfl-table-row-spacing -obfl-preferred-empty-space"/>
            <p:label-elements match="*[@css:render-table-by]/css:box[@type='table']"
                              attribute="css:render-table-by"
                              label="parent::*/@css:render-table-by"/>
            <p:label-elements match="*[@css:_obfl-table-col-spacing]/css:box[@type='table']"
                              attribute="css:_obfl-table-col-spacing"
                              label="parent::*/@css:_obfl-table-col-spacing"/>
            <p:label-elements match="*[@css:_obfl-table-row-spacing]/css:box[@type='table']"
                              attribute="css:_obfl-table-row-spacing"
                              label="parent::*/@css:_obfl-table-row-spacing"/>
            <p:label-elements match="*[@css:_obfl-preferred-empty-space]/css:box[@type='table']"
                              attribute="css:_obfl-preferred-empty-space"
                              label="parent::*/@css:_obfl-preferred-empty-space"/>
            <p:delete match="*[not(self::css:box[@type='table'])]/@css:render-table-by"/>
            <p:delete match="*[not(self::css:box[@type='table'])]/@css:_obfl-table-col-spacing"/>
            <p:delete match="*[not(self::css:box[@type='table'])]/@css:_obfl-table-row-spacing"/>
            <p:delete match="*[not(self::css:box[@type='table'])]/@css:_obfl-preferred-empty-space"/>
        </p:group>
    </p:for-each>
    
    <px:message message="[progress pxi:css-to-obfl 8 css:eval-counter] Evaluate css:counter elements."/>
    <css:eval-counter exclude-counters="page">
        <p:documentation>
            Evaluate css:counter elements. <!-- depends on label-targets, parse-content and
            make-boxes -->
        </p:documentation>
    </css:eval-counter>
    
    <px:message message="[progress pxi:css-to-obfl 2 css:flow-from] Evaluate css:flow elements."/>
    <css:flow-from>
        <p:documentation>
            Evaluate css:flow elements. <!-- depends on parse-content and eval-counter -->
        </p:documentation>
    </css:flow-from>
    
    <px:message message="[progress pxi:css-to-obfl 1 css:eval-target-text] Evaluate css:text elements."/>
    <css:eval-target-text>
        <p:documentation>
            Evaluate css:text elements. <!-- depends on label-targets and parse-content -->
        </p:documentation>
    </css:eval-target-text>
    
    <px:message message="[progress pxi:css-to-obfl 1 pxi:css-to-obfl.for-each-anonymous-inline-boxes] Wrap/unwrap with inline css:box elements."/>
    <p:for-each>
        <px:message>
            <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.for-each-anonymous-inline-boxes 1/',p:iteration-size(),' css:make-anonyous-inline-boxes]')"/>
        </px:message>
        <css:make-anonymous-inline-boxes>
            <p:documentation>
                Wrap/unwrap with inline css:box elements.
            </p:documentation>
        </css:make-anonymous-inline-boxes>
    </p:for-each>
    
    <p:group>
        <p:documentation>
            Split flows into sections.
        </p:documentation>
        <px:message message="[progress pxi:css-to-obfl 2 pxi:css-to-obfl.split-sections] Split flows into sections."/>
        <p:for-each>
            <px:message>
                <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.split-sections 1/',p:iteration-size(),' pxi:css-to-obfl.split-sections.section]')"/>
            </px:message>
            <px:message message="[progress pxi:css-to-obfl.split-sections.section 50 css:parse-counter-set] Make css:counter-set-page attributes."/>
            <css:parse-counter-set counters="page">
                <p:documentation>
                    Make css:counter-set-page attributes.
                </p:documentation>
            </css:parse-counter-set>
            <p:delete match="/*[@css:flow]//*/@css:page|
                             /*[@css:flow]//*/@css:volume|
                             /*[@css:flow]//*/@css:counter-set-page|
                             //css:box[@type='table']//*/@css:page-break-before|
                             //css:box[@type='table']//*/@css:page-break-after|
                             //css:box[@type='table']//*/@css:page|
                             //css:box[@type='table']//*/@css:volume|
                             //css:box[@type='table']//*/@css:counter-set-page|
                             //*[@css:obfl-toc]//*/@css:page-break-before|
                             //*[@css:obfl-toc]//*/@css:page-break-after">
                <p:documentation>
                    Don't support 'page', 'volume' and 'counter-set: page' within named flows or
                    tables. Don't support 'page-break-before' and 'page-break-after' within tables
                    or '-obfl-toc' elements.
                </p:documentation>
            </p:delete>
            <px:message message="[progress pxi:css-to-obfl.split-sections.section 50 css:split] Page and volume split."/>
            <css:split split-before="*[@css:page or @css:volume or @css:counter-set-page]|
                                     css:box[@type='block' and @css:page-break-before='right']|
                                     css:box[@type='table']"
                       split-after="*[@css:page or @css:volume]|
                                    css:box[@type='block' and @css:page-break-after='right']|
                                    css:box[@type='table']">
                <p:documentation>
                    Split before and after css:page attributes, before css:counter-set-page
                    attributes, before and after css:volume attributes, before and after tables,
                    before css:page-break-before attributes with value 'right', and after
                    css:page-break-after attributes with value 'right'. <!-- depends on make-boxes
                    -->
                </p:documentation>
            </css:split>
        </p:for-each>
        <px:message message="[progress pxi:css-to-obfl 2 pxi:css-to-obfl.pages-and-volumes] Move css:page, css:counter-set-page and css:volume attributes to css:_ root element."/>
        <p:for-each>
            <px:message>
                <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.pages-and-volumes 1/',p:iteration-size(),']')"/>
            </px:message>
            <p:group>
                <p:documentation>
                    Move css:page, css:counter-set-page and css:volume attributes to css:_ root
                    element.
                </p:documentation>
                <p:wrap wrapper="css:_" match="/*[not(@css:flow)]"/>
                <p:label-elements match="/*[descendant::*/@css:page]" attribute="css:page"
                                  label="(descendant::*/@css:page)[last()]"/>
                <p:label-elements match="/*[descendant::*/@css:counter-set-page]" attribute="css:counter-set-page"
                                  label="(descendant::*/@css:counter-set-page)[last()]"/>
                <p:label-elements match="/*[descendant::*/@css:volume]" attribute="css:volume"
                                  label="(descendant::*/@css:volume)[last()]"/>
                <p:delete match="/*//*/@css:page"/>
                <p:delete match="/*//*/@css:counter-set-page"/>
                <p:delete match="/*//*/@css:volume"/>
            </p:group>
            <p:rename match="css:box[@type='inline']
                             [matches(string(.), '^[\s&#x2800;]*$') and
                             not(descendant::css:white-space or
                             descendant::css:string or
                             descendant::css:counter or
                             descendant::css:text or
                             descendant::css:content or
                             descendant::css:leader or
                             descendant::css:custom-func)]"
                      new-name="css:_">
                <p:documentation>
                    Delete empty inline boxes (possible side effect of css:split).
                </p:documentation>
            </p:rename>
            <p:delete match="css:_/@type"/>
        </p:for-each>
        <p:group>
            <p:documentation>
                Repeat css:string-set attributes at the beginning of sections as css:string-entry.
            </p:documentation>
            <p:split-sequence test="/*[not(@css:flow)]" name="_1"/>
            <css:repeat-string-set name="_2"/>
            <p:identity>
                <p:input port="source">
                    <p:pipe step="_2" port="result"/>
                    <p:pipe step="_1" port="not-matched"/>
                </p:input>
            </p:identity>
        </p:group>
        <px:message message="[progress pxi:css-to-obfl 14 css:shift-string-set] Move css:string-set attributes."/>
        <css:shift-string-set>
            <p:documentation>
                Move css:string-set attributes. <!-- depends on make-anonymous-inline-boxes -->
            </p:documentation>
        </css:shift-string-set>
        <px:message message="[progress pxi:css-to-obfl 1 pxi:shift-obfl-marker] Move css:_obfl-marker attributes."/>
        <pxi:shift-obfl-marker>
            <p:documentation>
                Move css:_obfl-marker attributes. <!-- depends on make-anonymous-inline-boxes -->
            </p:documentation>
        </pxi:shift-obfl-marker>
        <px:message message="[progress pxi:css-to-obfl 1 css:shift-id] Move css:id attributes to css:box elements."/>
        <css:shift-id>
            <p:documentation>
                Move css:id attributes to css:box elements.
            </p:documentation>
        </css:shift-id>
    </p:group>
    
    <px:message message="[progress pxi:css-to-obfl 1 pxi:css-to-obfl.for-each-padding]"/>
    <p:for-each>
        <px:message>
            <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.for-each-padding 1/',(p:iteration-size() * 2),' css:parse-properties] Make css:padding-left, css:padding-right, css:padding-top and css:padding-bottom attributes.')"/>
        </px:message>
        <css:parse-properties properties="padding-left padding-right padding-top padding-bottom">
            <p:documentation>
                Make css:padding-left, css:padding-right, css:padding-top and css:padding-bottom
                attributes.
            </p:documentation>
        </css:parse-properties>
        <px:message>
            <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.for-each-padding 1/',(p:iteration-size() * 2),' css:padding-to-margin] Padding to margin.')"/>
        </px:message>
        <css:padding-to-margin/>
    </p:for-each>
    
    <px:message message="[progress pxi:css-to-obfl 8 pxi:css-to-obfl.for-each-black-box]"/>
    <p:for-each>
        <px:message>
            <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.for-each-black-box 1/',(p:iteration-size() * 2),' p:unwrap] Unwrap css:_ elements.')"/>
        </px:message>
        <p:unwrap match="css:_[not(@css:*) and parent::*]" name="unwrap-css-_">
            <p:documentation>
                All css:_ elements except for root elements, top-level elements in named flows (with
                css:anchor attribute), and empty elements with a css:string-set or css:_obfl-marker
                attribute within a css:box element should be gone now. <!-- depends on shift-id and
                shift-string-set -->
            </p:documentation>
        </p:unwrap>
        <px:message>
            <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.for-each-black-box 1/',(p:iteration-size() * 2),' css:make-anonymous-black-boxes] Wrap inline css:box elements in block css:box elements where necessary.')"/>
        </px:message>
        <css:make-anonymous-block-boxes>
            <p:documentation>
                Wrap inline css:box elements in block css:box elements where necessary. <!-- depends
                on unwrap css:_ -->
            </p:documentation>
        </css:make-anonymous-block-boxes>
    </p:for-each>
    
    <p:split-sequence test="//css:box"/>
    
    <px:message message="[progress pxi:css-to-obfl 3 pxi:css-to-obfl.for-each-margin-attributes]"/>
    <p:for-each>
        <px:message>
            <p:with-option name="message" select="concat('[progress pxi:css-to-obfl.for-each-margin-attributes 1/',p:iteration-size(),' pxi:css-to-obfl.for-each-margin-attributes.item]')"/>
        </px:message>
        <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 20 css:parse-properties] Make css:margin-*, css:border-*, css:border-bottom and css:text-indent attributes."/>
        <css:parse-properties properties="margin-left margin-right margin-top margin-bottom
                                          border-left border-right border-top border-bottom text-indent">
            <p:documentation>
                Make css:margin-left, css:margin-right, css:margin-top, css:margin-bottom,
                css:border-left, css:border-right, css:border-top, css:border-bottom and
                css:text-indent attributes.
            </p:documentation>
        </css:parse-properties>
        <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 20 css:adjust-boxes] Adjust boxes."/>
        <css:adjust-boxes>
          <p:documentation>
            <!-- depends on make-anonymous-block-boxes -->
          </p:documentation>
        </css:adjust-boxes>
        <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 20 css:new-definition] New definition."/>
        <css:new-definition>
            <p:input port="definition">
                <p:inline>
                    <xsl:stylesheet version="2.0" xmlns:new="css:new-definition">
                        <xsl:variable name="new:properties" as="xs:string*"
                                      select="('margin-left',   'page-break-before', 'text-indent', 'text-transform', '-obfl-vertical-align',
                                               'margin-right',  'page-break-after',  'text-align',  'hyphens',        '-obfl-vertical-position',
                                               'margin-top',    'page-break-inside', 'line-height', 'white-space',    '-obfl-toc-range',
                                               'margin-bottom', 'orphans',                          'word-spacing',   '-obfl-table-col-spacing',
                                               'border-left',   'widows',                           'letter-spacing', '-obfl-table-row-spacing',
                                               'border-right',                                                        '-obfl-preferred-empty-space',
                                               'border-top',
                                               'border-bottom')"/>
                        <xsl:function name="new:is-valid" as="xs:boolean">
                            <xsl:param name="css:property" as="element()"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="new:applies-to($css:property/@name, $context)
                                                  and (
                                                    if ($css:property/@name='-obfl-vertical-align')
                                                    then $css:property/@value=('before','center','after')
                                                    else if ($css:property/@name=('-obfl-vertical-position',
                                                                                  '-obfl-table-col-spacing',
                                                                                  '-obfl-table-row-spacing',
                                                                                  '-obfl-preferred-empty-space'))
                                                    then matches($css:property/@value,'^auto|0|[1-9][0-9]*$')
                                                    else if ($css:property/@name='-obfl-toc-range')
                                                    then ($context/@css:_obfl-toc and $css:property/@value=('document','volume'))
                                                    else (
                                                      css:is-valid($css:property)
                                                      and not($css:property/@value=('inherit','initial'))
                                                    )
                                                  )"/>
                        </xsl:function>
                        <xsl:function name="new:initial-value" as="xs:string">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="if ($property='-obfl-vertical-align')
                                                  then 'after'
                                                  else if ($property='-obfl-vertical-position')
                                                  then 'auto'
                                                  else if ($property='-obfl-toc-range')
                                                  then 'document'
                                                  else if ($property=('-obfl-table-col-spacing','-obfl-table-row-spacing'))
                                                  then '0'
                                                  else if ($property='-obfl-preferred-empty-space')
                                                  then '2'
                                                  else css:initial-value($property)"/>
                        </xsl:function>
                        <xsl:function name="new:is-inherited" as="xs:boolean">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="$property=('text-transform','hyphens','word-spacing')"/>
                        </xsl:function>
                        <xsl:function name="new:applies-to" as="xs:boolean">
                            <xsl:param name="property" as="xs:string"/>
                            <xsl:param name="context" as="element()"/>
                            <xsl:sequence select="$property=('text-transform','hyphens','word-spacing')
                                                  or (
                                                    if (matches($property,'^border-'))
                                                    then $context/@type=('block','table','table-cell')
                                                    else if (matches($property,'^margin-'))
                                                    then $context/@type=('block','table','table-cell')
                                                    else if ($property='line-height')
                                                    then $context/@type=('block','table')
                                                    else if ($property=('text-indent','text-align'))
                                                    then $context/@type=('block','table-cell')
                                                    else if ($property=('-obfl-table-col-spacing',
                                                                        '-obfl-table-row-spacing',
                                                                        '-obfl-preferred-empty-space'))
                                                    then $context/@type='table'
                                                    else $context/@type='block'
                                                  )"/>
                        </xsl:function>
                    </xsl:stylesheet>
                </p:inline>
            </p:input>
        </css:new-definition>
        <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 10 p:delete] Remove text nodes from block boxes with no line boxes."/>
        <p:delete match="css:box[@type='block']
                                [matches(string(.), '^[\s&#x2800;]*$') and
                                 not(descendant::css:white-space or
                                     descendant::css:string or
                                     descendant::css:counter or
                                     descendant::css:text or
                                     descendant::css:content or
                                     descendant::css:leader or
                                     descendant::css:custom-func)]
                                //text()">
            <p:documentation>
                Remove text nodes from block boxes with no line boxes.
            </p:documentation>
        </p:delete>
        <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 20 pxi:propagate-page-break] Resolve css:page-break-before=avoid and css:page-break-after=always."/>
        <pxi:propagate-page-break>
            <p:documentation>
                Resolve css:page-break-before="avoid" and css:page-break-after="always".
                <!-- depends on make-anonymous-block-boxes -->
            </p:documentation>
        </pxi:propagate-page-break>
        <!--
            Move css:page-break-after="avoid" to last descendant block (TODO: move to
            pxi:propagate-page-break?)
        -->
        <p:add-attribute match="css:box[@type='block'
                                        and not(child::css:box[@type='block'])
                                        and (some $self in . satisfies
                                          some $ancestor in $self/ancestor::*[@css:page-break-after='avoid'] satisfies
                                            not($self/following::css:box intersect $ancestor//*))]"
                         attribute-name="css:page-break-after"
                         attribute-value="avoid"/>
        <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 2 p:delete] Move css:page-break-after=avoid to last descendant block"/>
        <p:delete match="css:box[@type='block' and child::css:box[@type='block']]/@css:page-break-after[.='avoid']"/>
        <!--
            Delete css:margin-top from first block and move css:margin-top of other blocks to
            css:margin-bottom of their preceding block
        -->
        <p:choose>
            <p:when test="$skip-margin-top-of-page='true'">
                <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 1 p:delete] Delete css:margin-top from first block and move css:margin-top of other blocks to css:margin-bottom of their preceding block"/>
                <p:delete match="css:box
                                   [@type='block']
                                   [@css:margin-top]
                                   [not(preceding::*)]
                                   [not(ancestor::*[@css:border-top])]
                                 /@css:margin-top"/>
                <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 1 p:label-elements]"/>
                <p:label-elements match="css:box
                                           [@type='block']
                                           [following-sibling::*[1]
                                              [some $self in . satisfies
                                                 $self/descendant-or-self::*
                                                   [@css:margin-top][1]
                                                   [not(preceding::* intersect $self/descendant::*)]
                                                   [not((ancestor::* intersect $self/descendant-or-self::*)[@css:border-top])]]]"
                                  attribute="css:_margin-bottom_"
                                  label="max((0,
                                              @css:margin-bottom/number(),
                                              following::*[@css:margin-top][1]/@css:margin-top/number()))"/>
                <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 6 p:delete]"/>
                <p:delete match="@css:margin-top[(preceding::css:box[@type='block']
                                                    except ancestor::*/preceding-sibling::*/descendant::*)
                                                   [last()][@css:_margin-bottom_]]"/>
                <p:rename match="@css:_margin-bottom_" new-name="css:margin-bottom"/>
            </p:when>
            <p:otherwise>
                <px:message message="[progress pxi:css-to-obfl.for-each-margin-attributes.item 8]"/>
                <p:identity/>
            </p:otherwise>
        </p:choose>
    </p:for-each>
    
    <p:split-sequence test="//css:box[@css:border-top|
                                      @css:border-bottom|
                                      @css:margin-top|
                                      @css:margin-bottom|
                                      descendant::text()|
                                      descendant::css:white-space|
                                      descendant::css:string|
                                      descendant::css:counter|
                                      descendant::css:text|
                                      descendant::css:content|
                                      descendant::css:leader|
                                      descendant::css:custom-func]">
        <p:documentation>
            Remove empty sections.
        </p:documentation>
    </p:split-sequence>
    
    <!-- for debug info -->
    <p:for-each><p:identity/></p:for-each>
    
    <px:message message="[progress pxi:css-to-obfl 26 css-to-obfl.xsl]"/>
    <p:xslt template-name="start">
        <p:input port="stylesheet">
            <p:document href="css-to-obfl.xsl"/>
        </p:input>
        <p:with-param name="braille-translator-query" select="if ($text-transform='auto') then '' else $text-transform">
            <p:empty/>
        </p:with-param>
        <p:with-param name="duplex" select="$duplex">
            <p:empty/>
        </p:with-param>
    </p:xslt>
    
    <!--
        add <marker class="foo/prev"/>
    -->
    <px:message message="[progress pxi:css-to-obfl 10] add &lt;marker class=&quot;foo/prev&quot;/&gt;"/>
    <p:insert match="obfl:marker[not(matches(@class,'^indicator/|/entry$'))]" position="before">
        <p:input port="insertion">
          <p:inline><marker xmlns="http://www.daisy.org/ns/2011/obfl"/></p:inline>
        </p:input>
    </p:insert>
    <p:label-elements match="obfl:marker[not(@class)]" attribute="class" label="concat(following-sibling::obfl:marker[1]/@class,'/prev')"/>
    <p:label-elements match="obfl:marker[not(@value)]" attribute="value"
                      label="string-join(for $class in @class return (preceding::obfl:marker[concat(@class,'/prev')=$class])[last()]/@value,'')"/>
    
    <!--
        because empty marker values would be regarded as absent in BrailleFilterImpl
    -->
    <px:message message="[progress pxi:css-to-obfl 1]"/>
    <p:add-attribute match="obfl:marker[@value='']" attribute-name="value" attribute-value="&#x200B;"/>
    
    <!--
        move table-of-contents elements to the right place
    -->
    <px:message message="[progress pxi:css-to-obfl 1] move table-of-contents elements to the right place"/>
    <p:group>
        <p:identity name="_1"/>
        <p:insert match="/obfl:obfl/obfl:volume-template[not(preceding-sibling::obfl:volume-template)]" position="before">
            <p:input port="insertion" select="//obfl:toc-sequence/obfl:table-of-contents">
                <p:pipe step="_1" port="result"/>
            </p:input>
        </p:insert>
        <p:delete match="obfl:toc-sequence/obfl:table-of-contents"/>
    </p:group>
    
</p:declare-step>
