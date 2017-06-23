require 'mysql2'

config = {
  db: {
    host:     ENV['ISUCONP_DB_HOST'] || 'localhost',
    port:     ENV['ISUCONP_DB_PORT'] && ENV['ISUCONP_DB_PORT'].to_i,
    username: ENV['ISUCONP_DB_USER'] || 'root',
    password: ENV['ISUCONP_DB_PASSWORD'],
    database: ENV['ISUCONP_DB_NAME'] || 'isuconp',
  },
}

db = Mysql2::Client.new(
  host: config[:db][:host],
  port: config[:db][:port],
  username: config[:db][:username],
  password: config[:db][:password],
  database: config[:db][:database],
  encoding: 'utf8mb4',
  reconnect: true,
)
db.query_options.merge!(symbolize_keys: true, database_timezone: :local, application_timezone: :local)
Thread.current[:isuconp_db] = db

db.query("select id, imgdata, mime from posts order by id asc").to_a.each do |post|
  ext = post[:mime].split('/')[1]
  dist = "../public/image/#{post[:id]}.#{ext}"
  File.write(dist, post[:imgdata]) unless File.exist?(dist)
end
