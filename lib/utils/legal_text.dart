// lib/utils/legal_text.dart
//
// Textos legales de Houra. Si más adelante cambias algo relevante
// (nuevos datos que recoges, nuevo responsable, etc.), actualiza también
// la fecha de "Última actualización" de ambos documentos.

const String kContactoEmail = 'ayalasanchezcristian2000@gmail.com';
const String kResponsable = 'Cristian Ayala Sánchez';
const String kFechaActualizacion = '14 de septiembre de 2026';

const String kPrivacyPolicy = '''
POLÍTICA DE PRIVACIDAD DE HOURA

Última actualización: $kFechaActualizacion

1. RESPONSABLE DEL TRATAMIENTO
$kResponsable, actuando como persona física/autónomo, es el responsable de los datos personales tratados a través de la aplicación Houra. Contacto para cualquier consulta sobre privacidad: $kContactoEmail

2. QUÉ DATOS RECOGEMOS
- Datos de cuenta: nombre, correo electrónico y contraseña (esta última no la almacenamos nosotros, la gestiona Firebase Authentication de forma cifrada).
- Datos de uso de la app: tu tarifa por hora, tu meta mensual de horas, tus categorías personalizadas, y las entradas de horas trabajadas que registras (concepto, horas, tarifa, categoría y fecha).
No recogemos datos de pago, ubicación, contactos ni ningún otro dato sensible.

3. PARA QUÉ USAMOS TUS DATOS
Usamos estos datos exclusivamente para ofrecerte el servicio de la app: mostrarte tus horas trabajadas, tus ingresos estimados y tus estadísticas personales. No usamos tus datos con fines publicitarios ni los vendemos a terceros.

4. BASE LEGAL
El tratamiento se basa en la ejecución del servicio que nos solicitas al crear una cuenta (art. 6.1.b RGPD).

5. CON QUIÉN COMPARTIMOS TUS DATOS
Usamos Firebase (Google Ireland Ltd. / Google LLC) como proveedor de autenticación y base de datos. Google actúa como encargado del tratamiento bajo sus propias garantías de seguridad y cláusulas contractuales tipo para transferencias internacionales. No compartimos tus datos con nadie más.

6. CUÁNTO TIEMPO CONSERVAMOS TUS DATOS
Conservamos tus datos mientras tu cuenta permanezca activa. Si eliminas tu cuenta desde la app, tus datos (perfil y entradas de horas) se borran de forma permanente en un plazo máximo de 30 días.

7. TUS DERECHOS
Puedes ejercer en cualquier momento tus derechos de acceso, rectificación, supresión, portabilidad, limitación y oposición escribiendo a $kContactoEmail. También puedes eliminar tu cuenta y todos tus datos directamente desde Perfil → Eliminar cuenta, sin necesidad de contactarnos. Si consideras que no hemos atendido tu solicitud correctamente, puedes reclamar ante la Agencia Española de Protección de Datos (www.aepd.es).

8. SEGURIDAD
Tus datos se almacenan cifrados en tránsito y en reposo mediante la infraestructura de Firebase/Google Cloud. El acceso a tu cuenta está protegido por autenticación con contraseña.

9. MENORES
Houra no está dirigida a menores de 16 años. Si detectamos una cuenta de un menor sin consentimiento parental, la eliminaremos.

10. CAMBIOS EN ESTA POLÍTICA
Podemos actualizar esta política ocasionalmente. Si los cambios son relevantes, te avisaremos dentro de la app.
''';

const String kTermsAndConditions = '''
TÉRMINOS Y CONDICIONES DE USO DE HOURA

Última actualización: $kFechaActualizacion

1. ACEPTACIÓN
Al crear una cuenta en Houra aceptas estos términos. Si no estás de acuerdo, no uses la app.

2. QUÉ ES HOURA
Houra es una herramienta personal para registrar horas trabajadas y calcular ingresos estimados a partir de la tarifa que tú mismo introduces. No es una herramienta de facturación, contabilidad ni asesoría fiscal, y no genera documentos con validez legal o tributaria.

3. TU CUENTA
Eres responsable de mantener la confidencialidad de tu contraseña y de toda la actividad que ocurra en tu cuenta. Debes proporcionar datos veraces al registrarte.

4. USO ACEPTABLE
No debes usar Houra para fines ilícitos, ni intentar acceder a cuentas de otros usuarios o vulnerar la seguridad de la app.

5. EXACTITUD DE LOS DATOS
Los cálculos de ganancias mostrados en la app son estimaciones basadas en los datos que tú introduces. No nos responsabilizamos de decisiones económicas, fiscales o laborales tomadas a partir de esta información.

6. DISPONIBILIDAD DEL SERVICIO
Hacemos lo posible por mantener la app disponible, pero no garantizamos un funcionamiento ininterrumpido o libre de errores.

7. PROPIEDAD INTELECTUAL
El diseño, marca y código de Houra son propiedad de $kResponsable. Tus datos (las horas que registras) son tuyos; no reclamamos ningún derecho sobre su contenido.

8. LIMITACIÓN DE RESPONSABILIDAD
En la medida permitida por la ley, Houra se ofrece "tal cual", sin garantías de ningún tipo. No respondemos por daños indirectos derivados del uso de la app.

9. BAJA Y ELIMINACIÓN DE CUENTA
Puedes eliminar tu cuenta en cualquier momento desde Perfil → Eliminar cuenta. Esto borra tu perfil y todas tus entradas de forma permanente e irreversible.

10. LEY APLICABLE
Estos términos se rigen por la legislación española. Cualquier disputa se someterá a los juzgados y tribunales competentes en España, salvo que la normativa de consumidores te otorgue un fuero distinto.

11. CONTACTO
Para cualquier duda sobre estos términos: $kContactoEmail
''';