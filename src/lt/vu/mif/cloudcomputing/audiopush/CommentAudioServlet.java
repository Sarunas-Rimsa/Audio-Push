package lt.vu.mif.cloudcomputing.audiopush;

import java.io.IOException;
import java.util.Date;
import javax.servlet.http.*;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class CommentAudioServlet extends HttpServlet {
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
	    UserService userService = UserServiceFactory.getUserService();
	    User user = userService.getCurrentUser();
	
	    String content = req.getParameter("content");
	    Date date = new Date();
	    Entity greeting = new Entity("Greeting");
	    greeting.setProperty("user", user);
	    greeting.setProperty("date", date);
	    greeting.setProperty("content", content);
	    greeting.setProperty("record_key", req.getParameter("recordKey"));

	    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    	datastore.beginTransaction();
	    datastore.put(greeting);
        datastore.getCurrentTransaction().commit();
	    
	    resp.sendRedirect("/view.jsp?item=" + req.getParameter("recordKey"));

	}
}
