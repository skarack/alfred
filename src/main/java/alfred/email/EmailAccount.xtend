package alfred.email

import org.eclipse.xtend.lib.annotations.Data

@Data class EmailAccount {
	val String server
	val String username
	val String password
}