# times

## Models

Post: String author, Date time, String text

Comment: String author, Date time, String text

## APIs

```http
GET /api/version -> version

GET /api/ -> num_posts
GET /api/<nth>/ -> Post
GET /api/<nth>/views -> num_views
GET /api/<nth>/comments/ -> [Comment
POST /api/<nth>/comment/<author> body=<text> -> new_len
GET /api/<nth>/comments/len -> num_comments

DELETE /api/pop/ (auth) -> new_len
POST /api/<author>/ body=<text> (auth) -> new_len
```

## Extra

数据库不使用，采用每次启动读取数据每次退出序列化数据的方式 🌚

WebSocket 在文章被回复的时候发送文章索引。

SIGQUIT: output data and exit

SIGUSR1: output data

SIGUSR2: clear anti-spam log

## Installation

```bash
crystal build -s -p --release src/times.cr
./times dolphins &
```

## Usage

`timelinerd <password>`

## Contributing

1. [Fork it](https://github.com/geekapk/times/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[duangsuse]](https://github.com/duangsuse) duangsuse - creator, maintainer
