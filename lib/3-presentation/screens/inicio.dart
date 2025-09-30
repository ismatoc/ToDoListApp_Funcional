import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:todolistapp/3-presentation/providers/login_providers.dart';
import 'package:todolistapp/3-presentation/screens/screens.dart';

class Inicio extends ConsumerStatefulWidget {
  static const name = 'inicio';
  const Inicio({super.key});

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends ConsumerState<Inicio> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _userController;
  TextEditingController? _passwordController;
  bool _obscureText = true;
  bool _isLoading = false;
  int activa = 0;
  final unfocusNode = FocusNode();
  Future<void> onLoginSuccess(int idUsuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_usuario', idUsuario);

    // 👇 avisa al servicio en background (no reinicia nada)
    FlutterBackgroundService().invoke('set_user', {'id_usuario': idUsuario});
  }

  Future<void> onLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_usuario');
    FlutterBackgroundService().invoke('set_user', {'id_usuario': null});
  }

  @override
  void initState() {
    super.initState();
    _userController ??= TextEditingController();
    _passwordController ??= TextEditingController();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

   

    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => unfocusNode.canRequestFocus
              ? FocusScope.of(context).requestFocus(unfocusNode)
              : FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            
            Scaffold(
              backgroundColor: Colors.blue.shade50,
              appBar: AppBar(
                leading: const SizedBox.shrink(),
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            
                centerTitle: true,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              body: Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // const Icon(Icons.assignment, size: 60, color: Colors.blueAccent),
                            Image.asset('assets/lista.png', width: 120,),
                            const SizedBox(height: 16),
                            Text(
                              "Bienvenido",
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                            ),
                            const SizedBox(height: 24),
            
                          
            
                            TextFormField(
                              controller: _userController,
                              textAlign: TextAlign.center,
                              decoration: Inputs(
                                context,
                                'Usuario',
                                prefixIcon: Icons.person_outline,
                                requerido: true,
                              ),
                              
                            ),
            
            
                            const SizedBox(height: 16),
            
                          
                            TextFormField(
                              controller: _passwordController,
                              textAlign: TextAlign.center,
                              obscureText: _obscureText,
                              decoration: Inputs(
                                context,
                                'Contraseña',
                                requerido: true,
            
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () => setState(() => _obscureText = !_obscureText),
                                ),
                              ),
                              // validator: (value) =>
                              //     (value == null || value.isEmpty) ? "Ingrese su contraseña" : null,
                            ),
            
                            const SizedBox(height: 24),
            
                            // Botón
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.blueAccent,
                                ),
                                onPressed: () async {
                                  
                                  setState(() => _isLoading = true);
            
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  // Navigator.pop(context);
                                  activa = activa + 1;
                                  if(activa == 1){
            
                                    if (_userController!.text == '' && _passwordController!.text == ''){
                                      Mensajes("Requerido", "Ingrese campos requeridos.", DialogType.error, context);
                                      setState(() {
                                        activa = 0;
                                        _isLoading = false;
                                      });
                                    }else{
                                      final providerLogin = await ref.read( nowLoginProvider.notifier ).loadAllData({
                                        "tipo_consulta": "R",
                                        "usuario": _userController!.text,
                                        "clave": _passwordController!.text
                                      });
              
                                      var info = providerLogin.respuesta;
            
                                      
            
                                      if(info["estado"] == false){
                                        Mensajes("Error", info["mensaje"], DialogType.error, context);
                                        setState(() {
                                          activa = 0;
                                          _isLoading = false;
                                        });
                                      }else{
                                        Map<String, dynamic> decodedToken = JwtDecoder.decode(info["accesToken"]);
                                        print(decodedToken["id_usuario"]);
                                        onLoginSuccess(decodedToken["id_usuario"]);
                                        final loginInfo = ref.watch( loginProvider );
                                        loginInfo.setInfo(decodedToken);
            
                                        context.push('/principal');
                                        setState(() {
                                          activa = 0;
                                          _isLoading = false;
                                        });
                                        print(info);
                                      }
                                    }
                                  }
                                    
                                    
            
            
                                  // onLoginSuccess(3);
            
                                  // Navega si quieres:
                                  // context.push('/principal');
                                },
                                child: const Text("Ingresar", style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
            
                            const SizedBox(height: 24),

                            TextButton(
                              onPressed: () {
                                context.push('/principal/recuperar');
                              },
                              child: Text('¿Recuperar Contraseña?', style: TextStyle(decoration: TextDecoration.underline, fontSize: 15, color: Colors.blue, fontWeight: FontWeight.bold),)
                            )
            
                            // Botón
                            // SizedBox(
                            //   width: double.infinity,
                            //   child: ElevatedButton(
                            //     style: ElevatedButton.styleFrom(
                            //       padding: const EdgeInsets.symmetric(vertical: 16),
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(12),
                            //       ),
                            //       backgroundColor: Colors.blueAccent,
                            //     ),
                            //     onPressed: () async {
                                
            
            
                            //     onLogout();
            
                            //       // Navega si quieres:
                            //       // context.push('/principal');
                            //     },
                            //     child: const Text("Salir", style: TextStyle(fontSize: 16, color: Colors.white)),
                            //   ),
                            // ),
                            // const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ]
          
          
        ),
      ),
    );
  }
}
