package alfred.email

import java.util.Properties
import org.eclipse.xtend.lib.annotations.Accessors

class EmailAccount {
	@Accessors(PUBLIC_GETTER) val String imapHost
	@Accessors(PUBLIC_GETTER) val String smtpHost
	@Accessors(PUBLIC_GETTER) val String username
	@Accessors(PUBLIC_GETTER) val String password
	
	private new(String imapHost, String smtpHost, String username, String password) {
		this.imapHost = imapHost
		this.smtpHost = smtpHost
		this.username = username
		this.password = password
	}
	
	def static fromProperties(Properties props) {
		val imapHost = props.get("mail.imaps.host") as String ?: ""
		val smtpHost = props.get("mail.smtp.host") as String ?: ""
		val username = props.get("mail.username") as String ?: ""
		val password = props.get("mail.password") as String ?: ""
		
		new EmailAccount(imapHost, smtpHost, username, password)
	}
}