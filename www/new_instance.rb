#!/usr/bin/ruby
require_relative "../common"

install_cds = Dir["/usr/local/share/isos/*.iso"].map { |file| File.basename(file) }

errors = []

if ENV["REQUEST_METHOD"] == "POST"
  name = $cgi["name"]
  memory = $cgi["memory"].to_i
  disk = $cgi["disk"].to_i
  install_cd = $cgi["install_cd"]

  errors << "Name must be between 3 and 32 chars long" unless (3..32).cover? name.size

  errors << "Name contains invalid characters. Please only use letters, numbers and hyphens." if name =~ /[^a-z0-9\-]/

  errors << "Memory must be between 256 and 8192 megabytes" unless (256..8192).cover? memory

  errors << "Disk must be between 1 and 500 megabytes" unless (1..500).cover? disk

  errors << "Install CD is not valid" unless install_cds.include? install_cd
end

if ENV["REQUEST_METHOD"] == "GET" || errors.any?
  render <<-HTML, :errors => errors, :install_cds => install_cds, :name => name, :memory => memory, :disk => disk, :install_cd => install_cd
    <title>New instance - Bonniedoon</title>
    <h2>New instance</h2>
    <% if @errors.any? %>
      <ul>
        <% @errors.each do |error| %>
          <li><%= error %></li>
        <% end %>
      </ul>
    <% end %>
    <form method="POST" action="/new_instance.rb">
      <table>
        <tr><td>Name:</td><td><input name="name" value="<%= h @name %>"></td></tr>
        <tr><td>Memory (in MB):</td><td><input name="memory" value="<%= h @memory %>"></td></tr>
        <tr><td>Disk (in GB):</td><td><input name="disk" value="<%= h @disk %>"></td></tr>
        <tr>
          <td>Install CD:</td>
          <td>
            <select name="install_cd">
              <% @install_cds.each do |iso| %>
                <option <%= iso == @install_cd ? "selected" : "" %>><%= iso %></option>
              <% end %>
            </select>
          </td>
        </tr>
      </table>
      <br>
      <br>
      <input type="submit" value="Create instance">
    </form>
  HTML
  exit
end

vg = "#{Socket.gethostname}-vg"

output = `sudo lvcreate -L#{disk}G -n#{name} #{vg} 2>&1`

if !$?.success?
  render <<-HTML, :output => output
    <h2>Could not create LVM volume</h2>
    <pre><%= h @output %></pre>
  HTML
  exit
end

output = `sudo virt-install -n #{name} -r #{memory} -f /dev/mapper/#{vg.gsub("-", "--")}-#{name.gsub("-", "--")} --accelerate --graphics vnc --noautoconsole -v --network bridge:br0 --cdrom /usr/local/share/isos/#{install_cd} --vcpus sockets=1,cores=4,threads=2 2>&1`

if !$?.success?
  # couldn't create the vm, delete the LVM volume
  `sudo lvremove -f /dev/#{vg}/#{name}`
end

render <<-HTML, :output => output
  <pre><%= h @output %></pre>
  <a href="/">Back to instance list</a>
HTML
