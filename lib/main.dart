import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const OrcamentoApp());
}

/// O aplicativo principal, um `MaterialApp` com o tema e a página inicial.
class OrcamentoApp extends StatelessWidget {
  const OrcamentoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dj Junior Safera',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const OrcamentoPage(),
    );
  }
}

/// A página principal onde a lógica e a UI do gerador de orçamento residem.
class OrcamentoPage extends StatefulWidget {
  const OrcamentoPage({super.key});

  @override
  State<OrcamentoPage> createState() => _OrcamentoPageState();
}

class _OrcamentoPageState extends State<OrcamentoPage> {
  // Controladores para os campos de texto.
  final TextEditingController _artista = TextEditingController(
    text: 'Dj Junior Safera',
  );
  final TextEditingController _servicoController = TextEditingController(
    text: 'DJ para Evento Particular',
  );
  final TextEditingController _duracaoController = TextEditingController(
    text: '1',
  );
  final TextEditingController _localController = TextEditingController(
    text: '',
  );
  final TextEditingController _dataController = TextEditingController(text: '');
  final TextEditingController _valorHoraController = TextEditingController(
    text: '',
  );
  final TextEditingController _descontoController = TextEditingController(
    text: '',
  );
  final TextEditingController _valorSomController = TextEditingController(
    text: '',
  );

  // Variáveis de estado para armazenar os dados e os valores calculados.
  String _servico = '';
  double _duracao = 1;
  String _local = '';
  String _data = '';
  double _valorHora = 0;
  double _desconto = 0;
  double _valorSom = 0;
  bool _incluirSom = false; // Estado para controlar a inclusão do som.

  double _subtotalDJ = 0;
  double _subtotalSom = 0;
  double _valorTotal = 0;

  // Formato para moedas brasileiras.
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Inicializa os valores calculados quando a página é carregada.
    _calcularOrcamento();
    // Adiciona listeners para atualizar o orçamento quando os campos de texto mudam.
    _servicoController.addListener(
      () => setState(() {
        _servico = _servicoController.text;
      }),
    );
    _duracaoController.addListener(_atualizarDuracao);
    _localController.addListener(
      () => setState(() {
        _local = _localController.text;
      }),
    );
    _dataController.addListener(
      () => setState(() {
        _data = _dataController.text;
      }),
    );
    _valorHoraController.addListener(_atualizarValorHora);
    _descontoController.addListener(_atualizarDesconto);
    _valorSomController.addListener(_atualizarValorSom);
  }

  /// Atualiza a duração e recalcula o orçamento.
  void _atualizarDuracao() {
    setState(() {
      try {
        _duracao = double.parse(_duracaoController.text);
      } catch (e) {
        _duracao = 0;
      }
      _calcularOrcamento();
    });
  }

  /// Atualiza o valor por hora e recalcula o orçamento.
  void _atualizarValorHora() {
    setState(() {
      try {
        _valorHora = double.parse(_valorHoraController.text);
      } catch (e) {
        _valorHora = 0;
      }
      _calcularOrcamento();
    });
  }

  /// Atualiza o desconto e recalcula o orçamento.
  void _atualizarDesconto() {
    setState(() {
      try {
        _desconto = double.parse(_descontoController.text);
      } catch (e) {
        _desconto = 0;
      }
      _calcularOrcamento();
    });
  }

  /// Atualiza o valor do sistema de som e recalcula o orçamento.
  void _atualizarValorSom() {
    setState(() {
      try {
        _valorSom = double.parse(_valorSomController.text);
      } catch (e) {
        _valorSom = 0;
      }
      _calcularOrcamento();
    });
  }

  /// Função principal de cálculo do orçamento.
  void _calcularOrcamento() {
    _subtotalDJ = _duracao * _valorHora;
    _subtotalSom = _incluirSom ? _valorSom : 0;
    _valorTotal = (_subtotalDJ + _subtotalSom) - _desconto;

    if (_incluirSom) {
      _servicoController.text = 'DJ + Sistema de Som';
    } else {
      _servicoController.text = 'DJ para Evento Particular';
    }
    _servico = _servicoController.text;
  }

  /// Gera e compartilha o PDF do orçamento.
  Future<void> _gerarPDF() async {
    final pdf = pw.Document();
    final ttf = await PdfGoogleFonts.robotoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'ORÇAMENTO',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black,
                          font: ttf,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        _artista.text.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.normal,
                          color: PdfColors.black,
                          font: ttf,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
                _buildPdfInfoRow('Serviço', _servico, ttf),
                _buildPdfInfoRow('Duração do Evento', duracaoText(), ttf),
                _buildPdfInfoRow('Local', _local, ttf),
                _buildPdfInfoRow('Data', _data, ttf),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Detalhamento dos Serviços:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    font: ttf,
                  ),
                ),
                pw.SizedBox(height: 16),
                _buildPdfServiceDetail(
                  'DJ Profissional',
                  'O DJ será responsável por tocar músicas adequadas ao perfil do evento e do público presente, proporcionando entretenimento de qualidade.',
                  _valorHora,
                  _duracao,
                  _subtotalDJ,
                  ttf,
                ),
                if (_incluirSom) ...[
                  pw.SizedBox(height: 16),
                  _buildPdfSomDetail(ttf),
                ],
                if (!_incluirSom) ...[
                  pw.SizedBox(height: 16),
                  _buildPdfEquipmentDetail(ttf),
                ],
                pw.SizedBox(height: 16),
                _buildPdfSummary(ttf),
              ],
            ),
          );
        },
      ),
    );

    // Salva o PDF e o compartilha.
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'orcamento.pdf');
  }

  /// Widget auxiliar para exibir linhas de informação no PDF.
  pw.Widget _buildPdfInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.RichText(
        text: pw.TextSpan(
          style: pw.TextStyle(fontSize: 16, color: PdfColors.black, font: font),
          children: <pw.TextSpan>[
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para exibir os detalhes do serviço no PDF.
  pw.Widget _buildPdfServiceDetail(
    String serviceName,
    String description,
    double hourlyRate,
    double duration,
    double subtotal,
    pw.Font font,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Bullet(
          text: '$serviceName: $description',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.black, font: font),
        ),
        _buildPdfDetailRow(
          'Valor por hora ($serviceName)',
          _currencyFormat.format(hourlyRate),
          font,
        ),
        _buildPdfDetailRow('Duração', duracaoText(), font),
        _buildPdfDetailRow(
          'Subtotal ($serviceName)',
          _currencyFormat.format(subtotal),
          font,
        ),
      ],
    );
  }

  /// Widget auxiliar para exibir os detalhes do sistema de som no PDF.
  pw.Widget _buildPdfSomDetail(pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Bullet(
          text:
              'Sistema de Som: Equipamento de áudio de alta qualidade para garantir a distribuição sonora adequada no local. Inclui caixas de som, mesa de som e demais acessórios necessários.',
          style: pw.TextStyle(fontSize: 14, font: font),
        ),
        _buildPdfDetailRow('Duração', duracaoText(), font),
        _buildPdfDetailRow(
          'Subtotal',
          _currencyFormat.format(_subtotalSom),
          font,
        ),
      ],
    );
  }

  /// Widget auxiliar para exibir os detalhes do equipamento no PDF.
  pw.Widget _buildPdfEquipmentDetail(pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Equipamento e Infraestrutura:',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            font: font,
            fontSize: 16,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Bullet(
          text:
              'Equipamento de som, iluminação e outros recursos serão fornecidos pelo contratante ou pelo local do evento. O serviço do DJ é exclusivo para a música.',
          style: pw.TextStyle(fontSize: 14, font: font),
        ),
      ],
    );
  }

  /// Widget auxiliar para exibir o resumo dos custos e o valor total no PDF.
  pw.Widget _buildPdfSummary(pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Resumo dos Custos:',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildPdfDetailRow(
          'DJ (${duracaoText()})',
          _currencyFormat.format(_subtotalDJ),
          font,
        ),
        if (_incluirSom)
          _buildPdfDetailRow(
            'Som (${duracaoText()})',
            _currencyFormat.format(_subtotalSom),
            font,
          ),
        pw.SizedBox(height: 16),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Total:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
            ),
            pw.Text(
              _currencyFormat.format(_subtotalDJ + _subtotalSom),
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 1.5, color: PdfColors.black),
        pw.SizedBox(height: 32),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Valor Total com desconto:',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                  font: font,
                ),
              ),
              pw.Text(
                _currencyFormat.format(_valorTotal),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                  font: font,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget auxiliar para exibir detalhes de valores no PDF.
  pw.Widget _buildPdfDetailRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16.0, top: 2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('$label:', style: pw.TextStyle(fontSize: 14, font: font)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
          ),
        ],
      ),
    );
  }

  //
  @override
  void dispose() {
    _servicoController.dispose();
    _duracaoController.dispose();
    _localController.dispose();
    _dataController.dispose();
    _valorHoraController.dispose();
    _descontoController.dispose();
    _valorSomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold oferece a estrutura básica para a página.
    return Scaffold(
      // SingleChildScrollView permite que a página seja rolada.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Seção de entrada de dados.
              _buildInputSection(),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    _gerarPDF();
                  }
                },
                child: Text('Compartilhar'),
              ),
              const SizedBox(height: 32.0),
              // Separador.
              const Divider(thickness: 2, color: Colors.grey),
              const SizedBox(height: 32.0),
              // Seção de pré-visualização do orçamento.
              _buildOrcamentoPreview(),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget para os campos de entrada de dados.
  Widget _buildInputSection() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preencha os dados do orçamento:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Artista', _artista),
          _buildTextField('Serviço', _servicoController),
          _buildTextField(
            'Duração (horas)',
            _duracaoController,
            keyboardType: TextInputType.number,
          ),
          _buildTextField('Local', _localController),
          _buildTextField(
            'Data',
            _dataController,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              DataInputFormatter(),
            ],
          ),
          _buildTextField(
            'Valor por hora (R\$)',
            _valorHoraController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          // Switch para incluir o sistema de som
          SwitchListTile(
            title: const Text('Incluir Sistema de Som'),
            value: _incluirSom,
            onChanged: (bool value) {
              setState(() {
                _incluirSom = value;
                _calcularOrcamento();
              });
            },
          ),
          // Campo para o valor do som, visível apenas se o switch estiver ativado.
          if (_incluirSom)
            _buildTextField(
              'Valor do Som (R\$)',
              _valorSomController,
              keyboardType: TextInputType.number,
            ),
          _buildTextField(
            'Valor do Desconto (R\$)',
            _descontoController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar para construir os campos de texto.
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        inputFormatters: inputFormatters,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Campo obrigatório.';
          }
          return null;
        },
      ),
    );
  }

  /// Widget para a pré-visualização do orçamento.
  Widget _buildOrcamentoPreview() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'ORÇAMENTO',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _artista.text.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Serviço', _servico),
          _buildInfoRow('Duração do Evento', duracaoText()),
          _buildInfoRow('Local', _local),
          _buildInfoRow('Data', _data),
          const SizedBox(height: 32),
          const Text(
            'Detalhamento dos Serviços:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildServiceDetail(
            'DJ Profissional',
            'O DJ será responsável por tocar músicas adequadas ao perfil do evento e do público presente, proporcionando entretenimento de qualidade.',
            _valorHora,
            _duracao,
            _subtotalDJ,
          ),
          if (_incluirSom) ...[const SizedBox(height: 16), _buildSomDetail()],
          if (!_incluirSom) ...[
            const SizedBox(height: 16),
            const Text(
              'Equipamento e Infraestrutura:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '● Equipamento de som, iluminação e outros recursos serão fornecidos pelo contratante ou pelo local do evento. O serviço do DJ é exclusivo para a música.',
              style: TextStyle(fontSize: 14),
            ),
          ],
          const SizedBox(height: 32),
          _buildSummaryPreview(),
        ],
      ),
    );
  }

  String duracaoText() {
    if (_duracao == 1) {
      return '$_duracao hora';
    }
    return '$_duracao horas';
  }

  /// Widget auxiliar para exibir linhas de informação.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          children: <TextSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para exibir os detalhes do serviço.
  Widget _buildServiceDetail(
    String serviceName,
    String description,
    double hourlyRate,
    double duration,
    double subtotal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black),
            children: <TextSpan>[
              const TextSpan(
                text: '● ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '$serviceName: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: description),
            ],
          ),
        ),
        _buildDetailRow(
          'Valor por hora ($serviceName)',
          _currencyFormat.format(hourlyRate),
        ),
        _buildDetailRow('Duração', duracaoText()),
        _buildDetailRow(
          'Subtotal ($serviceName)',
          _currencyFormat.format(subtotal),
        ),
      ],
    );
  }

  /// Widget auxiliar para exibir os detalhes do sistema de som.
  Widget _buildSomDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                      text: '● Sistema de Som:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'Equipamento de áudio de alta qualidade para garantir a distribuição sonora adequada no local. Inclui caixas de som, mesa de som e demais acessórios necessários.',
                    ),
                  ],
                ),
              ),
              _buildDetailRow('Duração', duracaoText()),
              _buildDetailRow('Subtotal', _currencyFormat.format(_subtotalSom)),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget auxiliar para exibir o resumo dos custos e o total na pré-visualização.
  Widget _buildSummaryPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo dos Custos:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          'DJ (${duracaoText()})',
          _currencyFormat.format(_subtotalDJ),
        ),
        if (_incluirSom)
          _buildDetailRow(
            'Som (${duracaoText()})',
            _currencyFormat.format(_subtotalSom),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              _currencyFormat.format(_subtotalDJ + _subtotalSom),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Divider(thickness: 1.5, color: Colors.black),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: const Text(
                  'Valor Total com desconto:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                _currencyFormat.format(_valorTotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget auxiliar para exibir detalhes de valores.
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text('$label:', style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
