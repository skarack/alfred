package alfred.email

import java.util.ArrayList
import java.util.List
import javax.mail.Folder
import javax.mail.Multipart
import javax.mail.Part
import javax.mail.Session
import javax.mail.internet.InternetAddress
import javax.mail.Transport
import java.util.Properties
import javax.mail.PasswordAuthentication
import javax.mail.internet.MimeMessage
import javax.mail.Message

class EmailClient {
	val static RECV_PROTOCOL = "imaps"

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
	
	def static reply(EmailAccount account, Email email, String body) {
	    val props = new Properties();
	    props.put("mail.transport.protocol", "smtps");
	    props.put("mail.smtp.starttls.enable","true");
	    props.put("mail.smtp.auth", "true");
	    props.put("mail.smtp.host", "smtp_server");
	    props.put("mail.smtp.port", "587");
	
	    val session = Session.getInstance(props, new javax.mail.Authenticator() {
			override getPasswordAuthentication() {
				return new PasswordAuthentication(account.username, account.password);
			}
		});
	
	    val message = new MimeMessage(session);
	    message.setFrom(new InternetAddress("from_address"));
	    message.setRecipients(Message.RecipientType.TO, email.from);
	    message.setSubject(email.subject); 
	    message.setText(body);
	    Transport.send(message)
	}

	def private static Folder initialize(EmailAccount account) {
		val session = Session.getInstance(System.getProperties(), null)
		val store = session.getStore(RECV_PROTOCOL)

		store.connect(account.imapServer, -1, account.username, account.password)
		val inbox = store.getDefaultFolder().getFolder("INBOX")
		inbox.open(Folder.READ_WRITE)

		inbox
	}

	def private static void dispose(Folder inbox) {
		var store = inbox.getStore()
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
