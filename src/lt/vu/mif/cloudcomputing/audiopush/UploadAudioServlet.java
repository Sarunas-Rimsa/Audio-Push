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
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

@SuppressWarnings("serial")
public class UploadAudioServlet extends HttpServlet {
	
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		
        Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(req);
        List<BlobKey> keys = blobs.get("audio_file");

        if (keys == null) {
        	
        } else {
        	
            UserService userService = UserServiceFactory.getUserService();
            User user = userService.getCurrentUser();
            
        	Key recordKey = KeyFactory.createKey("Record", user.getNickname());
            Date date = new Date();
            double zero = 0.0;
            Entity record = new Entity("AudioRecord", recordKey);
            record.setProperty("file_title", req.getParameter("file_title"));
            record.setProperty("file_subtitle", req.getParameter("file_subtitle"));
            record.setProperty("file_desc", req.getParameter("file_desc"));
            record.setProperty("file_visibility", req.getParameter("visibility"));
            record.setProperty("file_owner", user.getNickname());
            record.setProperty("date", date);
            record.setProperty("content", keys.get(0).getKeyString());
            record.setProperty("rating", zero);
            
            DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
            datastore.put(record);
            
            if (req.getParameter("file_tags") != null && req.getParameter("file_tags").trim().length() > 0) {
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
	}
}
