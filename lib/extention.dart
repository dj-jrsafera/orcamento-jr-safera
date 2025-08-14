extension RealStringExtensions on String {
  /// Remove "R$", pontos e espaços, mantendo apenas os números e vírgula
  String apenasNumeros() {
    // Remove "R$", espaços e pontos
    String s = replaceAll("R\$", "").replaceAll(".", "").replaceAll(" ", "");
    // Substitui vírgula por ponto, caso queira número decimal
    s = s.replaceAll(",", ".");
    return s;
  }
}
