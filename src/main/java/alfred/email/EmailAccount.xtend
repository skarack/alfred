package alfred.email

import org.eclipse.xtend.lib.annotations.Data

@Data class EmailAccount {
	val String imapServer
	val String username
	val String password
}