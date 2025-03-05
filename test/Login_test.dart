import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../lib/views/login_screen.dart'; // Usa la ruta correcta
import 'Login_test.mocks.dart'; // Importa los mocks generados

@GenerateMocks([], customMocks: [
  MockSpec<FirebaseAuth>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleSignInAccount;
  late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Inicializa Firebase de forma normal
    await Firebase.initializeApp();
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleSignInAccount = MockGoogleSignInAccount();
    mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
    when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuthentication);
    when(mockGoogleSignInAuthentication.accessToken).thenReturn('fake-access-token');
    when(mockGoogleSignInAuthentication.idToken).thenReturn('fake-id-token');
    when(mockFirebaseAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.displayName).thenReturn('Test User');
  });

  testWidgets('Debe mostrar el botón de inicio de sesión y permitir autenticación con Google', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    // Verifica que el botón de inicio de sesión existe
    expect(find.text('Iniciar sesión con Google'), findsOneWidget);

    // Simula un tap en el botón
    await tester.tap(find.text('Iniciar sesión con Google'));
    await tester.pump();

    // Verifica que la autenticación se intentó realizar
    verify(mockGoogleSignIn.signIn()).called(1);
    verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
  });
}
