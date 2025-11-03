part of '../../smart_pagination/pagination.dart';

class EmptyDisplay extends StatelessWidget {
  const EmptyDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No documents found'));
  }
}
