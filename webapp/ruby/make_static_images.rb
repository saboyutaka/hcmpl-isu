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

db.query("select id from posts order by id").to_a.each do |p|
  print '.'
  id = p[:id]
  post = db.query("select imgdata, mime from posts where id = #{id} limit 1").first
  ext = post[:mime].split('/')[1]
  ext = 'jpg' if ext == 'jpeg'
  dist = "../public/image/#{id}.#{ext}"
  File.write(dist, post[:imgdata]) unless File.exist?(dist)
end
puts ''
puts 'finished.'

