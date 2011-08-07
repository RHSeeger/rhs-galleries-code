package com.rhseeger.tags;

import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspTagException;
import javax.servlet.jsp.tagext.TagSupport;

import org.apache.commons.lang.StringEscapeUtils;

public class EscapeJavascriptString extends TagSupport {
	String value;

	public void setValue(String value) {
		this.value = value;
	}
	public String getValue() {
		return value;
	}

	public int doStartTag() throws JspException {
		try {
			pageContext.getOut().print(StringEscapeUtils.escapeJavaScript(getValue()).replace("<", "&lt;").replace("\\n", "<br>"));
		} catch (Exception ex) {
			throw new JspTagException("SimpleTag: " + ex.getMessage());
		}
		return SKIP_BODY;
	}
	public int doEndTag() {
		return EVAL_PAGE;
	}
}
