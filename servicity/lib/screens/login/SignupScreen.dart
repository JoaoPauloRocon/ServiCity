import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _tipoUsuarioController = TextEditingController(); // Cliente ou Prestador de Serviço
  final _serviceTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pixKeyController = TextEditingController();
  final _nascimentoController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _tipoUsuarioController.dispose();
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _pixKeyController.dispose();
    _nascimentoController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Verificar se o usuário já existe
        final email = _emailController.text.trim();
        final existingUser = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        if (existingUser.isNotEmpty) {
          setState(() {
            _errorMessage = 'Usuário já cadastrado com esse e-mail';
          });
          return;
        }

        // Cadastro do usuário
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: _senhaController.text.trim(),
        );

        Map<String, dynamic> userData = {
          'uid': userCredential.user!.uid,
          'nome': _nomeController.text,
          'email': email,
          'cpf': _cpfController.text,
          'telefone': _telefoneController.text,
          'nascimento': _nascimentoController.text,
          'tipoUsuario': _tipoUsuarioController.text,
        };

        if (_tipoUsuarioController.text == 'prestador') {
          userData.addAll({
            'serviceType': _serviceTypeController.text,
            'description': _descriptionController.text,
            'pixKey': _pixKeyController.text,
            'pixQrCode': _generatePixQrCode(_pixKeyController.text),
          });
        }

        await FirebaseFirestore.instance.collection('Users').doc(userCredential.user!.uid).set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _errorMessage = 'Erro: $e';
        });
      }
    }
  }

  String _generatePixQrCode(String pixKey) {
    return '00020126580014BR.GOV.BCB.PIX0116${pixKey}5204000053039865802BR5925${_nomeController.text}6009SAO PAULO61080500000062070503***6304***'; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('Cadastrar Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(labelText: 'CPF'),
                inputFormatters: [CpfInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o CPF';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _telefoneController,
                decoration: InputDecoration(labelText: 'Telefone'),
                inputFormatters: [PhoneInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _nascimentoController,
                decoration: InputDecoration(labelText: 'Data de Nascimento'),
                inputFormatters: [DateInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data de nascimento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  } else if (value.length < 8) {
                    return 'A senha deve ter pelo menos 8 dígitos';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: 'cliente',
                decoration: InputDecoration(labelText: 'Tipo de Usuário'),
                items: [
                  DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  DropdownMenuItem(value: 'prestador', child: Text('Prestador de Serviços')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoUsuarioController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o tipo de usuário';
                  }
                  return null;
                },
              ),
              if (_tipoUsuarioController.text == 'prestador') ...[
                TextFormField(
                  controller: _serviceTypeController,
                  decoration: InputDecoration(labelText: 'Tipo de Serviço'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o tipo de serviço';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Descrição do Serviço'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a descrição do serviço';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _pixKeyController,
                  decoration: InputDecoration(labelText: 'Chave PIX'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a chave PIX';
                    }
                    return null;
                  },
                ),
              ],
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cadastrarUsuario,
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) {
      text = text.substring(0, 11);
    }
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String formattedText = text;
    if (text.length > 9) {
      formattedText = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9, 11)}';
    } else if (text.length > 3) {
      formattedText = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6)}';
    }
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) {
      text = text.substring(0, 11);
    }
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String formattedText = text;
    if (text.length > 10) {
      formattedText = '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}';
    } else if (text.length > 2) {
      formattedText = '(${text.substring(0, 2)}) ${text.substring(2)}';
    }
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 8) {
      text = text.substring(0, 8);
    }
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    String formattedText = text;
    if (text.length > 4) {
      formattedText = '${text.substring(0, 2)}/${text.substring(2, 4)}/${text.substring(4, 8)}';
    } else if (text.length > 2) {
      formattedText = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
