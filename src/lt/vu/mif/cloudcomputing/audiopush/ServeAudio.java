package lt.vu.mif.cloudcomputing.audiopush;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
 
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;

public class ServeAudio extends HttpServlet {
	private BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	 
	public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
	BlobKey blobKey = new BlobKey(req.getParameter("audio"));
	
	resp.setHeader("Content-Disposition", "attachment ;filename =en.mp3");
	resp.setContentType("audio/mpeg3"); 
	
	blobstoreService.serve(blobKey, resp);
	}

}
