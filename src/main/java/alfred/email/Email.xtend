package alfred.email

import org.eclipse.xtend.lib.annotations.Data
import javax.mail.Address

@Data class Email {
	val Address[] from
	val String subject
	val String body
}