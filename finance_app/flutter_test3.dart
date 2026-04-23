import 'dart:io';

void main() {
  while (true) {
    stdout.write('Berapa banyak angka yang ingin ditampilkan? ');
    int n = int.parse(stdin.readLineSync()!);

    if (n <= 0 || n.isNegative == true ) {
      print("Input tidak valid. Harap masukkan angka positif.");
      continue;
    }

    int angka1 = 0;
    int angka2 = 1;

    for (int i = 0; i < n; i++) {
      stdout.write('\n  $angka1 ');
      int temp = angka1 + angka2;
      angka1 = angka2;
      angka2 = temp;
    }
  }
}
