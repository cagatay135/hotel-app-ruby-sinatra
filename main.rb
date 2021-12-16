require "sinatra"
require 'sinatra/reloader' if development?
require 'sqlite3'


@db = SQLite3::Database.open 'test.db'
@db.execute "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTOINCREMENT,username TEXT , email TEXT , password TEXT)"
@db.execute "CREATE TABLE IF NOT EXISTS room(id INTEGER PRIMARY KEY AUTOINCREMENT,statu TEXT , fiyat INT , boyut INT , kapasite INT , servisler TEXT , gunler TEXT)"


$username=""

get "/" do
  @username=$username
  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room"
  erb :index
end

get '/register' do
  @msg = "MAİL"
  @username=$username
  erb :register
end

get '/login' do
  erb :login
end

get '/about' do
  @username=$username
  erb :about
end

get '/contact' do
  @username=$username
  erb :contact
end

get '/admin' do
  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room"
  erb:admin
end

get '/adminekle' do
  erb:adminadd
end

get '/adminsil' do
  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room"
  erb:admindelete
end

get '/room' do
  @username=$username

  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room"
  @querylength = @query.length
  erb :room
end

get '/tek' do
  @username=$username

  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room WHERE statu='#{'Tek Oda'}'"
  @querylength = @query.length
  erb :room
end

get '/aile' do
  @username=$username

  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room WHERE statu='#{'Aile Odası'}'"
  @querylength = @query.length
  erb :room
end

get '/premium' do
  @username=$username

  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room WHERE statu='#{'Premium Oda'}'"
  @querylength = @query.length
  erb :room
end

get '/detail/:id' do
  @username=$username
  id=params[:id]
  puts id
  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room WHERE id='#{id}'"
  erb :detail
end

post '/uygunluk' do
  datein=params['date-in']
  dateout=params['date-out']

  @db = SQLite3::Database.open 'test.db'

end

post '/register' do
  isim=params['name']
  mail=params['email']
  sifre=params['password']

  @db = SQLite3::Database.open 'test.db'
  query = @db.execute "SELECT * FROM user WHERE email=\"#{mail}\""
  if query.length > 0
    @msg = "BU Mail Adresi Kullanımda"
    erb :register
  else
  @db.execute "INSERT INTO user (username , email , password) VALUES ('#{isim}' , '#{mail}' , '#{sifre}')"
  redirect '/login'
  end
end

post '/login' do
  mail=params['email']
  password=params['password']

  @db = SQLite3::Database.open 'test.db'
  query = @db.execute "SELECT * FROM user WHERE email=\"#{mail}\" AND password=\"#{password}\""
  puts query.length
  if query.length > 0

    $username=query[0][0]
    puts "Giriş Başarılı"
    redirect '/'
  else 
    erb:login
  end
end

post '/mailat' do
require 'mail'

name=params['name']
surname=params['surname']
subject=params['subject']
mail=params['mail']
message=params['message']


options = { :address              	  => "smtp.gmail.com",
                :port                 => 587,
                :user_name            => 'cagatayrubyproject@gmail.com',
                :password             => 'Qweasd12',
                :authentication       => 'plain',
                :enable_starttls_auto => true  }

Mail.defaults do
      delivery_method :smtp, options
end

Mail.deliver do
      to 'cagatayrubyproject@gmail.com'
      from 'cagatayrubyproject@gmail.com'
      mesaj = "Adı : " + name + "\n" + "Soyadı : " + surname + "\n" + "Mail : " + mail + "\n" + "Konu : " + subject + "\n" + "Mesaj : " + message + "\n"
      subject subject
      body mesaj
end
redirect '/contact'
end

post "/search" do
  @username=$username
  giris=params['giris']
  cikis=params['cikis']

  @db = SQLite3::Database.open 'test.db'
  @query1 = @db.execute "SELECT * FROM room WHERE gunler LIKE '%#{giris}%'"
  @query2 = @db.execute "SELECT * FROM room WHERE gunler LIKE '%#{cikis}%'"

  if  @query1.length > 0 || @query2.length > 0
    redirect "/"   
  else
    @query = @db.execute "SELECT * FROM room"
    @querylength = @query.length

    erb:room
  end
end

post "/rightsearch" do
  @username=$username
  ad=params['ad']

  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "SELECT * FROM room WHERE ad LIKE '%#{ad}%'"

  @querylength = @query.length
  if  @query.length > 0 
    erb:room
  else
    redirect "/"
  end
end

post "/ekle" do
  statu=params['statu']
  isim=params['otelisim']
  fiyat=params['fiyat']
  boyut=params['boyut']
  kapasite=params['kapasite']
  servisler=params['servisler']
  link=params['link']
  aciklama=params['aciklama']

  fiyat = fiyat.to_i
  boyut = boyut.to_i
  kapasite = kapasite.to_i
  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "INSERT INTO room (statu , ad , fiyat , boyut , kapasite , servisler , aciklama , link) VALUES('#{statu}' , '#{isim}' , #{fiyat} , #{boyut} , #{kapasite} , '#{servisler}' , '#{aciklama}' , '#{link}')"

  @querylength = @query.length
  if  @query.length > 0 
    redirect "/adminekle"
  else
    redirect "/adminekle"
  end
end

not_found do
  status 404
  erb :oops
end

post '/delete' do
  id=params[:id]
  @db = SQLite3::Database.open 'test.db'
  @query = @db.execute "DELETE FROM room WHERE id=(\"#{id}\")"
  redirect 'adminsil'
end