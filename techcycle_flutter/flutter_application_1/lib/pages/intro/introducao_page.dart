import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';

class IntroducaoPage extends StatelessWidget {
  const IntroducaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 40.0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Home',
                      style: TextStyle(color: AppColors.tertiary),
                    ),
                  ),
                  const SizedBox(width: 40),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Sobre nós',
                      style: TextStyle(color: AppColors.tertiary),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Expanded(
              child: Row(
                children: [
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Eleve seu estabelecimento de descarte de lixo eletrônico.',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text.rich(
                          TextSpan(
                            text: 'Com um sistema de ',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Gestão de itens!',
                                style: TextStyle(color: AppColors.tertiary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Olá! Somos a TechCycle, um grupo de desenvolvedores '
                          'Front-end e Back-end com especialidade em Gestão de Itens. '
                          'Vamos começar a alavancar o seu descarte?',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.secondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // Botões
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Acesse agora!',
                              style: TextStyle(
                                fontSize: 24,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: AppColors.secondary,
                                    side: const BorderSide(
                                      color: AppColors.tertiary,
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 20,
                                    ),
                                  ),
                                  child: const Text(
                                    'Registrar',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: AppColors.secondary,
                                    side: const BorderSide(
                                      color: AppColors.tertiary,
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 20,
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Imagem (placeholder por enquanto)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.hover,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.recycling,
                          size: 200,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.tertiary,
              child: const Center(
                child: Text(
                  'Desenvolvido por TechCycle.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}