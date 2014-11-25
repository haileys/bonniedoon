require "cgi"
require "erb"
require "socket"

$cgi = CGI.new

HOSTNAME = Socket.gethostname

def h(str)
  CGI.escapeHTML(str.to_s)
end

def id_param
  $cgi["id"].to_i
end

def post_only!
  if ENV["REQUEST_METHOD"] != "POST"
    render <<-HTML, :status => 405
      <h1>nope</h1>
    HTML
    exit
  end
end

def render(erb, vars = {})
  if status = vars.delete(:status)
    print "Status: #{status}\n"
  end

  print "Content-Type: text/html\n\n"

  ctx = Object.new

  vars.each do |k, v|
    ctx.instance_variable_set("@#{k}", v)
  end

  print ERB.new(erb).result(ctx.instance_eval { binding })
end
