import java.util.Arrays;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.assertEquals;

import com.rhseeger.services.GoogleTopicsManager;


public class TopicListManager_Test {
	GoogleTopicsManager manager;
	
	@Before
	public void setup() {
		manager = new GoogleTopicsManager();
	}
	@After
	public void cleanup() {
		
	}
	/**
	 * public static String parseToJson(String fileContents)
	 */
//	@Test
//	public void parseToJson_1() {
//		String googleJson = "nowqueries = {\"queries\":[{\"query\":\"vanessa bryant\"},{\"query\":\"tumblr\"}],\"timestamp\":\"1304984053\",\"locale\":\"en-us\"};\n" +
//			"some other stuff";
//		assertEquals("[{\"query\":\"vanessa bryant\"},{\"query\":\"tumblr\"}]", GoogleTopicsManager.parseToJson(googleJson));
//	}
	
	/**
	 * public static List<String> parseJsonToTopics(String json)
	 */
//	@Test
//	public void parseJsonToTopics_1() {
//		String json = "[" +
//			"{\"query\":\"vanessa bryant\",\"language\":\"en\",\"country\":\"us\",\"type\":3,\"search_link\":\"http://www.google.com/search?q=vanessa%20bryant&hl=en&gl=us&tbs=mbl:1&rtfu=1304986004&usg=78dd\",\"triggering_source\":0}," +
//			"{\"query\":\"rondo\",\"language\":\"en\",\"country\":\"us\",\"type\":3,\"search_link\":\"http://www.google.com/search?q=rondo&hl=en&gl=us&tbs=mbl:1&rtfu=1304986004&usg=5057\",\"triggering_source\":0}," +
//			"{\"query\":\"tumblr\",\"language\":\"en\",\"country\":\"us\",\"type\":3,\"search_link\":\"http://www.google.com/search?q=tumblr&hl=en&gl=us&tbs=mbl:1&rtfu=1304986004&usg=28ee\",\"triggering_source\":0}]";
//		assertEquals(Arrays.asList("vanessa bryant", "rondo", "tumblr"), GoogleTopicsManager.parseJsonToTopics(json));
//	}
}
