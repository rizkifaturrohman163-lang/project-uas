import 'package:apk_stokked/db_helper.dart';
import 'package:apk_stokked/main_page.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;

  //controllers:
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _konfirmasi_password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            vertical: 70,
            horizontal: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'images/images3.jpeg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 25),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Selamat Datang",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Silahkan masuk unruk mengelola stok kedelai",
                  style: TextStyle(fontSize: 15, color: (Colors.grey)),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),

              //kolom konfirmasi password (jika bukan login)
              if (isLogin == false) ...[
                SizedBox(height: 20),
                TextField(
                  controller: _konfirmasi_password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Center(child: Text(isLogin ? 'Login' : 'Daftar')),
                onPressed: () async {
                  DbHelper _db = DbHelper();
                  if (isLogin) {
                    //logika untuk login:
                    bool loginSukses = await _db.checkLogin(
                      _username.text,
                      _password.text,
                    );
                    if (loginSukses) {
                      // masuk ke halaman utama
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainPage(),
                        ),
                      );
                    } else {
                      //tampilkan pesan username/password salah
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Username/Password salah'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    //logika untuk registrasi:
                    if (_password.text == _konfirmasi_password.text &&
                        _username.text.isNotEmpty) {
                      await _db.register(_username.text, _password.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Registrasi berhasil! Anda sudah bisa login',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      //kembali ke mode login
                      setState(() {
                        isLogin = true;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Registrasi Gagal! Pastikan Nama & Password sesuai ketentuan',
                          ),
                          backgroundColor: Colors.redAccent,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 5),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Center(
                  child: Text(
                    isLogin
                        ? 'Belum punya akun? Daftar'
                        : 'Sudah punya akun? Login',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
