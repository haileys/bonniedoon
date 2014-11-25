#!/usr/bin/ruby
require_relative "../common"
require "securerandom"

ppm_path = "/tmp/instance-screenshot-#{SecureRandom.hex(16)}.ppm"
png_path = "/tmp/instance-screenshot-#{SecureRandom.hex(16)}.png"

`virsh screenshot --domain #{id_param} --file #{ppm_path}`
`convert #{ppm_path} #{png_path}`

print "Content-Type: image/png\n\n"
print File.read(png_path)

File.delete(ppm_path)
File.delete(png_path)
