#!/usr/bin/ruby
require_relative "../common"

dominfo = `virsh dominfo #{id_param}`.strip

if dominfo.empty?
  render <<-HTML, :status => 404
    <h2>Instance not found</h2>
    <a href="/">Back to instance list</a>
  HTML
  exit
end

/^Name:(\s+)(?<instance_name>.+)$/ =~ dominfo

render <<-HTML, :instance_id => id_param, :instance_name => instance_name, :dominfo => dominfo
  <title><%= h @instance_name %> - Bonniedoon</title>
  <a href="/">Back to instance list</a>
  <h2><%= h @instance_name %></h2>
  <pre><%= h @dominfo %></pre>
  <form method="post" action="/instance_action.rb">
    <input type="hidden" name="id" value="<%= @instance_id %>">
    <input type="submit" name="action" value="ACPI Reboot">
    <input type="submit" name="action" value="Hard Reset">
  </form>
  <hr>
  <img src="/instance_screenshot.rb?id=<%= @instance_id %>" name="screenshot">
  <script>
    // var origImageUrl = document.images.screenshot.src;
    // setInterval(function() {
    //   document.images.screenshot.src = origImageUrl + "&" + (+new Date);
    // }, 2000);
  </script>
HTML
