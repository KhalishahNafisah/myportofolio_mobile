# myportofolio_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### Tugas 7
1. Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!

--> 

Widget Tree pada Flutter adalah susunan widget secara hierarkis yang membentuk tampilan aplikasi Flutter. Widget induk mengatur atau membungkus widget anak, misalnya untuk menentukan posisi, ukuran, atau jarak.

Pada proyek ini, [MyApp] membangun [MaterialApp], kemudian [MaterialApp] menggunakan [MyHomePage] sebagai halaman awal. Halaman tersebut membangun [Scaffold] yang berisi [AppBar] dan isi halaman.

Widget dengan satu anak biasanya menggunakan properti child, sedangkan widget yang menampung beberapa anak, seperti Column dan Row, menggunakan children.



2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!

--> 

Widget adalah komponen penyusun antarmuka di FLutter, setiap widget mendeskripsikan apa yang ditampilkan, bagaimana komponen disusun, atau bagaimana komponen berperilaku.

- [MyApp]: Widget buatan sendiri untuk konfigurasi aplikasi
- [MyHomePage]: Widget buatan sendiri untuk halaman utama
- [InfoCard]: Menampilan kartu informasi pemilik
- [ItemCard]: Menampilkan kartu menu aksi
- [MaterialApp]: Mengatur tema dan halaman awal aplikasi
- [Scaffold]: Menyediakan kerangka halaman
- [AppBar]: Menampilkan bilah judul
- [Padding]: Memberi jarak di sekitar widget
- [Column]: Menyusun widget secara vertikal
- [Row]: Menyusun widget secara horizontal
- [Card]: Menampilkan kartu informasi
- [Container]: Mengatur ruang, ukuran, atau tampilan suatu bagian
- [Text]: Menampilkan tulisan
- [SizedBox]: Memberikan ukuran atau jarak
- [Center]: Menempatkan anak di tengah
- [GridView]: Menampilkan kartu aksi dalam susunan grid
- [Material]: Menyediakan permukaan Material pada kartu aksi
- [InkWell]: Menangani ketukan dan efek sentuhan
- [Icon]: Menampilkan ikon
- [SnackBar]: Menampilkan pesan ketika tombol ditekan



3. Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!

-->

[MaterialApp] menyediakan konfigurasi untuk aplikasi yang menggunakan Material Design. Dalam proyek ini, widget tersebut mengatur judul, tema warna, dan halaman awal melalui properti [home].

Widget ini biasanya ditempatkan dekat akar aplikasi agar konfigurasi bersama, seperti tema dan fasilitas navigasi, tersedia bagi widget di bawahnya.



4. Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?

-->

[StatelessWidget] digunakan ketika widget tidak perlu mengelola state lokal yang dapat berubah. Tampilannya ditentukan oleh konfigurasi yang diterima dan informasi dari [BuildContext].

[StatefulWidget] digunakan ketika widget perlu mengelola perubahan data lokal selama aplikasi berjalan. Data yang berubah disimpan pada objek [State], misalnya nilai penghitung atau pilihan pengguna.

Halaman utama proyek ini menggunakan [StatelessWidget] karena profil dan daftar menu bersifat tetap.



5. Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?

-->

[BuildContext] merupakan referensi terhadap lokasi sebuah widget dalam widget tree. Context diberikan pada metode [build] dan dapat digunakan untuk mengakses informasi atau layanan dari ancestor yang sesuai.

Dalam proyek ini, [Theme.of(context)] digunakan untuk membaca tema, sedangkan [ScaffoldMessenger.of(context)] digunakan untuk mengakses pengelola SnackBar. Lokasi context penting karena menentukan ancestor yang dapat ditemukan.



6. Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?

-->

Hot reload menerapkan perubahan kode sambil mempertahankan state aplikasi. Hot reload tidak menjalankan ulang [main()] atau [initState()].

Hot restart memulai kembali aplikasi Dart dan menghilangkan state sebelumnya. Ini diperlukan ketika perubahan harus menjalankan ulang proses inisialisasi atau tidak dapat diterapkan melalui hot reload.

Full restart dilakukan dengan menghentikan dan menjalankan aplikasi kembali. Ini diperlukan, misalnya, setelah perubahan kode native seperti Kotlin atau Swift.

Hot reload ketika baru mengubah tampilan atau isi fungsi, misalnya warna kartu, teks, dll. Kalau hot restart ketika perlu menjalankan ulang dari main().







### Tugas 8 & AI Disclosure

1. Perbedaan navigasi dan penggunaannya

[Navigator.push()] menambahkan halaman baru di atas tumpukan navigasi, sehingga halaman sebelumnya tetap tersedia untuk kembali. [Navigator.pushReplacement()] mengganti halaman aktif dengan halaman baru. Navigator.pop() mengeluarkan route teratas, misalnya untuk kembali ke halaman sebelumnya atau menutup dialog.

Pada aplikasi saya, kartu Tambah Pengalaman membuka formulir menggunakan [Navigator.push()]. Dengan demikian, tombol kembali bawaan perangkat dapat membawa pengguna ke halaman sebelumnya.

Opsi Home pada drawer menjalankan [Navigator.pop(context)] untuk menutup drawer, kemudian [Navigator.pushReplacement()] untuk mengganti halaman aktif dengan [MyHomePage()].


2. Konsistensi struktur dan tema halaman

[Scaffold] menyediakan kerangka halaman melalui properti seperti [appBar], [drawer], dan [body]. [AppBar] menampilkan judul halaman, sedangkan [Drawer] menyediakan pilihan navigasi.

Halaman utama dan formulir Pengalaman menggunakan komponen [LeftDrawer] yang sama. Dengan penggunaan komponen bersama, pilihan navigasi tetap konsisten dan perubahan drawer cukup dilakukan pada satu berkas.

Contoh konsistensi warna adalah penggunaan [Theme.of(context).colorScheme.primary] sebagai warna latar [AppBar] pada halaman utama dan formulir Pengalaman. Warna tersebut berasal dari tema aplikasi yang menggunakan warna dasar indigo.


3. Pemilihan tata letak formulir

Formulir menggunakan [Column] untuk menyusun input secara vertikal agar urutan pengisian mudah diikuti. [Padding] memberikan jarak antara isi formulir dan tepi layar, sedangkan [SizedBox] memberikan jarak antarinput dan sebelum tombol Simpan.

[SingleChildScrollView] memungkinkan pengguna menggulir formulir ketika tinggi konten melebihi ruang yang tersedia. Hal ini membantu ketika layar kecil atau keyboard muncul, sehingga input dan tombol Simpan tetap dapat dijangkau.

Selain itu, [SafeArea] membantu menjaga konten dari area sistem perangkat. [Scaffold] secara default menyesuaikan ruang body ketika keyboard tampil.


4. Peran key dan validasi formulir

[GlobalKey<FormState>] memberikan identitas kepada [Form] sekaligus menyediakan akses ke state formulir melalui [currentState]. Key disimpan sebagai field pada objek [State] agar tidak dibuat ulang setiap kali [build()] dijalankan.

[validator] memeriksa nilai suatu input. Jika nilainya salah, validator mengembalikan pesan kesalahan. Jika benar, validator mengembalikan [null].

Ketika tombol Simpan ditekan, [validate()] menjalankan seluruh validator pada formulir. Jika hasilnya [true], aplikasi menjalankan [save()] untuk mengambil nilai melalui [onSaved], kemudian menampilkan ringkasan dalam dialog.

Contoh nilai yang ditolak adalah judul "   ", karena setelah [trim()] hasilnya kosong. Judul yang melebihi 255 karakter juga ditolak.

Pemilihan keyboard saja belum cukup karena [TextInputType.url] hanya membantu pengguna mengetik URL. Pengguna masih dapat memasukkan ["bukan-url"], sehingga pemeriksaan melalui validator tetap diperlukan.

--> Saya menggunakan Codex (OpenAI) untuk mengklarifikasi istilah dan konsep Flutter yang masih membingungkan serta memperoleh tutorial pengerjaan untuk bagian yang tidak saya kuasai. Saya menentukan bagian portofolio yang dikembangkan dan arah pengerjaannya. Codex juga membantu menjalankan pengujian otomatis hasil pengerjaan saya apakah sudah sesuai atau masih perlu perbaikan. Keputusan akhir dan tanggung jawab atas hasil tugas tetap berada pada saya.