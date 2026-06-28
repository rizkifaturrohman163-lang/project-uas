import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final url = Uri.parse('http://10.80.225.171/kedelai_api/catatan_kedelai.php');

  // Mengambil data log stok dari server
  Future<List<dynamic>> getCatatanStok() async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat data stok');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

  // Menghitung total stok secara dinamis dari database api
  int _hitungTotalStok(List<dynamic> listData) {
    int total = 0;
    for (var catatan in listData) {
      int nominal = int.tryParse(catatan['nominal'].toString()) ?? 0;
      bool isMasuk =
          catatan['kategori'].toString().toLowerCase() == 'masuk' ||
          catatan['kategori'].toString().toLowerCase() ==
              'pemasukan'; // Toleransi data lama

      if (isMasuk) {
        total += nominal;
      } else {
        total -= nominal;
      }
    }
    return total;
  }

  // Mengirim data penambahan stok ke server
  Future<void> postCatatanStok(String kuantitas, String kategori) async {
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nominal": kuantitas, "kategori": kategori}),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data stok berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data stok gagal ditambahkan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Gagal menyimpan ke server');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data gagal ditambahkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Form input Bottom Sheet untuk tambah stok masuk / keluar
  void tampilkanForm(BuildContext context) {
    final TextEditingController kuantitasController = TextEditingController();
    final List<String> listKategori = ['Masuk', 'Keluar'];
    String kategoriDipilih = 'Masuk';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModelState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Catatan Stok Kedelai',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: kuantitasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah / Kuantitas',
                      suffixText: 'Kg',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: kategoriDipilih,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Transaksi Stok',
                      border: OutlineInputBorder(),
                    ),
                    items: listKategori.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value == 'Masuk'
                              ? 'Barang Masuk (Pemasukan)'
                              : 'Barang Keluar (Dijual)',
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModelState(() {
                        kategoriDipilih = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff009688),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(14),
                      ),
                      onPressed: () async {
                        if (kuantitasController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jumlah kuantitas harus diisi!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        await postCatatanStok(
                          kuantitasController.text,
                          kategoriDipilih,
                        );
                        kuantitasController.clear();
                        setState(() {
                          kategoriDipilih = 'Masuk';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Simpan Stok',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Refresh data di halaman utama setelah modal form ditutup
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffcf7fa),
      appBar: AppBar(
        title: const Text('Stok Kacang Kedelai'),
        centerTitle: true,
        backgroundColor: const Color(0xff009688),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getCatatanStok(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat mutasi stok barang'),
            );
          }

          List<dynamic> listData = snapshot.data!;
          int totalStok = _hitungTotalStok(listData);

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xff009688),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Stok Saat Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalStok Kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Judul Riwayat Aktivitas
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Riwayat Keluar Masuk Barang',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),

              // 2. List Daftar Riwayat Mutasi Stok Barang
              Expanded(
                child: ListView.builder(
                  itemCount: listData.length,
                  itemBuilder: (context, index) {
                    var catatan = listData[index];
                    String kat = catatan['kategori'].toString().toLowerCase();
                    bool isMasuk = kat == 'masuk' || kat == 'pemasukan';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xfff7f2f7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMasuk
                                  ? const Color(0xffc8e6c9)
                                  : const Color(0xfffcd8dc),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isMasuk
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isMasuk
                                  ? const Color(0xff388e3c)
                                  : const Color(0xffec407a),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${catatan['nominal']} Kg',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff4a4a4a),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isMasuk
                                    ? 'Kacang Masuk (Pemasukan)'
                                    : 'Kacang Keluar (Dijual)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Tombol Tambah Transaksi Stok (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tampilkanForm(context);
        },
        backgroundColor: const Color(0xffe1bee7),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Color(0xff4a148c), size: 28),
      ),
    );
  }
}
