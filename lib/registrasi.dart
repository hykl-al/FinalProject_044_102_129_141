import 'package:bmkg_fix/login.dart';
import 'package:flutter/material.dart';
import 'package:bmkg_fix/page/page_home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrasiPage extends StatefulWidget {
  @override
  _RegistrasiPageState createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  // Fungsi untuk registrasi dengan Supabase
  Future<void> register(String email, String password) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Menggunakan Supabase untuk mendaftar pengguna baru
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      // Memeriksa apakah registrasi berhasil
      if (response.user != null) {
        // Navigasi ke halaman Home setelah berhasil registrasi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi gagal. Coba lagi!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrasi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      register(
                        _emailController.text,
                        _passwordController.text,
                      );
                    },
                    child: Text('Registrasi'),
                  ),
          ],
        ),
      ),
    );
  }
}
