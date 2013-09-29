package lt.vu.mif.cloudcomputing.audiopush;

import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
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

public class DeleteAudioServlet extends HttpServlet {
	
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

            	BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
            	BlobKey blobKey = new BlobKey((String) record.getProperty("content"));
            	            	
            	blobstoreService.delete(blobKey);
            	
	            datastore.delete(KeyFactory.stringToKey(req.getParameter("recordKey")));
	            
	            Query tagQuery = new Query("Tag").setFilter(FilterOperator.EQUAL.of("record_key", req.getParameter("recordKey")));
	            List<Entity> tagsToDelete = datastore.prepare(tagQuery).asList(FetchOptions.Builder.withLimit(50));

	            Query guestbookQuery = new Query("Greeting").setFilter(FilterOperator.EQUAL.of("record_key", req.getParameter("recordKey")));
	            List<Entity> greetings = datastore.prepare(guestbookQuery).asList(FetchOptions.Builder.withLimit(50));

	            for (Entity greeting : greetings) {
	            	datastore.delete(greeting.getKey());
	            }
	            
	            for (Entity tagToDelete : tagsToDelete) {
	            	datastore.delete(tagToDelete.getKey());
	            }
	            
	            resp.sendRedirect("/library.jsp");
            }
            else {
            	resp.sendRedirect("/cheater.jsp");
            }

	}

}
