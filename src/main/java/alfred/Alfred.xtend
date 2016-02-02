package alfred

import alfred.email.EmailAccount
import alfred.email.EmailClient

class Alfred {
//	val static final TIXATI_EXEC_PATH = '''C:\Program Files\tixati\tixati.exe'''
//	val static EMAIL_CHECK_INTERVAL = 30000
	 
	def static void main(String[] args) {
		// MVP requirements
		// [x]Check for new email every 30s
		// [-]Parse message body for command
		// [ ]Execute command
		// [ ]Reply with results if necessary
		// [ ]Rinse and repeat
		
		// Modify parameters to match your email provider's information
		val account = new EmailAccount("imap-server", "username", "password")
//		while(true) {
			val emails = EmailClient.fetchUnreadEmail(account)
			emails.forEach[println('''
			Addresses: �FOR address : from�[�address.toString�]�ENDFOR�
			Subject: �subject�
			Body: �body�
			''')]
//			Thread.sleep(EMAIL_CHECK_INTERVAL) 
//		}
	}
	
//	def static startAndStopTixati() {
//		val process = new ProcessBuilder(TIXATI_EXEC_PATH).start
//		Thread.sleep(5000)
//		process.destroy
//	}

	
}