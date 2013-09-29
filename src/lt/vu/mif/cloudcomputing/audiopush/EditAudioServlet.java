package lt.vu.mif.cloudcomputing.audiopush;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.EntityNotFoundException;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class EditAudioServlet extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
			
            UserService userService = UserServiceFactory.getUserService();
            User user = userService.getCurrentUser();

            DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
            Entity record = null;
			try {
				record = datastore.get(KeyFactory.stringToKey(req.getParameter("recordKey")));
			} catch (EntityNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
            
            if (user.getNickname().equals(record.getProperty("file_owner"))) {
            
	            record.setProperty("file_title", req.getParameter("file_title"));
	            record.setProperty("file_subtitle", req.getParameter("file_subtitle"));
	            record.setProperty("file_desc", req.getParameter("file_desc"));
	            record.setProperty("file_visibility", req.getParameter("visibility"));
	            
	            datastore.put(record);
	            
	            if (req.getParameter("file_tags").trim().length() == 0) {
	            	
		            Query tagQuery = new Query("Tag").setFilter(FilterOperator.EQUAL.of("record_key", req.getParameter("recordKey")));
		            List<Entity> tagsToDelete = datastore.prepare(tagQuery).asList(FetchOptions.Builder.withLimit(50));
		            
		            for (Entity tagToDelete : tagsToDelete) {
		            	datastore.delete(tagToDelete.getKey());
		            }
	            }
	                        
	            if (req.getParameter("file_tags") != null && req.getParameter("file_tags").trim().length() > 0) {
	            	
		            Query tagQuery = new Query("Tag").setFilter(FilterOperator.EQUAL.of("record_key", req.getParameter("recordKey")));
		            List<Entity> tagsToDelete = datastore.prepare(tagQuery).asList(FetchOptions.Builder.withLimit(50));
		            
		            for (Entity tagToDelete : tagsToDelete) {
		            	datastore.delete(tagToDelete.getKey());
		            }
	            	
		            String tags = req.getParameter("file_tags").replace(" ", "");
		            String[] tagArray = tags.split(",");
		            for (String tag : tagArray) {
			            Entity recordTag = new Entity("Tag");
			            recordTag.setProperty("record_key", KeyFactory.keyToString(record.getKey()));
			            recordTag.setProperty("record_tag", tag);
			            datastore.put(recordTag);
		            }
	            }

	            resp.sendRedirect("/library.jsp");

            }
            else {
            	resp.sendRedirect("/cheater.jsp");
            }
	}
}
