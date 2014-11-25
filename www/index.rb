#!/usr/bin/ruby
require_relative "../common"

instances = `virsh list --all`.strip.lines.drop(2).map { |l| l.strip.split(" ", 3) }

render(<<-HTML, :instances => instances)
  <title><%= h HOSTNAME %> - Bonniedoon</title>
  <h2>Instances on <%= h HOSTNAME %></h2>
  <ul>
    <% @instances.each do |id, name, state| %>
      <li><a href="/instance.rb?id=<%= h id %>"><%= h name %></a> (<%= h state %>)</li>
    <% end %>
  </ul>
HTML
