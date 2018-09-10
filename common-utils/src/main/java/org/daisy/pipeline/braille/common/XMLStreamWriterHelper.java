package org.daisy.pipeline.braille.common;

import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Stack;

import javax.xml.namespace.NamespaceContext;
import javax.xml.namespace.QName;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import javax.xml.stream.XMLStreamWriter;

import static javax.xml.stream.XMLStreamConstants.CDATA;
import static javax.xml.stream.XMLStreamConstants.CHARACTERS;
import static javax.xml.stream.XMLStreamConstants.COMMENT;
import static javax.xml.stream.XMLStreamConstants.END_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.END_ELEMENT;
import static javax.xml.stream.XMLStreamConstants.PROCESSING_INSTRUCTION;
import static javax.xml.stream.XMLStreamConstants.SPACE;
import static javax.xml.stream.XMLStreamConstants.START_DOCUMENT;
import static javax.xml.stream.XMLStreamConstants.START_ELEMENT;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NamedNodeMap;

public final class XMLStreamWriterHelper {
	
	public interface WriterEvent {
		public void writeTo(XMLStreamWriter writer) throws XMLStreamException;
	}
	
	public interface FutureWriterEvent extends WriterEvent {
		public boolean isReady();
	}
	
	public interface BufferedXMLStreamWriter extends XMLStreamWriter {
		public void writeEvent(FutureWriterEvent event) throws XMLStreamException;
	}
	
	private static QName nodeName(Node node) {
		String prefix = node.getPrefix();
		String ns = node.getNamespaceURI();
		String localPart = node.getLocalName();
		if (prefix != null)
			return new QName(ns, localPart, prefix);
		else
			return new QName(ns, localPart);
	}
	
	public static Map<QName,String> getAttributes(XMLStreamReader reader) {
		Map<QName,String> map = new HashMap<QName,String>();
		for (int i = 0; i < reader.getAttributeCount(); i++)
			map.put(reader.getAttributeName(i), reader.getAttributeValue(i));
		return map;
	}
	
	public static void copyAttribute(XMLStreamWriter writer, Node attr) throws XMLStreamException {
		copyAttribute(writer, attr, false);
	}
	
	public static void copyAttribute(XMLStreamWriter writer, Node attr, boolean copyNamespaceNodes) throws XMLStreamException {
		writeAttribute(writer, nodeName(attr), attr.getNodeValue(), copyNamespaceNodes);
	}
	
	public static void copyAttributes(XMLStreamWriter writer, Element element) throws XMLStreamException {
		copyAttributes(writer, element, false);
	}
	
	public static void copyAttributes(XMLStreamWriter writer, Element element, boolean copyNamespaceNodes) throws XMLStreamException {
		NamedNodeMap attributes = element.getAttributes();
		for (int i = 0; i < attributes.getLength(); i++) {
			Node attr = attributes.item(i);
			copyAttribute(writer, attr, copyNamespaceNodes);
		}
	}
	
	public static void copyAttributes(XMLStreamWriter writer, XMLStreamReader reader) throws XMLStreamException {
		for (int i = 0; i < reader.getAttributeCount(); i++)
			writeAttribute(writer, reader.getAttributeName(i), reader.getAttributeValue(i));
	}
	
	public static void copyCData(XMLStreamWriter writer, XMLStreamReader reader) throws XMLStreamException {
		writer.writeCData(reader.getText());
	}
	
	public static void copyCharacters(XMLStreamWriter writer, Node text) throws XMLStreamException {
		writer.writeCharacters(text.getNodeValue());
	}
	
	public static void copyCharacters(XMLStreamWriter writer, XMLStreamReader reader) throws XMLStreamException {
		writer.writeCharacters(reader.getText());
	}
	
	public static void copyComment(XMLStreamWriter writer, Node node) throws XMLStreamException {
		writer.writeComment(node.getNodeValue());
	}
	
	public static void copyComment(XMLStreamWriter writer, XMLStreamReader reader) throws XMLStreamException {
		writer.writeComment(reader.getText());
	}
	
	public static void copyElement(XMLStreamWriter writer, XMLStreamReader reader) throws XMLStreamException {
		writeStartElement(writer, reader.getName());
		copyAttributes(writer, reader);
		int depth = 0;
		while (true)
			try {
				int event = reader.next();
				switch (event) {
				case START_ELEMENT:
					copyStartElement(writer, reader);
					copyAttributes(writer, reader);
					depth++;
					break;
				case END_ELEMENT:
					writer.writeEndElement();
					depth--;
					if (depth < 0)
						return;
					break;
				default:
					copyEvent(writer, event, reader); }}
			catch (NoSuchElementException e) {
				throw new RuntimeException("coding error"); }
	}
	
	public static void copyEvent(XMLStreamWriter writer, int event, XMLStreamReader reader) throws XMLStreamException {
		switch (event) {
		case START_DOCUMENT:
			writer.writeStartDocument();
			break;
		case END_DOCUMENT:
			writer.writeEndDocument();
			break;
		case START_ELEMENT:
			copyStartElement(writer, reader);
			break;
		case END_ELEMENT:
			writer.writeEndElement();
			break;
		case SPACE:
		case CHARACTERS:
			copyCharacters(writer, reader);
			break;
		case PROCESSING_INSTRUCTION:
			copyProcessingInstruction(writer, reader);
			break;
		case CDATA:
			copyCData(writer, reader);
			break;
		case COMMENT:
			copyComment(writer, reader);
			break;
		}
	}
	
	public static void copyProcessingInstruction(XMLStreamWriter writer, Node pi) throws XMLStreamException {
		writer.writeProcessingInstruction(pi.getLocalName(), pi.getNodeValue());
	}
	
	public static void copyProcessingInstruction(XMLStreamWriter writer, XMLStreamReader reader) throws XMLStreamException {
		String target = reader.getPITarget();
		String data = reader.getPIData();
		if (data == null)
			writer.writeProcessingInstruction(target);
		else
			writer.writeProcessingInstruction(target, data);
	}
	
	public static void copyStartElement(XMLStreamWriter writer, Element element) throws XMLStreamException {
		copyStartElement(writer, element, false, false);
	}
	
	public static void copyStartElement(XMLStreamWriter writer, Element element,
	                                    boolean copyAttributes, boolean copyNamespaceNodes)
			throws XMLStreamException {
		String prefix = element.getPrefix();
		String ns = element.getNamespaceURI();
		String localPart = element.getLocalName();
		if (prefix != null)
			writer.writeStartElement(prefix, localPart, ns);
		else
			writer.writeStartElement(ns, localPart);
		if (copyAttributes) {
			copyAttributes(writer, element, copyNamespaceNodes);
		}
	}
	
	public static void copyStartElement(XMLStreamWriter writer, XMLStreamReader reader) throws XMLStreamException {
		writeStartElement(writer, reader.getName());
	}
	
	public static void writeAttribute(XMLStreamWriter writer, QName name, String value) throws XMLStreamException {
		writeAttribute(writer, name, value, false);
	}
	
	public static void writeAttribute(XMLStreamWriter writer, QName name, String value, boolean writeNamespaceNodes)
			throws XMLStreamException {
		String prefix = name.getPrefix();
		String ns = name.getNamespaceURI();
		String localPart = name.getLocalPart();
		if ("http://www.w3.org/2000/xmlns/".equals(ns)) {
			if (!writeNamespaceNodes)
				return;
		}
		if (prefix == null || "".equals(prefix))
			writer.writeAttribute(ns, localPart, value);
		else
			writer.writeAttribute(prefix, ns, localPart, value);
	}
	
	public static void writeStartElement(XMLStreamWriter writer, QName name) throws XMLStreamException {
		String prefix = name.getPrefix();
		String ns = name.getNamespaceURI();
		String localPart = name.getLocalPart();
		if (prefix != null)
			writer.writeStartElement(prefix, localPart, ns);
		else
			writer.writeStartElement(ns, localPart);
	}
	
	public static class ToStringWriter implements XMLStreamWriter {
		
		private StringBuilder b = new StringBuilder();
		
		private Stack<String> elements = new Stack<String>();
		private boolean startTagOpen = false;
		
		@Override
		public String toString() {
			return b.toString();
		}

		@Override
		public void close() throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void flush() throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public NamespaceContext getNamespaceContext() {
			throw new UnsupportedOperationException();
		}

		@Override
		public String getPrefix(String uri) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public Object getProperty(String name) throws IllegalArgumentException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void setDefaultNamespace(String uri) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void setNamespaceContext(NamespaceContext context) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void setPrefix(String prefix, String uri) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeAttribute(String localName, String value) throws XMLStreamException {
			writeAttribute(null, localName, value);
		}

		@Override
		public void writeAttribute(String prefix, String namespaceURI, String localName, String value) throws XMLStreamException {
			b.append(" ").append(localName).append("='").append(value).append("'");
		}

		@Override
		public void writeAttribute(String namespaceURI, String localName, String value) throws XMLStreamException {
			writeAttribute(null, namespaceURI, localName, value);
		}

		@Override
		public void writeCData(String data) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}
		
		@Override
		public void writeCharacters(String text) throws XMLStreamException {
			if (startTagOpen) {
				b.append(">");
				startTagOpen = false; }
			b.append(text);
		}

		@Override
		public void writeCharacters(char[] text, int start, int len) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeComment(String data) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeDefaultNamespace(String namespaceURI) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeDTD(String dtd) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeEmptyElement(String localName) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeEmptyElement(String namespaceURI, String localName) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeEmptyElement(String prefix, String localName, String namespaceURI) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeEndDocument() throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeEndElement() throws XMLStreamException {
			if (startTagOpen) {
				b.append("/>");
				startTagOpen = false;
				elements.pop(); }
			else
				b.append("</").append(elements.pop()).append(">");
		}

		@Override
		public void writeEntityRef(String name) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeNamespace(String prefix, String namespaceURI) throws XMLStreamException {
		}

		@Override
		public void writeProcessingInstruction(String target) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeProcessingInstruction(String target, String data) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeStartDocument() throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeStartDocument(String version) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}

		@Override
		public void writeStartDocument(String encoding, String version) throws XMLStreamException {
			throw new UnsupportedOperationException();
		}
		
		@Override
		public void writeStartElement(String localName) throws XMLStreamException {
			writeStartElement(null, localName);
		}

		@Override
		public void writeStartElement(String namespaceURI, String localName) throws XMLStreamException {
			writeStartElement(null, namespaceURI, localName);
		}

		@Override
		public void writeStartElement(String prefix, String localName, String namespaceURI) throws XMLStreamException {
			if (startTagOpen) {
				b.append(">");
				startTagOpen = false; }
			elements.push(localName);
			b.append("<").append(localName);
			startTagOpen = true;
		}
	}
	
	private XMLStreamWriterHelper() {
		// no instantiation
	}
}
