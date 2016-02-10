package alfred

import alfred.email.EmailAccount
import alfred.email.EmailClient
import alfred.sceduling.Result
import alfred.sceduling.Scheduler
import alfred.tasks.Parser
import java.io.FileInputStream
import java.util.Properties

class Alfred {
	val static EMAIL_CHECK_INTERVAL = 30000
	 
	def static void main(String[] args) {
		val prop = new Properties
		prop.load(new FileInputStream("config.properties"))
		
		val trustedAddresses = (prop.get("security.mail.from.whitelist") as String)?.split(",") ?: newArrayOfSize(0)
		// Modify parameters to match your email provider's information
		val account = EmailAccount.fromProperties(prop)
		
		while(true) {
			val emails = EmailClient.fetchUnreadEmail(account)
			println('''Received «emails.length» email(s)''')
			emails.filter[trustedAddresses.empty || trustedAddresses.contains(it)].forEach[
				val task = Parser.extractTask(body)
				Scheduler.runTask(task, [theTask, result|
					val replyBody = if( result.equals(Result.Success)) "Task sucessful" else "Task failed"
					println('''Task completed with status: «result»''')
					EmailClient.reply(account, it, replyBody)])
			]
			
			Thread.sleep(EMAIL_CHECK_INTERVAL) 
		}
	}
}