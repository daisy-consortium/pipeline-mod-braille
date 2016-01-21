<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
                xmlns:css="http://www.daisy.org/ns/pipeline/braille-css"
                type="css:make-pseudo-elements"
                exclude-inline-prefixes="#all"
                version="1.0">
    
    <p:documentation>
        Generate pseudo-elements.
    </p:documentation>
    
    <p:input port="source">
        <p:documentation>
            Pseudo-element rules in the input must be declared in css:before, css:after and
            css:duplicate attributes.
        </p:documentation>
    </p:input>
    
    <p:output port="result">
        <p:documentation>
            For each element with a css:before attribute in the input, an empty css:before element
            will be inserted in the output as the element's first child. Similarly, for each element
            with a css:after attribute, a css:after element will be inserted as the element's last
            child. The css:before, css:after and css:duplicate attributes are moved to the inserted
            elements and renamed to 'style'. For each element with a css:duplicate attribute in the
            input, a copy of the element is inserted directly after the element, but the css:before,
            css:after, css:duplicate and style attributes are omitted. The css:duplicate attribute
            is moved to the copy and renamed to 'style'. The original element gets a css:id
            attribute if it does not exist yet, and the copy gets a matching css:anchor attribute.
        </p:documentation>
    </p:output>
    
    <p:xslt>
        <p:input port="stylesheet">
            <p:document href="make-pseudo-elements.xsl"/>
        </p:input>
        <p:input port="parameters">
            <p:empty/>
        </p:input>
    </p:xslt>
    
</p:declare-step>
