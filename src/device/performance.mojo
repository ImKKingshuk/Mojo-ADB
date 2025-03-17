# MojoADB: Device Performance Module

from core.client import ADBClient
from core.errors import ADBError
from python import Python

# Device performance monitoring
struct PerformanceMonitor:
    var client: ADBClient
    var monitoring: Bool
    var monitor_thread: PythonObject
    var callback: PythonObject
    var monitor_interval: Int
    
    fn __init__(inout self, client: ADBClient, monitor_interval: Int = 5):
        self.client = client
        self.monitoring = False
        self.monitor_thread = None
        self.callback = None
        self.monitor_interval = monitor_interval
    
    fn get_cpu_usage(self, serial: String) -> Dict[String, String]:
        """
        Get CPU usage information for the device.
        Returns a dictionary with CPU usage statistics.
        """
        var cpu_usage = Dict[String, String]()
        
        try:
            # Get CPU info
            let result = self.client.send_command("shell cat /proc/stat | grep '^cpu'")
            cpu_usage["stats"] = result.strip()
            
            # Get top processes by CPU usage
            let top_cpu = self.client.send_command("shell top -n 1 -o %CPU | head -n 10")
            cpu_usage["top_processes"] = top_cpu.strip()
            
            # Get CPU frequency
            let freq = self.client.send_command("shell cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq")
            cpu_usage["frequency"] = freq.strip()
        except e:
            cpu_usage["error"] = str(e)
        
        return cpu_usage
    
    fn get_memory_usage(self, serial: String) -> Dict[String, String]:
        """
        Get memory usage information for the device.
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
            
            # Get top processes by memory usage
            let top_mem = self.client.send_command("shell top -n 1 -o %MEM | head -n 10")
            memory_usage["top_processes"] = top_mem.strip()
        except e:
            memory_usage["error"] = str(e)
        
        return memory_usage
    
    fn get_io_stats(self, serial: String) -> Dict[String, String]:
        """
        Get I/O statistics for the device.
        Returns a dictionary with I/O statistics.
        """
        var io_stats = Dict[String, String]()
        
        try:
            # Get I/O stats
            let io_stat = self.client.send_command("shell cat /proc/diskstats")
            io_stats["diskstats"] = io_stat.strip()
            
            # Get I/O wait time
            let io_wait = self.client.send_command("shell cat /proc/stat | grep 'cpu '")
            io_stats["io_wait"] = io_wait.strip()
        except e:
            io_stats["error"] = str(e)
        
        return io_stats
    
    fn get_network_throughput(self, serial: String) -> Dict[String, String]:
        """
        Get network throughput information for the device.
        Returns a dictionary with network throughput statistics.
        """
        var network_throughput = Dict[String, String]()
        
        try:
            # Get network stats
            let net_stat = self.client.send_command("shell cat /proc/net/dev")
            network_throughput["stats"] = net_stat.strip()
            
            # Get active connections
            let connections = self.client.send_command("shell netstat -an | grep 'ESTABLISHED'")
            network_throughput["connections"] = connections.strip()
        except e:
            network_throughput["error"] = str(e)
        
        return network_throughput
    
    fn get_thermal_info(self, serial: String) -> Dict[String, String]:
        """
        Get thermal information for the device.
        Returns a dictionary with thermal statistics.
        """
        var thermal_info = Dict[String, String]()
        
        try:
            # Get thermal zones
            let thermal_zones = self.client.send_command("shell ls /sys/class/thermal/")
            thermal_info["zones"] = thermal_zones.strip()
            
            # Get temperatures for each thermal zone
            for zone in thermal_zones.split():
                if "thermal_zone" in zone:
                    let temp = self.client.send_command("shell cat /sys/class/thermal/" + zone + "/temp")
                    thermal_info[zone] = temp.strip()
        except e:
            thermal_info["error"] = str(e)
        
        return thermal_info
    
    fn start_monitoring(inout self, callback: PythonObject = None):
        """
        Start monitoring device performance metrics.
        If a callback function is provided, it will be called with performance data.
        The callback should accept one parameter: a dictionary of performance metrics.
        """
        if self.monitoring:
            return
            
        self.callback = callback
        self.monitoring = True
        
        # Create a monitoring thread using Python's threading
        threading = Python.import_module("threading")
        time = Python.import_module("time")
        
        def monitor_performance():
            while self.monitoring:
                try:
                    # Collect performance metrics
                    var metrics = Dict[String, Dict[String, String]]()
                    metrics["cpu"] = self.get_cpu_usage(self.client.serial)
                    metrics["memory"] = self.get_memory_usage(self.client.serial)
                    metrics["io"] = self.get_io_stats(self.client.serial)
                    metrics["network"] = self.get_network_throughput(self.client.serial)
                    metrics["thermal"] = self.get_thermal_info(self.client.serial)
                    
                    # Call the callback with the metrics
                    if self.callback:
                        self.callback(metrics)
                    
                    # Sleep for the monitoring interval
                    time.sleep(self.monitor_interval)
                except e:
                    print("Error in performance monitoring:", str(e))
                    time.sleep(self.monitor_interval)
        
        # Start the monitoring thread
        self.monitor_thread = threading.Thread(target=monitor_performance)
        self.monitor_thread.daemon = True
        self.monitor_thread.start()
        
    fn stop_monitoring(inout self):
        """
        Stop the performance monitoring thread.
        """
        if not self.monitoring:
            return
            
        self.monitoring = False
        if self.monitor_thread:
            # Wait for the thread to terminate
            time = Python.import_module("time")
            time.sleep(self.monitor_interval + 1)
            self.monitor_thread = None
    
    fn get_performance_snapshot(self, serial: String) -> Dict[String, Dict[String, String]]:
        """
        Get a snapshot of all performance metrics.
        Returns a dictionary with all performance metrics.
        """
        var snapshot = Dict[String, Dict[String, String]]()
        
        # Get CPU usage
        snapshot["cpu"] = self.get_cpu_usage(serial)
        
        # Get memory usage
        snapshot["memory"] = self.get_memory_usage(serial)
        
        # Get I/O stats
        snapshot["io"] = self.get_io_stats(serial)
        
        # Get network throughput
        snapshot["network"] = self.get_network_throughput(serial)
        
        # Get thermal info
        snapshot["thermal"] = self.get_thermal_info(serial)
        
        return snapshot