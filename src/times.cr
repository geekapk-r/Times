require "kemal"
require "kemal/websocket"

require "json"

require "./times/*"

PASS      = ARGV[0]
POSTS     = Hash(Int16, Post).new
SOCKS     = Set(HTTP::WebSocket).new
posts_len = 0i16

class Post
  @author : String
  @title : String
  @date : Time
  @text : String
  def initialize(@author : String, @title : String, @text : String)
    @comments = Set(Comment).new
    @date = Time.now
    @n_comments = 0
    @views = 0
  end

  # Get json
  def get
    JSON.build do |j|
      j.object do
        j.field "author", @author
        j.field "title", @title
        j.field "text", @text
        j.field "time", @date
        j.field "views", @views
        j.field "num_comment", @n_comments
      end
    end
    @views += 1
  end

  def author
    @author
  end

  def text
    @text
  end

  def title
    @title
  end

  def views
    @views
  end

  # Put comment
  def comment(author, text)
    @comments.add Comment.new(author, text)
    @n_comments += 1
  end

  # Get comments
  def get_comment
    JSON.build do |j|
      j.object do
        j.array do
          @comment.each do |c|
            j.object do
              j.field "author", c.author
              j.field "text", c.text
              j.field "time", c.date
            end
          end
        end
      end
    end
  end
end

class Comment
  def initialize(@author, @text)
    @author : String = author
    @text : String = text
    @date : Time = Time.now
  end
  getter author
  getter text
  getter date
end

# Simple news server with coments&views
module Times
  # Index
  get "/" do
    render "src/views/index.ecr"
  end

  # Admin console
  get "/m" do |env|
    pass = env.request.headers["pass"]
    halt env, 403, "Auth Failed" if pass != PASS
    render "src/views/admin.ecr"
  end

  # Post view
  get "/:nth" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
    post = POSTS[nth]
    halt env, 404, "Post Not Found" if post.nil?
    render "src/views/post.ecr"
  end

  # Comments view
  get "/:nth/comments" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
    post = POSTS[nth]
    halt env, 404, "Post Not Found" if post.nil?
    render "src/views/comments.ecr"
  end

  # Version
  get "/api/version" do
    VERSION
  end

  # Number of posts
  get "/api" do
    posts_len
  end

  # Get post
  get "/api/:nth" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  # Get post views
  get "/api/:nth/views" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  # Get post comments
  get "/api/:nth/comments" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  # Get post comment length
  get "/api/:nth/comments/len" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
  end

  # New comment
  post "/api/:nth/comment/:author" do |env|
    nth : Int16 = env.params.url["nth"].to_i16
    author : String = env.params.url["nth"]
  end

  # Delete lastest post
  delete "/api/pop" do |env|
    pass = env.request.headers["pass"]
  end

  # Add a post
  post "/api/post/:author/:title" do |env|
    pass = env.request.headers["pass"]
    author = env.params.url["author"]
    title = env.params.url["title"]
    halt env, 403, "Auth Failed" if pass != PASS
    post = Post.new author, title, env.request.body.to_s
    POSTS[posts_len] = post
    posts_len += 1
  end

  # Listen changes
  ws "/" do |socket|
    SOCKS.add socket
    socket.on_close do
      SOCKS.delete socket
    end
  end
end

serve_static false
Kemal.run
