import 'package:flutter/material.dart';

class ElectionNotActivePage extends StatefulWidget {
  final String status;
  
  const ElectionNotActivePage({
    super.key, 
    this.status = 'Not Started'
  });

  @override
  ElectionNotActivePageState createState() => ElectionNotActivePageState();
}

class ElectionNotActivePageState extends State<ElectionNotActivePage> {
  int _tapCount = 0;

  void _checkTaps() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        _tapCount = 0;
        Navigator.pushNamed(context, '/admin');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sri Lanka eVote System',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Election status icon
              Icon(
                widget.status == 'Ended' ? Icons.how_to_vote_outlined : Icons.access_time_rounded,
                size: 80,
                color: widget.status == 'Ended' ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 30),
              
              // Status text with tap detector
              GestureDetector(
                onTap: widget.status == 'Ended' ? _checkTaps : null,
                child: Text(
                  widget.status == 'Ended' 
                      ? 'Election Has Ended'
                      : 'Election Has Not Started Yet',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              
              // Description text
              Text(
                widget.status == 'Ended'
                    ? 'Thank you for your participation. The election voting period has concluded.'
                    : 'Please check back later when the election is open for voting.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Access results if election has ended
              if (widget.status == 'Ended')
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/results');
                    },
                    child: const Text('View Results'),
                  ),
                ),
              
              if (widget.status == 'Ended') 
                const SizedBox(height: 30),
              
              // Contact us button
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/contactus');
                  },
                  child: const Text('Contact Us'),
                ),
              ),
              
              // Guidelines button
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/guidlines');
                  },
                  child: const Text('Guidelines'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}