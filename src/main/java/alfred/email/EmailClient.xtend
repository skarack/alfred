package alfred.email

import java.util.ArrayList
import java.util.List
import javax.mail.Folder
import javax.mail.Multipart
import javax.mail.Part
import javax.mail.Session
import javax.mail.Store

class EmailClient {
	val static PROTOCOL = "imaps"

	def static List<Email> fetchUnreadEmail(EmailAccount account) {
		val emails = new ArrayList<Email>

		val inbox = initialize(account)

		val count = inbox.getUnreadMessageCount()
		if (count > 0) {
			inbox.getMessages(1, count).forEach [
				val body = ExtractBody
				if (!body.isNullOrEmpty) {
					emails.add(new Email(from, subject, body))
				}
			]
		}

		dispose(inbox)

		emails
	}

	def private static Folder initialize(EmailAccount account) {
		val Session session = Session.getInstance(System.getProperties(), null)
		val Store store = session.getStore(PROTOCOL)

		store.connect(account.server, -1, account.username, account.password)
		val inbox = store.getDefaultFolder().getFolder("INBOX")
		inbox.open(Folder.READ_ONLY)

		inbox
	}

	def private static void dispose(Folder inbox) {
		var Store store = inbox.getStore()
		inbox.close(false)
		store.close()
	}

	def private static ExtractBody(Part part) {
		val StringBuilder sb = new StringBuilder

		if (part.isMimeType("text/*")) {
			sb.append((part.getContent() as String))
		} else if (part.isMimeType("multipart/alternative")) {
			// prefer html text over plain text
			val Multipart mp = (part.getContent() as Multipart)
			for (var int i = 0; i < mp.getCount(); i++) {
				val Part bp = mp.getBodyPart(i)
				if (bp.isMimeType("text/plain")) {
					sb.append((bp.getContent() as String))
				}
			}
		} else if (part.isMimeType("multipart/*")) {
			var Multipart mp = (part.getContent() as Multipart)
			for (var int i = 0; i < mp.getCount(); i++) {
				val s = (mp.getBodyPart(i).getContent() as String)
				if (!s.isNullOrEmpty) {
					sb.append(s)
				}
			}
		}

		sb.toString
	}
}
