class Aluno {
  final int id;
  final String matricula;
  final String nome;
  final String email;
  final String? urlFoto;
  final double saldo;

  Aluno({
    required this.id,
    required this.matricula,
    required this.nome,
    required this.email,
    this.urlFoto,
    required this.saldo,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      matricula: json['matricula'],
      nome: json['nome'],
      email: json['email'],
      urlFoto: json['url_foto'],
      saldo: double.parse(json['saldo'].toString()),
    );
  }
}