import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: CesiColors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: const TextStyle(color: CesiColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;
  const ErrorView({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: CesiColors.error),
            const SizedBox(height: 12),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _friendlyMessage(error),
              style: const TextStyle(color: CesiColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _friendlyMessage(Object e) {
    final s = e.toString();
    if (s.contains('SocketException') ||
        s.contains('Connection') ||
        s.contains('Network is unreachable')) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }
    if (s.contains('401')) {
      return 'Cette fonctionnalité nécessite d\'être connecté.';
    }
    if (s.contains('403')) {
      return 'Vous n\'avez pas les droits nécessaires.';
    }
    if (s.contains('429')) {
      return 'Trop de requêtes — veuillez patienter quelques secondes.';
    }
    if (s.contains('500') || s.contains('502') || s.contains('503')) {
      return 'Le serveur rencontre un problème. Réessayez dans un instant.';
    }
    return 'Veuillez réessayer dans un instant.';
  }
}

class EmptyView extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: CesiColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: CesiColors.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
