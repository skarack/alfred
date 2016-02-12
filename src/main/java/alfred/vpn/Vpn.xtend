package alfred.vpn

import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.List
import alfred.tasks.Task
import java.util.ArrayList

class Vpn {
	var static refCount = 0
	var static vpnName = ""
	var static vpnUsername = ""
	var static vpnPassword = ""
	var static Thread monitorThread
	var static boolean keepMonitoring = false
	
	val static List<Task> tasks = new ArrayList
	
	def static connect(Task task) {
		var ProcessBuilder pb=new ProcessBuilder("rasdial", vpnName, vpnUsername, vpnPassword)
		pb.redirectErrorStream(true) 
		var Process process=pb.start() 
		while(process.alive) {}
		var result = process.exitValue
		
		if(result == 0) {
			if(refCount == 0) {
				monitorVpnState
			}
			refCount++
			tasks.add(task)
		}
		
		result == 0
	}
	
	def static disconnect(Task task) {
		refCount--
		
		tasks.remove(task)
		val result = if(refCount == 0) {
			var ProcessBuilder pb=new ProcessBuilder("rasdial", vpnName, "/disconnect")
			pb.redirectErrorStream(true) 
			var Process process=pb.start() 
			while(process.alive) {}
			process.exitValue == 0
			
			keepMonitoring = false
		} else {
			true
		}
		
		result
	}
	
	def static setVpnInfo(String name, String username, String password) {
		vpnName = name;
		vpnUsername = username;
		vpnPassword = password;
	}
	
	def private static monitorVpnState() {
		monitorThread = new Thread([
			while(keepMonitoring) {
				var ProcessBuilder pb=new ProcessBuilder("rasdial")
				pb.redirectErrorStream(true) 
				var Process process=pb.start() 
				val ouput = new BufferedReader(new InputStreamReader(process.inputStream))  
				if(!ouput.lines.anyMatch([contains(vpnName)])) {
					// vpn is down
					notifyTasks(1)
				}
				Thread.sleep(10000)
			}
		])
		keepMonitoring = true
		monitorThread.start
	}
	
	def private static notifyTasks(int errCode) {
		tasks.forEach[notify(errCode)]
	}
}