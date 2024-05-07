import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

// Model University merepresentasikan sebuah universitas dengan properti nama dan website.
class University {
  String name; // Nama universitas
  String website; // Website universitas

  // Konstruktor untuk inisialisasi objek University.
  University({required this.name, required this.website});

  // Fungsi factory untuk membuat objek University dari data JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Mendapatkan nama universitas dari data JSON.
      website: json['web_pages'][0], // Mendapatkan website universitas dari data JSON.
    );
  }
}

// UniversityCubit adalah Cubit yang mengelola keadaan daftar universitas.
class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit() : super([]); // Konstruktor untuk inisialisasi dengan daftar kosong.

  // Fungsi asinkron untuk mengambil daftar universitas berdasarkan negara dari API.
  Future<void> fetchUniversities(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country"; // URL API dengan parameter negara.
    final response = await http.get(Uri.parse(url)); // Melakukan permintaan HTTP GET.

    if (response.statusCode == 200) { // Jika permintaan berhasil.
      List<dynamic> data = jsonDecode(response.body); // Mendekode respons JSON menjadi daftar dinamis.
      List<University> universities = data.map((json) => University.fromJson(json)).toList(); // Mengonversi data JSON menjadi objek University.
      emit(universities); // Memancarkan daftar universitas ke dalam keadaan.
    } else { // Jika permintaan gagal.
      throw Exception('Failed to load universities'); // Melemparkan pengecualian dengan pesan kesalahan.
    }
  }
}

// MyApp adalah StatefulWidget utama yang membangun tampilan aplikasi.
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // Membuat dan mengembalikan objek state untuk MyApp.
  }
}

// MyAppState mengelola keadaan dan tampilan aplikasi.
class MyAppState extends State<MyApp> {
  late UniversityCubit _universityCubit; // Objek Cubit untuk mengelola daftar universitas.
  late String _selectedCountry; // Variabel untuk menyimpan negara yang dipilih dari dropdown.

  @override
  void initState() {
    super.initState();
    _universityCubit = UniversityCubit(); // Inisialisasi objek UniversityCubit.
    _selectedCountry = 'Indonesia'; // Mengatur negara default yang dipilih.
    _universityCubit.fetchUniversities(_selectedCountry); // Memuat daftar universitas untuk negara default.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Universitas',
      home: Scaffold(
        appBar: AppBar(
          title: Text('List Universitas'),
        ),
        body: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCountry,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCountry = newValue; // Mengubah negara yang dipilih.
                  });
                  _universityCubit.fetchUniversities(newValue); // Memuat daftar universitas untuk negara yang baru dipilih.
                }
              },
              items: <String>[
                'Indonesia',
                'Malaysia',
                'Singapore',
                'Vietnam', // Tambahkan Vietnam
                'Thailand' // Tambahkan Thailand
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: BlocBuilder<UniversityCubit, List<University>>(
                bloc: _universityCubit,
                builder: (context, universities) {
                  if (universities.isNotEmpty) {
                    return ListView.builder(
                      itemCount: universities.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(universities[index].name),
                          subtitle: Text(universities[index].website),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
