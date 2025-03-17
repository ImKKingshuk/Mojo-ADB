# MojoADB: Device Diagnostics Module

from core.client import ADBClient
from core.errors import ADBError
from python import Python

# Device diagnostics and health monitoring
struct DeviceDiagnostics:
    var client: ADBClient
    
    fn __init__(inout self, client: ADBClient):
        self.client = client
    
    fn get_system_info(self, serial: String) -> Dict[String, String]:
        """
        Get comprehensive system information about a device.
        Returns a dictionary with system properties.
        """
        var system_info = Dict[String, String]()
        
        try:
            # Get Android version
            let build_prop = self.client.send_command("shell getprop ro.build.version.release")
            system_info["android_version"] = build_prop.strip()
            
            # Get device model
            let model = self.client.send_command("shell getprop ro.product.model")
            system_info["model"] = model.strip()
            
            # Get device manufacturer
            let manufacturer = self.client.send_command("shell getprop ro.product.manufacturer")
            system_info["manufacturer"] = manufacturer.strip()
            
            # Get CPU info
            let cpu_info = self.client.send_command("shell cat /proc/cpuinfo")
            system_info["cpu_info"] = cpu_info.strip()
            
            # Get memory info
            let mem_info = self.client.send_command("shell cat /proc/meminfo")
            system_info["mem_info"] = mem_info.strip()
            
            # Get storage info
            let storage_info = self.client.send_command("shell df -h")
            system_info["storage_info"] = storage_info.strip()
            
            # Get kernel version
            let kernel_version = self.client.send_command("shell uname -a")
            system_info["kernel_version"] = kernel_version.strip()
            
            # Get build fingerprint
            let build_fingerprint = self.client.send_command("shell getprop ro.build.fingerprint")
            system_info["build_fingerprint"] = build_fingerprint.strip()
            
            # Get security patch level
            let security_patch = self.client.send_command("shell getprop ro.build.version.security_patch")
            system_info["security_patch"] = security_patch.strip()
        except e:
            system_info["error"] = str(e)
        
        return system_info
    
    fn get_memory_usage(self, serial: String) -> Dict[String, String]:
        """
        Get detailed memory usage information.
        Returns a dictionary with memory usage statistics.
        """
        var memory_usage = Dict[String, String]()
        
        try:
            # Get memory info
            let mem_info = self.client.send_command("shell cat /proc/meminfo")
            for line in mem_info.split("\n"):
                if ": " in line:
                    let parts = line.split(":", 1)
                    if len(parts) == 2:
                        memory_usage[parts[0].strip()] = parts[1].strip()
            
            # Get process memory usage
            let proc_mem = self.client.send_command("shell dumpsys meminfo")
            memory_usage["process_memory"] = proc_mem.strip()
        except e:
            memory_usage["error"] = str(e)
        
        return memory_usage
    
    fn get_network_stats(self, serial: String) -> Dict[String, String]:
        """
        Get network statistics and information.
        Returns a dictionary with network information.
        """
        var network_stats = Dict[String, String]()
        
        try:
            # Get network interfaces
            let interfaces = self.client.send_command("shell ip addr")
            network_stats["interfaces"] = interfaces.strip()
            
            # Get network statistics
            let net_stat = self.client.send_command("shell cat /proc/net/dev")
            network_stats["statistics"] = net_stat.strip()
            
            # Get routing table
            let routing = self.client.send_command("shell ip route")
            network_stats["routing"] = routing.strip()
            
            # Get WiFi information
            let wifi_info = self.client.send_command("shell dumpsys wifi")
            network_stats["wifi"] = wifi_info.strip()
        except e:
            network_stats["error"] = str(e)
        
        return network_stats
    
    fn get_battery_health(self, serial: String) -> Dict[String, String]:
        """
        Get detailed battery health information.
        Returns a dictionary with battery health metrics.
        """
        var battery_health = Dict[String, String]()
        
        try:
            # Get battery info
            let battery_info = self.client.send_command("shell dumpsys battery")
            for line in battery_info.split("\n"):
                line = line.strip()
                if ": " in line:
                    let parts = line.split(": ")
                    if len(parts) == 2:
                        battery_health[parts[0]] = parts[1]
            
            # Get battery stats
            let battery_stats = self.client.send_command("shell dumpsys batterystats")
            battery_health["stats"] = battery_stats.strip()
        except e:
            battery_health["error"] = str(e)
        
        return battery_health
    
    fn run_diagnostics(self, serial: String) -> Dict[String, Dict[String, String]]:
        """
        Run a comprehensive diagnostic check on the device.
        Returns a dictionary with all diagnostic information.
        """
        var diagnostics = Dict[String, Dict[String, String]]()
        
        # Get system information
        diagnostics["system"] = self.get_system_info(serial)
        
        # Get memory usage
        diagnostics["memory"] = self.get_memory_usage(serial)
        
        # Get network statistics
        diagnostics["network"] = self.get_network_stats(serial)
        
        # Get battery health
        diagnostics["battery"] = self.get_battery_health(serial)
        
        return diagnostics
    
    fn check_device_health(self, serial: String) -> Dict[String, String]:
        """
        Perform a quick health check on the device.
        Returns a dictionary with health status indicators.
        """
        var health_status = Dict[String, String]()
        
        try:
            # Check if device is responsive
            let ping_result = self.client.send_command("shell echo 'ping'")
            health_status["responsive"] = "true" if ping_result.strip() == "ping" else "false"
            
            # Check battery level
            let battery_level = self.client.send_command("shell dumpsys battery | grep level")
            if "level" in battery_level:
                let level = battery_level.split(":")[1].strip()
                health_status["battery_level"] = level
                health_status["battery_status"] = "low" if int(level) < 20 else "ok"
            
            # Check storage space
            let storage = self.client.send_command("shell df /data | tail -1")
            let parts = storage.split()
            if len(parts) >= 5:
                let usage_percent = parts[4].replace("%", "")
                health_status["storage_usage"] = usage_percent + "%"
                health_status["storage_status"] = "critical" if int(usage_percent) > 90 else "warning" if int(usage_percent) > 80 else "ok"
            
            # Check running processes count
            let process_count = self.client.send_command("shell ps | wc -l")
            health_status["process_count"] = process_count.strip()
            
            # Overall health assessment
            var issues = 0
            if health_status.get("responsive", "") != "true":
                issues += 1
            if health_status.get("battery_status", "") == "low":
                issues += 1
            if health_status.get("storage_status", "") != "ok":
                issues += 1
            
            if issues == 0:
                health_status["overall_health"] = "good"
            elif issues == 1:
                health_status["overall_health"] = "fair"
            else:
                health_status["overall_health"] = "poor"
                
        except e:
            health_status["error"] = str(e)
            health_status["overall_health"] = "unknown"
        
        return health_status