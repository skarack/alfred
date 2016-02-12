package alfred

import alfred.email.EmailAccount
import alfred.email.EmailClient
import alfred.sceduling.Result
import alfred.sceduling.Scheduler
import alfred.tasks.Parser
import alfred.vpn.Vpn
import java.io.FileInputStream
import java.util.Properties

class Alfred {
	val static EMAIL_CHECK_INTERVAL = 30000
	 
	def static void main(String[] args) {
		val prop = new Properties
		prop.load(new FileInputStream("config.properties"))

		val emailCheckInterval = try { Integer.parseInt(prop.get("general.mail.check.interval") as String) } catch(NumberFormatException e) { EMAIL_CHECK_INTERVAL }
		Vpn.setVpnInfo(prop.get("general.vpn.name") as String, prop.get("general.vpn.username") as String, prop.get("general.vpn.password") as String)
		val account = EmailAccount.fromProperties(prop)
		
		while(true) {
			val emails = EmailClient.fetchUnreadEmail(account)
			println('''Received «emails.length» email(s)''')
			emails.forEach[
				val task = Parser.extractTask(body)
				Scheduler.runTask(task, [theTask, result|
					val replyBody = if( result.equals(Result.Success)) "Task sucessful" else "Task failed"
					println('''Task completed with status: «result»''')
					EmailClient.reply(account, it, replyBody)])
			]
			
			Thread.sleep(emailCheckInterval) 
		}
	}
}