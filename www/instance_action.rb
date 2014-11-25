#!/usr/bin/ruby
require_relative "../common"

post_only!

print "Content-Type: text/plain\n\n"

case $cgi["action"]
when "ACPI Reboot"
  puts `virsh reboot --domain #{id_param} --mode acpi`
when "Hard Reset"
  puts `virsh reset --domain #{id_param}`
end

# print "Status: 302\n"
# print "Location: /instance.rb?id=#{id_param}\n\n"
