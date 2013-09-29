package lt.vu.mif.cloudcomputing.audiopush;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class DeleteGreetingServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
			
            UserService userService = UserServiceFactory.getUserService();
            User user = userService.getCurrentUser();

            DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
            Entity greeting = null;
			try {
				greeting = datastore.get(KeyFactory.stringToKey(req.getParameter("recordKey")));
			} catch (EntityNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            
            if (((User) greeting.getProperty("user")).getNickname().equals(user.getNickname())) {
            	
            	String itemKey = (String) greeting.getProperty("record_key");
            	datastore.beginTransaction();
	            datastore.delete(KeyFactory.stringToKey(req.getParameter("recordKey")));
	            datastore.getCurrentTransaction().commit();
	            resp.sendRedirect("/view.jsp?item="+itemKey);
            }
            else {
            	resp.sendRedirect("/cheater.jsp");
            }

	}
}
