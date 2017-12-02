defmodule Twitterclient do
  use GenServer
  alias Twi.User
  alias Twi.Server
  alias Twi.Instance

  
  # ________________________________________________
  # CONNECTION TO MAINSERVER
  # ________________________________________________
  def main(args) do
    if List.first(args) == "" do
      IO.puts "Please enter the arguments"
    else

      numberOfUsers = args |> Enum.at(0) |> String.to_integer
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

      ## Simulate Register users
      factor1_=numberOfUsers
      startTime = System.os_time()
      for x <- 0..factor1_ do
        register("#{x}","rr")
      end
      endtime = System.os_time()
      totalTime = endtime - startTime
      IO.puts "#{factor1_} Users registered in Time : #{totalTime} microseconds"

      # Simulate Active users following activity
      rangeFactor1_=numberOfUsers*0.4 |> round
      rangeFactor2_=numberOfUsers*0.6 |> round
      factor1_=100
      startTime = System.os_time()
      for y <-rangeFactor1_..rangeFactor2_ do
        for x <- 0..factor1_ do
          follow("#{x}","#{y}")
        end
      end
      endtime = System.os_time()
      totalTime = endtime - startTime
      range_=rangeFactor2_-rangeFactor1_
      combinations_=range_*factor1_
      IO.puts "#{range_} Users interacting in #{combinations_} combinations : followed in Time : #{totalTime} microseconds"


      # Simulate Passive users following activity
      rangeFactor1_=1
      rangeFactor2_=numberOfUsers*0.39 |> round
      factor1_=70
      startTime = System.os_time()
      for y <-rangeFactor1_..rangeFactor2_ do
        for x <- 0..factor1_ do
          follow("#{x}","#{y}")
        end
      end
      endtime = System.os_time()
      totalTime = endtime - startTime
      range_=rangeFactor2_-rangeFactor1_
      combinations_=range_*factor1_
      IO.puts "#{range_} Users interacting in #{combinations_} combinations : followed in Time : #{totalTime} microseconds"
    


      #Simulate tweets for active users
      rangeFactor1_=numberOfUsers*0.4 |> round
      rangeFactor2_=numberOfUsers*0.6 |> round
      factor1_=200
      factor2_=100

      startTime = System.os_time()
      for y <-rangeFactor1_..rangeFactor2_ do
        for x <- 0..factor1_ do
          add_tweet("#{y}","#{y} Sent a tweet number #{x}")
        end
      end
      endtime = System.os_time()
      totalTime = endtime - startTime
      range_=rangeFactor2_-rangeFactor1_
      combinations_=range_*factor1_*factor2_
      IO.puts "#{range_} Users sending tweets in #{combinations_} combinations : followed in Time : #{totalTime} microseconds"
    
      #Simulate tweets for passive users
      rangeFactor1_=1
      rangeFactor2_=numberOfUsers*0.39 |> round
      factor1_=10
      factor2_=70

      startTime = System.os_time()
      for y <-rangeFactor1_..rangeFactor2_ do
        for x <- 0..factor1_ do
          add_tweet("#{y}","#{y} Sent a tweet number #{x}")
        end
      end
      endtime = System.os_time()
      totalTime = endtime - startTime
      range_=rangeFactor2_-rangeFactor1_
      combinations_=range_*factor1_*factor2_
      IO.puts "#{range_} Users sending tweets in #{combinations_} combinations : followed in Time : #{totalTime} microseconds"
    
    end
  end

  def get_server_ip_address() do
    {:ok, ifs} = :inet.getif()
      {a,b,c,d} =
        Enum.filter(ifs , fn({{ip, _, _, _} , _t, _net_mask}) -> ip != 127 end)
        |> Enum.map(fn {ip, _broadaddr, _mask} -> ip end)
        |>List.last
      "#{a}.#{b}.#{c}.#{d}"        
    end      


  # ________________________________________________
  # FUNCTIONALITIES FOR USER
  # ________________________________________________

  def register(username,password \\"") do
      pid = :global.whereis_name(:mainserver)
      # IO.puts "#{username}"
      user = %User{username: username |> String.to_atom, password: password, online: true}
      GenServer.cast(pid, {:register, user})
  end

def login(username,password) do
  pid = :global.whereis_name(:mainserver)
  reply = GenServer.call(pid,{:login,username,password})
  
end
def logout(username) do
  pid = :global.whereis_name(:mainserver)
  reply = GenServer.call(pid,{:logout,username})
  
end

def add_tweet(username,tweet) do
  pid = :global.whereis_name(:mainserver)
  #reply = GenServer.call(pid,{:login,username,password})
  reply =  GenServer.call(pid,{:find_add_tweet,username,tweet})  
end

def follow(username,to_follow) do
  pid= :global.whereis_name(:mainserver)
  reply = GenServer.call(pid,{:follow_user,username,to_follow})
end

def retweet(username,tweet) do
  pid= :global.whereis_name(:mainserver)
  reply = GenServer.call(pid,{:retweet,username,tweet})
end

  # ________________________________________________
  # CLIENT QUERY COMMANDS
  # ________________________________________________


def fetch_mention(username) do
  pid= :global.whereis_name(:mainserver)
  reply = GenServer.call(pid,{:fetch_mention,username})
end

def fetch_hashtags(hashtag) do
  # Fetches hastags for user who are not online. Based on twitter functionality
  pid= :global.whereis_name(:mainserver)
  reply = GenServer.call(pid,{:fetch_hashtags,hashtag})
end

def fetch_userHomepage(username) do
  pid= :global.whereis_name(:mainserver)
  reply = GenServer.call(pid,{:fetch_userHomepage,username})
end

 
end
