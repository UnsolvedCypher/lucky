require "../spec_helper"

include ContextHelper

describe Lucky::RemoteIpHandler do
  describe "getting the remote_address" do
    it "returns nil when no remote IP is found" do
      context = build_context(path: "/path")

      run_remote_ip_handler(context)
      context.request.remote_address.should eq nil
    end

    it "returns the X_FORWARDED_FOR address" do
      headers = HTTP::Headers.new
      headers["X_FORWARDED_FOR"] = "1.2.3.4,127.0.0.1"
      request = HTTP::Request.new("GET", "/remote-ip", body: "", headers: headers)
      context = build_context(request)

      run_remote_ip_handler(context)
      context.request.remote_address.should eq "1.2.3.4"
    end

    it "returns nil if the X_FORWARDED_FOR is an empty string, and no default remote_address is found" do
      headers = HTTP::Headers.new
      headers["X_FORWARDED_FOR"] = ""
      request = HTTP::Request.new("GET", "/remote-ip", body: "", headers: headers)
      context = build_context(request)

      run_remote_ip_handler(context)
      context.request.remote_address.should eq nil
    end

    it "returns the original remote_address" do
      request = HTTP::Request.new("GET", "/remote-ip", body: "", headers: HTTP::Headers.new)
      request.remote_address = "255.255.255.255"
      context = build_context(request)

      run_remote_ip_handler(context)
      context.request.remote_address.should eq "255.255.255.255"
    end
  end
end

private def run_remote_ip_handler(context)
  handler = Lucky::RemoteIpHandler.new
  handler.next = ->(_ctx : HTTP::Server::Context) {}
  handler.call(context)
end
