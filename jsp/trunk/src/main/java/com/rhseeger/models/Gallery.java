package com.rhseeger.models;

import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(
	name="galleries",
	uniqueConstraints = {@UniqueConstraint(columnNames={"searchTerm"})}
)
public class Gallery {
	@Id
	@GeneratedValue(generator="increment")
	@GenericGenerator(name="increment", strategy = "increment")
	Long id;
	
	String searchTerm;
	
	@OneToMany( cascade = {CascadeType.PERSIST, CascadeType.MERGE} )
	@JoinTable( joinColumns = @JoinColumn(name = "id") )
	@IndexColumn( name="POSITION", base = 1 )
	@Cascade({ org.hibernate.annotations.CascadeType.ALL })
	List<Photo> photos;
	
	/**
	 * GETTERS/SETTERS
	 */
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }
	
	public String getSearchTerm() { return searchTerm; }
	public void setSearchTerm(String searchTerm) { this.searchTerm = searchTerm; }
	
	public List<Photo> getPhotos() { return photos; }
	public void setPhotos(List<Photo> photos) { this.photos = photos; }
	
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

	public String toString() {
		return "[Gallery (topic=" + searchTerm + ") (numPhotos=" + photos.size() + ")]";
	}
	
}
