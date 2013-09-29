package lt.vu.mif.cloudcomputing.audiopush;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class RateAudioServlet extends HttpServlet {
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
	    UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	
	    String ratingString = req.getParameter("rating");
	    double ratingDouble = Double.parseDouble(ratingString);
	    Entity rating = new Entity("Rating");
	    rating.setProperty("user", user);
	    rating.setProperty("record_rating", ratingDouble);
	    rating.setProperty("record_key", req.getParameter("recordKeyRating"));

	    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    	datastore.beginTransaction();
	    datastore.put(rating);
        datastore.getCurrentTransaction().commit();
        
        Entity record = null;
    	datastore.beginTransaction();
        
        try {
        	record = datastore.get(KeyFactory.stringToKey(req.getParameter("recordKeyRating")));
        }
        catch(Exception e) {
        	e.printStackTrace();
        }
        
        Query ratingsQuery = new Query("Rating").setFilter(FilterOperator.EQUAL.of("record_key", req.getParameter("recordKeyRating")));
    	List<Entity> ratings = datastore.prepare(ratingsQuery).asList(FetchOptions.Builder.withLimit(500));
    	
    	double sum = 0.0;
    	
    	for (Entity rating1: ratings) {
    		sum = sum + (double)rating1.getProperty("record_rating");
    	}
    	
    	double avg = sum / (double)ratings.size();
    	
    	record.setProperty("rating", avg);
    	datastore.put(record);    	

        datastore.getCurrentTransaction().commit();
	    resp.sendRedirect("/view.jsp?item=" + req.getParameter("recordKeyRating"));

	}

}
