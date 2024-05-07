import 'package:flutter/material.dart'; // Mengimpor paket flutter/material yang berisi widget dan fungsi yang diperlukan untuk membangun antarmuka pengguna.
import 'package:http/http.dart' as http; // Mengimpor paket http untuk melakukan permintaan HTTP dengan alias 'http'.
import 'dart:convert'; // Mengimpor paket dart:convert untuk mengonversi data dari dan ke format JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor paket flutter_bloc untuk menggunakan BLoC dalam manajemen state.

class University { // Mendefinisikan kelas model University untuk merepresentasikan entitas universitas.
  String name; // Membuat properti String bernama 'name' untuk menyimpan nama universitas.
  String website; // Membuat properti String bernama 'website' untuk menyimpan website universitas.

  University({required this.name, required this.website}); // Membuat konstruktor untuk menginisialisasi properti 'name' dan 'website' pada saat pembuatan objek University.

  factory University.fromJson(Map<String, dynamic> json) { // Membuat factory constructor untuk membuat objek University dari data JSON.
    return University(
      name: json['name'], // Mengambil nilai 'name' dari objek JSON.
      website: json['web_pages'][0], // Mengambil nilai 'web_pages' indeks ke-0 dari objek JSON untuk menyimpan website.
    );
  }
}

abstract class UniversityEvent {} // Mendefinisikan kelas abstrak UniversityEvent sebagai tipe acuan untuk event yang terjadi dalam manajemen state.

class FetchUniversities extends UniversityEvent { // Mendefinisikan kelas FetchUniversities yang merupakan subkelas dari UniversityEvent untuk mengeksekusi event mengambil data universitas.
  final String country; // Mendefinisikan properti 'country' untuk menyimpan negara yang dipilih.

  FetchUniversities(this.country); // Konstruktor untuk menginisialisasi properti 'country' saat membuat objek FetchUniversities.
}

class UniversityState { // Mendefinisikan kelas model UniversityState untuk menyimpan state aplikasi terkait universitas.
  final List<University> universities; // Properti untuk menyimpan daftar universitas.
  final bool isLoading; // Properti untuk menandakan apakah aplikasi sedang memuat data.
  final String error; // Properti untuk menyimpan pesan error jika terjadi kesalahan.
  final String selectedCountry; // Properti untuk menyimpan negara yang dipilih pada dropdown.

  UniversityState({ // Konstruktor dengan nilai default untuk properti.
    this.universities = const [], // Nilai default untuk daftar universitas adalah list kosong.
    this.isLoading = false, // Nilai default untuk isLoading adalah false.
    this.error = '', // Nilai default untuk error adalah string kosong.
    this.selectedCountry = 'Indonesia', // Nilai default untuk selectedCountry adalah 'Indonesia'.
  });

  UniversityState copyWith({ // Metode untuk menghasilkan salinan objek state dengan perubahan tertentu.
    List<University>? universities, // Parameter opsional untuk mengubah properti universities.
    bool? isLoading, // Parameter opsional untuk mengubah properti isLoading.
    String? error, // Parameter opsional untuk mengubah properti error.
    String? selectedCountry, // Parameter opsional untuk mengubah properti selectedCountry.
  }) {
    return UniversityState( // Mengembalikan objek UniversityState baru dengan properti yang diperbarui sesuai dengan nilai-nilai yang diberikan.
      universities: universities ?? this.universities, // Menggunakan nilai yang diberikan atau nilai default jika tidak ada perubahan.
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> { // Mendefinisikan kelas UniversityBloc yang merupakan turunan dari Bloc dengan tipe event UniversityEvent dan state UniversityState.
  UniversityBloc() : super(UniversityState()) { // Konstruktor untuk membuat instance UniversityBloc dengan state awal UniversityState().

    on<FetchUniversities>((event, emit) async { // Event handler untuk menangani event FetchUniversities.
      emit(state.copyWith(isLoading: true, selectedCountry: event.country)); // Mengeluarkan state baru dengan isLoading: true dan selectedCountry diperbarui menjadi negara yang dipilih.
      try {
        final response = await http.get( // Mengirim permintaan HTTP GET ke API untuk mengambil data universitas berdasarkan negara yang dipilih.
            Uri.parse('http://universities.hipolabs.com/search?country=${event.country}'));
        if (response.statusCode == 200) { // Jika respons dari permintaan berhasil (status code 200).
          List jsonResponse = json.decode(response.body); // Mendekodekan respons JSON.
          List<University> universities =
              jsonResponse.map((univ) => University.fromJson(univ)).toList(); // Mengonversi data JSON ke objek University.
          emit(state.copyWith( // Mengeluarkan state baru dengan daftar universitas yang diperbarui dan isLoading: false.
            universities: universities,
            isLoading: false,
            error: '',
          ));
        } else { // Jika respons dari permintaan gagal (status code tidak 200).
          emit(state.copyWith( // Mengeluarkan state baru dengan pesan error dan isLoading: false.
            error: 'Failed to load universities',
            isLoading: false,
          ));
        }
      } catch (e) { // Menangani kesalahan jika gagal mengambil data.
        emit(state.copyWith( // Mengeluarkan state baru dengan pesan error dan isLoading: false.
          error: 'Failed to load universities',
          isLoading: false,
        ));
      }
    });
  }
}

class MyApp extends StatelessWidget { // Mendefinisikan kelas MyApp sebagai root widget aplikasi.
  @override
  Widget build(BuildContext context) { // Metode build untuk membuat widget aplikasi.
    return BlocProvider( // Memberikan BlocProvider ke seluruh aplikasi untuk menyediakan UniversityBloc.
      create: (_) => UniversityBloc(), // Membuat instance UniversityBloc.
      child: MaterialApp( // Menggunakan MaterialApp sebagai root widget aplikasi.
        title: 'List Universities', // Judul aplikasi.
        home: UniversityList(), // Widget beranda aplikasi.
      ),
    );
  }
}

class UniversityList extends StatelessWidget { // Mendefinisikan kelas UniversityList untuk menampilkan daftar universitas.
  final List<String> countries = [ // Daftar negara-negara yang akan ditampilkan di dropdown.
    'Indonesia',
    'Malaysia',
    'Singapore',
    'Vietnam',
    'Thailand'
  ];

  @override
  Widget build(BuildContext context) { // Metode build untuk membuat widget UniversityList.
    final universityBloc = BlocProvider.of<UniversityBloc>(context); // Mendapatkan instance UniversityBloc dari BlocProvider.

    return Scaffold( // Menggunakan Scaffold sebagai kerangka tampilan.
      appBar: AppBar( // AppBar sebagai bagian atas tampilan.
        title: Text('List Universities'), // Judul AppBar.
      ),
      body: Column( // Widget utama berbentuk kolom.
        children: [
          Padding( // Widget padding untuk menambahkan ruang di sekitar widget anaknya.
            padding: EdgeInsets.all(8.0),
            child: DropdownButton<String>( // DropdownButton untuk memilih negara.
              value: context.watch<UniversityBloc>().state.selectedCountry, // Nilai dropdown sesuai dengan negara yang dipilih.
              onChanged: (newCountry) { // Event handler untuk perubahan nilai dropdown.
                universityBloc.add(FetchUniversities(newCountry!)); // Memicu event FetchUniversities dengan negara yang baru dipilih.
              },
              items: countries.map((String country) { // Membuat item-item dropdown dari daftar negara.
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
            ),
          ),
          Expanded( // Expanded untuk menyesuaikan widget dengan sisa ruang yang tersedia.
            child: BlocBuilder<UniversityBloc, UniversityState>( // BlocBuilder untuk membangun UI berdasarkan state UniversityBloc.
              builder: (context, state) { // Builder untuk membangun widget berdasarkan state.
                if (state.isLoading) { // Jika sedang memuat data, tampilkan indikator loading.
                  return Center(child: CircularProgressIndicator());
                } else if (state.error.isNotEmpty) { // Jika terjadi kesalahan, tampilkan pesan error.
                  return Center(child: Text('Error: ${state.error}'));
                } else { // Jika tidak ada kesalahan, tampilkan daftar universitas.
                  return ListView.builder(
                    itemCount: state.universities.length,
                    itemBuilder: (context, index) {
                      University university = state.universities[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(university.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(university.website),
                          onTap: () {},
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() { // Metode main untuk menjalankan aplikasi.
  runApp(MyApp()); // Menjalankan aplikasi Flutter dengan MyApp sebagai root widget.
}
