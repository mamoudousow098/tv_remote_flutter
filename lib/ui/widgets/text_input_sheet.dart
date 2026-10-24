import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/remote_provider.dart';

/// Saisie de texte envoyée à la TV (recherche YouTube, Netflix…).
/// Disponible uniquement en mode réseau, sur les plateformes qui l'acceptent.
Future<void> showTextInputSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true, // le clavier ne doit pas masquer le champ
    showDragHandle: true,
    builder: (_) => const _TextInputSheet(),
  );
}

class _TextInputSheet extends ConsumerStatefulWidget {
  const _TextInputSheet();

  @override
  ConsumerState<_TextInputSheet> createState() => _TextInputSheetState();
}

class _TextInputSheetState extends ConsumerState<_TextInputSheet> {
  final TextEditingController _text = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _text.text;
    if (value.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await ref.read(remoteProvider.notifier).sendText(value);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _text,
              autofocus: true,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Texte à envoyer à la TV',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            tooltip: 'Envoyer',
            onPressed: _sending ? null : _submit,
            icon: _sending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
