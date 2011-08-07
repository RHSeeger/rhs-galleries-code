package com.rhseeger.models;

import java.util.HashMap;
import java.util.Map;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

import org.hibernate.annotations.GenericGenerator;

@Entity
@Table(name="photos")
public class Photo {
	@Id
	@GeneratedValue(generator="increment")
	@GenericGenerator(name="increment", strategy = "increment")
	Long id;
	String flickrPhotoId;
	String title;
	@Column(columnDefinition="text")
	String description;
	String flickrOwnerId;
	String flickrOwnerDisplayName;
	String flickrFarm;
	String flickrServer;
	String flickrSecret;
	
	/**
	 * GETTERS/SETTERS 
	 */
	public Long getId() { return id; }
	public void setId(Long id) { this.id = id; }

	public String getFlickrPhotoId() { return flickrPhotoId; }
	public void setFlickrPhotoId(String flickrPhotoId) { this.flickrPhotoId = flickrPhotoId; }

	public String getTitle() { return title; }
	public void setTitle(String title) { this.title = title; }

	public String getDescription() { return description; }
	public void setDescription(String description) { this.description = description; }

	public String getFlickrOwnerId() { return flickrOwnerId; }
	public void setFlickrOwnerId(String flickrOwnerId) { this.flickrOwnerId = flickrOwnerId; }

	public String getFlickrOwnerDisplayName() { return flickrOwnerDisplayName; }
	public void setFlickrOwnerDisplayName(String flickrOwnerDisplayName) { this.flickrOwnerDisplayName = flickrOwnerDisplayName; }

	public String getFlickrFarm() { return flickrFarm; }
	public void setFlickrFarm(String flickrFarm) { this.flickrFarm = flickrFarm; }

	public String getFlickrServer() { return flickrServer; }
	public void setFlickrServer(String flickrServer) { this.flickrServer = flickrServer; }

	public String getFlickrSecret() { return flickrSecret; }
	public void setFlickrSecret(String flickrSecret) { this.flickrSecret = flickrSecret; }

	/**
	 * OTHER METHODS
	 */
	
	/**
     * http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}.jpg
     * or
     * http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
     * or
     * http://farm{farm-id}.static.flickr.com/{server-id}/{id}_{o-secret}_o.(jpg|gif|png)
     */
	public String getUrl(ImageUrlSize size) {
		switch(size) { 
		case original:
			return "http://farm" + flickrFarm + ".static.flickr.com/" + flickrServer + "/" + flickrPhotoId + "_" + flickrSecret + ".jpg";
		default:
            return "http://farm" + flickrFarm + ".static.flickr.com/" + flickrServer + "/" + flickrPhotoId + "_" + flickrSecret + "_" + size.getSuffix() + ".jpg";
		}
	}
	
	public Map<String,String> getUrl() {
		Map<String,String> result = new HashMap<String,String>();
		for(ImageUrlSize size : ImageUrlSize.values()) {
			result.put(size.name(), getUrl(size));
		}
		return result;
	}
	
	public String getLinkbackUrl() {
		return "http://www.flickr.com/photos/" + flickrOwnerId + '/' + flickrPhotoId;
	}
	
	/**
     The letter suffixes are as follows:
     s small square 75x75
     t thumbnail, 100 on longest side
     m small, 240 on longest side
     - medium, 500 on longest side
     z medium 640, 640 on longest side
     b large, 1024 on longest side*
     o original image, either a jpg, gif or png, depending on source format
     */
	public static enum ImageUrlSize {
		thumbnail("t"),
		tiny("s"),
		small("m"),
		medium("-"),
		large("z"),
		huge("b"),
		original("o");
		
		String sizeSuffix;
		ImageUrlSize(String sizeSuffix) {
			this.sizeSuffix = sizeSuffix;
		}
		
		public String getSuffix() {
			return sizeSuffix;
		}
	}
	
	@Override
	public String toString() {
		return "[Photo: {" + getLinkbackUrl() + " = '" + getTitle() + "' by '" + getFlickrOwnerDisplayName() + "' -> " + getDescription() + "}]";
	}
}
