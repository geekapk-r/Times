require "kemal"
require "kemal/websocket"

require "./times/*"

PASS      = ARGV[0] || "dolphins"
POSTS     = {Int16 => Post}
POSTS_LEN = 0i16
SOCKS     = Set(HTTP::WebSocket).new

class Post
  def initialize(author, text)
    @author : String
    @data : Time
    @text : String
    @comments = Set(Comment).new
  end
end

class Comment
  def initialize(author, text)
    @author : String = author
    @text : String = text
    @date : Time = Time.now
  end
end

# Simple news server with coments&views
module Times
  # Views
  get "/" do
    render "src/views/index.ecr"
  end

  get "/m" do |env|
    pass = env.request.headers["pass"]
    halt env, 403, "Auth Failed" if pass != PASS
    render "src/views/admin.ecr"
  end

  get "/:nth" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
    post = POSTS[nth]
    halt env, 404, "Post Not Found" if post.nil?
    render "src/views/post.ecr"
  end

  get "/:nth/comments" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
    post = POSTS[nth]
    halt env, 404, "Post Not Found" if post.nil?
    render "src/views/comments.ecr"
  end

  # APIs
  get "/api/version" do
    VERSION
  end

  get "/api" do
    POSTS_LEN
  end

  get "/api/:nth" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  get "/api/:nth/views" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  get "/api/:nth/comments" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  get "/api/:nth/comments/len" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  post "/api/:nth/comment/:author" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
    author : String = env.params.url["nth"]
  end

  delete "/api/pop" do |env|
    pass = env.request.headers["pass"]
  end

  post "/api/post/:author" do |env|
    pass = env.request.headers["pass"]
    author = env.params.url["author"]
  end

  ws "/" do |socket|
    SOCKS.add socket
  end
end

serve_static false
Kemal.run
