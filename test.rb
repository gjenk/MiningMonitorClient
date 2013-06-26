#Testing if querying cgminer too often causes problems for cgminer
#This test file queries the miner every minute for 100 minutes

i = 0
while( i < 101)
    puts "Testing if querying cgminer every minute causes cgminer to crash"
    s = TCPSocket.new '192.168.1.100', 4028
    s.puts '{"command":"summary"}'
    summary_query = s.gets
    s.close
    parsed = JSON.parse(summary_query.strip!)
    status = parsed["STATUS"]
    status = status[0]
    status = ['Status']
    #check for the correct status

    s = TCPSocket.new '192.168.1.100', 4028
    s.puts '{"command":"gpucount"}'
    gpucount_query = s.gets
    s.close
    parsed = JSON.parse(gpucount_query.strip!)
    status = parsed["STATUS"]
    status = status[0]
    status = ['Status']
    #check for the correct status 

    s = TCPSocket.new '192.168.1.100', 4028
    s.puts '{"command":"pools"}'
    pools_query = s.gets
    s.close
    parsed = JSON.parse(pools_query.strip!) 
    status = parsed["STATUS"]
    status = status[0]
    status = ['Status']
    #check for the correct status 

    i++
    sleep(60)
end

