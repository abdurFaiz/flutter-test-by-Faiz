import 'dart:io';

void main() {
  while (true) {
    stdout.write("Tolong masukkan angka : ");
    String? input = stdin.readLineSync();

    if (input == null || input.isEmpty) {
      print("Input tidak valid. Harap masukkan angka.");
      continue;
    }
    int? angka = int.tryParse(input);

    if (angka == null) {
      print("Input tidak valid. Harap masukkan angka.");
      continue;
    }

    print(angka % 2 == 0
        ? "Angka $angka adalah genap"
        : "Angka $angka adalah ganjil");
    break;
  }
}
