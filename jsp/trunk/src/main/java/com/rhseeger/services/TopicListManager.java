package com.rhseeger.services;

import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.orm.hibernate3.HibernateTemplate;

import com.rhseeger.models.TopicList;

public class TopicListManager {
	static final private Logger logger = Logger.getLogger(TopicListManager.class);
	private HibernateTemplate hibernateTemplate;

	public void setSessionFactory(SessionFactory sessionFactory) {
		logger.info("SessionFactory supplied");
		this.hibernateTemplate = new HibernateTemplate(sessionFactory);
	}
	public SessionFactory getSessionFactory() {
		return hibernateTemplate.getSessionFactory();
	}
	
	// Can we find a way to set this transaction to read-only?
	public TopicList getTopicList(String source) {
		Session session = hibernateTemplate.getSessionFactory().openSession();
        session.beginTransaction();
        try {
        	return getTopicList(source, session);
        } finally {
            session.getTransaction().commit(); // THIS IS CLOSING THE SESSION.. WTF
            session.close();
        }
	}	
	
	public TopicList getTopicList(String source, Session session) {
		Query query = session.createQuery( "FROM TopicList AS topicList LEFT JOIN FETCH topicList.topics WHERE source = :source " );
		query.setString("source", source);
		return (TopicList)(query.uniqueResult());
	}	

	public TopicList getTopicListOrNew(String source) {
    	TopicList result = getTopicList(source);
    	return (result == null) ? new TopicList() : result;
	}	
	
	public TopicList getTopicListOrNew(String source, Session session) {
    	TopicList result = getTopicList(source, session);
    	return (result == null) ? new TopicList() : result;
	}	

}