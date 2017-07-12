#!/usr/bin/env ruby
# encoding: utf-8

# This was never intended for production
# Still a work in progress
require 'ostruct'
require 'socket'
require 'securerandom'

# These are gems that the program depends on
begin
  require 'system'
  require 'system/getifaddrs'
  require 'enum'
rescue LoadError=>Error
  puts("The following error occured, #{Error}")
end

# The family of protocols: Socket::PF_INET, Socket::PF_INET6, Socket::PF_UNIX
# Usuaully you'll need  Socket::SOCK_STREAM or Socket::SOCK_DGRAM

##########################
# Set up Networking Data #
##########################

# These is information on our machine
Local_Addresses = System.get_all_ifaddrs
# This is a list of the URL's the user wishes to connect to
Remote_Addresses = []

##################
# Set up Classes #
##################

# This simple error class will help us give more specific exceptions
class Socket_Creation_Error < StandardError
end

class Socket_Options_Error < Socket_Creation_Error
end

class Socket_Options < Enum
  private
  enum %w(UDP TCP '0' Default)
end

class Client
  private
  # ip and hostname are values of the machine you are connecting to
  def initialize(ip='127.0.0.1', hostname='', port=80, protocol=0, ipv6=false)
    @ip = ip
    @hostname = hostname
    @port = port
    @protocol = protocol
    @ipv6 = ipv6
    
    if not_in(@protocol, Socket_Options.values) 
      raise SocketError("The input for protocol given was invalid!\nPlease use: #{Socket_Options.values}")
    end
    
    if @protocol == 'TCP'
      @sock = TCPSocket.new(@ip, @sport)
      @sock.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)

    # 0 means 'default' protocol, which can vary to different protocols.
    elif (@protocol == 0) | (@protocol == 'Default')
      @sock = Socket.new(Socket::PF_INET, Socket::SOCK_DGRAM, 0)
      @sock.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)

    elif @protocol == 'UDP'  
      if @ipv6 == true
        @sock = UDPSocket.new(Socket::AF_INET6).ipv6only!
        @sock.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)

      else
        @sock = UDPSocket.new(Socket::AF_INET)
        @sock.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)

    else
      raise Socket_Options_Error("The input for protocol given was invalid!\nPlease use: #{Socket_Options.values}")
    end
  end
  
  def connect(ip)
    begin
      if (@protocol == 'Default') | (@protocol == 0)
        @sock.connect(Socket.pack_sockaddr_in(port, ip))
        @sock.sync
      elif @protocol = 'TCP'
        @sock.connect(Socket.pack_sockaddr_in(port,ip))
        @sock.sync
      end
    rescue Errno::ECONNREFUSED
      puts("Connection has been refused")
    end
  end
  def read
    data = @sock.recvfrom(1600)
    data_read = @sock.read(1600)
    
    if data
      peername = @sock.getpeername
      peerid = @sock.getpeereid
      @sock.sync  
      
      return data, data_read
  end
  
  def 
  
  def write(data)
    if data
      @sock.write(data)
    @sock.close_write
  end
  
  def 
  
  end
  
end
