package com.rhseeger.models;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import org.apache.commons.lang.StringUtils;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(
	name="topics",
	uniqueConstraints = {@UniqueConstraint(columnNames={"source"})}
)
public class TopicList {
	@Id
	@GeneratedValue(generator="increment")
	@GenericGenerator(name="increment", strategy = "increment")
	private Long id;
	
	private String source;
	
	@ElementCollection  
	@JoinTable( joinColumns = @JoinColumn(name = "id") )
	@IndexColumn( name="POSITION", base = 1 )
	private List<String> topics;

	public TopicList() {}
	
	/**
	 * GETTERS/SETTERS
	 */
	public Long getId() {		return id;	}
	public void setId(Long id) {		this.id = id;	}
	
	public String getSource() {		return source;	}
	public void setSource(String source) {		this.source = source;	}
	
	public List<String> getTopics() {
		return Collections.unmodifiableList(topics);
	}
	public void setTopics(List<String> topics) {
		this.topics = new ArrayList<String>();
		this.topics.addAll(topics);
	}

	/**
	 * PERSISTENCE
	 */
//	@PrePersist
//	protected void onCreate() {
//		tsCreated = new Date();
//		tsModified = new Date();
//	}
//
//	@PreUpdate
//	protected void onUpdate() {
//		tsModified = new Date();
//	}

	/**
	 * OTHER METHODS
	 */
	@Override
	public String toString() {
		return "[TopicList: " + source + " {" + StringUtils.join(topics, ",") + "}]";
	}
}
