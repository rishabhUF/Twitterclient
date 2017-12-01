defmodule Twitterclient do
  use GenServer
  alias Twi.User
  alias Twi.Server

  def main do
    ip=get_server_ip_address()
    Node.start(:"client@#{ip}")
    Node.set_cookie(:"client@#{ip}", :"twiserver")
    GenServer.start_link(Twitterclient, [], name: Client)
    case Node.connect(:"rishabh@#{ip}") do
      true -> IO.puts "here"
      reason ->
        IO.puts "Could not connect to server, reason: #{reason}"
        System.halt(0)    
    end
    :global.sync()
    :global.registered_names
    pid = :global.whereis_name(:mainserver)
   pid
  IO.puts "global registered"
  username = "ris"
  password = "r"
  user = %User{username: username |> String.to_atom, password: password, online: true}
  GenServer.cast(pid,{:register,user})  


  end

def register(username,password \\"") do
    IO.puts "#{username}"
    user = %User{username: username |> String.to_atom, password: password, online: true}
    GenServer.cast(Twi, {:register, user})
end
  def get_server_ip_address() do
    {:ok, ifs} = :inet.getif()
    {a,b,c,d} =
        Enum.filter(ifs , fn({{ip, _, _, _} , _t, _net_mask}) -> ip != 127 end)
        |> Enum.map(fn {ip, _broadaddr, _mask} -> ip end)
        |>List.last
    "#{a}.#{b}.#{c}.#{d}"        
  end       
end


