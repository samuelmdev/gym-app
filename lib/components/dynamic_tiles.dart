import 'package:flutter/material.dart';

class DynamicTiles extends StatefulWidget {
  const DynamicTiles({super.key});

  @override
  _DynamicTilesState createState() => _DynamicTilesState();
}

class _DynamicTilesState extends State<DynamicTiles> {
  int _selectedIndex = 0;

  final List<String> _titles = ['Schedule', 'Progress', 'Overview'];
  final List<String> _routes = ['/schedule', '/progress', '/overview'];

  void _onSwipeLeft() {
    setState(() {
      _selectedIndex = (_selectedIndex + 1) % _titles.length;
    });
  }

  void _onSwipeRight() {
    setState(() {
      _selectedIndex = (_selectedIndex - 1 + _titles.length) % _titles.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /* Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10), */
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(_routes[_selectedIndex]);
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < 0) {
              _onSwipeLeft();
            } else if (details.primaryVelocity! > 0) {
              _onSwipeRight();
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.30,
            width: double.infinity,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _titles[_selectedIndex],
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _titles.asMap().entries.map((entry) {
            int index = entry.key;
            String label = entry.value;
            return _buildIconButton(index, _getIconForLabel(label), label);
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Schedule':
        return Icons.schedule;
      case 'Progress':
        return Icons.assessment;
      case 'Overview':
        return Icons.dashboard;
      default:
        return Icons.help;
    }
  }

  Widget _buildIconButton(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              isSelected ? Colors.yellow.withOpacity(0.1) : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.yellow : Colors.grey,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.yellow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
