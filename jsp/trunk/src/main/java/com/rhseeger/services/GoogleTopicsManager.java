package com.rhseeger.services;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.apache.log4j.Logger;
import org.w3c.dom.NodeList;
import org.w3c.tidy.Tidy;

/**
 * Google's trend information isn't supposed to be accessed as an API. Since this is just a learning
 * experience, I don't think they'll mind if we just grab the HTML and parse it.
 * @author Robert
 *
 */
public class GoogleTopicsManager {
	static final private Logger logger = Logger.getLogger(GoogleTopicsManager.class);
	
	static final String TOPIC_URL = "http://www.google.com/trends";
	
	public List<String> getTopics() {
		try {
			URL url = new URL(TOPIC_URL);
			URLConnection urlc = url.openConnection();
			java.io.InputStream is = urlc.getInputStream();
			Tidy tidy = new Tidy();
			tidy.setDocType("HTML 4.01 Transitional");
			tidy.setQuiet(true);
			org.w3c.dom.Document doc = tidy.parseDOM(is, null);
			
			XPathFactory  factory=XPathFactory.newInstance();
			XPath xPath=factory.newXPath();
			XPathExpression  xPathExpression= xPath.compile("//td[@class='hotListTable']//table[@class='hotTerm']/tr/td/a/text()");
			NodeList nodes = (NodeList) xPathExpression.evaluate(doc, XPathConstants.NODESET);
			logger.debug("Found " + nodes.getLength() + " nodes");

			List<String> result = new ArrayList<String>();
			for (int i=0; i<nodes.getLength();i++){
				result.add(nodes.item(i).getNodeValue());
			}
			logger.debug("Topics: " + result);
			return result;
		} catch(MalformedURLException ex) {
			logger.info(ex.getClass() + ":" + ex.getMessage());
			throw new RuntimeException(ex);
		} catch(XPathExpressionException ex) {
			logger.info(ex.getClass() + ":" + ex.getMessage());
			throw new RuntimeException(ex);
		} catch(IOException ex) {
			logger.info(ex.getClass() + ":" + ex.getMessage());
			throw new RuntimeException(ex);
		}
	}

}

