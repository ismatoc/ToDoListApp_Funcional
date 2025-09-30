import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todolistapp/3-presentation/providers/resetpassword_provider.dart';
import 'package:todolistapp/3-presentation/providers/validareset_provider.dart';
import 'package:todolistapp/3-presentation/screens/screens.dart';

class Recuperar extends ConsumerStatefulWidget {
  const Recuperar({super.key});
  static const name = 'recuperar';

  @override
  _RecuperarState createState() => _RecuperarState();
}

class _RecuperarState extends ConsumerState<Recuperar> {

  final _formKey = GlobalKey<FormState>();
  final _formKey_restablece = GlobalKey<FormState>();

  TextEditingController? _correoController;
  TextEditingController? _codigoController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmarpasswordController;

    bool _obscureText = true;


  final unfocusNode = FocusNode();

   bool _isLoading = false;
   int activa = 0;

  @override
  void initState() {
    super.initState();
    _correoController ??= TextEditingController();
    _codigoController ??= TextEditingController();
    _passwordController ??= TextEditingController();
    _confirmarpasswordController ??= TextEditingController();


  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocusNode.canRequestFocus
              ? FocusScope.of(context).requestFocus(unfocusNode)
              : FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.undo, color: Colors.white,size: 30,), // 👈 color solo aquí
                onPressed: () => Navigator.pop(context),
              ),
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
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text('Recuperar Contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                          
                            Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                    
                                  const SizedBox(height: 24),
                                  
                                  TextFormField(
                                    controller: _correoController,
                                    textAlign: TextAlign.center,
                                    decoration: Inputs(
                                      context,
                                      'Correo',
                                      prefixIcon: Icons.mail,
                                      requerido: true,
                                    ),
                                    
                                  ),
                    
                    
                                  const SizedBox(height: 24),
                    
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
                                      onPressed:() async {
                                        setState(() => _isLoading = true);
                    
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        activa = activa + 1;
                                        if(activa == 1){
                    
                                          if(_correoController!.text != ''){
                                            final providerRestablecer = await ref.read( nowResetProvider.notifier ).loadAllData({
                                              "tipo_consulta":"R1",
                                              "correo":_correoController!.text
                                            });
                    
                                            print(providerRestablecer);

                                            if(providerRestablecer.respuesta.length > 0){
                                              Mensajes('Correcto', 'se envío codigo de actualización a su correo,', DialogType.success, context);
                                              setState(() {
                                                activa = 0;
                                                _isLoading = false;
                                              });
                                            }else{
                                               Mensajes('Error', 'correo no existe, ingrese uno correcto', DialogType.error, context);
                                              setState(() {
                                                activa = 0;
                                                _isLoading = false;
                                              });
                                            }
                    
                                            setState(() {
                                              activa = 0;
                                              _isLoading = false;
                                            });
                                          }else{
                                            Mensajes('Requerido', 'Ingrese campo requerido.', DialogType.error, context);
                                            setState(() {
                                              activa = 0;
                                              _isLoading = false;
                                            });
                                          }
                                        
                                        }
                                        
                    
                    
                                      }, 
                                      child: const Text('Generar Código', style: TextStyle(fontSize: 16, color: Colors.white))
                                    ),
                                  )
                                  
                    
                                ],
                              )
                            )
                            
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text('Actualizar Contraseña', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue)),
                          
                            Form(
                              key: _formKey_restablece,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                    
                                  const SizedBox(height: 24),
                                  
                                  TextFormField(
                                    controller: _codigoController,
                                    textAlign: TextAlign.center,
                                    decoration: Inputs(
                                      context,
                                      'Codigo',
                                      prefixIcon: Icons.abc,
                                      requerido: true,
                                    ),
                                    
                                  ),

                                  const SizedBox(height: 20),


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

                                  const SizedBox(height: 20),

                                  TextFormField(
                                    controller: _confirmarpasswordController,
                                    textAlign: TextAlign.center,
                                    obscureText: _obscureText,
                                    decoration: Inputs(
                                      context,
                                      'Confirmar contraseña',
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
                                      onPressed:() async {
                                        setState(() => _isLoading = true);
                    
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        activa = activa + 1;
                                        if(activa == 1){
                    
                                          print(_codigoController?.text);
                                          print(_passwordController?.text);
                                          print(_confirmarpasswordController?.text);

                                          if(_codigoController?.text != '' && _passwordController?.text != '' && _confirmarpasswordController?.text != ''){

                                            if(_passwordController?.text == _confirmarpasswordController?.text){
                                              
                                              final providervalidaRestablecer = await ref.read( nowValidaResetProvider.notifier ).loadAllData({
                                                "tipo_consulta":"R",
                                                "codigo_restablece":_codigoController!.text.toUpperCase()
                                              });

                                              print(providervalidaRestablecer);
                                              if(providervalidaRestablecer.respuesta.length > 0){
                                                if(providervalidaRestablecer.respuesta[0]["estado"] == 'A'){
                                                  final providerRestablecerPass = await ref.read( nowResetProvider.notifier ).loadAllData({
                                                    "tipo_consulta":"U",
                                                    "id_usuario":providervalidaRestablecer.respuesta[0]["id_usuario"],
                                                    "clave":_passwordController!.text
                                                  });

                                                  Mensajes('Actualizado', 'Contraseña actualizada.!', DialogType.success, context);

                                                }else{
                                                  Mensajes('Info', 'codigo ya se utilizo, genere uno nuevo.!', DialogType.info, context);
                                                  setState(() {
                                                    activa = 0;
                                                    _isLoading = false;
                                                  });
                                                }
                                              }else{
                                                Mensajes('Info', 'codigo no existe.!', DialogType.info, context);
                                                setState(() {
                                                  activa = 0;
                                                  _isLoading = false;
                                                });
                                              }

                                              setState(() {
                                                activa = 0;
                                                _isLoading = false;
                                              });
                                            }else{
                                              Mensajes('Error', 'contraseña no es igual a la confirmación de contraseña.', DialogType.info, context);
                                              setState(() {
                                                activa = 0;
                                                _isLoading = false;
                                              });
                                            }

                                          }else{
                                            Mensajes('Error', 'Ingrese los campos requeridos', DialogType.error, context);
                                            setState(() {
                                              activa = 0;
                                              _isLoading = false;
                                            });
                                          }

                                          
                                      
                                        }
                                        
                    
                    
                                      }, 
                                      child: const Text('Restablecer', style: TextStyle(fontSize: 16, color: Colors.white))
                                    ),
                                  )
                                  
                    
                                ],
                              )
                            )
                            
                          ],
                        ),
                      ),
                    ),
                  ],
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
        ],
      ),
    );
  }
}