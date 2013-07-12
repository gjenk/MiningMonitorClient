# push.rb queries the local CGMiner software and pushes the json
# recieved to the Heroku web server using a PUT
#
# push.rb can take an optional argument which is the command sent to the
# CGMiner. If no command is given, it defaults to "summary"

require 'socket'
require 'rest_client'
require 'json'

user = ARGV[0]
worker = ARGV[1]

worker_user_name = "#{user}:#{worker}"

s = TCPSocket.new '192.168.1.100', 4028
s.puts '{"command":"summary"}'
summary_query = s.gets

s = TCPSocket.new '192.168.1.100', 4028
s.puts '{"command":"pools"}'
pools_query = s.gets

s = TCPSocket.new '192.168.1.100', 4028
s.puts '{"command": "devs"}'
dev_query = s.gets
dev_query.strip!

parsed = JSON.parse dev_query
devs = parsed["DEVS"]
gpuinfo = []
devs.length.times do |n|
   gpuinfo << devs[n]["Temperature"]
   gpuinfo << devs[n]["MHS 5s"]
end

summary_query.strip! 
parsed = JSON.parse(summary_query)
summary = parsed["SUMMARY"]
summary = summary[0]
hashrate = summary["MHS av"]
accepted = summary["Accepted"]
rejected = summary["Rejected"]
hw_errors = summary["Hardware Errors"]

pools_query.strip!
parsed = JSON.parse(pools_query)
pool = parsed["POOLS"]

gpucount = gpuinfo.length/2

pool1 = pool[0]
pool1active = (pool1["Status"] == "Alive")
pool1name = pool1["URL"]
pool1mining = pool1["Stratum Active"]

if pool.length > 1
    pool2 = pool[1]
    pool2name = pool2["URL"]
    pool2active = (pool2["Status"] == "Alive")
    pool2mining = pool2["Stratum Active"] 
end

updateinfo = { worker_user_name: worker_user_name, hashrate: hashrate, accepted: accepted, rejected: rejected, hw_errors: hw_errors, num_gpu: gpucount, pool1name: pool1name, pool1active: pool1active, pool1mining: pool1mining, gpus: gpuinfo }
puts updateinfo
if pool2 != nil
    updateinfo[:pool2name] = pool2name
    updateinfo[:pool2active] = pool2active
    updateinfo[:pool2mining] = pool2mining
end
path = "/workers/update"
host = "https://miningmonitor.herokuapp.com"

puts "sending data to #{host}#{path}"

puts RestClient.put "#{host}#{path}", updateinfo, {:content_type => :json} 
