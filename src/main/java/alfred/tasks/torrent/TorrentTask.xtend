package alfred.tasks.torrent

import alfred.tasks.EmptyTask
import alfred.tasks.Task
import com.turn.ttorrent.client.Client
import com.turn.ttorrent.client.SharedTorrent
import java.io.File
import java.net.InetAddress
import org.apache.commons.io.FileUtils
import org.apache.http.HttpEntity
import org.apache.http.HttpResponse
import org.apache.http.client.methods.HttpGet
import org.apache.http.impl.client.HttpClients
import alfred.sceduling.Result

class TorrentTask implements Task {
	val String action
	val String value
	
	private new(String action, String value) {
		this.action = action
		this.value = value
	}

	def static fromParts(String[] parts) {
		val task = switch (parts.get(1).toLowerCase) {
			case "download": new TorrentTask("download", parts.get(2))
			default: new EmptyTask
		}

		task
	}

	override execute() {
		var result = Result.Failure
		println('''Executing torrent task, action: �action�, value: �value�''')
		switch(action) {
			case "download": result = downloadTorrent()
		}
		
		result
	}
	
	def private downloadTorrent() {
		val torrent = File.createTempFile("alfred", "torrent")
		
		val httpclient = HttpClients.custom().setUserAgent("Mozilla/5.0 (X11; U; Linux i586; en-US; rv:1.7.3) Gecko/20040924 Epiphany/1.4.4 (Ubuntu)").build() 
		val HttpGet httpget = new HttpGet(value)
		val HttpResponse response = httpclient.execute(httpget)
		val HttpEntity entity = response.getEntity()
		if (entity !== null) {
			val inputStream = entity.getContent() // write the file to whether you want it.
			FileUtils.copyInputStreamToFile(inputStream, torrent)
		}

		val client = new Client(
			InetAddress.getLocalHost(),
			SharedTorrent.fromFile(torrent, new File("path_to_download_folder"))
		)

		client.download()
		client.waitForCompletion
		
		return Result.Success
	}
}
