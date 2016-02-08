package alfred

import alfred.email.EmailAccount
import alfred.email.EmailClient
import alfred.tasks.Parser
import alfred.sceduling.Scheduler
import alfred.sceduling.Result

class Alfred {
	val static EMAIL_CHECK_INTERVAL = 30000
	 
	def static void main(String[] args) {
		// Modify parameters to match your email provider's information
		val account = new EmailAccount("imaps_server", "username", "password")
		while(true) {
			val emails = EmailClient.fetchUnreadEmail(account)
			println('''Received «emails.length» email(s)''')
			emails.forEach[
				val task = Parser.extractTask(body)
				Scheduler.runTask(task, [_, result|
					val replyBody = if( result.equals(Result.Success)) "Task sucessful" else "Task failed"
					println('''Task completed with status: «result»''')
					EmailClient.reply(account, it, replyBody)
				])
			]
			
			Thread.sleep(EMAIL_CHECK_INTERVAL) 
		}
	}
}